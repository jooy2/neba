// NebaAlert: the suite the React package runs on Alert, asked the way Flutter
// asks it — the sheet it is drawn on, where each part lands, the ink each
// part is set in and the semantics it builds — rather than the elements and
// classes it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles info = tokens.roles(NebaColor.info);

  void noop() {}

  Future<void> pump(WidgetTester tester, Widget alert, {double width = 480}) {
    return tester.pumpWidget(
      host(
        Center(
          child: SizedBox(width: width, child: alert),
        ),
      ),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet).first);

  Rect sheetRect(WidgetTester tester) => tester.getRect(find.byType(NebaSheet).first);

  Rect rectOf(WidgetTester tester, String text) => tester.getRect(find.text(text));

  Color inkOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!
        .color!;
  }

  Finder glyph([List<NebaGlyphPart>? parts]) => find.byWidgetPredicate(
    (Widget widget) =>
        widget is NebaGlyph &&
        !identical(widget.parts, NebaGlyphs.close) &&
        (parts == null || identical(widget.parts, parts)),
  );

  Finder dismissButton() => find.byWidgetPredicate(
    (Widget widget) => widget is NebaGlyph && identical(widget.parts, NebaGlyphs.close),
  );

  SemanticsRole regionRole(WidgetTester tester) {
    return tester.widget<NebaLiveRegion>(find.byType(NebaLiveRegion)).role;
  }

  // The sheet's padding and its hairline, at `md`.
  const double inset = 16 + 1;
  // `md`: the body's 13 on 22, the title's 15 on 20, 4 between them.
  const double line = 22;

  group('rendering', () {
    testWidgets('renders its message in a live region', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAlert(child: Text('Everything is fine.')));

      expect(
        tester.getSemantics(find.byType(NebaLiveRegion)),
        matchesSemantics(label: 'Everything is fine.', isLiveRegion: true),
      );
      semantics.dispose();
    });

    testWidgets('renders a title above the message', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(title: Text('Deploy failed'), child: Text('The build exited with 1.')),
      );

      final Rect title = rectOf(tester, 'Deploy failed');
      final Rect message = rectOf(tester, 'The build exited with 1.');

      expect(title.bottom, lessThanOrEqualTo(message.top));
      expect(title.left, message.left);
    });

    testWidgets('reflects a changed message on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(child: Text('Before')));
      await pump(tester, const NebaAlert(child: Text('After')));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('takes the width it is given', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(child: Text('Saved')), width: 320);

      expect(sheetRect(tester).width, 320);
    });

    testWidgets('wraps a long message under itself rather than under the glyph', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAlert(
          child: Text('A message long enough to wrap onto a second line and then a third.'),
        ),
        width: 240,
      );

      final Rect message = rectOf(
        tester,
        'A message long enough to wrap onto a second line and then a third.',
      );

      expect(message.height, greaterThan(line));
      expect(message.left, greaterThan(tester.getRect(glyph()).right));
    });
  });

  group('icon', () {
    testWidgets('draws the glyph of its severity by default', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(child: Text('Saved')));

      expect(glyph(NebaGlyphs.note), findsOneWidget);
    });

    testWidgets('drops the glyph when asked', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(showIcon: false, child: Text('Saved')));

      expect(glyph(), findsNothing);
      expect(rectOf(tester, 'Saved').left - sheetRect(tester).left, inset);
    });

    testWidgets('takes a glyph of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(
          icon: SizedBox.square(key: Key('mine'), dimension: 10),
          child: Text('Saved'),
        ),
      );

      expect(find.byKey(const Key('mine')), findsOneWidget);
      expect(glyph(), findsNothing);
    });

    // The severity has to be in the shape as well as in the colour: an alert
    // that says "this went wrong" only in red says it only to some readers.
    testWidgets('draws a different glyph per severity', (WidgetTester tester) async {
      final Map<NebaColor, List<NebaGlyphPart>> shapes = <NebaColor, List<NebaGlyphPart>>{
        NebaColor.primary: NebaGlyphs.note,
        NebaColor.secondary: NebaGlyphs.note,
        NebaColor.info: NebaGlyphs.note,
        NebaColor.success: NebaGlyphs.success,
        NebaColor.warning: NebaGlyphs.warning,
        NebaColor.danger: NebaGlyphs.danger,
      };

      for (final MapEntry<NebaColor, List<NebaGlyphPart>> entry in shapes.entries) {
        await pump(tester, NebaAlert(color: entry.key, child: const Text('Saved')));

        expect(glyph(entry.value), findsOneWidget, reason: entry.key.name);
      }
    });

    testWidgets('sizes its glyph at 1.2 times the message and hands that size down', (
      WidgetTester tester,
    ) async {
      double? handed;

      await pump(
        tester,
        NebaAlert(
          icon: Builder(
            builder: (BuildContext context) {
              handed = IconTheme.of(context).size;

              return const SizedBox.square(dimension: 10);
            },
          ),
          child: const Text('Saved'),
        ),
      );
      expect(handed, closeTo(13 * 1.2, 0.001));

      await pump(tester, const NebaAlert(child: Text('Saved')));
      expect(tester.getSize(glyph()).width, closeTo(13 * 1.2, 0.001));
    });

    testWidgets('centres the glyph on the first line of the message', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(
          child: Text('A message long enough to wrap onto a second line and then a third.'),
        ),
        width: 240,
      );

      expect(tester.getCenter(glyph()).dy, sheetRect(tester).top + inset + line / 2);
    });
  });

  group('live region', () {
    testWidgets('waits for a pause on an informational alert', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(color: NebaColor.info, child: Text('Saved')));

      expect(regionRole(tester), SemanticsRole.status);
    });

    testWidgets('interrupts on a warning or an error', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(color: NebaColor.danger, child: Text('It broke')));
      expect(regionRole(tester), SemanticsRole.alert);

      await pump(tester, const NebaAlert(color: NebaColor.warning, child: Text('Careful')));
      expect(regionRole(tester), SemanticsRole.alert);
    });

    testWidgets('picks the region by severity for every family', (WidgetTester tester) async {
      for (final NebaColor color in NebaColor.values) {
        await pump(tester, NebaAlert(color: color, child: const Text('Saved')));

        expect(regionRole(tester), NebaAlert.rolesFor[color], reason: color.name);
      }
    });

    testWidgets('lets the caller override the role', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(
          color: NebaColor.danger,
          role: SemanticsRole.status,
          child: Text('It broke'),
        ),
      );

      expect(regionRole(tester), SemanticsRole.status);
    });

    testWidgets('is no live region at all when the role is none', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAlert(role: SemanticsRole.none, child: Text('Saved')));

      expect(tester.getSemantics(find.byType(NebaLiveRegion)), matchesSemantics(label: 'Saved'));
      semantics.dispose();
    });

    // The whole alert was the live region, so every announcement ended with
    // the names of the buttons in it.
    testWidgets('leaves the action and the dismiss button out of what is announced', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaAlert(
          color: NebaColor.danger,
          title: const Text('Deploy failed'),
          action: NebaButton(onPressed: noop, child: const Text('Retry')),
          onClose: noop,
          child: const Text('The build exited with 1.'),
        ),
      );

      final SemanticsNode region = tester.getSemantics(find.byType(NebaLiveRegion));
      expect(region.label, 'Deploy failed\nThe build exited with 1.');

      bool holds(SemanticsNode node, String label) {
        bool found = node.label == label;

        node.visitChildren((SemanticsNode child) {
          found = found || holds(child, label);

          return !found;
        });

        return found;
      }

      expect(holds(region, 'Retry'), isFalse);
      expect(holds(region, 'Dismiss'), isFalse);
      expect(find.bySemanticsLabel('Retry'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('dismissing', () {
    testWidgets('shows the dismiss button only when onClose is given', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(child: Text('Saved')));
      expect(dismissButton(), findsNothing);

      await pump(tester, NebaAlert(onClose: noop, child: const Text('Saved')));
      expect(dismissButton(), findsOneWidget);
    });

    testWidgets('calls onClose when pressed', (WidgetTester tester) async {
      int closed = 0;

      await pump(tester, NebaAlert(onClose: () => closed += 1, child: const Text('Saved')));
      await tester.tap(dismissButton());

      expect(closed, 1);
    });

    testWidgets('is a button named in the default word', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaAlert(onClose: noop, child: const Text('Saved')));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Dismiss')),
        matchesSemantics(
          label: 'Dismiss',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('takes a custom accessible name for the dismiss button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaAlert(onClose: noop, closeLabel: 'Hide this notice', child: const Text('Saved')),
      );

      expect(find.bySemanticsLabel('Hide this notice'), findsOneWidget);
      semantics.dispose();
    });

    // Drawn at the size of the text beside it, pressed at the size of a
    // finger.
    testWidgets('is drawn at the size of the text and pressed across 24 pixels', (
      WidgetTester tester,
    ) async {
      int closed = 0;

      await pump(tester, NebaAlert(onClose: () => closed += 1, child: const Text('Saved')));

      final Rect button = tester.getRect(
        find.ancestor(of: dismissButton(), matching: find.byType(SizedBox)).first,
      );
      expect(button.width, closeTo(13 * 1.15, 0.001));

      await tester.tapAt(button.center + const Offset(11.5, 0));
      await tester.tapAt(button.center + const Offset(0, -11.5));
      expect(closed, 2);

      await tester.tapAt(button.center + const Offset(12.5, 0));
      expect(closed, 2);
    });

    testWidgets('is reached and pressed from the keyboard', (WidgetTester tester) async {
      int closed = 0;

      await pump(tester, NebaAlert(onClose: () => closed += 1, child: const Text('Saved')));

      Focus.of(tester.element(dismissButton())).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(closed, 1);
    });

    testWidgets('pins the dismiss button to the end of the first line', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaAlert(
          onClose: noop,
          child: const Text('A message long enough to wrap onto a second line and then a third.'),
        ),
        width: 240,
      );

      final Rect button = tester.getRect(
        find.ancestor(of: dismissButton(), matching: find.byType(SizedBox)).first,
      );

      expect(sheetRect(tester).right - button.right, closeTo(inset, 0.001));
      expect(button.center.dy, sheetRect(tester).top + inset + line / 2);
    });
  });

  group('action', () {
    testWidgets('renders the action beside the message and presses it', (
      WidgetTester tester,
    ) async {
      int retried = 0;

      await pump(
        tester,
        NebaAlert(
          action: NebaButton(onPressed: () => retried += 1, child: const Text('Retry')),
          child: const Text('It failed'),
        ),
      );
      await tester.tap(find.text('Retry'));

      expect(retried, 1);
      expect(rectOf(tester, 'Retry').left, greaterThan(rectOf(tester, 'It failed').right));
    });

    testWidgets('stays on the first line, before the dismiss button', (WidgetTester tester) async {
      await pump(
        tester,
        NebaAlert(
          action: NebaButton(onPressed: noop, size: NebaSize.xs, child: const Text('Retry')),
          onClose: noop,
          child: const Text('A message long enough to wrap onto a second line and then a third.'),
        ),
        width: 320,
      );

      final Rect action = tester.getRect(find.byType(NebaButton));

      expect(action.center.dy, sheetRect(tester).top + inset + line / 2);
      expect(action.right, lessThan(tester.getRect(dismissButton()).left));
    });

    testWidgets('lets an action taller than the line stand out of it', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(
          action: SizedBox(key: Key('tall'), width: 40, height: 30),
          child: Text('Saved'),
        ),
      );

      // Centred on the line rather than pushing it, as CSS lets it overflow.
      expect(
        tester.getCenter(find.byKey(const Key('tall'))).dy,
        sheetRect(tester).top + inset + line / 2,
      );
      expect(sheetRect(tester).height, 2 * inset + line);
    });
  });

  group('style props', () {
    testWidgets('is an outline alert in the info family by default', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(child: Text('Saved')));

      expect(sheetOf(tester).fill, info.panel);
      expect(sheetOf(tester).edge, info.line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('maps colour and elevation onto the sheet', (WidgetTester tester) async {
      final NebaColorRoles warning = tokens.roles(NebaColor.warning);

      await pump(
        tester,
        const NebaAlert(
          variant: NebaVariant.solid,
          color: NebaColor.warning,
          elevation: 2,
          child: Text('Careful'),
        ),
      );

      expect(sheetOf(tester).fill, warning.fill);
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(sheetOf(tester).elevation, 2);

      await pump(
        tester,
        const NebaAlert(color: NebaColor.warning, elevation: 2, child: Text('Careful')),
      );
      expect(sheetOf(tester).fill, warning.panel);
      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('lays a text alert on the wash alone, with no plate and no shadow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAlert(variant: NebaVariant.text, elevation: 2, child: Text('Saved')),
      );

      expect(sheetOf(tester).fill, info.soft);
      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).elevation, 0);
      expect(sheetOf(tester).blur, isFalse);
      expect(sheetOf(tester).texture, isFalse);
    });

    testWidgets('sets the message in the body ink and the title in the accent', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAlert(child: Text('Saved')));
      expect(inkOf(tester, 'Saved'), tokens.fg);

      await pump(
        tester,
        const NebaAlert(title: Text('Deploy failed'), child: Text('The build exited with 1.')),
      );
      expect(inkOf(tester, 'Deploy failed'), info.accent);
      expect(inkOf(tester, 'The build exited with 1.'), tokens.mutedFg);
    });

    testWidgets('sets everything on a solid alert in one ink', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(
          variant: NebaVariant.solid,
          title: Text('Deploy failed'),
          child: Text('The build exited with 1.'),
        ),
      );

      expect(inkOf(tester, 'Deploy failed'), info.onSolid);
      expect(inkOf(tester, 'The build exited with 1.'), info.onSolid);
    });

    testWidgets('sets the title and the message on the sheet type ladder', (
      WidgetTester tester,
    ) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(
          tester,
          NebaAlert(size: size, title: const Text('Failed'), child: const Text('Exit 1')),
        );

        final double padding = NebaBox.padding[NebaDensity.standard]![size]!;

        expect(rectOf(tester, 'Failed').height, NebaScale.sheetTitleLeading[size]);
        expect(rectOf(tester, 'Exit 1').height, NebaScale.sheetBodyLeading[size]);
        expect(
          sheetRect(tester).height,
          2 * (padding + 1) +
              NebaScale.sheetTitleLeading[size]! +
              NebaScale.sheetHeaderGap[size]! +
              NebaScale.sheetBodyLeading[size]!,
          reason: size.name,
        );
      }
    });

    testWidgets('is as tall as its padding and one line when it is one line', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAlert(child: Text('Saved')));

      expect(sheetRect(tester).height, 2 * inset + line);
    });

    testWidgets('changes padding with density', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAlert(density: NebaDensity.compact, showIcon: false, child: Text('Saved')),
      );

      expect(rectOf(tester, 'Saved').left - sheetRect(tester).left, 10 + 1);
      expect(rectOf(tester, 'Saved').top - sheetRect(tester).top, 10 + 1);
    });

    testWidgets('takes its defaults from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(
              size: NebaSize.lg,
              density: NebaDensity.compact,
              variant: NebaVariant.solid,
            ),
            child: Center(
              child: SizedBox(width: 480, child: NebaAlert(child: Text('Saved'))),
            ),
          ),
        ),
      );

      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(rectOf(tester, 'Saved').height, NebaScale.sheetBodyLeading[NebaSize.lg]);
      expect(sheetRect(tester).height, 2 * 12 + NebaScale.sheetBodyLeading[NebaSize.lg]!);
    });

    testWidgets('keeps its glyph on the first line when the text is scaled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Builder(
            builder: (BuildContext context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
                child: const Center(
                  child: SizedBox(width: 480, child: NebaAlert(child: Text('Saved'))),
                ),
              );
            },
          ),
        ),
      );

      expect(tester.getSize(glyph()).width, closeTo(26 * 1.2, 0.001));
      expect(tester.getCenter(glyph()).dy, rectOf(tester, 'Saved').center.dy);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(
        tester,
        NebaAlert(
          title: const Text('Deploy failed'),
          onClose: noop,
          action: NebaButton(onPressed: noop, child: const Text('Retry')),
          child: const Text('The build exited with 1.'),
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(dismissButton()));
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaAlert), matching: find.byType(Transform)),
        findsNothing,
      );
      await press.up();
    });
  });

  group('transition', () {
    testWidgets('arrives by its transition', (WidgetTester tester) async {
      await pump(tester, const NebaAlert(transition: NebaTransition.fade(), child: Text('Saved')));

      final Finder fade = find.ancestor(of: find.byType(NebaSheet), matching: find.byType(Opacity));
      expect(tester.widget<Opacity>(fade.first).opacity, 0);

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(fade.first).opacity, 1);
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('names the dismiss button in the language it was given', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        NebaAlert(onClose: noop, locale: const Locale('ko'), child: const Text('저장하지 못했습니다')),
      );

      expect(find.bySemanticsLabel('알림 닫기'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a word of its own over the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        NebaAlert(
          onClose: noop,
          locale: const Locale('ko'),
          closeLabel: 'Dismiss',
          child: const Text('저장하지 못했습니다'),
        ),
      );

      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      semantics.dispose();
    });
  });
}
