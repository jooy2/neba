// NebaMockup: the suite the React package runs on Mockup, asked the way
// Flutter asks it — the size the device is drawn at and the size its screen
// is laid out at, what the media query on the screen says, the bars and the
// cut-out it draws, and the shadow — rather than the elements and styles it
// writes.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget mockup, {double width = 200}) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: mockup,
          ),
        ),
      ),
    );
  }

  /// What the content on the screen is told the screen is.
  Size screenOf(WidgetTester tester) {
    return MediaQuery.sizeOf(tester.element(find.byKey(const ValueKey<String>('content'))));
  }

  const Widget content = SizedBox.expand(key: ValueKey<String>('content'));

  group('rendering', () {
    testWidgets('draws its child on the screen', (WidgetTester tester) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile, child: Text('Hello')));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('fills the width it is in, in the device proportion', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, bezel: NebaMockupBezel.none),
      );

      expect(tester.getSize(find.byType(NebaMockup)), Size(200, 200 * 844 / 390));
    });

    testWidgets('takes a width, a height or both', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, bezel: NebaMockupBezel.none, width: 195),
      );

      expect(tester.getSize(find.byType(NebaMockup)), const Size(195, 422));

      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, bezel: NebaMockupBezel.none, height: 422),
      );

      expect(tester.getSize(find.byType(NebaMockup)), const Size(195, 422));

      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.mobile,
          bezel: NebaMockupBezel.none,
          width: 300,
          height: 300,
        ),
        width: 400,
      );

      // The box it is given, with the device held inside it whole.
      expect(tester.getSize(find.byType(NebaMockup)), const Size(300, 300));
      expect(tester.getSize(find.byType(FittedBox)), const Size(300, 300));
    });
  });

  group('resolution', () {
    testWidgets('is laid out at the resolution it was given', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.mobile,
          resolution: Size(400, 800),
          systemUi: false,
          child: content,
        ),
      );

      expect(screenOf(tester), const Size(400, 800));
    });

    testWidgets('takes a step of the ladder when no resolution is given', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.desktop,
          size: NebaSize.sm,
          systemUi: false,
          child: content,
        ),
      );

      expect(screenOf(tester), const Size(1280, 800));
    });

    testWidgets('swaps its axes in landscape, and leaves a desktop alone', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.tablet,
          orientation: NebaMockupOrientation.landscape,
          systemUi: false,
          child: content,
        ),
      );

      expect(screenOf(tester), const Size(1180, 820));

      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.desktop,
          orientation: NebaMockupOrientation.landscape,
          systemUi: false,
          child: content,
        ),
      );

      expect(screenOf(tester), const Size(1440, 900));
    });

    testWidgets('tells what is on the screen the screen is the window', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, systemUi: false, child: content),
        width: 200,
      );

      expect(screenOf(tester), const Size(390, 844));
      expect(
        MediaQuery.paddingOf(tester.element(find.byKey(const ValueKey<String>('content')))),
        EdgeInsets.zero,
      );
    });
  });

  group('hardware', () {
    test('is the screen itself when there is no bezel', () {
      final NebaMockupMetrics bare = NebaMockup.metricsOf(
        device: NebaMockupDevice.mobile,
        bezel: NebaMockupBezel.none,
      );

      expect(bare.frame, const Size(390, 844));
      expect(bare.stand, isNull);
    });

    test('grows around the screen once there is a bezel', () {
      final NebaMockupMetrics phone = NebaMockup.metricsOf(device: NebaMockupDevice.mobile);

      expect(phone.frame, const Size(390 + 26, 844 + 26));

      final NebaMockupMetrics thick = NebaMockup.metricsOf(
        device: NebaMockupDevice.mobile,
        bezel: NebaMockupBezel.thick,
        orientation: NebaMockupOrientation.landscape,
      );

      // A forehead and a chin become the sides when it is turned.
      expect(thick.bezel, const EdgeInsets.fromLTRB(62, 16, 62, 16));
    });

    test('is a different shape on a laptop than on a monitor', () {
      final NebaMockupMetrics monitor = NebaMockup.metricsOf(device: NebaMockupDevice.desktop);
      final NebaMockupMetrics laptop = NebaMockup.metricsOf(
        device: NebaMockupDevice.desktop,
        hardware: NebaMockupHardware.laptop,
      );

      expect(monitor.stand, isNotNull);
      expect(monitor.base, isNull);
      expect(laptop.base, isNotNull);
      expect(laptop.frame.width, greaterThan(laptop.body.width));
      // A laptop's chin is on its base, so its lid's bezel is even.
      expect(laptop.bezel.bottom, laptop.bezel.top);
    });

    test('ignores hardware on a handheld, which holds itself up', () {
      final NebaMockupMetrics tablet = NebaMockup.metricsOf(
        device: NebaMockupDevice.tablet,
        hardware: NebaMockupHardware.laptop,
      );

      expect(tablet.base, isNull);
      expect(tablet.frame, tablet.body);
    });
  });

  group('the cut-out', () {
    test('is a dynamic island on an iOS phone and a punch hole on an Android one', () {
      expect(
        NebaMockup.defaultNotch(NebaMockupDevice.mobile, NebaMockupOs.ios),
        NebaMockupNotch.dynamicIsland,
      );
      expect(
        NebaMockup.defaultNotch(NebaMockupDevice.mobile, NebaMockupOs.android),
        NebaMockupNotch.punchHole,
      );
      expect(
        NebaMockup.defaultNotch(NebaMockupDevice.tablet, NebaMockupOs.ipados),
        NebaMockupNotch.none,
      );
    });

    Finder holes() => find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color == const Color(0xFF0D0E10),
    );

    testWidgets('is drawn on an iOS phone, and turned off by none', (WidgetTester tester) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile));

      expect(holes(), findsOneWidget);
      expect(tester.getSize(holes()), const Size(125, 36));

      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, notch: NebaMockupNotch.none),
      );

      expect(holes(), findsNothing);
    });

    testWidgets('stays when the system UI is turned off', (WidgetTester tester) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile, systemUi: false));

      expect(holes(), findsOneWidget);
    });
  });

  group('the system UI', () {
    testWidgets('draws a clock by default, and takes the time it is given', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile));

      expect(find.text('9:41'), findsOneWidget);

      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile, time: '12:30'));

      expect(find.text('12:30'), findsOneWidget);
    });

    testWidgets('draws nothing when it is turned off, and gives the room back', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile, child: content));

      // A 54-pixel status bar and a 34-pixel home indicator.
      expect(screenOf(tester), const Size(390, 844 - 54 - 34));

      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, systemUi: false, child: content),
      );

      expect(find.text('9:41'), findsNothing);
      expect(screenOf(tester), const Size(390, 844));
    });

    testWidgets('keeps the chrome out of a screen reader', (WidgetTester tester) async {
      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile));

      expect(find.bySemanticsLabel('9:41'), findsNothing);
    });

    testWidgets('docks down the leading edge on Linux', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.desktop, os: NebaMockupOs.linux, child: content),
      );

      expect(screenOf(tester), const Size(1440 - 66, 900 - 34));
    });

    test('falls back to the device’s own system, and reads ios on a tablet as the tablet one', () {
      expect(
        NebaMockup.resolveOs(NebaMockupDevice.desktop, NebaMockupOs.android),
        NebaMockupOs.macos,
      );
      expect(NebaMockup.resolveOs(NebaMockupDevice.tablet, NebaMockupOs.ios), NebaMockupOs.ipados);
      expect(NebaMockup.resolveOs(NebaMockupDevice.mobile, NebaMockupOs.ipados), NebaMockupOs.ios);
      expect(NebaMockup.resolveOs(NebaMockupDevice.mobile, null), NebaMockupOs.ios);
    });
  });

  group('the screen', () {
    testWidgets('gives what fits the screen exactly and clips the rest', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaMockup(device: NebaMockupDevice.mobile, systemUi: false, child: content),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
      // In the screen's own pixels, which the device is scaled from.
      expect(tester.getSize(find.byKey(const ValueKey<String>('content'))), const Size(390, 844));
    });

    testWidgets('scrolls when asked', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaMockup(
          device: NebaMockupDevice.mobile,
          scroll: true,
          child: SizedBox(height: 3000),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('takes a decoration as a wallpaper', (WidgetTester tester) async {
      const BoxDecoration wallpaper = BoxDecoration(color: Color(0xFF123456));

      await pump(tester, const NebaMockup(device: NebaMockupDevice.mobile, wallpaper: wallpaper));

      expect(
        tester
            .widgetList<Container>(find.byType(Container))
            .where((Container container) => container.decoration == wallpaper),
        hasLength(1),
      );
    });
  });

  group('elevation', () {
    /// The alpha of the pixel 6 pixels under the middle of the device's
    /// bottom edge, on a transparent page.
    Future<double> under(WidgetTester tester, int elevation) async {
      final GlobalKey boundary = GlobalKey();

      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: boundary,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: NebaMockup(
                  device: NebaMockupDevice.mobile,
                  elevation: elevation,
                  width: 100,
                ),
              ),
            ),
          ),
        ),
      );

      final double height = 100 * (844 + 26) / (390 + 26);
      late double alpha;

      await tester.runAsync(() async {
        final ui.Image image =
            await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
        final ByteData bytes = (await image.toByteData())!;
        final int x = 40 + 50;
        final int y = (40 + height + 6).round();

        alpha = bytes.getUint8((y * image.width + x) * 4 + 3) / 255;
      });

      return alpha;
    }

    testWidgets('draws no shadow at elevation 0, and one under the device when raised', (
      WidgetTester tester,
    ) async {
      expect(await under(tester, 0), 0);
      expect(await under(tester, 2), greaterThan(0));
    });
  });
}
