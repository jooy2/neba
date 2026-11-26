/**
 * Builds the Flutter gallery for the web, into `public/flutter/`, where every
 * Flutter preview on the site is served from.
 *
 *   npm run flutter:demos              builds it unless a build is there
 *   npm run flutter:demos -- --force   builds it again
 *
 * The output is git-ignored and skipped when present, because a build takes
 * a minute and a change to the docs rarely needs one. After a change to the
 * Flutter package or to a demo, pass `--force`.
 *
 * Beside the build it writes `demos.json`, the keys in the gallery's generated
 * registry. `Demo.vue` reads it once, and shows a Flutter frame for exactly the
 * demos that have a Dart twin; every other preview stays the React one.
 *
 * Without Flutter on the machine this warns and leaves the site without
 * Flutter previews, rather than failing a build that only touched Markdown.
 */
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const site = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const gallery = resolve(site, '../packages/flutter/example');
const out = resolve(site, 'public/flutter');
const force = process.argv.includes('--force');
const flutter = process.platform === 'win32' ? 'flutter.bat' : 'flutter';

if (!force && existsSync(resolve(out, 'version.json'))) {
  console.log(
    'flutter: the previews are already built; `npm run flutter:demos -- --force` rebuilds them'
  );
} else {
  /*
   * `--base-href /flutter/` because that is where `public/flutter` is served:
   * without it every asset the engine asks for resolves against the page's own
   * path. `--pwa-strategy=none` leaves out the service worker, which would
   * cache the gallery under the site's origin and keep serving a reader the
   * previous build after a new one is deployed.
   */
  const result = spawnSync(
    flutter,
    [
      'build',
      'web',
      '--release',
      '--base-href',
      '/flutter/',
      '--pwa-strategy=none',
      '--no-tree-shake-icons',
      '--output',
      out
    ],
    { cwd: gallery, stdio: 'inherit', shell: process.platform === 'win32' }
  );

  if (result.error?.code === 'ENOENT') {
    console.warn(
      'flutter: Flutter is not on PATH, so the site has no Flutter previews. ' +
        'Install it from https://docs.flutter.dev/install and run `npm run flutter:demos`.'
    );
  } else if (result.status !== 0) {
    // Flutter has printed the error already; a stack trace says nothing more.
    process.exitCode = result.status ?? 1;
  } else {
    console.log(`flutter: the previews are built into ${out}`);
  }
}

if (existsSync(resolve(out, 'version.json'))) {
  const registry = readFileSync(resolve(gallery, 'lib/demos/registry.dart'), 'utf8');
  const keys = [...registry.matchAll(/^\s*'([a-z0-9-]+\/[a-z0-9-]+)':/gm)].map((match) => match[1]);

  writeFileSync(resolve(out, 'demos.json'), `${JSON.stringify(keys)}\n`);
}
