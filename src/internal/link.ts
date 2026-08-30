/**
 * The one rule the library makes about a link it did not write.
 *
 * A `target` other than the current tab hands the new page a `window.opener`
 * pointing back at this one, and a `Referer` header naming it. Modern browsers
 * imply `noopener` for `target="_blank"`; none of them implies `noreferrer`,
 * and neither is implied for a named target. So the two tokens are added
 * wherever a component lets a caller choose where a link opens — TextLink,
 * a Menu row, a NavigationMenu link — and they are added the same way in all
 * three, because a library where only one of them is safe is a library whose
 * users cannot tell which.
 *
 * It is a *merge* and not an override, and that is the whole reason this is a
 * function rather than a string. The common reason to write a `rel` by hand is
 * `nofollow` or `sponsored`, which is an SEO decision and has nothing to do
 * with the two tokens above — spelled as a plain default it would silently take
 * the protection off the link that still opens in a new tab.
 */
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
