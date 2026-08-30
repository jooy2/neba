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
 *
 * The last group is the same failure mode one level in: the styling a caller
 * passes. A `className` dropped on the floor, or a slot offered and never read,
 * leaves a component that looks exactly right in every test here — because
 * nothing here passes it one — and does nothing at all in a consumer's app.
 */
import { describe, expect, it } from 'vitest';
import pkg from '../../package.json';
import terser from '../../terser.config.json';
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

/**
 * Every JSX opening tag in a module, as text.
 *
 * Crude on purpose. It walks from a `<Name` to the `>` that closes that tag,
 * counting braces so a `className={cx(a > b ? …)}` cannot end it early. It is
 * not a parser and does not need to be: the only question asked of it is
 * whether *one element* carries both a spread and an attribute of its own.
 */
function openingTags(source: string): string[] {
  const tags: string[] = [];
  const opener = /<[A-Za-z][\w.]*/g;
  let match: RegExpExecArray | null;

  while ((match = opener.exec(source)) !== null) {
    let depth = 0;
    let index = match.index;

    while (index < source.length) {
      const character = source[index];

      if (character === '{') depth += 1;
      else if (character === '}') depth -= 1;
      else if (character === '>' && depth === 0) break;

      index += 1;
    }

    tags.push(source.slice(match.index, index));
  }

  return tags;
}

/**
 * The same thing in the other shape a component can be written in.
 *
 * Twenty-eight components render through Base UI's `useRender`, which takes the
 * element's attributes as an *object* rather than as a tag — so a scan that
 * only reads JSX would have nothing to say about Box, Button, Typography or any
 * other component with a `render` prop.
 *
 * Only the top level of the object is kept: a nested `style: { ...slots }` is a
 * value, not an attribute of the element, and reading it as one would report
 * every component that mixes its colour slots into a caller's style.
 */
function renderPropsObjects(source: string): string[] {
  const objects: string[] = [];

  for (const match of source.matchAll(/\bprops:\s*\{/g)) {
    let index = match.index + match[0].length - 1;
    let depth = 0;
    const top: string[] = [];

    while (index < source.length) {
      const character = source[index];

      if (character === '{') {
        depth += 1;
        if (depth > 1) top.push(' ');
      } else if (character === '}') {
        depth -= 1;
        if (depth === 0) break;
        top.push(' ');
      } else {
        top.push(depth === 1 ? character : ' ');
      }

      index += 1;
    }

    objects.push(top.join(''));
  }

  return objects;
}

/**
 * An element that spreads its props *and* writes an attribute of its own, in a
 * module that never took that attribute out of the props first.
 *
 * `<div {...props} className={ours} />` type-checks, renders, and throws away
 * the class name the caller passed. Written the other way round it throws away
 * the component's own instead. Both are invisible in this repository — the
 * component looks right, because nothing here passes it one — and both are a
 * caller's styling silently doing nothing in their project.
 */
function spreadCollisions(attribute: string): string[] {
  const offenders: string[] = [];
  const destructured = new RegExp(`(^|[\\s{,])${attribute},`);
  const inTag = new RegExp(`(^|\\s)${attribute}=\\{`);
  const inObject = new RegExp(`(^|[\\s{])${attribute}\\s*:`);

  for (const [path, source] of Object.entries(sources)) {
    if (destructured.test(source)) {
      continue;
    }

    for (const tag of openingTags(source)) {
      if (/\{\.\.\.[A-Za-z]/.test(tag) && inTag.test(tag)) {
        offenders.push(`${path}: ${tag.split('\n')[0]}`);
      }
    }

    for (const object of renderPropsObjects(source)) {
      if (/\.\.\.[A-Za-z]/.test(object) && inObject.test(object)) {
        offenders.push(`${path}: useRender props`);
      }
    }
  }

  return offenders;
}

/** The four slots every field-shaped component has, from `NebaFieldSlot`. */
const fieldSlots = ['label', 'control', 'description', 'error'];

/** Every `classNames?: NebaSlots<X>` in the library, with the names `X` holds. */
function slotUnions(): Array<{ path: string; name: string; slots: string[]; source: string }> {
  const unions: Array<{ path: string; name: string; slots: string[]; source: string }> = [];

  for (const [path, source] of Object.entries(sources)) {
    const referenced = new Set([...source.matchAll(/NebaSlots<(\w+)>/g)].map((match) => match[1]));

    for (const name of referenced) {
      const declaration = source.match(new RegExp(`export type ${name} =([\\s\\S]*?);`));

      unions.push({
        path,
        name,
        source,
        slots: declaration === null ? [] : slotNames(declaration[1])
      });
    }
  }

  return unions;
}

/** The literals a slot union resolves to, following `NebaFieldSlot` and `Exclude`. */
function slotNames(union: string): string[] {
  const excluded = new Set(
    [...union.matchAll(/Exclude<[^,]+,\s*'([^']+)'\s*>/g)].map((match) => match[1])
  );
  const named = [...union.matchAll(/'([a-zA-Z]+)'/g)].map((match) => match[1]);
  const inherited = union.includes('NebaFieldSlot') ? fieldSlots : [];

  return [...new Set([...named, ...inherited])].filter((slot) => !excluded.has(slot));
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

  describe('names its client boundary', () => {
    // Every React API a component here reaches for — `useState`, `useRef`,
    // `useContext`, `createContext`, `useEffect` — is absent from React's
    // `react-server` build. A module that calls one and is not marked is not a
    // module that renders badly under RSC; it is `undefined is not a function`
    // in someone's Next.js app, and it cannot happen in this repository,
    // because nothing here renders on a server.
    const CLIENT_ONLY =
      /React\.(useState|useEffect|useLayoutEffect|useRef|useContext|useReducer|useSyncExternalStore|useTransition|useDeferredValue|useImperativeHandle|useInsertionEffect|createContext|useOptimistic|useActionState)\b/;

    /** `'use client'` as the very first thing in the file — a leading comment would still parse, but line one is the rule a grep can check. */
    const DIRECTIVE = /^'use client';\n/;

    it("starts every component with 'use client'", () => {
      // All of them, and not only the ones that happen to hold state today.
      // Nearly every component already takes `transition` (a hook), `render` (a
      // hook) or an event handler, and the ones that do not are one prop away
      // from it. A per-component answer would be a table that rots; "every
      // Neba component is a client component" is a sentence a consumer can
      // hold.
      const offenders = Object.entries(sources)
        .filter(([path]) => /src\/components\/.+\.tsx$/.test(path))
        .filter(([, source]) => !DIRECTIVE.test(source))
        .map(([path]) => path.replace('../../', ''));

      expect(offenders).toEqual([]);
    });

    it('starts every module that calls a client-only React API with it too', () => {
      // The shared modules under `internal/`. A file with no directive is a
      // module either graph may pull in, which is right for the ones that are
      // arithmetic, a table or a glyph — and wrong for the nine that hold a
      // context, an effect or a store.
      const offenders = Object.entries(sources)
        .filter(([, source]) => CLIENT_ONLY.test(source))
        .filter(([, source]) => !DIRECTIVE.test(source))
        .map(([path]) => path.replace('../../', ''));

      expect(offenders).toEqual([]);
    });

    it('leaves the barrels and the locales unmarked', () => {
      // A barrel that only re-exports is reachable from either graph, and a
      // server component importing `neba` should reach the client modules
      // behind it rather than a boundary of its own. `registerMessages` is the
      // load-bearing one: marked, it would come back to a consumer's server
      // module as a client reference instead of a function, and calling it
      // would throw.
      const offenders = Object.entries(sources)
        .filter(
          ([path]) =>
            /src\/(index|types)\.ts$/.test(path) ||
            /src\/locales\//.test(path) ||
            /src\/components\/[^/]+\/index\.ts$/.test(path)
        )
        .filter(([, source]) => DIRECTIVE.test(source))
        .map(([path]) => path.replace('../../', ''));

      expect(offenders).toEqual([]);
    });

    it('keeps terser from eating the directive on the way out', () => {
      // `compress.directives` removes "redundant or non-standard" directives,
      // and in a module — where `use strict` is implied — `use client` is both
      // as far as terser is concerned. It strips it, silently, from all one
      // hundred and six files, and the published package then says nothing at
      // all to Next.js. This is `output.preserve_annotations`' twin: the
      // directive and the `@__PURE__` comments each survive `npm run build`
      // only because one setting says so.
      expect(terser.compress).toMatchObject({ directives: false });
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
  /**
   * What a caller writes on a component, and whether it survives.
   *
   * Both halves of this fail the way the rest of this file's subjects do:
   * silently, and somewhere else. A dropped `className` renders a component
   * that looks exactly right here, because nothing in this repository passes
   * one to it; a slot offered and never read is a prop that type-checks, reads
   * as supported, and does nothing at all.
   */
  describe('keeps the styling it was handed', () => {
    it('takes the class name out of the props it spreads', () => {
      expect(spreadCollisions('className')).toEqual([]);
    });

    it('takes the style out of the props it spreads', () => {
      expect(spreadCollisions('style')).toEqual([]);
    });

    it('declares every slot union beside the component that offers it', () => {
      const orphans = slotUnions()
        .filter((union) => union.slots.length === 0)
        .map((union) => `${union.path}: ${union.name}`);

      expect(orphans).toEqual([]);
    });

    /**
     * `className` is the root on every component in the library. A `root` key
     * beside it would be a second spelling of an idea that already has one,
     * which is the whole thing `src/types.ts` exists to prevent.
     */
    it('never offers a `root` slot beside `className`', () => {
      const offenders = slotUnions()
        .filter((union) => union.slots.includes('root'))
        .map((union) => `${union.path}: ${union.name}`);

      expect(offenders).toEqual([]);
    });

    it('reads every slot it offers', () => {
      const unread: string[] = [];

      for (const union of slotUnions()) {
        for (const slot of union.slots) {
          if (
            !union.source.includes(`classNames?.${slot}`) &&
            !union.source.includes(`classNames.${slot}`)
          ) {
            unread.push(`${union.path}: ${union.name}.${slot}`);
          }
        }
      }

      expect(unread).toEqual([]);
    });
  });
});
