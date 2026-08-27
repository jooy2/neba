/**
 * The translations, and the one call that turns them on.
 *
 * Neba ships English and nothing else. Every other language is a module in this
 * folder that a project imports and registers, once, before it renders:
 *
 * ```ts
 * import { registerMessages, ko, ja } from 'neba/locales';
 *
 * registerMessages('ko', ko);
 * registerMessages('ja', ja);
 * ```
 *
 * The reason is the one every other table in the library answers to: a bundler
 * drops a module nothing imports, and it cannot drop a key out of an object
 * literal. Eighteen languages behind an `import { Chip }` is eighteen languages
 * in the bundle of a product that speaks one. Registered, a language costs
 * about half a kilobyte and only the languages named are paid for.
 *
 * Each locale is also its own entry point — `neba/locales/ko` — for a build
 * that would rather not reach through the barrel at all.
 *
 * Register at module scope, before the first render. Registration mutates the
 * tables the components read; it does not re-render a tree that has already
 * resolved its strings.
 */

export { registerMessages, type NebaLocale } from '../internal/i18n.js';

export { ko } from './ko.js';
export { ja } from './ja.js';
export { zhHans } from './zh-hans.js';
export { zhHant } from './zh-hant.js';
export { es } from './es.js';
export { pt } from './pt.js';
export { fr } from './fr.js';
export { de } from './de.js';
export { it } from './it.js';
export { nl } from './nl.js';
export { pl } from './pl.js';
export { ru } from './ru.js';
export { tr } from './tr.js';
export { ar } from './ar.js';
export { hi } from './hi.js';
export { id } from './id.js';
export { vi } from './vi.js';
export { th } from './th.js';
