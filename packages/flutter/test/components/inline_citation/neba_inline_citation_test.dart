// NebaInlineCitation: the suite the React package runs on InlineCitation,
// asked the way Flutter asks it — the number drawn and the name said, the
// link it is and the one it refuses to be, the focus it takes, and the
// preview a resting pointer or the keyboard uncovers.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/agent.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget citation) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 20, color: Color(0xFF000000)),
              child: citation,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder mark() => find.byType(NebaCitationMark);

  /// The mark's own node: the one named "Source N".
  SemanticsNode node(WidgetTester tester, String name) {
    return tester.getSemantics(find.bySemanticsLabel(RegExp('^$name')));
  }

  group('the mark', () {
    testWidgets('draws the number it was given, at 0.8 of the type around it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaInlineCitation(index: 3));

      expect(find.text('3'), findsOneWidget);
      expect(tester.widget<Text>(find.text('3')).style?.fontSize, 16);
    });

    testWidgets('is named in words, since the mark itself only says a number', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaInlineCitation(index: 3, href: Uri.parse('https://example.com/a'), onPressed: () {}),
      );

      expect(
        node(tester, 'Source 3').getSemanticsData().linkUrl,
        Uri.parse('https://example.com/a'),
      );
      expect(
        node(tester, 'Source 3'),
        matchesSemantics(
          label: 'Source 3',
          isLink: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('says its name and is no link when there is nothing to press', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaInlineCitation(index: 3));

      expect(node(tester, 'Source 3').label, 'Source 3');
      expect(node(tester, 'Source 3'), isNot(matchesSemantics(isLink: true)));
      semantics.dispose();
    });

    testWidgets('takes the focus without a link only when it has a preview to open', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(tester, NebaInlineCitation(index: 3, focusNode: focus));
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);

      await pump(
        tester,
        NebaInlineCitation(index: 3, title: const Text('Design language'), focusNode: focus),
      );
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
    });

    testWidgets('runs its press where it was pointed', (WidgetTester tester) async {
      int pressed = 0;

      await pump(
        tester,
        NebaInlineCitation(
          index: 1,
          href: Uri.parse('https://example.com/a'),
          onPressed: () => pressed += 1,
        ),
      );
      await tester.tap(mark());

      expect(pressed, 1);
    });

    // An address in a chat or a search result was not written by the app's
    // author.
    testWidgets('refuses an address whose scheme is not one of the four', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int pressed = 0;

      await pump(
        tester,
        NebaInlineCitation(
          index: 1,
          href: Uri.parse('javascript:alert(1)'),
          onPressed: () => pressed += 1,
        ),
      );
      await tester.tap(mark(), warnIfMissed: false);

      expect(pressed, 0);
      expect(node(tester, 'Source 1'), isNot(matchesSemantics(isLink: true)));
      semantics.dispose();
    });

    testWidgets('says a link leaves the app in its name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaInlineCitation(
          index: 1,
          href: Uri.parse('https://example.com/a'),
          onPressed: () {},
          newTab: true,
        ),
      );

      expect(find.bySemanticsLabel('Source 1 (opens in a new tab)'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('washes the mark in its family', (WidgetTester tester) async {
      await pump(tester, const NebaInlineCitation(index: 1, color: NebaColor.success));

      final NebaColorRoles roles = tokens.roles(NebaColor.success);
      expect(tester.widget<NebaCitationMark>(mark()).roles.soft, roles.soft);
      expect(tester.widget<Text>(find.text('1')).style?.color, roles.onTint);
    });
  });

  group('the preview', () {
    testWidgets('uncovers the source when the pointer rests on the mark', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaInlineCitation(
          index: 2,
          title: const Text('Design language'),
          site: const Text('example.com'),
          description: const Text('A Neba surface is a sheet of cut acrylic.'),
          href: Uri.parse('https://example.com/design'),
          onPressed: () {},
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(mark()));
      await tester.pump(const Duration(milliseconds: 700));
      await settle(tester);

      expect(find.text('Design language'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('A Neba surface is a sheet of cut acrylic.'), findsOneWidget);
      // The title is a link to the same place.
      expect(find.byType(NebaTextLink), findsOneWidget);
    });

    testWidgets('opens its preview from the keyboard when there is no link', (
      WidgetTester tester,
    ) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(
        tester,
        NebaInlineCitation(index: 2, title: const Text('Design language'), focusNode: focus),
      );
      focus.requestFocus();
      await tester.pump(const Duration(milliseconds: 700));
      await settle(tester);

      expect(find.text('Design language'), findsOneWidget);
      expect(find.byType(NebaTextLink), findsNothing);
    });

    testWidgets('opens its preview from the keyboard on a link too', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);

      await pump(
        tester,
        NebaInlineCitation(
          index: 2,
          title: const Text('Design language'),
          href: Uri.parse('https://example.com/design'),
          onPressed: () {},
          focusNode: focus,
        ),
      );
      focus.requestFocus();
      await tester.pump(const Duration(milliseconds: 700));
      await settle(tester);

      expect(find.text('Design language'), findsOneWidget);
    });

    testWidgets('is a bare mark when there is nothing to preview', (WidgetTester tester) async {
      await pump(
        tester,
        NebaInlineCitation(index: 2, href: Uri.parse('https://example.com/a'), onPressed: () {}),
      );

      expect(find.byType(NebaHoverCard), findsNothing);
    });

    testWidgets('is a bare mark when the preview is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaInlineCitation(index: 2, title: Text('Design language'), preview: false),
      );

      expect(find.byType(NebaHoverCard), findsNothing);
    });
  });
}
