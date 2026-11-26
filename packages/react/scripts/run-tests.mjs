/**
 * The suite, in sessions small enough for the browser to survive one.
 *
 * `vitest run` on its own has not finished this suite in chromium for weeks —
 * not on any runner, and not locally. It dies as `[vitest] Browser connection
 * was closed while running tests`, always somewhere past the hundredth file,
 * always with every test that started passing and every file still queued
 * behind it never running at all. Firefox and WebKit finish the same suite
 * every time.
 *
 * What was measured, before this existed:
 *
 * - Twelve full runs, none of which finished. The file it dies on moves — nine
 *   different components so far — and the count it dies at moves with it,
 *   between the 99th and the 125th of 146.
 * - Nine runs of a third of the suite each: all green, every time.
 * - The browser is not out of memory and the page is still alive enough to log
 *   `[vite] server connection lost` from both the orchestrator and the tester
 *   before the run gives up. Nothing re-optimizes a dependency near the
 *   failure.
 * - `browser.isolate: false`, which would stop the per-file iframe churn, hangs
 *   outright.
 * - `server.hmr: false`, which would stop a WebSocket being opened per tester,
 *   went one for five. Inside the noise, so it is not in the config.
 *
 * The one thing that reliably separates a run that finishes from one that does
 * not is **how many files the browser has been asked to hold in one session**,
 * which is the only lever here that is ours. So the suite is run in shards, and
 * each shard is its own browser. Nothing is skipped, no test is retried, and a
 * failing test still fails its shard — which is the whole difference between
 * this and the `retry` the flake keeps inviting.
 *
 * Two kinds of shard are run again, once. The first is one whose browser never
 * arrived: Vitest gave up connecting to the session before a single test ran,
 * which is a runner that could not start Firefox in time, seen on Windows.
 *
 * The second is one whose browser stopped answering. Vitest has a timeout for
 * a session to connect and none after that, so a frame that never reports back
 * holds the run until something outside it gives up — which was the CI step's
 * twenty-minute cap, with nothing in the log past the last file that finished.
 * Chromium on Windows did it forty files into a fresh session, on a file of
 * pure functions with no imports, so the shard size does not prevent it. A shard
 * that says nothing for `silenceLimit` is stopped, and run again only when
 * nothing it reported before going quiet had failed: a failed test is a result,
 * and running it again would be the retry this file refuses. The cost is that a
 * hang one of our own components causes only sometimes passes on the second
 * run, and the line saying the shard was stopped is the only trace of it.
 *
 * Neither is a result, and a shard that ran to the end keeps whatever it
 * reported.
 *
 * Vitest's own tracker has the underlying report open against browser mode. If
 * it is fixed upstream, this file goes away and `test` goes back to being
 * `vitest run`.
 */
import { readdirSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const vitest = resolve(root, 'node_modules/vitest/vitest.mjs');

/**
 * How many files one browser session is asked to hold.
 *
 * The observed floor of the failure is the 99th file, so this is a shade under
 * half of it. Lower would buy margin nothing has needed and cost a browser
 * start-up per shard; higher walks back toward the thing being avoided.
 */
const filesPerSession = 50;

/**
 * How long a shard may say nothing before it is taken to have stopped.
 *
 * The longest a green run has gone quiet is about twenty seconds, a DataTable
 * file under WebKit on Windows, and Vitest reports a browser that never
 * connected after sixty. Three minutes is well past both, and it is what a
 * wedged shard costs now instead of the CI step's twenty.
 */
const silenceLimit = 3 * 60 * 1000;

/** The same set `test.include` names, counted rather than matched. */
function testFileCount() {
  return readdirSync(resolve(root, 'test'), { recursive: true, encoding: 'utf8' }).filter((name) =>
    /\.test\.tsx?$/.test(name)
  ).length;
}

/*
 * An argument means somebody is running part of the suite on purpose — a path
 * filter, a reporter, a `-t`. That run is small, or it is being read, and
 * sharding it would either split a handful of files across empty shards or bury
 * the output it was asked for. It goes straight through, and nothing watches it
 * for silence either: a `--watch` or a `--ui` is quiet for as long as nobody
 * saves a file, and whoever is reading a run can stop it.
 */
const passthrough = process.argv.slice(2);
const guarded = passthrough.length === 0;
const shards = guarded ? Math.max(1, Math.ceil(testFileCount() / filesPerSession)) : 1;

/*
 * Colour is kept as it was when the output went straight to the terminal: the
 * output is piped now, so that it can be read for the two failures below, and
 * a pipe is not a TTY.
 */
const env =
  process.stdout.isTTY && process.env.FORCE_COLOR === undefined
    ? { ...process.env, FORCE_COLOR: '1' }
    : process.env;

/** A line of the runner's own, set apart from what Vitest says. */
function announce(text) {
  process.stdout.write(`\n\x1b[1m▸ ${text}\x1b[0m\n`);
}

/**
 * Ends a run that will not end itself, and everything it started. A browser
 * outlives a killed Node on Windows, so there the whole tree goes.
 */
function stop(child) {
  if (process.platform === 'win32') {
    const taskkill = spawn('taskkill', ['/pid', String(child.pid), '/t', '/f'], {
      stdio: 'ignore'
    });

    taskkill.on('error', () => child.kill());
  } else {
    child.kill('SIGKILL');
  }
}

/**
 * One run of Vitest, passed through as it arrives, and the end of what it said.
 *
 * With `guarded`, a run that says nothing for `silenceLimit` is stopped, and
 * `silent` says that it was. `failing` is whether anything it said reported a
 * failure, which the end of what it said may no longer hold.
 */
function run(args, guarded) {
  return new Promise((resolveRun) => {
    const child = spawn(process.execPath, args, { cwd: root, env });
    let said = '';
    let silent = false;
    let failing = false;
    let timer;

    const onSilence = () => {
      silent = true;
      announce(`nothing for ${silenceLimit / 60000} minutes; stopping the browser`);
      stop(child);
    };
    const listen = () => {
      if (guarded) {
        clearTimeout(timer);
        timer = setTimeout(onSilence, silenceLimit);
      }
    };
    const keep = (chunk, stream) => {
      stream.write(chunk);
      said = (said + chunk.toString()).slice(-65536);
      failing ||= reportedFailure(said);
      listen();
    };

    listen();
    child.stdout.on('data', (chunk) => keep(chunk, process.stdout));
    child.stderr.on('data', (chunk) => keep(chunk, process.stderr));
    child.on('close', (status) => {
      clearTimeout(timer);
      resolveRun({ status, said, silent, failing });
    });
  });
}

/** What Vitest said, without its colours. */
function plain(said) {
  return said.replace(/\x1b\[[0-9;]*m/g, '');
}

/** The browser never connected, and so nothing ran. */
function neverStarted(said) {
  const text = plain(said);

  return /Failed to connect to the browser session/.test(text) && /Tests\s+no tests/.test(text);
}

/**
 * Something failed: a failed test is reported as a line starting with `×`, and a
 * failed file or an error's stack as one starting with `❯`.
 */
function reportedFailure(said) {
  return /^\s*[×❯]\s/m.test(plain(said));
}

const failed = [];

for (let shard = 1; shard <= shards; shard += 1) {
  if (shards > 1) {
    announce(`shard ${shard} of ${shards}`);
  }

  const args = [vitest, 'run', ...passthrough];

  if (shards > 1) {
    args.push(`--shard=${shard}/${shards}`);
  }

  let { status, said, silent, failing } = await run(args, guarded);

  if (status !== 0 && neverStarted(said)) {
    announce(`the browser never connected; shard ${shard} again`);
    ({ status } = await run(args, guarded));
  } else if (silent && !failing) {
    announce(`the browser stopped answering; shard ${shard} again`);
    ({ status } = await run(args, guarded));
  }

  if (status !== 0) {
    failed.push(shard);
  }
}

if (failed.length > 0) {
  if (shards > 1) {
    process.stderr.write(`\nshards that failed: ${failed.join(', ')} of ${shards}\n`);
  }

  process.exitCode = 1;
}
