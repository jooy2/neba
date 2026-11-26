import type { NebaColorScheme } from './NebaProvider.js';

/*
 * Kept out of `NebaProvider.tsx` on purpose, and kept without a 'use client'.
 * This is a plain function whose whole job is to run on a server — in Next.js
 * it is called from `app/layout.tsx`, a Server Component — and a function
 * exported from a client module reaches a Server Component as a client
 * reference, which throws when it is called.
 */

/** Where the provider and the script below remember the reader's choice. */
export const DEFAULT_STORAGE_KEY = 'neba-color-scheme';

/**
 * The script to run before the first paint, so a remembered dark page does not
 * flash white on the way in.
 *
 * The one thing a provider cannot do for you: React runs after the document has
 * been painted once, and by then the flash has happened. Inline the string this
 * returns in `<head>`, above everything:
 *
 * ```tsx
 * <script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
 * ```
 *
 * It reads the same key and writes the same attribute and `color-scheme` the
 * provider does, so the two cannot disagree — which is the reason it is here
 * rather than in a documentation snippet somebody copies once and never updates.
 */
export function colorSchemeScript(
  options: { storageKey?: string; defaultColorScheme?: NebaColorScheme } = {}
): string {
  const key = options.storageKey ?? DEFAULT_STORAGE_KEY;
  const fallback = options.defaultColorScheme ?? 'system';

  return (
    `(function(){try{var s=localStorage.getItem(${embed(key)})||${embed(fallback)};` +
    `if(s==='system'){s=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'}` +
    // `color-scheme` beside the attribute, as the provider writes it: without it
    // the scrollbars and native controls stay light until the app hydrates.
    `var d=document.documentElement;d.setAttribute('data-theme',s);d.style.colorScheme=s}catch(e){}})()`
  );
}

/**
 * A string, as a literal safe to write inside a `<script>` element.
 *
 * `JSON.stringify` closes the quotes and nothing else, and the browser stops
 * parsing the element at the first `</script` in it however that sequence is
 * quoted — so a `storageKey` holding one would end the tag and hand the rest of
 * this to the HTML parser as markup. `<` is escaped to `\u003c`, which the
 * JavaScript parser reads back as the same character. The same escape
 * `Breadcrumb` writes its `BreadcrumbList` out with, for the same reason.
 */
function embed(value: string): string {
  return JSON.stringify(value).replace(/</g, '\\u003c');
}
