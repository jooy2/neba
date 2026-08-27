/**
 * The half-sentence a bundler needs before it will drop an unused component.
 *
 * `React.forwardRef(…)` is a call, and a bundler has no way to know that a call
 * does nothing but return a value. So in a file that exports more than one
 * component — `Tabs` and `Tab` and `TabPanel`, `Menu` and its eight rows — the
 * ones a caller never imported are kept anyway, because deleting them might
 * have deleted a side effect. The convention that says otherwise is an
 * `@__PURE__` comment immediately before the call, which every modern bundler
 * reads and nothing else has to understand.
 *
 * This writes them into `dist/` between `tsc` and `terser`, and deliberately
 * not into `src/`. The annotation is a fact about the *compiled* module rather
 * than about the source: nothing a reader of `Chip.tsx` needs to know is in it,
 * and putting it there cost more than it looks like it would. It is sixteen
 * characters in front of an already long line, so Prettier rewraps the whole
 * `forwardRef` signature and re-indents the function body underneath it — one
 * annotation, a hundred-line diff, seventy-seven files of it, and every one of
 * those lines in `git blame` forever.
 *
 * Terser then has to be told to write them out again: it understands the
 * annotation, uses it, and by default drops it on the floor, which would leave
 * the published files saying nothing at all to the consumer's bundler. That is
 * `output.preserve_annotations` in `terser.config.json`, and the two settings
 * are useless apart.
 *
 * The count is checked against `src/`, and a mismatch fails the build. That is
 * the whole reason this is a script and not a `sed`: the failure mode of a
 * regex over emitted code is that it quietly stops matching — a component
 * written a new way, a compiler that emits `forwardRef` differently — and the
 * only symptom would be a consumer's bundle getting bigger.
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

/**
 * The three calls worth annotating, all of which only ever return a value.
 *
 * Matched wherever they appear rather than only after an `=`: an annotation on
 * a call whose result *is* used costs nothing, since it says "safe to drop if
 * unused" rather than "drop this". `React.` and not a bare name because that is
 * what `import * as React from 'react'` compiles every one of them to.
 */
const CALL = /(?<!__PURE__\*\/\s*)\bReact\.(forwardRef|createContext|memo)\(/g;

/**
 * The same call once it has been marked — what is actually counted.
 *
 * The namespace is left open rather than pinned to `React.`, so the count is
 * the same before and after `terser` has renamed it to a letter. Running this
 * twice, or over a `dist/` that has already been minified, then agrees with
 * itself instead of reporting a mismatch that is not one.
 */
const MARKED = /\/\*@__PURE__\*\/\s*[A-Za-z_$][\w$]*\.(forwardRef|createContext|memo)\(/g;

/** Every `.js` under a directory, deepest first or not — order does not matter. */
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

/** What `src/` says the count should be, generics and all. */
function expected(dir) {
  let total = 0;

  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);

    if (statSync(path).isDirectory()) {
      total += expected(path);
    } else if (/\.tsx?$/.test(path)) {
      total += (
        readFileSync(path, 'utf8').match(/\bReact\.(forwardRef|createContext|memo)[(<]/g) ?? []
      ).length;
    }
  }

  return total;
}

const dist = resolve(root, 'dist');
let annotated = 0;

for (const path of scripts(dist)) {
  const source = readFileSync(path, 'utf8');
  const marked = source.replace(CALL, (whole) => `/*@__PURE__*/ ${whole}`);

  if (marked !== source) {
    writeFileSync(path, marked);
  }

  // Every marked call, not only the ones this run marked: `tsc` writes `dist/`
  // fresh on a real build, but a second run over the same output would
  // otherwise count nothing and report a mismatch that is not one.
  annotated += (marked.match(MARKED) ?? []).length;
}

const wanted = expected(resolve(root, 'src'));

if (annotated !== wanted) {
  console.error(
    `pure annotations: dist/ carries ${annotated}, but src/ has ${wanted}.\n\n` +
      'Something is written a way this does not recognise, and the symptom of leaving it\n' +
      "alone is a consumer's bundle quietly getting bigger. Check what `tsc` emitted for\n" +
      'the call that was missed, and widen the pattern in scripts/annotate-pure.mjs.\n'
  );
  process.exitCode = 1;
} else {
  console.log(`pure: ${annotated} annotations`);
}
