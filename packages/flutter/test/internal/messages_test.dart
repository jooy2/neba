// The words the library says on its own behalf: how a language is found for a
// tag, how a partial one falls back to English, and that every table brought
// over from the React package says only what English says.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/messages_en.dart';
import 'package:neba/src/locales/all.dart';

import '../support/host.dart';

void main() {
  tearDown(resetNebaMessages);

  test('is English with no tag, and for a tag nobody registered', () {
    expect(resolveNebaMessages('action', null)['close'], 'Close');
    expect(resolveNebaMessages('action', '')['close'], 'Close');
    expect(resolveNebaMessages('action', 'ko')['close'], 'Close');
  });

  test('finds a registered language by script, then region, then language', () {
    registerNebaMessages('ko', ko);
    registerNebaMessages('zh-hans', zhHans);
    registerNebaMessages('zh-hant', zhHant);
    registerNebaMessages('pt', pt);

    expect(resolveNebaMessages('action', 'ko-KR')['close'], ko.messages['action']!['close']);
    expect(resolveNebaMessages('action', 'pt-BR')['close'], pt.messages['action']!['close']);
    expect(resolveNebaMessages('action', 'zh')['close'], zhHans.messages['action']!['close']);
    expect(resolveNebaMessages('action', 'zh-TW')['close'], zhHant.messages['action']!['close']);
    expect(
      resolveNebaMessages('action', 'zh-Hant-HK')['close'],
      zhHant.messages['action']!['close'],
    );
  });

  test('reads a tag\'s subtags by their shape, broadest last', () {
    expect(nebaLocaleCandidates('zh-Hant-TW'), <String>['zh-hant', 'zh-tw', 'zh']);
    expect(nebaLocaleCandidates('pt_BR'), <String>['pt-br', 'pt']);
    expect(nebaLocaleCandidates('es-419'), <String>['es-419', 'es']);
    expect(nebaLocaleCandidates(''), isEmpty);
  });

  test('fills in from English what a language does not have', () {
    registerNebaMessages(
      'xx',
      const NebaLocale(<String, Map<String, String>>{
        'action': <String, String>{'close': 'Shut'},
      }),
    );

    final Map<String, String> action = resolveNebaMessages('action', 'xx');

    expect(action['close'], 'Shut');
    expect(action['remove'], nebaEnglishMessages['action']!['remove']);
  });

  test('replaces a language registered twice rather than merging the two', () {
    registerNebaMessages(
      'xx',
      const NebaLocale(<String, Map<String, String>>{
        'action': <String, String>{'close': 'Shut', 'clear': 'Wipe'},
      }),
    );
    expect(resolveNebaMessages('action', 'xx')['clear'], 'Wipe');

    registerNebaMessages(
      'xx',
      const NebaLocale(<String, Map<String, String>>{
        'action': <String, String>{'close': 'Shut'},
      }),
    );
    expect(resolveNebaMessages('action', 'xx')['clear'], 'Clear');
  });

  test('fills placeholders, and leaves one with no value as it is', () {
    expect(fillNebaMessage('Remove {label}', <String, String>{'label': 'Tag'}), 'Remove Tag');
    expect(fillNebaMessage('{a} of {b}', <String, String>{'a': '1'}), '1 of {b}');
  });

  testWidgets('a widget speaks its own locale, then the provider\'s, then English', (
    WidgetTester tester,
  ) async {
    registerNebaMessages('ko', ko);
    late BuildContext captured;

    Future<void> pump({Locale? defaults}) async {
      await tester.pumpWidget(
        host(
          NebaProvider(
            defaults: NebaDefaults(locale: defaults),
            child: Builder(
              builder: (BuildContext context) {
                captured = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    }

    await pump();
    expect(nebaMessages(captured, 'action')['close'], 'Close');

    await pump(defaults: const Locale('ko'));
    expect(nebaMessages(captured, 'action')['close'], ko.messages['action']!['close']);
    expect(nebaMessages(captured, 'action', locale: const Locale('en'))['close'], 'Close');
  });

  group('every language brought over from the React package', () {
    final RegExp placeholder = RegExp(r'\{(\w+)\}');

    Set<String> placeholdersOf(String template) {
      return placeholder.allMatches(template).map((Match m) => m.group(1)!).toSet();
    }

    test('is all eighteen of them', () {
      expect(nebaAllLocales, hasLength(18));
    });

    for (final MapEntry<String, NebaLocale> locale in nebaAllLocales.entries) {
      test('${locale.key} names only namespaces and keys English has', () {
        for (final MapEntry<String, Map<String, String>> namespace
            in locale.value.messages.entries) {
          final Map<String, String>? english = nebaEnglishMessages[namespace.key];

          expect(english, isNotNull, reason: 'namespace ${namespace.key}');

          for (final String key in namespace.value.keys) {
            expect(english!.containsKey(key), isTrue, reason: '${namespace.key}.$key');
          }
        }
      });

      test('${locale.key} keeps every placeholder English has', () {
        for (final MapEntry<String, Map<String, String>> namespace
            in locale.value.messages.entries) {
          for (final MapEntry<String, String> message in namespace.value.entries) {
            final String english = nebaEnglishMessages[namespace.key]![message.key]!;

            expect(
              placeholdersOf(message.value),
              placeholdersOf(english),
              reason: '${namespace.key}.${message.key}: "${message.value}"',
            );
          }
        }
      });
    }
  });
}
