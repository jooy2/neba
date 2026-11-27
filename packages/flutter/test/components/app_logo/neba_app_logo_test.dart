import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

/// A one-pixel PNG, so a picture loads without a file.
final Uint8List _pixel = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  Future<void> pump(WidgetTester tester, Widget logo) {
    return tester.pumpWidget(host(Center(child: logo)));
  }

  NebaTokens tokensOf(WidgetTester tester) =>
      NebaTheme.of(tester.element(find.byType(NebaAppLogo)));

  group('mark', () {
    testWidgets('sets the name as a logotype at the control height with nothing to draw', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAppLogo(name: 'Neba'));

      expect(find.text('Neba'), findsOneWidget);
      expect(find.byType(NebaSheet), findsNothing);
      expect(tester.getSize(find.byType(NebaAppLogo)).height, NebaScale.controlHeight[NebaSize.md]);
    });

    testWidgets('sets the initials on a tile, a square at the control height', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaAppLogo(name: 'Acme Corp', shape: NebaAppLogoShape.app));

      expect(find.text('AC'), findsOneWidget);
      final double side = NebaScale.controlHeight[NebaSize.md]!;
      expect(tester.getSize(find.byType(NebaSheet)), Size.square(side));
      expect(
        tester.widget<NebaSheet>(find.byType(NebaSheet)).borderRadius,
        BorderRadius.circular(NebaAppLogo.tileRadius[NebaSize.md]!),
      );

      await pump(
        tester,
        const NebaAppLogo(name: 'Acme Corp', shape: NebaAppLogoShape.circle, initials: 'A'),
      );
      expect(find.text('A'), findsOneWidget);
      expect(
        tester.widget<NebaSheet>(find.byType(NebaSheet)).borderRadius,
        BorderRadius.circular(side / 2),
      );
    });

    testWidgets('fills a tile by its variant in the family', (WidgetTester tester) async {
      await pump(tester, const NebaAppLogo(name: 'N', shape: NebaAppLogoShape.app));
      final NebaColorRoles primary = tokensOf(tester).roles(NebaColor.primary);
      NebaSheet sheet() => tester.widget<NebaSheet>(find.byType(NebaSheet));

      expect(sheet().fill, primary.fill);

      await pump(
        tester,
        const NebaAppLogo(
          name: 'N',
          shape: NebaAppLogoShape.app,
          variant: NebaVariant.outline,
          color: NebaColor.info,
        ),
      );
      final NebaColorRoles info = tokensOf(tester).roles(NebaColor.info);
      expect(sheet().fill, info.panel);
      expect(sheet().edge, info.line);
    });

    testWidgets('lays a drawing out at 72% of a padded tile, and at all of it unpadded', (
      WidgetTester tester,
    ) async {
      const Widget drawing = AspectRatio(aspectRatio: 1, child: SizedBox.expand(key: Key('art')));
      final double side = NebaScale.controlHeight[NebaSize.lg]!;

      await pump(
        tester,
        const NebaAppLogo(
          name: 'Neba',
          shape: NebaAppLogoShape.app,
          size: NebaSize.lg,
          child: drawing,
        ),
      );
      expect(tester.getSize(find.byKey(const Key('art'))).height, closeTo(side * 0.72, 0.01));

      await pump(
        tester,
        const NebaAppLogo(
          name: 'Neba',
          shape: NebaAppLogoShape.app,
          size: NebaSize.lg,
          padded: false,
          child: drawing,
        ),
      );
      expect(tester.getSize(find.byKey(const Key('art'))).height, side);
    });

    testWidgets('takes a height of its own in place of the size\'s', (WidgetTester tester) async {
      await pump(tester, const NebaAppLogo(name: 'N', shape: NebaAppLogoShape.app, height: 56));

      expect(tester.getSize(find.byType(NebaSheet)), const Size.square(56));
    });

    testWidgets('draws a picture at the mark\'s height', (WidgetTester tester) async {
      await pump(tester, NebaAppLogo(name: 'Acme', image: MemoryImage(_pixel)));

      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.height, NebaScale.controlHeight[NebaSize.md]);
      expect(image.fit, BoxFit.contain);
    });

    testWidgets('sets the name beside a mark when asked', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAppLogo(name: 'Neba Studio', shape: NebaAppLogoShape.app, showName: true),
      );

      expect(find.text('NS'), findsOneWidget);
      expect(find.text('Neba Studio'), findsOneWidget);
    });
  });

  group('semantics', () {
    testWidgets('reads as the name it shows, and a picture as its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaAppLogo(name: 'Neba'));
      expect(tester.getSemantics(find.byType(NebaAppLogo)), matchesSemantics(label: 'Neba'));

      await pump(
        tester,
        NebaAppLogo(name: 'Acme', semanticLabel: 'Acme home', image: MemoryImage(_pixel)),
      );
      expect(
        tester.getSemantics(find.byType(NebaAppLogo)),
        matchesSemantics(isImage: true, label: 'Acme home'),
      );

      semantics.dispose();
    });

    testWidgets('is a link to a safe address when it does something', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;

      await pump(
        tester,
        NebaAppLogo(name: 'Neba', onPressed: () => presses++, href: Uri.parse('/')),
      );

      expect(
        tester.getSemantics(find.byType(NebaAppLogo)),
        matchesSemantics(
          isLink: true,
          label: 'Neba',
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byType(NebaAppLogo)).getSemanticsData().linkUrl,
        Uri.parse('/'),
      );

      await tester.tap(find.byType(NebaAppLogo));
      expect(presses, 1);

      semantics.dispose();
    });

    testWidgets('rings for keyboard focus and follows on Enter', (WidgetTester tester) async {
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
      int presses = 0;

      await pump(tester, NebaAppLogo(name: 'Neba', onPressed: () => presses++, focusNode: focus));
      focus.requestFocus();
      await tester.pump();
      await tester.pump();

      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).visible, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(presses, 1);
    });
  });
}
