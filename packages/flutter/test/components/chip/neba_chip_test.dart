// NebaChip: the suite the React package runs on Chip, asked the way Flutter
// asks it — the sheet, the size and the semantics it builds, and what a press
// and a key do — rather than the elements and classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  void noop() {}

  Future<void> pump(WidgetTester tester, Widget chip, {double width = 800}) {
    return tester.pumpWidget(host(Center(child: chip), width: width));
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  Size sizeOf(WidgetTester tester) => tester.getSize(find.byType(NebaSheet));

  Finder deleteButton() => find.byWidgetPredicate(
    (Widget widget) => widget is NebaGlyph && identical(widget.parts, NebaGlyphs.close),
  );

  group('rendering', () {
    testWidgets('renders its label', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('design-system')));

      expect(find.text('design-system'), findsOneWidget);
    });

    testWidgets('is plain text until it is given something to do', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaChip(child: Text('Draft')));

      expect(
        tester.getSemantics(find.text('Draft')),
        matchesSemantics(label: 'Draft', textDirection: TextDirection.ltr),
      );
      expect(
        find.descendant(of: find.byType(NebaChip), matching: find.byType(FocusableActionDetector)),
        findsNothing,
      );
      semantics.dispose();
    });

    testWidgets('becomes a button when it can be pressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaChip(onPressed: noop, child: const Text('Draft')));

      expect(
        tester.getSemantics(find.text('Draft')),
        matchesSemantics(
          label: 'Draft',
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

    testWidgets('reflects a changed label on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('Draft')));
      await pump(tester, const NebaChip(child: Text('Published')));

      expect(find.text('Published'), findsOneWidget);
    });

    testWidgets('cuts a long label short instead of overflowing', (WidgetTester tester) async {
      await pump(
        tester,
        const SizedBox(
          width: 80,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: NebaChip(child: Text('a label far longer than the room it is given')),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(sizeOf(tester).width, lessThanOrEqualTo(80));
      expect(tester.widget<RichText>(find.byType(RichText)).overflow, TextOverflow.ellipsis);
    });
  });

  group('count', () {
    testWidgets('renders a count beside the label', (WidgetTester tester) async {
      await pump(tester, const NebaChip(count: Text('12'), child: Text('Errors')));

      expect(find.text('12'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('12')).dx,
        greaterThan(tester.getTopRight(find.text('Errors')).dx),
      );
    });

    testWidgets('renders a count of zero rather than dropping it', (WidgetTester tester) async {
      await pump(tester, const NebaChip(count: Text('0'), child: Text('Errors')));

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('draws no plate when there is no count', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('Errors')));

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius == BorderRadius.circular(999),
        ),
        findsNothing,
      );
    });
  });

  group('delete', () {
    testWidgets('shows the × only when onDelete is given', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('typescript')));
      expect(deleteButton(), findsNothing);

      await pump(tester, NebaChip(onDelete: noop, child: const Text('typescript')));
      expect(deleteButton(), findsOneWidget);
    });

    testWidgets('calls onDelete when the × is pressed', (WidgetTester tester) async {
      int deleted = 0;

      await pump(tester, NebaChip(onDelete: () => deleted += 1, child: const Text('typescript')));
      await tester.tap(deleteButton());

      expect(deleted, 1);
    });

    testWidgets('takes a press on the room around the ×, the chip\'s height and its end', (
      WidgetTester tester,
    ) async {
      int deleted = 0;

      await pump(tester, NebaChip(onDelete: () => deleted += 1, child: const Text('typescript')));

      final Rect glyph = tester.getRect(deleteButton());
      final Rect chip = tester.getRect(find.byType(NebaSheet));
      await tester.tapAt(Offset(chip.right - 2, chip.top + 2));
      await tester.tapAt(Offset(glyph.center.dx, chip.bottom - 2));

      expect(deleted, 2);
    });

    testWidgets('does not also fire the chip when the chip is pressable', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      int deleted = 0;

      await pump(
        tester,
        NebaChip(
          onPressed: () => pressed += 1,
          onDelete: () => deleted += 1,
          child: const Text('typescript'),
        ),
      );
      await tester.tap(deleteButton());

      expect(deleted, 1);
      expect(pressed, 0);

      await tester.tap(find.text('typescript'));
      expect(pressed, 1);
      expect(deleted, 1);
    });

    testWidgets('takes a name of its own for the ×', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaChip(onDelete: noop, deleteLabel: 'Remove the tag', child: const Text('typescript')),
      );

      expect(find.bySemanticsLabel('Remove the tag'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('names the × after a label that is a Text', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaChip(onDelete: noop, child: const Text('  Draft ')));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Remove Draft')),
        matchesSemantics(
          label: 'Remove Draft',
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

    testWidgets('falls back to the bare word for a label that is not a Text', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaChip(
          onDelete: noop,
          child: const Row(children: <Widget>[Text('Draft')]),
        ),
      );

      expect(find.bySemanticsLabel('Remove'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('keyboard', () {
    testWidgets('reaches the label and then the ×, and Enter presses each', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      int deleted = 0;

      await pump(
        tester,
        NebaChip(
          onPressed: () => pressed += 1,
          onDelete: () => deleted += 1,
          child: const Text('typescript'),
        ),
      );

      Focus.of(tester.element(find.text('typescript'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(pressed, 1);

      // The × is the next stop after the label.
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, Focus.of(tester.element(deleteButton())));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(deleted, 1);
      expect(pressed, 1);
    });
  });

  group('state', () {
    testWidgets('says whether a pressable chip is selected once selected is passed', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      for (final bool selected in <bool>[true, false]) {
        await pump(tester, NebaChip(onPressed: noop, selected: selected, child: const Text('bug')));

        expect(
          tester.getSemantics(find.text('bug')),
          matchesSemantics(
            label: 'bug',
            isButton: true,
            isEnabled: true,
            hasEnabledState: true,
            hasSelectedState: true,
            isSelected: selected,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
          reason: '$selected',
        );
      }
      semantics.dispose();
    });

    testWidgets('is a plain button when it says nothing about being on', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaChip(onPressed: noop, child: const Text('bug')));

      // matchesSemantics holds every flag it is not given to false, the
      // selected state included.
      expect(
        tester.getSemantics(find.text('bug')),
        matchesSemantics(
          label: 'bug',
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

    testWidgets('deepens the surface when selected without changing the colour family', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles success = tokens.roles(NebaColor.success);

      await pump(
        tester,
        const NebaChip(color: NebaColor.success, selected: true, child: Text('bug')),
      );
      expect(sheetOf(tester).fill, success.panelPress);
      expect(sheetOf(tester).edge, success.lineHover);

      await pump(
        tester,
        const NebaChip(
          variant: NebaVariant.solid,
          color: NebaColor.success,
          selected: true,
          child: Text('bug'),
        ),
      );
      expect(sheetOf(tester).fill, success.fillActive);

      await pump(
        tester,
        const NebaChip(
          variant: NebaVariant.text,
          color: NebaColor.success,
          selected: true,
          child: Text('bug'),
        ),
      );
      expect(sheetOf(tester).fill, success.softPress);
    });

    testWidgets('drops the colour family when disabled', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChip(
          variant: NebaVariant.solid,
          color: NebaColor.danger,
          disabled: true,
          child: Text('Failing'),
        ),
      );
      expect(sheetOf(tester).fill, tokens.disabledBg);
      expect(sheetOf(tester).plate, NebaPlate.none);

      await pump(tester, const NebaChip(disabled: true, child: Text('Failing')));
      expect(sheetOf(tester).edge, tokens.disabledBorder);
      expect(sheetOf(tester).fill, const Color(0x00000000));
    });

    testWidgets('is not a button when disabled, even with onPressed, and its × does nothing', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int pressed = 0;
      int deleted = 0;

      await pump(
        tester,
        NebaChip(
          onPressed: () => pressed += 1,
          onDelete: () => deleted += 1,
          disabled: true,
          child: const Text('Draft'),
        ),
      );
      await tester.tap(find.text('Draft'), warnIfMissed: false);
      await tester.tap(deleteButton(), warnIfMissed: false);

      expect(pressed, 0);
      expect(deleted, 0);
      expect(
        tester.getSemantics(find.text('Draft')),
        matchesSemantics(label: 'Draft', hasEnabledState: true, textDirection: TextDirection.ltr),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Remove Draft')),
        matchesSemantics(label: 'Remove Draft', isButton: true, hasEnabledState: true),
      );
      semantics.dispose();
    });
  });

  group('style props', () {
    testWidgets('is an outline chip in the primary family by default', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('Draft')));

      expect(sheetOf(tester).fill, primary.panel);
      expect(sheetOf(tester).edge, primary.line);
      expect(sheetOf(tester).plate, NebaPlate.glass);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('maps colour and elevation onto the sheet', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChip(
          variant: NebaVariant.solid,
          color: NebaColor.danger,
          elevation: 2,
          child: Text('Failing'),
        ),
      );

      expect(sheetOf(tester).fill, tokens.roles(NebaColor.danger).fill);
      expect(sheetOf(tester).plate, NebaPlate.solid);
      expect(sheetOf(tester).elevation, 2);
    });

    testWidgets('lays a text chip on a wash with no plate and no shadow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaChip(variant: NebaVariant.text, elevation: 2, child: Text('typescript')),
      );

      expect(sheetOf(tester).fill, primary.soft);
      expect(sheetOf(tester).plate, NebaPlate.none);
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('sits one step down the control ladder, whatever the density', (
      WidgetTester tester,
    ) async {
      const Map<NebaSize, double> heights = <NebaSize, double>{
        NebaSize.xs: 22,
        NebaSize.sm: 22,
        NebaSize.md: 26,
        NebaSize.lg: 32,
        NebaSize.xl: 40,
      };

      for (final MapEntry<NebaSize, double> entry in heights.entries) {
        for (final NebaDensity density in NebaDensity.values) {
          for (final NebaVariant variant in NebaVariant.values) {
            await pump(
              tester,
              NebaChip(
                size: entry.key,
                density: density,
                variant: variant,
                child: const Text('Draft'),
              ),
            );

            expect(
              sizeOf(tester).height,
              entry.value,
              reason: '${entry.key.name} ${density.name} ${variant.name}',
            );
          }
        }
      }
    });

    testWidgets('changes its inline padding with density', (WidgetTester tester) async {
      await pump(tester, const NebaChip(child: Text('Draft')));
      final double standard = sizeOf(tester).width;

      await pump(tester, const NebaChip(density: NebaDensity.compact, child: Text('Draft')));
      final double compact = sizeOf(tester).width;

      // 12 on each side of a `sm` control, against 8.
      expect(standard - compact, 8);
    });

    testWidgets('takes its defaults from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.xl, variant: NebaVariant.solid),
            child: Center(child: NebaChip(child: Text('Draft'))),
          ),
        ),
      );

      expect(sizeOf(tester).height, 40);
      expect(sheetOf(tester).plate, NebaPlate.solid);
    });

    testWidgets('centres every part of the chip on one line', (WidgetTester tester) async {
      await pump(
        tester,
        NebaChip(
          startIcon: const SizedBox.square(dimension: 10),
          count: const Text('4'),
          onDelete: noop,
          child: const Text('Comments'),
        ),
      );

      final double centre = tester.getCenter(find.byType(NebaSheet)).dy;

      for (final Finder part in <Finder>[
        find.byWidgetPredicate((Widget w) => w is SizedBox && w.width == 10),
        find.text('Comments'),
        find.text('4'),
        deleteButton(),
      ]) {
        expect(tester.getCenter(part).dy, moreOrLessEquals(centre, epsilon: 0.5));
      }
    });

    testWidgets('sizes its icons at 1.2 times the label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChip(startIcon: NebaGlyph(<NebaGlyphPart>[]), child: Text('main')),
      );

      // A `md` chip's label is the `sm` control's 12 pixels.
      expect(tester.getSize(find.byType(NebaGlyph)), const Size.square(12 * 1.2));
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, NebaChip(onPressed: noop, child: const Text('Draft')));

      final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Draft')));
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaChip), matching: find.byType(Transform)),
        findsNothing,
      );
      await press.up();
    });
  });

  group('the pointer', () {
    testWidgets('lights only a chip that can be pressed', (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);

      await pump(tester, const NebaChip(child: Text('Draft')));
      await mouse.moveTo(tester.getCenter(find.text('Draft')));
      await tester.pumpAndSettle();
      expect(sheetOf(tester).fill, primary.panel);

      await mouse.moveTo(Offset.zero);
      await pump(tester, NebaChip(onPressed: noop, child: const Text('Draft')));
      await mouse.moveTo(tester.getCenter(find.text('Draft')));
      await tester.pumpAndSettle();
      expect(sheetOf(tester).fill, primary.panelHover);
      expect(sheetOf(tester).edge, primary.lineHover);

      await mouse.removePointer();
    });

    testWidgets('lands a press on the frame the pointer goes down', (WidgetTester tester) async {
      await pump(tester, NebaChip(onPressed: noop, child: const Text('Draft')));

      final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Draft')));
      await tester.pump();

      expect(sheetOf(tester).fill, primary.panelPress);
      expect(sheetOf(tester).pressed, isTrue);

      await press.up();
      await tester.pump();
      expect(sheetOf(tester).pressed, isFalse);
    });
  });

  group('transition', () {
    testWidgets('arrives by its transition', (WidgetTester tester) async {
      await pump(tester, const NebaChip(transition: NebaTransition.fade(), child: Text('Draft')));

      final Finder fade = find.ancestor(of: find.byType(NebaSheet), matching: find.byType(Opacity));
      expect(tester.widget<Opacity>(fade.first).opacity, 0);

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(fade.first).opacity, 1);
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('names the × in the language it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        NebaChip(onDelete: noop, locale: const Locale('ko'), child: const Text('초안')),
      );

      expect(find.bySemanticsLabel('초안 삭제'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a word of its own over the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        NebaChip(
          onDelete: noop,
          locale: const Locale('ko'),
          deleteLabel: '태그 지우기',
          child: const Text('초안'),
        ),
      );

      expect(find.bySemanticsLabel('태그 지우기'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the count plate', () {
    BoxDecoration plateOf(WidgetTester tester) {
      return tester
              .widget<DecoratedBox>(
                find.ancestor(of: find.text('12'), matching: find.byType(DecoratedBox)).first,
              )
              .decoration
          as BoxDecoration;
    }

    testWidgets('is a fill of its own on a chip that is not filled', (WidgetTester tester) async {
      for (final NebaVariant variant in <NebaVariant>[NebaVariant.outline, NebaVariant.text]) {
        await pump(
          tester,
          NebaChip(variant: variant, count: const Text('12'), child: const Text('Errors')),
        );

        expect(plateOf(tester).color, primary.fill, reason: variant.name);
      }
    });

    testWidgets('is a hole punched in the fill on one that is', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaChip(variant: NebaVariant.solid, count: Text('12'), child: Text('Errors')),
      );

      expect(plateOf(tester).color, tokens.glowOnFill);
    });
  });
}
