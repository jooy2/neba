// NebaPill: the suite the React package runs on Pill, asked the way Flutter
// asks it — the shape and the sheet it is drawn on, where each slot lands,
// what opens under it and what a press reaches — rather than the classes it
// writes.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget pill, {EdgeInsets padding = EdgeInsets.zero}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: pill),
        ),
      ),
    );
  }

  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  Color? washOver(WidgetTester tester, String text) {
    final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
      find.ancestor(of: find.text(text), matching: find.byType(DecoratedBox)),
    );

    return boxes
        .map((DecoratedBox box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((BoxDecoration decoration) => decoration.color)
        .whereType<Color>()
        .firstOrNull;
  }

  group('rendering', () {
    testWidgets('renders its content', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Recording')));

      expect(find.text('Recording'), findsOneWidget);
    });

    testWidgets('places startIcon before the content and endIcon after it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPill(
          startIcon: SizedBox(key: Key('start'), width: 8, height: 8),
          endIcon: Text('02:14'),
          title: Text('Recording'),
        ),
      );

      final double start = tester.getRect(find.byKey(const Key('start'))).left;
      final double title = tester.getRect(find.text('Recording')).left;
      final double end = tester.getRect(find.text('02:14')).left;

      expect(start, lessThan(title));
      expect(title, lessThan(end));
    });

    testWidgets('reflects changed content on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('One')));
      await pump(tester, const NebaPill(title: Text('Two')));

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });
  });

  group('shape', () {
    testWidgets('is a stadium: its corners are half the row', (WidgetTester tester) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaPill(size: size, title: const Text('Live')));

        final double height = NebaScale.controlHeight[size]!;

        expect(sheetOf(tester).borderRadius, BorderRadius.circular(height / 2));
        expect(tester.getSize(find.byType(NebaSheet)).height, height);
      }
    });

    testWidgets('keeps the corner of its row when a second line grows it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPill(title: Text('Degraded'), description: Text('EU-west is slow')),
      );

      expect(tester.getSize(find.byType(NebaSheet)).height, greaterThan(32));
      expect(sheetOf(tester).borderRadius, BorderRadius.circular(16));
    });

    testWidgets('floats by default rather than lying flat on the page', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaPill(title: Text('Live')));
      expect(sheetOf(tester).elevation, 2);

      await pump(tester, const NebaPill(elevation: 0, title: Text('Live')));
      expect(sheetOf(tester).elevation, 0);
    });

    testWidgets('sits in the flow by default', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live')), padding: const EdgeInsets.all(20));

      expect(tester.getSize(find.byType(NebaPill)), tester.getSize(find.byType(NebaSheet)));
    });

    testWidgets('hangs a pinned pill clear of its edge and the screen inset', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPill(position: NebaPosition.sticky, title: Text('Live')),
        padding: const EdgeInsets.only(top: 20, bottom: 30),
      );

      expect(
        tester.getRect(find.byType(NebaSheet)).top - tester.getRect(find.byType(NebaPill)).top,
        12 + 20,
      );

      await pump(
        tester,
        const NebaPill(
          position: NebaPosition.sticky,
          side: NebaSide.bottom,
          safeArea: false,
          title: Text('Live'),
        ),
        padding: const EdgeInsets.only(top: 20, bottom: 30),
      );

      expect(
        tester.getRect(find.byType(NebaPill)).bottom -
            tester.getRect(find.byType(NebaSheet)).bottom,
        12,
      );
    });

    testWidgets('pins itself in the overlay, centred, when fixed', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => const Column(
                  children: <Widget>[
                    NebaPill(position: NebaPosition.fixed, title: Text('Building')),
                    Text('Below'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final Rect overlay = tester.getRect(find.byType(Overlay));
      final Rect pill = tester.getRect(find.byType(NebaSheet));

      expect(tester.getRect(find.text('Below')).top, overlay.top);
      expect(pill.top, overlay.top + 12);
      expect(pill.center.dx, closeTo(overlay.center.dx, 0.5));
      expect(pill.width, lessThan(overlay.width));
    });
  });

  group('details', () {
    const Widget details = Text('Gate B14');

    testWidgets('builds nothing extra without details', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live')));

      expect(find.byType(NebaDisclosurePanel), findsNothing);
    });

    testWidgets('holds the details closed until expanded', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live'), details: details));

      expect(tester.getSize(find.byType(NebaSheet)).height, 32);
      expect(find.text('Gate B14').hitTestable(), findsNothing);

      await pump(tester, const NebaPill(title: Text('Live'), details: details, expanded: true));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaSheet)).height, greaterThan(32));
      expect(find.text('Gate B14').hitTestable(), findsOneWidget);
    });

    testWidgets('draws an expanded pill open from the first frame', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live'), details: details, expanded: true));

      expect(tester.getSize(find.byType(NebaSheet)).height, greaterThan(32));
    });

    testWidgets('is already as wide as its details while they are closed', (
      WidgetTester tester,
    ) async {
      const Widget wide = Text('A line of details far longer than the title');

      await pump(tester, const NebaPill(title: Text('Live'), details: wide));
      final double closed = tester.getSize(find.byType(NebaSheet)).width;

      await pump(tester, const NebaPill(title: Text('Live'), details: wide, expanded: true));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaSheet)).width, closed);
      expect(closed, greaterThan(tester.getSize(find.text('Live')).width + 40));
    });

    testWidgets('follows details that grow while it is open', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live'), details: details, expanded: true));
      final double one = tester.getSize(find.byType(NebaSheet)).height;

      await pump(
        tester,
        const NebaPill(
          title: Text('Live'),
          expanded: true,
          details: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[details, details]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(NebaSheet)).height, greaterThan(one));
    });

    testWidgets('tells a screen reader that pressing it reveals the details', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, NebaPill(title: const Text('Live'), details: details, onPressed: () {}));

      expect(
        tester.getSemantics(find.text('Live')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasExpandedState: true,
          isExpanded: false,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Live',
        ),
      );

      await pump(
        tester,
        NebaPill(title: const Text('Live'), details: details, expanded: true, onPressed: () {}),
      );

      expect(
        tester.getSemantics(find.text('Live')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Live',
        ),
      );

      handle.dispose();
    });

    testWidgets('says nothing about expanding when there is nothing to expand', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, NebaPill(title: const Text('Live'), onPressed: () {}));

      expect(
        tester.getSemantics(find.text('Live')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Live',
        ),
      );

      handle.dispose();
    });

    testWidgets('leaves closed details out of the semantics tree', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaPill(title: Text('Live'), details: details));

      expect(find.bySemanticsLabel('Gate B14'), findsNothing);

      handle.dispose();
    });
  });

  group('interaction', () {
    testWidgets('is no button until onPressed makes it one', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pump(tester, const NebaPill(title: Text('Live')));

      expect(
        tester.getSemantics(find.text('Live')),
        matchesSemantics(label: 'Live', textDirection: TextDirection.ltr),
      );
      expect(
        find.descendant(of: find.byType(NebaPill), matching: find.byType(Focus)),
        findsNothing,
      );

      handle.dispose();
    });

    testWidgets('presses through its row, with endIcon left outside it', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      int ends = 0;

      await pump(
        tester,
        NebaPill(
          title: const Text('Deploying'),
          onPressed: () => presses++,
          endIcon: GestureDetector(onTap: () => ends++, child: const Text('Pause')),
        ),
      );

      await tester.tap(find.text('Deploying'));
      expect(presses, 1);

      await tester.tap(find.text('Pause'));
      expect(presses, 1);
      expect(ends, 1);
    });

    testWidgets('lights and presses its row rather than the whole shell', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles roles = tokens.roles(NebaColor.secondary);

      await pump(
        tester,
        NebaPill(
          title: const Text('Deploying'),
          onPressed: () {},
          endIcon: const Text('Pause'),
          details: const Text('Step 3 of 7'),
          expanded: true,
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(find.text('Deploying')));
      await tester.pump();

      expect(washOver(tester, 'Deploying'), roles.fillActive);
      expect(washOver(tester, 'Pause'), isNull);
      expect(washOver(tester, 'Step 3 of 7'), isNull);

      await press.up();
      await tester.pumpAndSettle();
    });

    testWidgets('answers Enter from the keyboard', (WidgetTester tester) async {
      int presses = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await pump(
        tester,
        NebaPill(title: const Text('Live'), focusNode: node, onPressed: () => presses++),
      );

      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      expect(presses, 1);
    });
  });

  group('style', () {
    testWidgets('takes the tinted surface of a control, not a container', (
      WidgetTester tester,
    ) async {
      final NebaColorRoles roles = tokens.roles(NebaColor.info);

      await pump(tester, const NebaPill(color: NebaColor.info, title: Text('Live')));
      expect(sheetOf(tester).fill, roles.fill);

      await pump(
        tester,
        const NebaPill(variant: NebaVariant.outline, color: NebaColor.info, title: Text('Live')),
      );
      expect(sheetOf(tester).fill, roles.panel);
      expect(sheetOf(tester).edge, roles.line);

      await pump(
        tester,
        const NebaPill(variant: NebaVariant.text, color: NebaColor.info, title: Text('Live')),
      );
      expect(sheetOf(tester).fill, Color.alphaBlend(roles.soft, tokens.backing));
      expect(sheetOf(tester).plate, NebaPlate.none);
    });

    testWidgets('lays its wash on the page surface where transparency is reduced', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: NebaPill(variant: NebaVariant.text, title: Text('Live')),
          ),
          highContrast: true,
        ),
      );

      final NebaTokens opaque = tokens.withReducedTransparency();

      expect(
        sheetOf(tester).fill,
        Color.alphaBlend(opaque.roles(NebaColor.secondary).soft, opaque.surface),
      );
    });

    testWidgets('changes height with size but not with density', (WidgetTester tester) async {
      await pump(tester, const NebaPill(size: NebaSize.lg, title: Text('Live')));
      expect(tester.getSize(find.byType(NebaSheet)).height, 40);

      await pump(tester, const NebaPill(density: NebaDensity.compact, title: Text('Live')));
      expect(tester.getSize(find.byType(NebaSheet)).height, 32);
    });

    testWidgets('narrows only its padding with density', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Live')));
      final double standard = tester.getSize(find.byType(NebaSheet)).width;

      await pump(tester, const NebaPill(density: NebaDensity.compact, title: Text('Live')));

      expect(tester.getSize(find.byType(NebaSheet)).width, lessThan(standard));
      expect(styleOf(tester, 'Live').fontSize, NebaScale.controlText[NebaSize.md]);
    });
  });

  group('title and description', () {
    testWidgets('renders both, the title first', (WidgetTester tester) async {
      await pump(tester, const NebaPill(title: Text('Degraded'), description: Text('Slow')));

      expect(
        tester.getRect(find.text('Degraded')).top,
        lessThan(tester.getRect(find.text('Slow')).top),
      );
    });

    testWidgets('renders either one on its own', (WidgetTester tester) async {
      await pump(tester, const NebaPill(description: Text('Slow')));
      expect(find.text('Slow'), findsOneWidget);

      await pump(tester, const NebaPill(title: Text('Degraded')));
      expect(find.text('Degraded'), findsOneWidget);
    });

    testWidgets('centres them between the two slots, well clear of both', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPill(
          startIcon: SizedBox(key: Key('start'), width: 8, height: 8),
          endIcon: SizedBox(key: Key('end'), width: 8, height: 8),
          title: Text('Recording'),
        ),
      );

      final Rect start = tester.getRect(find.byKey(const Key('start')));
      final Rect end = tester.getRect(find.byKey(const Key('end')));
      final Rect title = tester.getRect(find.text('Recording'));
      final double room = NebaPill.centerPadding[NebaDensity.standard]![NebaSize.md]!;

      expect(title.left - start.right, greaterThanOrEqualTo(room));
      expect(end.left - title.right, greaterThanOrEqualTo(room));
    });

    testWidgets('puts child in the same centred column, after both', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPill(title: Text('Live'), description: Text('Now'), child: Text('Extra')),
      );

      expect(
        tester.getRect(find.text('Extra')).top,
        greaterThan(tester.getRect(find.text('Now')).top),
      );
      expect(
        tester.getCenter(find.text('Extra')).dx,
        closeTo(tester.getCenter(find.text('Live')).dx, 0.5),
      );
    });

    testWidgets('sets the description in the title ink, one step smaller and lighter', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaPill(title: Text('Degraded'), description: Text('Slow')));

      final TextStyle title = styleOf(tester, 'Degraded');
      final TextStyle description = styleOf(tester, 'Slow');

      expect(description.color, title.color);
      expect(description.fontSize, NebaScale.metaText[NebaSize.md]);
      expect(title.fontWeight, FontWeight.w500);
      expect(description.fontWeight, FontWeight.w400);
    });
  });

  group('the leading slot', () {
    testWidgets('is a round box the size of a standalone icon', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPill(startIcon: SizedBox(width: 4, height: 4), title: Text('Live')),
      );

      final Finder oval = find.descendant(
        of: find.byType(NebaPill),
        matching: find.byType(ClipOval),
      );

      expect(tester.getSize(oval), Size.square(NebaScale.iconSize[NebaSize.md]!));
    });

    testWidgets('lets a picture fill it, cropped rather than letterboxed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPill(startIcon: Image.memory(_wide, width: 60, height: 30), title: const Text('Live')),
      );

      final FittedBox fit = tester.widget<FittedBox>(
        find.descendant(of: find.byType(NebaPill), matching: find.byType(FittedBox)),
      );

      expect(fit.fit, BoxFit.cover);
    });
  });
}

/// A 2-by-1 PNG, for a picture wider than the round box it lands in.
final Uint8List _wide = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x02, 0x00, 0x00, 0x00, 0x7B, 0x40, 0xE8, 0xDD, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0x00, 0x04, //
  0xFF, 0x01, 0x07, 0x00, 0x01, 0xFF, 0xE2, 0x23, 0x9E, 0x59, 0x00, 0x00, //
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
]);
