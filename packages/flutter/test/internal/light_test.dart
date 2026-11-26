// The light on a surface: the pointer spotlight, the release afterglow, the
// focus ring and the ink, and how each of them moves.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';

import '../support/host.dart';

void main() {
  final ValueNotifier<Offset?> pointer = ValueNotifier<Offset?>(null);
  const NebaGlowColors colors = NebaGlowColors(glow: Color(0x29FFFFFF), flash: Color(0x38FFFFFF));

  Widget glow(NebaInteraction interaction, {bool disableAnimations = false}) {
    return host(
      SizedBox(
        width: 100,
        height: 40,
        child: NebaGlow(interaction: interaction, pointer: pointer, colors: colors),
      ),
      disableAnimations: disableAnimations,
    );
  }

  List<double> opacities(WidgetTester tester) {
    return tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((Opacity layer) => layer.opacity)
        .toList();
  }

  testWidgets('lights white over a fill and with the family wash elsewhere', (
    WidgetTester tester,
  ) async {
    final NebaTokens tokens = NebaTokens.light();

    expect(
      NebaGlowColors.of(tokens, NebaColor.primary, NebaVariant.solid),
      NebaGlowColors(glow: tokens.glowOnFill, flash: tokens.flashOnFill),
    );
    expect(
      NebaGlowColors.of(tokens, NebaColor.danger, NebaVariant.outline),
      NebaGlowColors(
        glow: tokens.roles(NebaColor.danger).soft,
        flash: tokens.roles(NebaColor.danger).softPress,
      ),
    );
  });

  testWidgets('the spotlight fades in over 240ms on hover', (WidgetTester tester) async {
    await tester.pumpWidget(glow(const NebaInteraction()));
    expect(opacities(tester), <double>[0, 0]);

    await tester.pumpWidget(glow(const NebaInteraction(hovered: true)));
    await tester.pump(const Duration(milliseconds: 120));
    expect(opacities(tester).first, inExclusiveRange(0, 1));

    await tester.pump(const Duration(milliseconds: 130));
    expect(opacities(tester).first, 1);
  });

  testWidgets('the afterglow lands on the press and drains over 900ms', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(glow(const NebaInteraction()));
    await tester.pumpWidget(glow(const NebaInteraction(pressed: true)));
    await tester.pump();
    expect(opacities(tester).last, 1);

    await tester.pumpWidget(glow(const NebaInteraction()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(opacities(tester).last, inExclusiveRange(0, 1));

    await tester.pump(const Duration(milliseconds: 510));
    expect(opacities(tester).last, 0);
  });

  testWidgets('draws no light for a reader who asked for less motion', (WidgetTester tester) async {
    await tester.pumpWidget(
      glow(const NebaInteraction(hovered: true, pressed: true), disableAnimations: true),
    );

    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('the focus ring changes colour and never the size of what it rings', (
    WidgetTester tester,
  ) async {
    Widget ring(bool visible) {
      return host(
        const Center(
          child: NebaFocusRing(
            visible: false,
            color: Color(0xFF3355FF),
            child: SizedBox(width: 80, height: 32),
          ),
        ),
      );
    }

    await tester.pumpWidget(ring(false));
    final Size before = tester.getSize(find.byType(NebaFocusRing));
    await tester.pumpWidget(ring(true));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(NebaFocusRing)), before);
  });

  testWidgets('ink lands in zero time on a press and eases otherwise', (WidgetTester tester) async {
    Widget ink(Color color, {bool instant = false}) {
      return host(NebaInk(color: color, instant: instant, child: const Text('Save')));
    }

    Color inkOf() => tester
        .widget<DefaultTextStyle>(
          find.ancestor(of: find.text('Save'), matching: find.byType(DefaultTextStyle)).first,
        )
        .style
        .color!;

    await tester.pumpWidget(ink(const Color(0xFF000000)));
    await tester.pumpWidget(ink(const Color(0xFFFFFFFF), instant: true));
    await tester.pump();
    expect(inkOf(), const Color(0xFFFFFFFF));

    await tester.pumpWidget(ink(const Color(0xFF000000)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(inkOf(), isNot(const Color(0xFF000000)));

    await tester.pumpAndSettle();
    expect(inkOf(), const Color(0xFF000000));
  });
}
