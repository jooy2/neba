/**
 * GitHub releases for version tags that were pushed before `release.yml`
 * existed.
 *
 *   node scripts/release-backfill.mjs v1.16.2
 *   node scripts/release-backfill.mjs all
 *   node scripts/release-backfill.mjs all --dry-run
 *
 * A tag push runs the workflow file of the commit it points at, and the
 * commits of 1.16.2 and every version before it have none — so their tags
 * produced no release, and rebuilding them with today's scripts would not
 * produce the package that shipped either. This writes each release the way
 * `release.yml` would, from what already exists:
 *
 * - the body from today's `CHANGELOG.md`, through `release-notes.mjs`, since a
 *   released section is never edited and is the same text it was;
 * - the tarball npm is serving for that version, fetched with `npm pack`, which
 *   is byte for byte what was published rather than a second build of it. A
 *   version npm does not have is released without one, and its body says so.
 *
 * `all` walks every `v*` tag, oldest first, and leaves alone any that already
 * has a release — including the newest, whose release `release.yml` wrote.
 * Every release it creates is marked as not the latest, so the badge stays on
 * the version that really is. A single tag is created or, when its release
 * exists, has its body and its tarball brought up to date.
 *
 * `release.yml` runs it from the Actions tab (`workflow_dispatch`), where `gh`
 * is signed in as the workflow; `--dry-run` prints what it would do without
 * touching GitHub, which is how to read it on a machine that is not.
 */
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const target = args.find((one) => !one.startsWith('--'));

if (!target) {
  throw new Error('release-backfill: name a tag such as v1.16.2, or "all"');
}

const { name } = JSON.parse(readFileSync(resolve(root, 'package.json'), 'utf8'));
const work = mkdtempSync(join(process.env.RUNNER_TEMP ?? tmpdir(), 'release-backfill-'));

/** A command's result, with its output kept rather than printed. */
function run(command, commandArgs) {
  const result = spawnSync(command, commandArgs, { cwd: root, encoding: 'utf8' });

  return { ok: result.status === 0, out: result.stdout ?? '', err: result.stderr ?? '' };
}

/** A command that has to work, printed as it runs. */
function must(command, commandArgs) {
  process.stdout.write(`  $ ${command} ${commandArgs.join(' ')}\n`);

  if (dryRun) {
    return '';
  }

  const result = run(command, commandArgs);

  if (!result.ok) {
    throw new Error(`${command} ${commandArgs[0]} failed:\n${result.err || result.out}`);
  }

  return result.out;
}

/** Oldest first, by the numbers rather than by the string. */
function byVersion(a, b) {
  const parts = (tag) =>
    tag
      .replace(/^v/, '')
      .split(/[.-]/)
      .map((part) => (/^\d+$/.test(part) ? Number(part) : part));
  const [left, right] = [parts(a), parts(b)];

  for (let index = 0; index < Math.max(left.length, right.length); index += 1) {
    const [x, y] = [left[index], right[index]];

    if (x === y) continue;
    if (x === undefined) return -1;
    if (y === undefined) return 1;
    if (typeof x === 'number' && typeof y === 'number') return x - y;

    return String(x) < String(y) ? -1 : 1;
  }

  return 0;
}

const all = target === 'all';
const tags = all
  ? run('git', ['tag', '--list', 'v*'])
      .out.split('\n')
      .filter((tag) => /^v\d+\.\d+\.\d+/.test(tag))
      .sort(byVersion)
  : [target.startsWith('v') ? target : `v${target}`];

const failed = [];

for (const tag of tags) {
  const version = tag.slice(1);

  process.stdout.write(`\n${tag}\n`);

  try {
    if (!run('git', ['rev-parse', '--verify', '--quiet', `refs/tags/${tag}`]).ok) {
      throw new Error(`there is no tag ${tag} in this checkout`);
    }

    // Read-only, so asked in a dry run as well; `gh` signed in to nothing
    // answers no, and the plan then shows a create for every tag.
    const exists = run('gh', ['release', 'view', tag]).ok;

    if (exists && all) {
      process.stdout.write('  already released; left alone\n');
      continue;
    }

    const notes = run(process.execPath, [resolve(root, 'scripts/release-notes.mjs'), version]);

    if (!notes.ok) {
      throw new Error(
        notes.err
          .trim()
          .split('\n')
          .find((line) => line.includes('release-notes:')) ?? notes.err
      );
    }

    const published = run('npm', ['view', `${name}@${version}`, 'version']).out.trim() === version;
    const body = published
      ? notes.out
      : `This version was not published to npm, so there is no package attached.\n\n${notes.out}`;
    const notesFile = join(work, `${tag}.md`);

    writeFileSync(notesFile, body);

    const assets = [];

    if (published) {
      const destination = mkdtempSync(join(work, `${tag}-`));

      must('npm', ['pack', `${name}@${version}`, '--pack-destination', destination, '--silent']);

      if (!dryRun) {
        assets.push(...readdirSync(destination).map((file) => join(destination, file)));
      } else {
        assets.push(join(destination, `${name}-${version}.tgz`));
      }
    } else {
      process.stdout.write(`  ${name}@${version} is not on npm; released without a package\n`);
    }

    if (exists) {
      must('gh', ['release', 'edit', tag, '--title', version, '--notes-file', notesFile]);

      if (assets.length > 0) {
        must('gh', ['release', 'upload', tag, ...assets, '--clobber']);
      }
    } else {
      must('gh', [
        'release',
        'create',
        tag,
        ...assets,
        '--verify-tag',
        '--title',
        version,
        '--notes-file',
        notesFile,
        '--latest=false',
        ...(version.includes('-') ? ['--prerelease'] : [])
      ]);
    }
  } catch (error) {
    process.stdout.write(`  failed: ${error.message}\n`);
    failed.push(tag);
  }
}

if (failed.length > 0) {
  process.stderr.write(`\nreleases that were not written: ${failed.join(', ')}\n`);
  process.exitCode = 1;
}
