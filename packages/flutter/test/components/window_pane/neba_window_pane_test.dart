// NebaWindowPane: the suite the React package runs on WindowPane, asked the
// way Flutter asks it — where the buttons are laid out, the colours and the
// sheet the chrome is drawn with, the sizes the window takes and reports, and
// which window is in front — rather than the elements and styles it writes.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  tearDown(resetNebaMessages);

  Future<void> pump(WidgetTester tester, Widget window) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 480, child: window),
        ),
      ),
    );
  }

  /// A desktop to put windows on: a 600 by 400 stage.
  Future<void> stage(WidgetTester tester, List<Widget> windows) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 600, height: 400, child: Stack(children: windows)),
          ),
        ),
      ),
    );
  }

  Finder control(String name) => find.bySemanticsLabel(name);

  NebaSheet sheet(WidgetTester tester, [int index = 0]) {
    return tester.widgetList<NebaSheet>(find.byType(NebaSheet)).elementAt(index);
  }

  Rect window(WidgetTester tester, [int index = 0]) {
    return tester.getRect(find.byType(NebaSheet).at(index));
  }

  /// The title bar's own box: its fill and its rule.
  BoxDecoration bar(WidgetTester tester, [int index = 0]) {
    return tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(NebaSheet).at(index),
                matching: find.byWidgetPredicate(
                  (Widget widget) =>
                      widget is Container &&
                      widget.constraints?.maxHeight != null &&
                      widget.constraints!.isTight == false &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration! as BoxDecoration).color != null,
                ),
              ),
            )
            .first
            .decoration!
        as BoxDecoration;
  }

  TextStyle titleStyle(WidgetTester tester, String title) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(title), matching: find.byType(RichText)))
        .text
        .style!;
  }

  group('rendering', () {
    testWidgets('renders its title and whatever is in it', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(title: Text('Notes'), child: Text('Body')));

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('names the window after its title', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(title: Text('Notes'), child: Text('Body')));

      expect(find.bySemanticsLabel('Notes'), findsWidgets);
    });

    testWidgets('puts the controls where macOS puts them', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(title: Text('Notes')));

      final double close = tester.getCenter(control('Close')).dx;
      final double minimize = tester.getCenter(control('Minimize')).dx;
      final double maximize = tester.getCenter(control('Maximize')).dx;

      expect(close, lessThan(minimize));
      expect(minimize, lessThan(maximize));
      expect(maximize, lessThan(tester.getRect(find.text('Notes')).left));
    });

    testWidgets('puts them where Windows puts them instead', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(os: NebaWindowOs.windows11, title: Text('Notes')));

      final Rect close = tester.getRect(control('Close'));

      expect(
        tester.getCenter(control('Minimize')).dx,
        lessThan(tester.getCenter(control('Maximize')).dx),
      );
      expect(tester.getCenter(control('Maximize')).dx, lessThan(close.center.dx));
      // Hard against the corner: 46 by 32, and the hairline the only thing
      // between it and the edge.
      expect(close.size, const Size(46, 32));
      expect(close.right, window(tester).right - 1);
    });

    testWidgets('puts them where Aqua put them, which is where macOS still does', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(os: NebaWindowOs.macosx, title: Text('Notes')));

      expect(
        tester.getCenter(control('Close')).dx,
        lessThan(tester.getCenter(control('Minimize')).dx),
      );
    });

    testWidgets('leaves the bottom corners of an older window square', (WidgetTester tester) async {
      for (final NebaWindowOs os in <NebaWindowOs>[
        NebaWindowOs.macosx,
        NebaWindowOs.windows7,
        NebaWindowOs.windowsxp,
      ]) {
        await pump(tester, NebaWindowPane(os: os, title: const Text('Old')));

        expect(sheet(tester).borderRadius.bottomLeft, Radius.zero, reason: os.name);
        expect(sheet(tester).borderRadius.topLeft, isNot(Radius.zero), reason: os.name);
      }

      await pump(tester, const NebaWindowPane(title: Text('New')));

      expect(sheet(tester).borderRadius.bottomLeft, const Radius.circular(10));
    });

    testWidgets('paints an XP window in its own colour and bands it in the same one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(os: NebaWindowOs.windowsxp, title: Text('XP')));

      expect(bar(tester).color, const Color(0xFF1F66D6));
      expect(sheet(tester).fill, const Color(0xFF1F66D6));
    });

    testWidgets('sinks the content into the band, on the systems that have one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaWindowPane(
          os: NebaWindowOs.windowsxp,
          height: 200,
          scroll: false,
          child: SizedBox.expand(),
        ),
      );

      final Rect body = tester.getRect(find.byType(SizedBox).last);
      final Rect frame = window(tester);

      expect(body.left - frame.left, 1 + 4);
      expect(frame.bottom - body.bottom, 1 + 4);
    });

    testWidgets("leaves a modern window's content filling it", (WidgetTester tester) async {
      await pump(
        tester,
        const NebaWindowPane(height: 200, scroll: false, child: SizedBox.expand()),
      );

      final Rect body = tester.getRect(find.byType(SizedBox).last);
      final Rect frame = window(tester);

      expect(body.left - frame.left, 1);
      expect(frame.bottom - body.bottom, 1);
      expect(body.top - frame.top, 1 + 38);
    });

    testWidgets('blurs what is behind an Aero window, and nothing behind a flat one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(os: NebaWindowOs.windows7));

      expect(sheet(tester).blur, isTrue);

      await pump(tester, const NebaWindowPane(os: NebaWindowOs.windows10));

      expect(sheet(tester).blur, isFalse);
    });

    testWidgets('draws only the buttons it was asked for', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaWindowPane(controls: <NebaWindowControl>{NebaWindowControl.close}),
      );

      expect(control('Close'), findsOneWidget);
      expect(control('Minimize'), findsNothing);
      expect(control('Maximize'), findsNothing);
    });

    testWidgets('draws none at all when it is told to', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(controls: <NebaWindowControl>{}));

      expect(control('Close'), findsNothing);
    });

    testWidgets('names its buttons in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, const NebaWindowPane(locale: Locale('ko')));

      expect(control('Close'), findsNothing);
      expect(control('Minimize'), findsNothing);
    });

    testWidgets('takes names of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaWindowPane(closeLabel: 'Quit', minimizeLabel: 'Hide', maximizeLabel: 'Zoom'),
      );

      expect(control('Quit'), findsOneWidget);
      expect(control('Hide'), findsOneWidget);
      expect(control('Zoom'), findsOneWidget);
    });

    testWidgets('reflects a changed title on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(title: Text('One')));
      await pump(tester, const NebaWindowPane(title: Text('Two')));

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('scales the chrome and not the content with size', (WidgetTester tester) async {
      expect(NebaWindowPane.metricsOf(NebaWindowOs.macos, NebaSize.md).bar, 38);
      expect(NebaWindowPane.metricsOf(NebaWindowOs.macos, NebaSize.xl).bar, 49);
      expect(NebaWindowPane.metricsOf(NebaWindowOs.windows7, NebaSize.md).closeWidth, 45);

      await pump(tester, const NebaWindowPane(size: NebaSize.xl, title: Text('Big')));

      expect(titleStyle(tester, 'Big').fontSize, 17);
    });
  });

  group('the three buttons', () {
    testWidgets('closes a window that keeps its own state, after it fades', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(title: Text('Notes')));
      await tester.tap(control('Close'));
      await tester.pump();

      // Still there, fading and out of reach.
      expect(find.text('Notes'), findsOneWidget);
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first).opacity, 0);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('leaves a controlled window open and reports the press', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaWindowPane(title: const Text('Notes'), open: true, onOpenChange: reported.add),
      );
      await tester.tap(control('Close'));
      await tester.pumpAndSettle();

      expect(reported, <bool>[false]);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('rolls the window up to its title bar, and back', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(height: 200, child: Text('Body')));

      expect(window(tester).height, 200);

      await tester.tap(control('Minimize'));
      await tester.pumpAndSettle();

      expect(window(tester).height, 38 + 2);
      expect(find.semantics.byLabel('Body'), findsNothing);

      await tester.tap(control('Minimize'));
      await tester.pumpAndSettle();

      expect(window(tester).height, 200);
      expect(find.semantics.byLabel('Body'), findsOne);
    });

    testWidgets('measures a window that starts rolled up', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(height: 200, defaultMinimized: true));

      expect(window(tester).height, 38 + 2);
    });

    testWidgets('fills what is holding it when it is maximized, and says so on the button', (
      WidgetTester tester,
    ) async {
      await stage(tester, const <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          width: 200,
          height: 120,
          defaultOffset: Offset(40, 30),
        ),
      ]);

      await tester.tap(control('Maximize'));
      await tester.pumpAndSettle();

      expect(window(tester), const Rect.fromLTWH(0, 0, 600, 400));
      expect(sheet(tester).borderRadius, BorderRadius.zero);
      expect(control('Restore'), findsOneWidget);

      await tester.tap(control('Restore'));
      await tester.pumpAndSettle();

      expect(window(tester), const Rect.fromLTWH(40, 30, 200, 120));
    });

    testWidgets('maximizes on a double click of the title bar', (WidgetTester tester) async {
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaWindowPane(title: const Text('Notes'), onMaximizedChange: reported.add),
      );

      final Offset onBar = tester.getCenter(find.text('Notes'));

      await tester.tapAt(onBar);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(onBar);
      await tester.pumpAndSettle();

      expect(reported, <bool>[true]);
    });

    testWidgets('leaves a double click on an action to the action', (WidgetTester tester) async {
      final List<bool> reported = <bool>[];
      int pressed = 0;

      await pump(
        tester,
        NebaWindowPane(
          title: const Text('Notes'),
          onMaximizedChange: reported.add,
          actions: NebaButton(onPressed: () => pressed += 1, child: const Text('Share')),
        ),
      );

      await tester.tap(find.text('Share'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      expect(pressed, 2);
      expect(reported, isEmpty);
    });

    testWidgets('reports a maximize a caller is driving without acting on it', (
      WidgetTester tester,
    ) async {
      final List<bool> reported = <bool>[];

      await stage(tester, <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          width: 200,
          height: 120,
          maximized: false,
          onMaximizedChange: reported.add,
        ),
      ]);
      await tester.tap(control('Maximize'));
      await tester.pumpAndSettle();

      expect(reported, <bool>[true]);
      expect(window(tester).size, const Size(200, 120));
    });
  });

  group('the chrome', () {
    testWidgets('dyes the title bar with the colour family when it is asked to', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(accent: true, color: NebaColor.danger));

      expect(bar(tester).color, tokens.roles(NebaColor.danger).family.solid);
    });

    testWidgets('quietens a window that is not in front rather than fading it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(title: Text('Back'), active: false));

      expect(titleStyle(tester, 'Back').color, tokens.mutedFg);
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first).opacity, 1);
    });

    testWidgets('lets the page through the chrome, and turns the acrylic on with it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(transparency: 0.45));

      expect(bar(tester).color!.a, closeTo(0.55, 0.02));
      expect(sheet(tester).blur, isTrue);
    });

    testWidgets('leaves an opaque window with nothing to blur', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane());

      expect(bar(tester).color!.a, 1);
      expect(sheet(tester).blur, isFalse);
    });

    testWidgets('turns opaque for a reader who asked for less transparency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 480, child: NebaWindowPane(transparency: 0.45)),
          ),
          highContrast: true,
        ),
      );

      expect(bar(tester).color!.a, closeTo(1, 0.001));
    });

    testWidgets('drops the shadow when it is told to, and sits a step back behind', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane());

      expect(sheet(tester).elevation, 2);

      await pump(tester, const NebaWindowPane(elevation: 0));

      expect(sheet(tester).elevation, 0);

      await pump(tester, const NebaWindowPane(active: false));

      expect(sheet(tester).elevation, 1);
    });
  });

  group('which window is in front', () {
    Widget two() {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: NebaWindowPane(title: Text('A'), height: 100)),
          SizedBox(width: 20),
          Expanded(child: NebaWindowPane(title: Text('B'), height: 100)),
        ],
      );
    }

    testWidgets('starts in front, so a page with one window on it is not greyed out', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaWindowPane(title: Text('Only')));

      expect(titleStyle(tester, 'Only').color, tokens.fg);
    });

    testWidgets('steps back when another window is pressed, and back again', (
      WidgetTester tester,
    ) async {
      await pump(tester, two());
      await tester.tap(find.text('B'));
      await tester.pump();

      expect(titleStyle(tester, 'A').color, tokens.mutedFg);
      expect(titleStyle(tester, 'B').color, tokens.fg);

      await tester.tap(find.text('A'));
      await tester.pump();

      expect(titleStyle(tester, 'A').color, tokens.fg);
      expect(titleStyle(tester, 'B').color, tokens.mutedFg);
    });

    testWidgets('hands the front to the window before it when the front one closes', (
      WidgetTester tester,
    ) async {
      await pump(tester, two());
      await tester.tap(find.text('B'));
      await tester.pump();
      await tester.tap(control('Close').last);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('B'), findsNothing);
      expect(titleStyle(tester, 'A').color, tokens.fg);
    });

    testWidgets('stays in front when the page around it is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NebaWindowPane(title: Text('Only'), height: 100),
              SizedBox(height: 200, child: Text('Prose')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Prose'));
      await tester.pump();

      expect(titleStyle(tester, 'Only').color, tokens.fg);
    });

    testWidgets('leaves it alone when the caller is driving it', (WidgetTester tester) async {
      await pump(
        tester,
        const Column(
          children: <Widget>[
            NebaWindowPane(title: Text('Driven'), active: false, height: 100),
            NebaWindowPane(title: Text('Other'), height: 100),
          ],
        ),
      );
      await tester.tap(find.text('Driven'));
      await tester.pump();

      expect(titleStyle(tester, 'Driven').color, tokens.mutedFg);
    });
  });

  group('where it sits', () {
    testWidgets('stays in the flow, and is moved by its offset alone', (WidgetTester tester) async {
      await pump(
        tester,
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            NebaWindowPane(height: 100, offset: Offset(30, 20)),
            SizedBox(height: 10, child: Text('After')),
          ],
        ),
      );

      expect(window(tester).topLeft, const Offset(30, 20));
      // What follows it is where it would be without the offset.
      expect(tester.getRect(find.text('After')).top, 100);
    });

    testWidgets('pins itself in the stack that holds it', (WidgetTester tester) async {
      await stage(tester, const <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          width: 200,
          height: 120,
          offset: Offset(50, 60),
        ),
      ]);

      expect(window(tester), const Rect.fromLTWH(50, 60, 200, 120));
    });

    testWidgets('reports where a drag put it', (WidgetTester tester) async {
      final List<Offset> reported = <Offset>[];

      await stage(tester, <Widget>[
        NebaWindowPane(
          title: const Text('Drag'),
          position: NebaWindowPanePosition.absolute,
          draggable: true,
          width: 200,
          height: 120,
          onOffsetChange: reported.add,
        ),
      ]);
      await tester.drag(find.text('Drag'), const Offset(80, 60), touchSlopX: 0, touchSlopY: 0);
      await tester.pumpAndSettle();

      expect(reported.last.dx, closeTo(80, 20));
      expect(reported.last.dy, closeTo(60, 20));
      expect(window(tester).topLeft, reported.last);
    });

    testWidgets('keeps the title bar of a placed window where it can be grabbed', (
      WidgetTester tester,
    ) async {
      await stage(tester, const <Widget>[
        NebaWindowPane(
          title: Text('Drag'),
          position: NebaWindowPanePosition.absolute,
          draggable: true,
          width: 200,
          height: 120,
        ),
      ]);
      await tester.drag(find.text('Drag'), const Offset(-900, 900));
      await tester.pumpAndSettle();

      // A strip of 48 pixels inside the start of the stage, and the bar
      // inside its bottom.
      expect(window(tester).right, 48);
      expect(window(tester).top, 400 - 38);
    });

    testWidgets('does not move a window that was not made draggable', (WidgetTester tester) async {
      await stage(tester, const <Widget>[
        NebaWindowPane(
          title: Text('Still'),
          position: NebaWindowPanePosition.absolute,
          width: 200,
          height: 120,
        ),
      ]);
      await tester.drag(find.text('Still'), const Offset(80, 60));
      await tester.pumpAndSettle();

      expect(window(tester).topLeft, Offset.zero);
    });
  });

  group('resizing', () {
    testWidgets('offers no handles until it is made resizable', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(height: 120));

      expect(find.bySemanticsLabel('Resize window'), findsNothing);

      await pump(tester, const NebaWindowPane(height: 120, resizable: true));

      expect(find.bySemanticsLabel('Resize window'), findsOneWidget);
    });

    testWidgets('tells a keyboard reader how the corner resizes', (WidgetTester tester) async {
      await pump(tester, const NebaWindowPane(height: 120, resizable: true));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Resize window')),
        matchesSemantics(
          label: 'Resize window',
          hint: 'Use the arrow keys to resize the window',
          isButton: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('leaves one corner reachable without a pointer', (WidgetTester tester) async {
      final List<Size> reported = <Size>[];

      await pump(
        tester,
        NebaWindowPane(width: 300, height: 120, resizable: true, onResize: reported.add),
      );

      Focus.of(tester.element(find.byType(NebaFocusRing).last)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(reported.last, const Size(316, 136));
      expect(window(tester).size, const Size(316, 136));
    });

    testWidgets('reports the size a drag settled on, held to its minimum', (
      WidgetTester tester,
    ) async {
      final List<Size> reported = <Size>[];

      await stage(tester, <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          resizable: true,
          width: 300,
          height: 160,
          onResize: reported.add,
        ),
      ]);

      final TestGesture gesture = await tester.startGesture(const Offset(296, 156));

      await gesture.moveBy(const Offset(40, 30));
      await tester.pump();

      expect(reported.last, const Size(340, 190));

      await gesture.moveBy(const Offset(-600, -600));
      await tester.pump();

      expect(reported.last, const Size(180, 38));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('takes a width passed after a resize over the size the resize gave it', (
      WidgetTester tester,
    ) async {
      await stage(tester, const <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          resizable: true,
          width: 300,
          height: 160,
        ),
      ]);

      final TestGesture gesture = await tester.startGesture(const Offset(296, 156));

      await gesture.moveBy(const Offset(40, 30));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(window(tester).size, const Size(340, 190));

      await stage(tester, const <Widget>[
        NebaWindowPane(
          position: NebaWindowPanePosition.absolute,
          resizable: true,
          width: 250,
          height: 160,
        ),
      ]);
      await tester.pumpAndSettle();

      expect(window(tester).size, const Size(250, 160));
    });

    testWidgets('brings the traffic-light glyphs back under the pointer', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        await pump(tester, const NebaWindowPane(title: Text('Mac')));

        double glyph() =>
            tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity)).last.opacity;

        expect(glyph(), 0);

        final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

        await mouse.addPointer(location: tester.getCenter(control('Close')));
        await tester.pumpAndSettle();

        expect(glyph(), 1);

        await mouse.removePointer();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
