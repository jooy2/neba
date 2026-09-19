/**
 * The renderer half of the A2UI support: `neba/a2ui`.
 *
 * `neba/a2ui/catalog.json` is what an agent is handed. This is what draws what
 * the agent writes back — a `Catalog` for `@a2ui/react`'s v0.9 surface, with
 * the eighteen components implemented against this library and the protocol's
 * own fourteen functions.
 *
 * **The three packages it needs are optional peers**, and that is safe here for
 * a reason worth stating, because it is not safe everywhere: this module is not
 * re-exported from `src/index.ts`. A bundler walking `neba` never reaches it,
 * so a project that imports `Button` and has never heard of A2UI resolves
 * nothing new. (`highlight.js` is a real dependency for the opposite reason —
 * `CodeBlock` *is* on the barrel, and an unresolvable specifier there fails the
 * whole build.) Only `import … from 'neba/a2ui'` pulls this in, and anyone
 * writing that line has installed them:
 *
 * ```bash
 * npm install @a2ui/react @a2ui/web_core zod
 * ```
 *
 * ## Versions
 *
 * The catalog is written against **A2UI v1.0** and `@a2ui/react` 0.11's newest
 * renderer is **v0.9**, so this registers with `@a2ui/react/v0_9`. The eighteen
 * components only use constructs the two versions share, which is what makes
 * the bridge a rename rather than a translation, and the two differences that
 * exist are both harmless: v1.0 moved `accessibility` from the catalog entry to
 * the envelope, which `schema.ts` puts back, and v1.0's `Action` gained a
 * `userMessage` that the v0.9 schema strips rather than rejects.
 *
 * There is no v1.0 React renderer to register with yet. When there is, what
 * changes is this file's import and nothing in `catalog.json`.
 */

import { Catalog, type FunctionImplementation } from '@a2ui/web_core/v0_9';
import { BASIC_FUNCTIONS } from '@a2ui/web_core/v0_9';
import catalog from './catalog.json' with { type: 'json' };
import { nebaComponents } from './components.js';

export { nebaComponents } from './components.js';
export { componentSchema, type CatalogSchema } from './schema.js';

/**
 * The fourteen the catalog declares, taken from the ones `web_core` already
 * implements rather than written again.
 *
 * Declaring a function in a catalog is a claim that the renderer runs it, and
 * `required`, `email`, `formatDate` and the rest are the *protocol's* semantics
 * rather than this library's — a second implementation of them would be a
 * second chance to disagree with the agent about what `formatCurrency` does,
 * on the one thing both sides have to read the same way.
 *
 * `test/package/a2ui.test.ts` checks that every name the catalog declares is
 * one `web_core` has, so a function added to the JSON and to nothing else fails
 * here rather than at the first surface that calls it.
 */
function functions(): FunctionImplementation[] {
  const declared = new Set(Object.keys(catalog.functions));
  const available = BASIC_FUNCTIONS.filter((one) => declared.has(one.name));

  if (available.length !== declared.size) {
    const missing = [...declared].filter(
      (name) => !BASIC_FUNCTIONS.some((one) => one.name === name)
    );

    throw new Error(
      `neba/a2ui: the catalog declares ${missing.join(', ')}, which @a2ui/web_core does not implement`
    );
  }

  return available;
}

/**
 * The catalog, ready to hand to a `MessageProcessor`.
 *
 * A function rather than a constant, because building it evaluates eighteen Zod
 * schemas and a project that never renders a surface should not pay for that on
 * import. Call it once and keep what it gives you: a `Catalog` is immutable and
 * the `MessageProcessor` holds on to it.
 *
 * ```tsx
 * import { MessageProcessor } from '@a2ui/web_core/v0_9';
 * import { A2uiSurface } from '@a2ui/react/v0_9';
 * import { createNebaCatalog } from 'neba/a2ui';
 *
 * const catalog = createNebaCatalog();
 * const processor = new MessageProcessor([catalog]);
 * ```
 *
 * The `catalogId` is the one in `catalog.json`, which is also the URL the file
 * is served from — so the id a surface names and the schema an agent was given
 * are the same string without anybody having to keep them in step.
 */
export function createNebaCatalog(): Catalog<
  (typeof nebaComponents)[number],
  FunctionImplementation
> {
  return new Catalog(catalog.catalogId, nebaComponents, functions());
}

/** The catalog's own id, for a `createSurface` message written by hand. */
export const nebaCatalogId: string = catalog.catalogId;
