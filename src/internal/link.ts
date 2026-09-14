/**
 * The one rule the library makes about a link it did not write.
 *
 * A `target` other than the current tab hands the new page a `window.opener`
 * pointing back at this one, and a `Referer` header naming it. Modern browsers
 * imply `noopener` for `target="_blank"`; none of them implies `noreferrer`,
 * and neither is implied for a named target. So the two tokens are added
 * wherever a component lets a caller choose where a link opens — TextLink, a
 * Menu row, a NavigationMenu link, a ChatBubble's link, an AppLogo, a
 * BottomNavigation destination — and they are added the same way in all of
 * them, because a library where only some are safe is a library whose users
 * cannot tell which.
 *
 * It is a *merge* and not an override, and that is the whole reason this is a
 * function rather than a string. The common reason to write a `rel` by hand is
 * `nofollow` or `sponsored`, which is an SEO decision and has nothing to do
 * with the two tokens above — spelled as a plain default it would silently take
 * the protection off the link that still opens in a new tab.
 */
/** The schemes a link may use. Everything else is dropped, `javascript:` above all. */
const allowedSchemes = new Set(['http', 'https', 'mailto', 'tel']);

/**
 * An `href` a component is safe to write, or nothing.
 *
 * A link's address very often comes from somebody other than the page's author:
 * the preview under a chat message, a destination read out of a CMS, a page link
 * a router built from a query. React 19 refuses a `javascript:` URL, but React
 * 18 — inside the peer range — writes it as it is, and a press then runs it.
 * So every component that writes an `href` passes it through here, and a scheme
 * outside `http`, `https`, `mailto` and `tel` leaves the element with no
 * `href` at all. A relative URL, a `#fragment` and a `//host` have no scheme and
 * are kept.
 *
 * The scheme is read the way a browser reads it: leading spaces and control
 * characters are dropped, and a tab or a newline anywhere in it is ignored, so
 * ` java\tscript:` is caught along with `JavaScript:`.
 */
export function safeHref(href: string | undefined): string | undefined {
  if (href === undefined) {
    return undefined;
  }

  let start = 0;

  while (start < href.length && href.charCodeAt(start) <= 0x20) {
    start += 1;
  }

  const read = href.slice(start).replace(/[\t\n\r]/g, '');
  const scheme = /^([a-z][a-z\d+.-]*):/i.exec(read);

  return scheme === null || allowedSchemes.has(scheme[1].toLowerCase()) ? href : undefined;
}

export function safeRel(target: string | undefined, rel: string | undefined): string | undefined {
  // `_self` is this tab, and `_parent`/`_top` are frames of the same document.
  // None of the three opens a browsing context that could reach back.
  if (!target || target === '_self' || target === '_parent' || target === '_top') {
    return rel;
  }

  return [...new Set([...(rel ?? '').split(/\s+/).filter(Boolean), 'noopener', 'noreferrer'])].join(
    ' '
  );
}
