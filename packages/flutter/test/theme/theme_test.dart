// How a widget finds its tokens and its defaults, with and without a provider.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/color.dart' show contrastRatio;

import '../support/host.dart';

void main() {
  Future<BuildContext> contextIn(
    WidgetTester tester,
    Widget Function(Widget) wrap, {
    Brightness brightness = Brightness.light,
    bool highContrast = false,
  }) async {
    late BuildContext captured;

    await tester.pumpWidget(
      host(
        wrap(
          Builder(
            builder: (BuildContext context) {
              captured = context;

              return const SizedBox();
            },
          ),
        ),
        brightness: brightness,
        highContrast: highContrast,
      ),
    );

    return captured;
  }

  Widget bare(Widget child) => child;

  group('NebaTheme.of', () {
    testWidgets('follows the platform brightness with nothing in the tree', (
      WidgetTester tester,
    ) async {
      final BuildContext light = await contextIn(tester, bare);
      expect(NebaTheme.of(light), NebaTokens.light());

      final BuildContext dark = await contextIn(tester, bare, brightness: Brightness.dark);
      expect(NebaTheme.of(dark), NebaTokens.dark());
    });

    testWidgets('makes the sheets opaque when the platform asks for high contrast', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await contextIn(tester, bare, highContrast: true);
      final NebaTokens tokens = NebaTheme.of(context);

      expect(tokens.backing, tokens.surface);
      expect(tokens.panel.a, 1);
      expect(tokens.blurSigma, 0);
      expect(identical(tokens, NebaTheme.of(context)), isTrue);
    });
  });

  group('NebaProvider', () {
    testWidgets('pins the colour scheme against the platform', (WidgetTester tester) async {
      final BuildContext context = await contextIn(
        tester,
        (Widget child) => NebaProvider(colorScheme: NebaColorScheme.dark, child: child),
      );

      expect(NebaTheme.of(context).brightness, Brightness.dark);
    });

    testWidgets('uses a product\'s own tokens for the scheme it resolves to', (
      WidgetTester tester,
    ) async {
      final NebaTokens brand = NebaTokens.light().withFamily(
        NebaColor.primary,
        NebaTokens.light().families[NebaColor.primary]!.copyWith(accent: const Color(0xFF00897B)),
      );
      final BuildContext context = await contextIn(
        tester,
        (Widget child) => NebaProvider(light: brand, child: child),
      );

      expect(NebaTheme.of(context).roles(NebaColor.primary).accent, const Color(0xFF00897B));
      expect(
        NebaTheme.of(context).roles(NebaColor.primary).ring,
        isNot(NebaTokens.light().roles(NebaColor.primary).ring),
      );
    });

    testWidgets('keeps the defaults an outer provider set and it did not', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await contextIn(
        tester,
        (Widget child) => NebaProvider(
          defaults: const NebaDefaults(size: NebaSize.lg, density: NebaDensity.compact),
          child: NebaProvider(
            defaults: const NebaDefaults(size: NebaSize.sm),
            child: child,
          ),
        ),
      );

      expect(NebaTheme.defaultsOf(context).size, NebaSize.sm);
      expect(NebaTheme.defaultsOf(context).density, NebaDensity.compact);
    });

    testWidgets('sets the direction only when asked to', (WidgetTester tester) async {
      final BuildContext rtl = await contextIn(
        tester,
        (Widget child) => NebaProvider(textDirection: TextDirection.rtl, child: child),
      );
      expect(Directionality.of(rtl), TextDirection.rtl);

      final BuildContext kept = await contextIn(
        tester,
        (Widget child) => NebaProvider(child: child),
      );
      expect(Directionality.of(kept), TextDirection.ltr);
    });
  });

  group('NebaTokens', () {
    test('derives again from a changed base token', () {
      final NebaTokens light = NebaTokens.light();
      final NebaTokens dimmer = light.copyWith(fillAlpha: 0.5);

      expect(dimmer.roles(NebaColor.primary).fill.a, closeTo(0.5, 1e-9));
      expect(light.roles(NebaColor.primary).fill.a, closeTo(0.88, 1e-9));
    });

    test('gives no shadow at elevation 0 and a deeper one at every step', () {
      final NebaTokens tokens = NebaTokens.light();

      expect(tokens.elevation(0), isEmpty);

      for (int level = 1; level < 4; level++) {
        expect(
          tokens.elevation(level + 1).last.blurRadius,
          greaterThan(tokens.elevation(level).last.blurRadius),
        );
      }
    });

    test('keeps every family\'s ink readable on its fill over a white page', () {
      final NebaTokens tokens = NebaTokens.light();

      for (final NebaColor color in NebaColor.values) {
        final NebaColorRoles roles = tokens.roles(color);
        final Color over = Color.alphaBlend(roles.fill, const Color(0xFFFFFFFF));

        expect(
          contrastRatio(roles.onSolid, over),
          greaterThanOrEqualTo(4.5),
          reason: '${color.name} on its fill',
        );
      }
    });
  });
}
