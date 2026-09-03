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
 * each shard is its own browser. Nothing is skipped, nothing is retried, and a
 * failing test still fails its shard — which is the whole difference between
 * this and the `retry` the flake keeps inviting.
 *
 * Vitest's own tracker has the underlying report open against browser mode. If
 * it is fixed upstream, this file goes away and `test` goes back to being
 * `vitest run`.
 */
import { readdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
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
 * the output it was asked for. It goes straight through.
 */
const passthrough = process.argv.slice(2);
const shards =
  passthrough.length > 0 ? 1 : Math.max(1, Math.ceil(testFileCount() / filesPerSession));

const failed = [];

for (let shard = 1; shard <= shards; shard += 1) {
  if (shards > 1) {
    process.stdout.write(`\n[1m▸ shard ${shard} of ${shards}[0m\n`);
  }

  const args = [vitest, 'run', ...passthrough];
  if (shards > 1) args.push(`--shard=${shard}/${shards}`);

  const { status } = spawnSync(process.execPath, args, { cwd: root, stdio: 'inherit' });

  if (status !== 0) failed.push(shard);
}

if (failed.length > 0) {
  if (shards > 1) {
    process.stderr.write(`\nshards that failed: ${failed.join(', ')} of ${shards}\n`);
  }

  process.exitCode = 1;
}
