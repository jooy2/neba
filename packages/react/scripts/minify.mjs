/**
 * Minifies every file in `dist/` in place, keeping component names.
 *
 * `terser.config.json` holds every option that JSON can hold, and this reads it.
 * The one option it cannot hold is `keep_fnames`, because the useful value is a
 * regular expression. Every component is `React.forwardRef(function Button(…))`,
 * and that inner name is what React DevTools and React's own warnings show. Terser
 * drops the name of a function expression that nothing inside it calls, so
 * without this every component in the published build is an anonymous
 * `ForwardRef`.
 *
 * Only names that start with a capital letter are kept, since that is how a
 * component is named and a helper is not. Keeping every name costs about five
 * times as much and shows a DevTools reader nothing more.
 *
 * It adds 0.2 kB gzipped across `dist/`. A consumer's own bundler minifies again
 * and decides for itself, so a page's bundle moves by a few dozen bytes either
 * way.
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { minify } from 'terser';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const config = readFileSync(resolve(root, 'terser.config.json'), 'utf8');

/** Every `.js` under a directory. */
function scripts(dir) {
  const found = [];

  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);

    if (statSync(path).isDirectory()) {
      found.push(...scripts(path));
    } else if (path.endsWith('.js')) {
      found.push(path);
    }
  }

  return found;
}

let minified = 0;

for (const path of scripts(resolve(root, 'dist'))) {
  // Parsed again for every file, because terser writes the top-level shorthand
  // into the nested `compress` and `mangle` objects it is handed.
  const options = { ...JSON.parse(config), keep_fnames: /^[A-Z]/ };
  const result = await minify(readFileSync(path, 'utf8'), options);

  writeFileSync(path, result.code);
  minified += 1;
}

console.log(`minify: ${minified} files`);
