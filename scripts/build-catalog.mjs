/**
 * Puts the A2UI catalog where the things that read it can find it.
 *
 * `src/a2ui/catalog.json` is the source, and `tsc` does not copy JSON any more
 * than it copies CSS — so this runs in `npm run build` and writes
 * `dist/a2ui/catalog.json`, which is what `neba/a2ui/catalog.json` resolves to.
 * With `--docs` it writes the docs site's copies instead, which are served
 * under `/a2ui/` and are the URLs the files' own `catalogId` names.
 *
 * **A published catalog names its minor version.** Its `catalogId` is
 * `…/a2ui/<major>.<minor>/catalog.json`, written in here from `package.json`,
 * because the docs deploy from `main` and a bare URL could describe components
 * a host's installed adapter does not have yet. The adapter registers the same
 * id, so a surface written against another minor is refused by name rather
 * than validated against the wrong schema. The bare `/a2ui/catalog.json` stays
 * as the latest, carrying the id of the minor it is. The source keeps the bare
 * id, which is what the tests in this repository read.
 *
 * The docs copies are generated rather than committed, for `copy-changelog.mjs`'
 * reason: two files that say the same thing say it until the day one of them
 * does not. The exception is a released minor: `--release` writes a snapshot to
 * `docs/a2ui/<major>.<minor>.json`, which is committed with the release, and
 * `--docs` serves every snapshot at its own path, so an older minor's URL keeps
 * answering after the site has moved on.
 *
 * The build also writes `dist/a2ui/adapter-catalog.json`, the same catalog with
 * its prose taken out, and points the adapter's two imports at it. Most of the
 * file is descriptions written for a model, which the renderer never reads —
 * they were about three quarters of what `neba/a2ui` put in a consumer's
 * bundle. `src/` keeps importing the whole file, so the tests and the docs read
 * what the agent reads.
 */
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const source = resolve(root, 'src/a2ui/catalog.json');
const releases = resolve(root, 'docs/a2ui');
const docs = process.argv.includes('--docs');
const release = process.argv.includes('--release');

/*
 * Parsed before it is copied. A catalog is prompt material for a model and a
 * validation schema for a renderer, and neither of them is a place to find out
 * that a trailing comma was left in it.
 */
const catalog = JSON.parse(readFileSync(source, 'utf8'));
const { version } = JSON.parse(readFileSync(resolve(root, 'package.json'), 'utf8'));
const minor = version.split('.').slice(0, 2).join('.');
const bare = catalog.catalogId;

if (!bare.endsWith('/a2ui/catalog.json')) {
  throw new Error(`a2ui: the source catalogId ${bare} is not the bare /a2ui/catalog.json URL`);
}

/** The catalog under the id of this minor, which is also where it is served. */
const id = bare.replace(/\/a2ui\/catalog\.json$/, `/a2ui/${minor}/catalog.json`);
const stamped = { ...catalog, $id: id, catalogId: id };

function write(path, value, spacing) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, `${JSON.stringify(value, null, spacing)}\n`);
}

/*
 * Only what a string says to a reader. A key called `description` whose value
 * is an object is a component's prop by that name — a TextField has one — and
 * stays.
 */
const PROSE = new Set(['description', 'instructions', 'title']);

function withoutProse(value) {
  if (Array.isArray(value)) {
    return value.map(withoutProse);
  }

  if (value === null || typeof value !== 'object') {
    return value;
  }

  return Object.fromEntries(
    Object.entries(value)
      .filter(([key, entry]) => !(PROSE.has(key) && typeof entry === 'string'))
      .map(([key, entry]) => [key, withoutProse(entry)])
  );
}

if (release) {
  write(resolve(releases, `${minor}.json`), stamped, 2);
  console.log(`a2ui: docs/a2ui/${minor}.json — the snapshot to commit with ${version}`);
} else if (docs) {
  const served = resolve(root, 'docs/public/a2ui');

  write(resolve(served, 'catalog.json'), stamped, 2);
  write(resolve(served, minor, 'catalog.json'), stamped, 2);

  // Every released minor at its own path, the one being built included only
  // if it has been released — otherwise the source is newer than the snapshot.
  const snapshots = existsSync(releases)
    ? readdirSync(releases).filter((name) => /^\d+\.\d+\.json$/.test(name))
    : [];

  for (const name of snapshots) {
    const released = name.replace(/\.json$/, '');

    if (released !== minor) {
      write(
        resolve(served, released, 'catalog.json'),
        JSON.parse(readFileSync(resolve(releases, name), 'utf8')),
        2
      );
    }
  }

  console.log(
    `a2ui: docs/public/a2ui/ — latest and ${minor}, and ${snapshots.length} released snapshot(s)`
  );
} else {
  const folder = resolve(root, 'dist/a2ui');

  write(resolve(folder, 'catalog.json'), stamped, 2);
  write(resolve(folder, 'adapter-catalog.json'), withoutProse(stamped));

  /*
   * Counted against `src/`, as `annotate-pure.mjs` counts its annotations: a
   * pattern over minified output fails by quietly matching nothing, and the
   * adapter would go on shipping the whole file with every check green.
   */
  const importing = readdirSync(resolve(root, 'src/a2ui')).filter(
    (name) =>
      /\.tsx?$/.test(name) &&
      readFileSync(resolve(root, 'src/a2ui', name), 'utf8').includes("from './catalog.json'")
  ).length;
  let pointed = 0;

  for (const name of readdirSync(folder).filter((one) => one.endsWith('.js'))) {
    const path = resolve(folder, name);
    const code = readFileSync(path, 'utf8');
    const next = code.replace(/(["'])\.\/catalog\.json\1/g, '"./adapter-catalog.json"');

    if (next !== code) {
      writeFileSync(path, next);
    }
    // Counted after the rewrite, so a second run over the same `dist/` agrees.
    pointed += next.split('"./adapter-catalog.json"').length - 1;
  }

  if (pointed !== importing) {
    throw new Error(
      `a2ui: ${importing} modules in src/a2ui import catalog.json and ${pointed} in dist/a2ui import adapter-catalog.json`
    );
  }

  console.log(
    `a2ui: dist/a2ui/catalog.json as ${id} — ${Object.keys(catalog.components).length} components, ` +
      `${Object.keys(catalog.functions).length} functions, ` +
      `${(readFileSync(source).length / 1024).toFixed(1)} kB`
  );
}
