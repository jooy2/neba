/**
 * Puts the A2UI catalog where the two things that read it can find it.
 *
 * `src/a2ui/catalog.json` is the source, and `tsc` does not copy JSON any more
 * than it copies CSS — so this runs in `npm run build` and writes
 * `dist/a2ui/catalog.json`, which is what `neba/a2ui/catalog.json` resolves to.
 * With `--docs` it writes the docs site's copy instead, which is served at
 * `/a2ui/catalog.json` and is the URL the file's own `catalogId` names.
 *
 * The docs copy is generated rather than committed, for `copy-changelog.mjs`'
 * reason: two files that say the same thing say it until the day one of them
 * does not, and the one that would drift is the one a host has already
 * downloaded.
 *
 * The build also writes `dist/a2ui/adapter-catalog.json`, the same catalog with
 * its prose taken out, and points the adapter's two imports at it. Most of the
 * file is descriptions written for a model, which the renderer never reads —
 * they were about three quarters of what `neba/a2ui` put in a consumer's
 * bundle. `src/` keeps importing the whole file, so the tests and the docs read
 * what the agent reads.
 */
import { copyFileSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const source = resolve(root, 'src/a2ui/catalog.json');
const target = process.argv.includes('--docs')
  ? resolve(root, 'docs/public/a2ui/catalog.json')
  : resolve(root, 'dist/a2ui/catalog.json');

/*
 * Parsed before it is copied. A catalog is prompt material for a model and a
 * validation schema for a renderer, and neither of them is a place to find out
 * that a trailing comma was left in it.
 */
const catalog = JSON.parse(readFileSync(source, 'utf8'));

mkdirSync(dirname(target), { recursive: true });
copyFileSync(source, target);

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

if (!process.argv.includes('--docs')) {
  const folder = dirname(target);
  const lean = resolve(folder, 'adapter-catalog.json');

  writeFileSync(lean, JSON.stringify(withoutProse(catalog)));

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
}

console.log(
  `a2ui: ${target.slice(root.length + 1)} — ${Object.keys(catalog.components).length} components, ` +
    `${Object.keys(catalog.functions).length} functions, ` +
    `${(readFileSync(source).length / 1024).toFixed(1)} kB`
);
