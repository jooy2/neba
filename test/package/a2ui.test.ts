/**
 * The A2UI catalog's shape.
 *
 * `src/a2ui/catalog.json` is two things at once, and neither of them fails
 * loudly. It is **prompt material**: an agent is handed it and writes UI
 * against it, so a component named one thing in its key and another in its
 * `component` const is a model writing something no renderer will accept. And
 * it is a **validation schema**: a host renderer checks incoming surfaces
 * against it, so a `$ref` that points nowhere is a check that silently passes.
 *
 * Nothing in this repository renders a catalog, exactly as nothing here runs
 * the published package — which is why this file exists beside
 * `resolution.test.ts` rather than beside a component.
 */
import { describe, expect, it } from 'vitest';
import catalog from '../../src/a2ui/catalog.json';
import pkg from '../../package.json';

/** Every module under `src/`, as text — the same glob `resolution.test.ts` uses. */
const sources = import.meta.glob('../../src/**/*.{ts,tsx}', {
  query: '?raw',
  import: 'default',
  eager: true
}) as Record<string, string>;

const entry = sources['../../src/index.ts'];

/** Every component barrel, by its folder name — what `src/index.ts` re-exports. */
const barrels = new Set(
  Object.keys(import.meta.glob('../../src/components/*/index.ts', { eager: true })).map((path) =>
    path.split('/').at(-2)!
  )
);

/** `DataList` → `data-list`, which is the folder rule in `CLAUDE.md`. */
function kebab(name: string): string {
  return name.replace(/(?<!^)[A-Z]/g, (letter) => `-${letter}`).toLowerCase();
}

type Schema = { properties?: Record<string, { const?: string }>; allOf?: Schema[] };

/** A component's own schema, which a `Checkable` one keeps inside an `allOf`. */
function ownSchema(definition: Schema): Schema {
  return definition.allOf?.find((part) => part.properties?.component) ?? definition;
}

/**
 * The names this catalog `$ref`s out of the specification's common types.
 *
 * Written out rather than fetched: a test that reached the network would fail
 * on a train, and what is being checked is that nothing crept in past the list
 * somebody actually read. They were read against
 * `specification/v1_0/json/common_types.json` in the A2UI repository.
 */
const COMMON_TYPES = [
  'Action',
  'Checkable',
  'Child',
  'ChildList',
  'DynamicBoolean',
  'DynamicNumber',
  'DynamicString'
];

const COMMON = 'https://a2ui.org/specification/v1_0/common_types.json#/$defs/';

/** Every `$ref` anywhere in the file. */
function refs(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.flatMap(refs);
  }

  if (value && typeof value === 'object') {
    return Object.entries(value).flatMap(([key, inner]) =>
      key === '$ref' && typeof inner === 'string' ? [inner] : refs(inner)
    );
  }

  return [];
}

describe('the A2UI catalog', () => {
  describe('is a catalog', () => {
    // `catalog_definition.json` is `additionalProperties: false`, so a key
    // outside this list is a file a renderer refuses rather than one it ignores.
    it('carries only the keys the definition schema allows', () => {
      expect(Object.keys(catalog)).toEqual([
        '$schema',
        '$id',
        'protocolVersion',
        'title',
        'description',
        'catalogId',
        'instructions',
        'components',
        'functions',
        '$defs'
      ]);
    });

    it('names the version of the protocol it is written against', () => {
      expect(catalog.protocolVersion).toBe('1.0');
    });

    it('identifies itself by the URL it is served from', () => {
      // The spec says a `catalogId` need not resolve. This one does, which is
      // what `scripts/build-catalog.mjs --docs` is for.
      expect(catalog.catalogId).toBe('https://neba.cdget.com/a2ui/catalog.json');
      expect(catalog.$id).toBe(catalog.catalogId);
    });

    it('never names a component `Surface`, which the definition schema forbids', () => {
      expect(Object.keys(catalog.components)).not.toContain('Surface');
    });
  });

  describe('says the same name twice', () => {
    it('gives every component a `component` const equal to its key', () => {
      for (const [name, definition] of Object.entries(catalog.components)) {
        expect(ownSchema(definition as Schema).properties?.component?.const, name).toBe(name);
      }
    });

    it('gives every function a `call` const equal to its key', () => {
      for (const [name, definition] of Object.entries(catalog.functions)) {
        expect((definition as Schema).properties?.call?.const, name).toBe(name);
      }
    });

    it('lists every one of them in the `$defs` a renderer validates against', () => {
      expect(catalog.$defs.anyComponent.oneOf.map((one) => one.$ref)).toEqual(
        Object.keys(catalog.components).map((name) => `#/components/${name}`)
      );
      expect(catalog.$defs.anyFunction.oneOf.map((one) => one.$ref)).toEqual(
        Object.keys(catalog.functions).map((name) => `#/functions/${name}`)
      );
    });
  });

  describe('describes components this library has', () => {
    /*
     * A catalog naming a component the library does not export is a model
     * writing something the host cannot draw. It is checked against the barrel
     * rather than against the folder names, because the barrel is what a
     * consumer's renderer imports from.
     */
    it('names only components the entry point exports', () => {
      const missing = Object.keys(catalog.components).filter(
        (name) =>
          !barrels.has(kebab(name)) || !entry.includes(`'./components/${kebab(name)}/index.js'`)
      );

      expect(missing).toEqual([]);
    });

    // Eighteen is the Basic Catalog's count, and the number is the decision:
    // a model cannot choose well from a list of a hundred and thirty-eight.
    it('stays sparse', () => {
      expect(Object.keys(catalog.components).length).toBeLessThanOrEqual(24);
    });
  });

  describe('refers to types that exist', () => {
    it('reaches the specification by its absolute identity', () => {
      const outside = refs(catalog).filter((ref) => !ref.startsWith('#/'));

      expect(outside.length).toBeGreaterThan(0);

      for (const ref of outside) {
        // Relative, the way the specification's own catalog writes them, only
        // resolves for a file sitting beside `common_types.json`. This one is
        // served from somewhere else entirely.
        expect(ref.startsWith(COMMON), ref).toBe(true);
        expect(COMMON_TYPES, ref).toContain(ref.slice(COMMON.length));
      }
    });

    it('points every local ref at something it holds', () => {
      for (const ref of refs(catalog).filter((one) => one.startsWith('#/'))) {
        const [, group, name] = ref.split('/');

        expect(Object.keys(catalog[group as 'components' | 'functions']), ref).toContain(name);
      }
    });
  });

  describe('is published', () => {
    it('is exported under a subpath of its own, ahead of the component wildcard', () => {
      // `neba/a2ui/catalog.json` would otherwise resolve through `./*` to
      // `dist/components/a2ui/catalog.json/index.js`, which does not exist.
      expect(pkg.exports['./a2ui/catalog.json']).toBe('./dist/a2ui/catalog.json');

      const keys = Object.keys(pkg.exports);

      expect(keys.indexOf('./a2ui/catalog.json')).toBeLessThan(keys.indexOf('./*'));
    });

    it('is copied into `dist/` by the build, and into the docs site beside it', () => {
      expect(pkg.scripts.build).toContain('node scripts/build-catalog.mjs');
      expect(pkg.scripts['docs:build']).toContain('npm run docs:catalog');
      expect(pkg.scripts['docs:dev']).toContain('npm run docs:catalog');
    });
  });
});
