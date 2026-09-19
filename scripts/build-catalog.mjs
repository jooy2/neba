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
 */
import { copyFileSync, mkdirSync, readFileSync } from 'node:fs';
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

console.log(
  `a2ui: ${target.slice(root.length + 1)} — ${Object.keys(catalog.components).length} components, ` +
    `${Object.keys(catalog.functions).length} functions, ` +
    `${(readFileSync(source).length / 1024).toFixed(1)} kB`
);
