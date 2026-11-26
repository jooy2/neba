/**
 * The renderer half of the A2UI support: `neba/a2ui`.
 *
 * `neba/a2ui/catalog.json` is what an agent is handed. This is what draws what
 * the agent writes back — a `Catalog` for `@a2ui/react`'s `A2uiSurface`, with
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
 * The catalog is written against **A2UI v1.0**, and the messages this draws
 * are v1.0's unless `protocolVersion` asks for v0.9's. `web_core` reads either
 * into the surface model `A2uiSurface` draws, and refuses a surface whose
 * messages name another version than its catalog. `@a2ui/react` has no entry
 * point per version past v0.9: its root is one renderer for both, and its
 * `v0_9` entry, which this imports, re-exports that root.
 *
 * The two versions no longer write a binding the same way. v1.0 binds with
 * `{ "@path": … }` and calls with `{ "@call": … }`, its messages carry
 * `"version": "1.0"`, and its checks return a validation result; v0.9 binds
 * with `{ "path": … }`, calls with `{ "call": … }` and carries
 * `"version": "v0.9"`. So each version gets its own schemas, from `schema.ts`,
 * and its own functions, below, while the views are the same. The catalog
 * spells v1.0's, so a host that draws v0.9 messages has an agent that writes
 * them from somewhere other than this file.
 *
 * A v1.0 message may also carry `accessibility.live`, `accessibility.hidden`
 * and a component's `metadata`; no component reads them, and the component is
 * drawn all the same.
 */

import {
  createBasicCatalogFunctions as createFunctionsV09,
  type FunctionImplementation
} from '@a2ui/web_core/v0_9';
import { Catalog, createBasicCatalogFunctions as createFunctionsV10 } from '@a2ui/web_core/v1_0';
import catalog from './catalog.json' with { type: 'json' };
import { componentsFor, nebaComponents } from './components.js';
import { functionSchema, type ProtocolVersion } from './schema.js';

export { nebaComponents } from './components.js';
export { componentSchema, type CatalogSchema, type ProtocolVersion } from './schema.js';

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
 * Each version gets its own set, because each reads its arguments the way its
 * messages write them. v1.0's checks return a validation result, which is what
 * the catalog declares, and its `and`, `or` and `not` read one by its `valid`
 * member; v0.9's return a boolean.
 *
 * `test/a2ui/adapter.test.tsx` checks that every name the catalog declares is
 * one `web_core` has, so a function added to the JSON and to nothing else fails
 * here rather than at the first surface that calls it.
 */
function functions(locale: string | undefined, version: ProtocolVersion): FunctionImplementation[] {
  const basic =
    version === 'v1.0' ? createFunctionsV10({ locale }) : createFunctionsV09({ locale });
  const declared = new Set(Object.keys(catalog.functions));
  const available = basic.filter((one) => declared.has(one.name));

  if (available.length !== declared.size) {
    const missing = [...declared].filter((name) => !basic.some((one) => one.name === name));

    throw new Error(
      `neba/a2ui: the catalog declares ${missing.join(', ')}, which @a2ui/web_core does not implement`
    );
  }

  return available.map((one) => {
    const widened = { ...one, schema: functionSchema(one.name, one.schema, version) };

    switch (one.name) {
      case 'openUrl':
        return onlyWhenActivated(widened);
      case 'formatDate':
        return withTimeOfDay(widened);
      default:
        return widened;
    }
  });
}

/** A date with no time and no offset, such as `2026-10-09`. */
const dateAlone = /^\d{4}-\d{2}-\d{2}$/;

/**
 * `formatDate`, given a date with no time in every browser.
 *
 * `web_core` reads a value with no offset as UTC by writing a `Z` after it,
 * which turns `2026-10-09` into `2026-10-09Z`. The language defines no such
 * form: Chromium and Firefox read it as midnight UTC anyway, and Safari reads
 * it as no date at all, so a date the catalog allows came out there as an
 * empty string. A date alone is handed over with that midnight written out.
 */
function withTimeOfDay(implementation: FunctionImplementation): FunctionImplementation {
  return {
    ...implementation,
    execute: (args, context, abortSignal) =>
      implementation.execute(
        typeof args.value === 'string' && dateAlone.test(args.value)
          ? { ...args, value: `${args.value}T00:00:00` }
          : args,
        context,
        abortSignal
      )
  };
}

/**
 * `openUrl`, run only while the reader is acting on the page.
 *
 * The catalog declares it `rendererOnly` and `requiresUserActivation`. v1.0's
 * `openUrl` carries the same flag and `web_core` refuses a call to it that no
 * press is behind; v0.9's carries none, so `web_core` runs it wherever an agent
 * writes the call, and a call written into any string is evaluated when the
 * component binds and again on every change to the data it reads. So a v0.9
 * surface could open a page the moment it was drawn. Here it acts only under a
 * transient user activation — a press that is still being handled — which is
 * what a button's action is and a binding is not, under both versions. A
 * browser without `navigator.userActivation` (Firefox before 120) keeps the
 * old behaviour, where its popup blocker is what stands in the way.
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
  /**
   * The protocol version of the messages the catalog draws. A v1.0 message
   * carries `"version": "1.0"` and a v0.9 one `"version": "v0.9"`. `web_core`
   * refuses a surface whose messages name another version than its catalog,
   * so pass the one the agent writes. The components are the same for both;
   * the schemas and the functions are each version's own.
   *
   * @default 'v1.0'
   */
  protocolVersion?: ProtocolVersion;
}

/**
 * The catalog, ready to hand to a `MessageProcessor`.
 *
 * The components' Zod schemas are built when this module is evaluated, since
 * `nebaComponents` is exported as they are. Call this once and keep what it
 * gives you: a `Catalog` is immutable and the `MessageProcessor` holds on to it.
 *
 * ```tsx
 * import { MessageProcessor } from '@a2ui/web_core/v1_0';
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
 * A catalog draws one version, and so does a processor holding it, since a
 * surface finds its catalog by id alone. A host whose agents write both keeps
 * a processor for each and hands a message to the one its `version` names.
 *
 * The `catalogId` is the one in `catalog.json`, which is also the URL the file
 * is served from — so the id a surface names and the schema an agent was given
 * are the same string without anybody having to keep them in step.
 */
export function createNebaCatalog(
  options: NebaCatalogOptions = {}
): Catalog<(typeof nebaComponents)[number], FunctionImplementation> {
  const { locale, protocolVersion = 'v1.0' } = options;

  // Checked rather than trusted: `web_core` takes any string, and pairs the
  // catalog with messages of whatever version it names, `v0.8` included.
  if (protocolVersion !== 'v0.9' && protocolVersion !== 'v1.0') {
    throw new Error(
      `neba/a2ui: protocolVersion is 'v0.9' or 'v1.0', not ${JSON.stringify(protocolVersion)}`
    );
  }

  // The messages' version rather than the file's `protocolVersion`, which is
  // always 1.0, written the way `web_core`'s own catalogs write it: `0.9`.
  return new Catalog(
    catalog.catalogId,
    protocolVersion.slice(1),
    componentsFor(protocolVersion),
    functions(locale, protocolVersion)
  );
}

/** The catalog's own id, for a `createSurface` message written by hand. */
export const nebaCatalogId: string = catalog.catalogId;
