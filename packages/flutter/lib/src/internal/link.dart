/// What a link may point at, as the React package's `internal/link.ts` says.
///
/// The library talking to itself: nothing here is exported.
library;

/// The schemes a link may carry. Anything else, `javascript:` above all, is
/// not written, because an address in a chat message or a CMS row was not
/// written by the app's author.
const Set<String> _safeSchemes = <String>{'http', 'https', 'mailto', 'tel'};

/// [href] when it is safe to hand to a reader as a link: a relative address,
/// a fragment or one of the safe schemes. `null` otherwise.
Uri? nebaSafeHref(Uri? href) {
  if (href == null) {
    return null;
  }

  final String scheme = href.scheme.toLowerCase();

  return scheme.isEmpty || _safeSchemes.contains(scheme) ? href : null;
}
