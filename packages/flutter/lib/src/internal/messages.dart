/// The words the library says on its own behalf, the React package's
/// `src/internal/i18n.ts` in Dart.
///
/// Almost nothing in Neba writes text a reader sees: a button says what it
/// was handed. The exceptions are the strings a widget has to invent because
/// there is nowhere else for them to come from, such as the label of a close
/// button or the word under a chat message that says it was read. They are a
/// set, kept in namespaces named as the React package names them, so a product
/// in Korean sets one language and every widget follows it.
///
/// English is built in. Every other language is a [NebaLocale] in
/// `package:neba/locales.dart`, registered by the app, so a product that says
/// nothing about languages carries none of them. All of them, English
/// included, are generated from the React package's tables by
/// `tool/generate.dart`, and `test/package/generated_test.dart` fails until a
/// change on that side is brought over.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/messages_en.dart';
import 'package:neba/src/theme/theme.dart';

/// A language, as `package:neba/locales.dart` hands it over: namespace, then
/// key, then the string, with `{placeholders}` where a value goes.
///
/// Every namespace is optional and so is every string in one: a language fills
/// in what it has and English answers for the rest, so a translation that has
/// not caught up with a new widget is one that has not caught up, rather than
/// a screen of blanks.
@immutable
class NebaLocale {
  /// A language's strings, by namespace and key.
  const NebaLocale(this.messages);

  /// The strings, by namespace and then by key.
  final Map<String, Map<String, String>> messages;
}

final Map<String, NebaLocale> _registered = <String, NebaLocale>{};
final Map<String, Map<String, String>> _resolved = <String, Map<String, String>>{};

/// Makes [locale] the words for [tag].
///
/// The tag is matched the way a widget's `locale` is: by script, then by
/// region, then by language, so registering `zh-hans` answers `zh-CN` and a
/// bare `zh`, and registering `pt` answers `pt-BR`. A second call for the same
/// tag replaces the first rather than merging into it. Register before the
/// widgets that need it are built: a widget already on screen keeps what it
/// read.
///
/// ```dart
/// import 'package:neba/locales.dart';
///
/// void main() {
///   registerNebaMessages('ko', ko);
///   runApp(const App());
/// }
/// ```
void registerNebaMessages(String tag, NebaLocale locale) {
  _registered[tag.trim().toLowerCase()] = locale;
  _resolved.clear();
}

/// Forgets every registered language. For tests.
@visibleForTesting
void resetNebaMessages() {
  _registered.clear();
  _resolved.clear();
}

/// The tags that are another spelling of a registered one: a reader in Taipei
/// asking for `zh-TW` and one in Hong Kong asking for `zh-HK` want the same
/// words, and a bare `zh` is Simplified.
const Map<String, String> _aliases = <String, String>{
  'zh': 'zh-hans',
  'zh-cn': 'zh-hans',
  'zh-my': 'zh-hans',
  'zh-sg': 'zh-hans',
  'zh-hk': 'zh-hant',
  'zh-mo': 'zh-hant',
  'zh-tw': 'zh-hant',
};

/// A BCP 47 tag's candidates, broadest last: `zh-Hant-TW` asks for
/// `zh-hant`, then `zh-tw`, then `zh`. Subtags are found by shape rather than
/// by position, because an extension or a variant can sit between them.
List<String> nebaLocaleCandidates(String tag) {
  final List<String> subtags = tag
      .toLowerCase()
      .split(RegExp('[-_]'))
      .where((String subtag) => subtag.isNotEmpty)
      .toList();

  if (subtags.isEmpty) {
    return const <String>[];
  }

  final String language = subtags.first;
  final Iterable<String> rest = subtags.skip(1);
  final String? script = rest.where((String s) => RegExp(r'^[a-z]{4}$').hasMatch(s)).firstOrNull;
  final String? region = rest
      .where((String s) => RegExp(r'^([a-z]{2}|\d{3})$').hasMatch(s))
      .firstOrNull;

  return <String>[
    if (script != null) '$language-$script',
    if (region != null) '$language-$region',
    language,
  ];
}

/// [namespace]'s strings for [tag], merged over English.
///
/// An empty or `null` tag is English.
Map<String, String> resolveNebaMessages(String namespace, String? tag) {
  final Map<String, String> english = nebaEnglishMessages[namespace] ?? const <String, String>{};
  final String key = tag?.trim().toLowerCase() ?? '';

  if (key.isEmpty) {
    return english;
  }

  return _resolved.putIfAbsent('$namespace|$key', () {
    for (final String candidate in nebaLocaleCandidates(key)) {
      final NebaLocale? locale = _registered[candidate] ?? _registered[_aliases[candidate]];
      final Map<String, String>? found = locale?.messages[namespace];

      if (found != null) {
        return Map<String, String>.unmodifiable(<String, String>{...english, ...found});
      }
    }

    return english;
  });
}

/// [namespace]'s strings for a widget in [context].
///
/// The language is the widget's own [locale], then `NebaProvider`'s default,
/// then the app's own locale, then English. The React package stops before the
/// app's locale, because a server and a browser rarely agree on one and text
/// that differs between them breaks hydration; a Flutter app has no such seam.
Map<String, String> nebaMessages(BuildContext context, String namespace, {Locale? locale}) {
  final Locale? chosen =
      locale ?? NebaTheme.defaultsOf(context).locale ?? Localizations.maybeLocaleOf(context);

  return resolveNebaMessages(namespace, chosen?.toLanguageTag());
}

/// Fills the `{placeholders}` in [template] from [values].
///
/// A whole sentence is translated rather than assembled from fragments,
/// because what differs between languages is often the order: "1–25 of 1,204"
/// is "전체 1,204개 중 1–25" in Korean. A placeholder with no value is left as
/// it is, so a mistranslated name shows up as itself rather than as a hole.
String fillNebaMessage(String template, Map<String, String> values) {
  return template.replaceAllMapped(RegExp(r'\{(\w+)\}'), (Match match) {
    return values[match.group(1)] ?? match.group(0)!;
  });
}
