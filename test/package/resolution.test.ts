/**
 * The package's shape — what `neba` is once it has been installed.
 *
 * Every other file in `test/` renders something. This one renders nothing: what
 * is under test is the wiring between `src/`, `dist/` and `package.json`, and
 * all three of the promises it makes fail *silently* in this repository. The
 * suite imports from the `neba` alias, which points at `src/index.ts` and is
 * resolved by Vite — and Vite will happily resolve an import a consumer's Node,
 * TypeScript or bundler will not. So a green suite is not evidence that the
 * published package resolves, and twice now it has not:
 *
 * - `export * from './types'`, with no extension, is what `tsc` emits verbatim
 *   under `module: Preserve`. Node's ESM resolver rejects it outright, and so
 *   does TypeScript under `moduleResolution: node16`, where it takes out every
 *   named export of the barrel at once — a consumer on that setting saw
 *   "Module 'neba' has no exported member 'Card'" for all eighty-eight.
 * - A component folder with no barrel, or a barrel `src/index.ts` never
 *   re-exports, is a component that exists in the repository, has a test and a
 *   documentation page, and cannot be imported.
 *
 * Neither shows up in a render test, in `tsc --noEmit`, or in a build. They
 * show up in someone else's project.
 */
import { describe, expect, it } from 'vitest';
import pkg from '../../package.json';
import * as i18n from '../../src/internal/i18n.js';

/** Every module under `src/`, as text. Vite inlines these at build time. */
const sources = import.meta.glob('../../src/**/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
}) as Record<string, string>;

/** Every language module, by the tag its file is named for. */
const localeFiles = Object.keys(import.meta.glob('../../src/locales/*.ts', { eager: true }))
  .map((path) => path.split('/').at(-1)!.replace(/\.ts$/, ''))
  .filter((name) => name !== 'index');

/** Every component barrel, by its folder name — the name a subpath import uses. */
const barrels = Object.keys(
  import.meta.glob('../../src/components/*/index.ts', { eager: true })
).map((path) => path.split('/').at(-2)!);

const entry = sources['../../src/index.ts'];

/** The specifier of every relative `import`/`export … from` in a module. */
function relativeSpecifiers(source: string): string[] {
  return [...source.matchAll(/(?:^|\n)\s*(?:import|export)[\s\S]*?from\s*['"](\.[^'"]*)['"]/g)].map(
    (match) => match[1]
  );
}

describe('the published package', () => {
  describe('resolves', () => {
    it('gives every relative import an explicit extension', () => {
      const offenders: string[] = [];

      for (const [path, source] of Object.entries(sources)) {
        for (const specifier of relativeSpecifiers(source)) {
          if (!/\.(js|css|json)$/.test(specifier)) {
            offenders.push(`${path.replace('../../', '')} → ${specifier}`);
          }
        }
      }

      // `.js` and not `.ts`: the extension is the one the *emitted* file has,
      // which is what a consumer resolves. TypeScript maps it back to the
      // source for us; nothing else in the chain would.
      expect(offenders).toEqual([]);
    });

    it('points a directory import at its barrel rather than at the directory', () => {
      const offenders: string[] = [];

      for (const [path, source] of Object.entries(sources)) {
        for (const specifier of relativeSpecifiers(source)) {
          if (specifier.endsWith('/')) {
            offenders.push(`${path.replace('../../', '')} → ${specifier}`);
          }
        }
      }

      expect(offenders).toEqual([]);
    });
  });

  describe('exports what it contains', () => {
    it('re-exports every component barrel from the entry point', () => {
      const missing = barrels.filter((name) => !entry.includes(`'./components/${name}/index.js'`));

      expect(missing).toEqual([]);
    });

    it('offers every component as a subpath as well as through the barrel', () => {
      // The barrel is the documented way in. The subpath is the escape hatch —
      // for a bundler that will not tree-shake, and for the ones that would
      // rather not parse a hundred and ninety-eight modules to keep five.
      const pattern = pkg.exports['./*'];

      expect(pattern.default).toBe('./dist/components/*/index.js');
      expect(pattern.types).toBe('./dist/components/*/index.d.ts');
      expect(pkg.typesVersions['*']['*']).toEqual(['dist/components/*/index.d.ts']);
    });

    it('offers the languages as a barrel and one entry point each', () => {
      expect(pkg.exports['./locales'].default).toBe('./dist/locales/index.js');
      expect(pkg.exports['./locales/*'].default).toBe('./dist/locales/*.js');
      // Ahead of the component wildcard, or `neba/locales/ko` would resolve to
      // `dist/components/locales/ko/index.js`.
      const keys = Object.keys(pkg.exports);

      expect(keys.indexOf('./locales/*')).toBeLessThan(keys.indexOf('./*'));
    });

    it('re-exports every language from the locales barrel', () => {
      const barrel = sources['../../src/locales/index.ts'];
      const missing = localeFiles.filter((tag) => !barrel.includes(`from './${tag}.js'`));

      expect(missing).toEqual([]);
    });

    it('claims a side effect only for stylesheets', () => {
      // This one line is what lets a bundler drop the eighty-seven components a
      // page did not import. Widen it and every consumer's bundle is the whole
      // library.
      expect(pkg.sideEffects).toEqual(['**/*.css']);
    });
  });

  describe('keeps its fixed costs divisible', () => {
    it('holds one message table per namespace, never one table of all of them', () => {
      // A bundler drops an unused `export const` and cannot drop a key out of
      // an object literal. Collapsing these back into a single table would put
      // eighteen languages of every namespace behind the first component that
      // needs one word — which is where this started: thirty-eight kilobytes
      // of translations behind a two-kilobyte Chip.
      // `useMessages` and `resolveMessages` end in the same word; the tables
      // are the exports that are tables.
      const tables = Object.entries(i18n).filter(
        ([name, value]) => name.endsWith('Messages') && typeof value === 'object'
      );

      expect(tables.length).toBeGreaterThan(1);

      for (const [name, table] of tables) {
        const english = (table as Record<string, Record<string, unknown>>)[''];

        // One level of plain strings. A nested object in there would mean a
        // table had grown a second namespace.
        for (const [key, value] of Object.entries(english)) {
          expect(typeof value, `${name}.${key}`).toBe('string');
        }
      }
    });
  });
});
