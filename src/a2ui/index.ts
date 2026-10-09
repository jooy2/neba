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
 * `zod` may be 3.25 or 4; `schema.ts` says why both work.
 *
 * ## Versions
 *
 * The catalog is written against **A2UI v1.0** and `@a2ui/react` 0.12's newest
 * renderer is **v0.9**, so this registers with `@a2ui/react/v0_9`, and the
 * messages it draws are v0.9's: `web_core` refuses a surface whose messages name
 * another version than its catalog. The eighteen components only use constructs
 * the two versions share, which is what makes the bridge a rename rather than a
 * translation, and none of the three differences that exist makes the renderer
 * refuse a message: v1.0 moved `accessibility` from the catalog entry to the
 * envelope, which `schema.ts` puts back; v1.0 lets a check leave out the
 * `message` v0.9 requires, which `schema.ts` accepts; and v1.0's `Action`
 * gained a `userMessage` that v0.9's refuses, which `schema.ts` accepts and the
 * host receives resolved.
 *
 * There is no v1.0 React renderer to register with yet. When there is, what
 * changes is this file's import and nothing in `catalog.json`.
 */

import {
  Catalog,
  createBasicCatalogFunctions,
  type FunctionImplementation
} from '@a2ui/web_core/v0_9';
import catalog from './catalog.json' with { type: 'json' };
import { nebaComponents } from './components.js';
import { functionSchema } from './schema.js';

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
 * `test/a2ui/adapter.test.tsx` checks that every name the catalog declares is
 * one `web_core` has, so a function added to the JSON and to nothing else fails
 * here rather than at the first surface that calls it.
 */
function functions(locale: string | undefined): FunctionImplementation[] {
  const basic = createBasicCatalogFunctions({ locale });
  const declared = new Set(Object.keys(catalog.functions));
  const available = basic.filter((one) => declared.has(one.name));

  if (available.length !== declared.size) {
    const missing = [...declared].filter((name) => !basic.some((one) => one.name === name));

    throw new Error(
      `neba/a2ui: the catalog declares ${missing.join(', ')}, which @a2ui/web_core does not implement`
    );
  }

  return available.map((one) => {
    const widened = { ...one, schema: functionSchema(one.name, one.schema) };

    return one.name === 'openUrl' ? onlyWhenActivated(widened) : widened;
  });
}

/**
 * `openUrl`, run only while the reader is acting on the page.
 *
 * The catalog declares it `rendererOnly` and `requiresUserActivation`, and
 * nothing enforced either: `web_core` runs it wherever an agent writes the
 * call, and a call written into any string is evaluated when the component
 * binds and again on every change to the data it reads. So a surface could
 * open a page the moment it was drawn. Here it acts only under a transient
 * user activation — a press that is still being handled — which is what a
 * button's action is and a binding is not. A browser without
 * `navigator.userActivation` (Firefox before 120) keeps the old behaviour,
 * where its popup blocker is what stands in the way.
 */
function onlyWhenActivated(implementation: FunctionImplementation): FunctionImplementation {
  return {
    ...implementation,
    execute: (args, context, abortSignal) => {
      if (typeof navigator !== 'undefined' && 'userActivation' in navigator) {
        if (!navigator.userActivation.isActive) {
          return undefined;
        }
      }

      return implementation.execute(args, context, abortSignal);
    }
  };
}

/** What `createNebaCatalog` takes. */
export interface NebaCatalogOptions {
  /**
   * The language `formatNumber`, `formatCurrency`, `formatDate` and `pluralize`
   * write in. Pass the one the components are in — a `NebaProvider`'s `locale` —
   * or the four write American English while the components follow the
   * provider. Left out, they write `en-US`, on a server and in every browser.
   */
  locale?: string;
}

/**
 * The catalog, ready to hand to a `MessageProcessor`.
 *
 * The components' Zod schemas are built when this module is evaluated, since
 * `nebaComponents` is exported as they are. Call this once and keep what it
 * gives you: a `Catalog` is immutable and the `MessageProcessor` holds on to it.
 *
 * ```tsx
 * import { MessageProcessor } from '@a2ui/web_core/v0_9';
 * import { A2uiSurface, type ReactComponentImplementation } from '@a2ui/react/v0_9';
 * import { createNebaCatalog } from 'neba/a2ui';
 *
 * const catalog = createNebaCatalog({ locale: 'ko' });
 * const processor = new MessageProcessor<ReactComponentImplementation>([catalog]);
 * ```
 *
 * The type argument is what makes a surface the processor creates one
 * `A2uiSurface` takes; `MessageProcessor` does not work it out from the
 * catalog.
 *
 * The `catalogId` is the one in `catalog.json`, which is also the URL the file
 * is served from — so the id a surface names and the schema an agent was given
 * are the same string without anybody having to keep them in step.
 */
export function createNebaCatalog(
  options: NebaCatalogOptions = {}
): Catalog<(typeof nebaComponents)[number], FunctionImplementation> {
  // `0.9` is the renderer's version rather than the file's `protocolVersion`:
  // the processor refuses a surface whose messages name another version than
  // its catalog, and the components are bound to v0.9's schemas.
  return new Catalog(catalog.catalogId, '0.9', nebaComponents, functions(options.locale));
}

/** The catalog's own id, for a `createSurface` message written by hand. */
export const nebaCatalogId: string = catalog.catalogId;
