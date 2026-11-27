// NebaApproval: the suite the React package runs on Approval, asked the way
// Flutter asks it — a group named by its question with a button per answer,
// the risk in words and in the family, the record line that replaces the
// buttons and takes the focus a press leaves behind, and its own words.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

const List<NebaApprovalOption> _options = <NebaApprovalOption>[
  NebaApprovalOption(value: 'once', label: Text('Allow once')),
  NebaApprovalOption(value: 'always', label: Text('Always allow')),
  NebaApprovalOption(value: 'deny', label: Text('Deny'), color: NebaColor.danger),
];

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget approval) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 480, child: approval),
        ),
      ),
    );
  }

  Finder button(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaButton));
  }

  /// The card's own node: the group named by its heading.
  SemanticsNode card(WidgetTester tester) {
    return tester.getSemantics(
      find.descendant(of: find.byType(NebaApproval), matching: find.byType(Semantics)).first,
    );
  }

  Color glyphColor(WidgetTester tester) {
    return IconTheme.of(tester.element(find.byType(NebaGlyph).first)).color!;
  }

  group('rendering', () {
    testWidgets('draws a button per option', (WidgetTester tester) async {
      await pump(tester, const NebaApproval(options: _options, title: Text('Write to disk?')));

      expect(button('Allow once'), findsOneWidget);
      expect(button('Always allow'), findsOneWidget);
      expect(button('Deny'), findsOneWidget);
    });

    testWidgets('names the group after the question', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaApproval(
          options: _options,
          title: Text('Write to disk?'),
          risk: NebaApprovalRisk.high,
          description: Text('It will overwrite the file.'),
        ),
      );

      expect(card(tester).label, 'Write to disk?');
      semantics.dispose();
    });

    testWidgets('falls back to a heading of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaApproval(options: _options));

      expect(find.text('Permission needed'), findsOneWidget);
      expect(card(tester).label, 'Permission needed');
      semantics.dispose();
    });

    testWidgets('draws a plain Text of details as preformatted text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaApproval(options: _options, details: Text('rm -rf ./build\necho done')),
      );

      expect(
        find.ancestor(
          of: find.text('rm -rf ./build\necho done'),
          matching: find.byType(NebaPreformatted),
        ),
        findsOneWidget,
      );
    });

    testWidgets('lists the descriptions its options carry', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaApproval(
          options: <NebaApprovalOption>[
            NebaApprovalOption(
              value: 'once',
              label: Text('Allow once'),
              description: Text('Just this call'),
            ),
            NebaApprovalOption(value: 'deny', label: Text('Deny')),
          ],
        ),
      );

      expect(find.text('Just this call'), findsOneWidget);
      // The label is drawn twice: on its button, and beside its description.
      expect(find.text('Allow once'), findsNWidgets(2));
      expect(find.text('Deny'), findsOneWidget);
    });

    testWidgets('draws every option outline unless it says otherwise', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaApproval(
          options: <NebaApprovalOption>[
            NebaApprovalOption(value: 'send', label: Text('Send'), variant: NebaVariant.solid),
            NebaApprovalOption(value: 'deny', label: Text('Not now')),
          ],
        ),
      );

      expect(tester.widget<NebaButton>(button('Send')).variant, NebaVariant.solid);
      expect(tester.widget<NebaButton>(button('Not now')).variant, NebaVariant.outline);
    });

    testWidgets('drops the glyph with showIcon off', (WidgetTester tester) async {
      await pump(tester, const NebaApproval(options: _options, showIcon: false));

      expect(
        find.descendant(of: find.byType(NebaApproval), matching: find.byType(NebaGlyph)),
        findsNothing,
      );
    });
  });

  group('risk', () {
    testWidgets('writes the level out in words', (WidgetTester tester) async {
      await pump(tester, const NebaApproval(options: _options, risk: NebaApprovalRisk.high));

      expect(find.text('High risk'), findsOneWidget);
    });

    testWidgets('takes over the colour family', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaApproval(options: _options, risk: NebaApprovalRisk.low, color: NebaColor.danger),
      );

      expect(glyphColor(tester), tokens.roles(NebaColor.info).accent);
      expect(tester.widget<NebaButton>(button('Allow once')).color, NebaColor.info);
    });

    testWidgets('leaves the family to color when there is no risk', (WidgetTester tester) async {
      await pump(tester, const NebaApproval(options: _options, color: NebaColor.success));

      expect(glyphColor(tester), tokens.roles(NebaColor.success).accent);
    });

    testWidgets('is the warning family with neither', (WidgetTester tester) async {
      await pump(tester, const NebaApproval(options: _options));

      expect(glyphColor(tester), tokens.roles(NebaColor.warning).accent);
      // The option's own colour still wins on its button.
      expect(tester.widget<NebaButton>(button('Deny')).color, NebaColor.danger);
    });
  });

  group('deciding', () {
    testWidgets('reports the value of the option that was pressed', (WidgetTester tester) async {
      final List<String> decided = <String>[];

      await pump(tester, NebaApproval(options: _options, onDecide: decided.add));
      await tester.tap(button('Always allow'));
      await tester.pump();

      expect(decided, <String>['always']);
    });

    // The card is a record of what was agreed to, not a question that
    // vanishes once it has been answered.
    testWidgets('stays in the transcript as the answer that was given', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaApproval(options: _options));
      await tester.tap(button('Allow once'));
      await tester.pump();

      expect(find.text('Answered'), findsOneWidget);
      expect(find.text('Allow once'), findsOneWidget);
      expect(find.byType(NebaButton), findsNothing);
    });

    // The pressed button left with the focus on it, and a keyboard reader
    // started again from the top of the page.
    testWidgets('hands the focus to the answer when a press replaces the buttons', (
      WidgetTester tester,
    ) async {
      final FocusNode once = FocusNode();
      addTearDown(once.dispose);

      await pump(
        tester,
        NebaApproval(
          options: _options,
          onDecide: (String _) {},
          child: Focus(focusNode: once, child: const SizedBox.shrink()),
        ),
      );

      // Focus the first button and press it from the keyboard.
      Focus.of(tester.element(find.text('Allow once'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump();

      final FocusNode? now = FocusManager.instance.primaryFocus;
      expect(now?.debugLabel, 'NebaApproval record');
    });

    testWidgets('leaves the focus where it went while a controlled answer was on its way', (
      WidgetTester tester,
    ) async {
      final FocusNode elsewhere = FocusNode(debugLabel: 'elsewhere');
      addTearDown(elsewhere.dispose);
      String? decision;

      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: <Widget>[
                  NebaApproval(options: _options, controlled: true, decision: decision),
                  NebaButton(
                    focusNode: elsewhere,
                    onPressed: () => setState(() => decision = 'deny'),
                    child: const Text('Answer'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      elsewhere.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump();

      expect(find.text('Answered'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus, elsewhere);
    });

    testWidgets('shows a decision it was handed rather than one it took', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaApproval(options: _options, decision: 'deny'));

      expect(find.text('Answered'), findsOneWidget);
      expect(find.text('Deny'), findsOneWidget);
    });

    testWidgets('leaves a controlled Approval unanswered until its caller says so', (
      WidgetTester tester,
    ) async {
      final List<String> decided = <String>[];

      await pump(tester, NebaApproval(options: _options, controlled: true, onDecide: decided.add));
      await tester.tap(button('Deny'));
      await tester.pump();

      expect(decided, <String>['deny']);
      expect(button('Deny'), findsOneWidget);
      expect(find.text('Answered'), findsNothing);
    });

    testWidgets('asks again when a controlled decision goes back to null', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaApproval(options: _options, controlled: true, decision: 'deny'));
      expect(find.text('Answered'), findsOneWidget);

      await pump(tester, const NebaApproval(options: _options, controlled: true));
      expect(button('Deny'), findsOneWidget);
    });

    testWidgets('takes every answer away while it is disabled', (WidgetTester tester) async {
      final List<String> decided = <String>[];

      await pump(tester, NebaApproval(options: _options, disabled: true, onDecide: decided.add));
      await tester.tap(button('Deny'), warnIfMissed: false);
      await tester.pump();

      expect(tester.widget<NebaButton>(button('Deny')).disabled, isTrue);
      expect(decided, isEmpty);
    });
  });

  group('its own words', () {
    tearDown(resetNebaMessages);

    // Only English ships; the other languages are registered by the app, so
    // an unregistered tag has to be a fallback rather than a page of blanks.
    testWidgets('falls back to English for a language nobody registered', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaApproval(options: _options, risk: NebaApprovalRisk.high, locale: Locale('ko')),
      );

      expect(find.text('Permission needed'), findsOneWidget);
      expect(find.text('High risk'), findsOneWidget);
    });

    testWidgets('lets a caller write them out instead', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaApproval(
          options: _options,
          labels: <String, String>{'request': 'Zustimmung nötig'},
        ),
      );

      expect(find.text('Zustimmung nötig'), findsOneWidget);
    });

    testWidgets('takes the locale from a provider', (WidgetTester tester) async {
      registerNebaMessages(
        'de',
        const NebaLocale(<String, Map<String, String>>{
          'approval': <String, String>{'request': 'Zustimmung nötig', 'answered': 'Beantwortet'},
        }),
      );

      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(locale: Locale('de', 'DE')),
          child: NebaApproval(options: _options, decision: 'once'),
        ),
      );

      expect(find.text('Zustimmung nötig'), findsOneWidget);
      expect(find.text('Beantwortet'), findsOneWidget);
    });
  });
}
