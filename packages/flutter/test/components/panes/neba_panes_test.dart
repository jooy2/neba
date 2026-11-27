// NebaPanes: the suite the React package runs on Panes, asked the way Flutter
// asks it — the widths the panes are laid out at instead of `aria-valuenow`,
// the colours the handle builds instead of classes, and semantics instead of
// ARIA.
//
// As in the React suite, the split is 408 pixels wide with an 8-pixel handle,
// so two panes have 400 to share and one percent is four pixels.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  NebaPane pane(
    String text, {
    NebaPaneSize? defaultSize,
    NebaPaneSize? minSize,
    NebaPaneSize? maxSize,
  }) {
    return NebaPane(
      defaultSize: defaultSize,
      minSize: minSize,
      maxSize: maxSize,
      child: Text(text),
    );
  }

  /// A split with a size to measure against, at the top left of the window
  /// whatever the direction, so a rect reads the same in both.
  Future<void> pump(
    WidgetTester tester,
    Widget panes, {
    double width = 408,
    double height = 208,
    TextDirection textDirection = TextDirection.ltr,
    NebaDefaults? defaults,
  }) {
    final Widget sized = Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, height: height, child: panes),
    );

    return tester.pumpWidget(
      host(
        defaults == null ? sized : NebaProvider(defaults: defaults, child: sized),
        textDirection: textDirection,
      ),
    );
  }

  Finder handles() => find.byType(NebaDragRegion);

  /// The share, in percent, of the pane before each handle of the outermost
  /// split: what React's `aria-valuenow` says, read off the layout.
  List<int> shares(WidgetTester tester, {bool vertical = false}) {
    final NebaPanes split = tester.widget<NebaPanes>(find.byType(NebaPanes).first);
    final List<NebaPane> panes = split.children;
    final double track = 8.0 * (panes.length - 1);
    final Size whole = tester.getSize(find.byType(NebaPanes).first);
    final double extent = (vertical ? whole.height : whole.width) - track;

    return <int>[
      for (int index = 0; index < panes.length - 1; index += 1)
        () {
          final Size size = tester.getSize(find.byWidget(panes[index]));
          return ((vertical ? size.height : size.width) / extent * 100).round();
        }(),
    ];
  }

  /// The pane nearest [text].
  Rect rectOf(WidgetTester tester, String text) {
    return tester.getRect(
      find.ancestor(of: find.text(text), matching: find.byType(NebaPane)).first,
    );
  }

  /// The tint under a handle and its hairline, as they were last built.
  (BoxDecoration, BoxDecoration) colorsOf(WidgetTester tester, {int index = 0}) {
    final Iterable<AnimatedContainer> containers = tester.widgetList<AnimatedContainer>(
      find.descendant(of: handles().at(index), matching: find.byType(AnimatedContainer)),
    );

    return (
      containers.first.decoration! as BoxDecoration,
      containers.last.decoration! as BoxDecoration,
    );
  }

  FocusNode handleFocus(WidgetTester tester, {int index = 0}) {
    return Focus.of(tester.element(handles().at(index)));
  }

  group('rendering', () {
    testWidgets('puts a handle between every pair of panes', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two'), pane('Three')]));

      expect(handles(), findsNWidgets(2));
    });

    testWidgets('renders no handle for a single pane', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('Only')]));

      expect(find.text('Only'), findsOneWidget);
      expect(handles(), findsNothing);
      expect(rectOf(tester, 'Only').size, const Size(408, 208));
    });

    testWidgets('splits the space evenly when no pane asks for a share', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      expect(shares(tester), <int>[50]);
    });

    testWidgets('gives a pane the share it asks for as a percentage', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', defaultSize: const NebaPaneSize.percent(25)),
            pane('Two'),
          ],
        ),
      );

      expect(shares(tester), <int>[25]);
    });

    testWidgets('gives a pane the share it asks for as a length, in the first frame', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', defaultSize: const NebaPaneSize.pixels(120)),
            pane('Two'),
          ],
        ),
      );

      // 120 of the 400 there are to share, before anything has been pumped
      // again: the layout measures and lays out at once.
      expect(rectOf(tester, 'One').width, 120);
      expect(shares(tester), <int>[30]);
    });

    testWidgets('pays for the handles before sharing out the rest', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      expect(rectOf(tester, 'One'), const Rect.fromLTWH(0, 0, 200, 208));
      expect(rectOf(tester, 'Two'), const Rect.fromLTWH(208, 0, 200, 208));
    });

    testWidgets('stands a handle upright between panes that run across', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      // A 24-pixel target, centred on the 8-pixel track between the panes.
      expect(tester.getRect(handles()), const Rect.fromLTWH(192, 0, 24, 208));
      expect(
        tester.widget<MouseRegion>(
          find.descendant(of: handles(), matching: find.byType(MouseRegion)).first,
        ),
        isA<MouseRegion>().having(
          (MouseRegion region) => region.cursor,
          'cursor',
          SystemMouseCursors.resizeColumn,
        ),
      );
    });

    testWidgets('lays a handle flat between panes that stack', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          orientation: NebaOrientation.vertical,
          children: <NebaPane>[pane('One'), pane('Two')],
        ),
      );

      expect(rectOf(tester, 'One'), const Rect.fromLTWH(0, 0, 408, 100));
      expect(rectOf(tester, 'Two'), const Rect.fromLTWH(0, 108, 408, 100));
      expect(tester.getRect(handles()), const Rect.fromLTWH(0, 92, 408, 24));
      expect(
        tester.widget<MouseRegion>(
          find.descendant(of: handles(), matching: find.byType(MouseRegion)).first,
        ),
        isA<MouseRegion>().having(
          (MouseRegion region) => region.cursor,
          'cursor',
          SystemMouseCursors.resizeRow,
        ),
      );
    });

    testWidgets('measures the other axis when the panes are stacked', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          orientation: NebaOrientation.vertical,
          children: <NebaPane>[
            pane('One', defaultSize: const NebaPaneSize.pixels(50)),
            pane('Two'),
          ],
        ),
      );

      // 208 tall, less the 8-pixel handle, is 200 to share.
      expect(shares(tester, vertical: true), <int>[25]);
    });

    testWidgets('lays the panes out from the end under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', defaultSize: const NebaPaneSize.pixels(100)),
            pane('Two'),
          ],
        ),
        textDirection: TextDirection.rtl,
      );

      expect(rectOf(tester, 'One'), const Rect.fromLTWH(308, 0, 100, 208));
      expect(rectOf(tester, 'Two'), const Rect.fromLTWH(0, 0, 300, 208));
    });

    testWidgets('re-splits when a pane is added on a rebuild', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));
      expect(shares(tester), <int>[50]);

      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two'), pane('Three')]));

      expect(shares(tester), <int>[33, 33]);
    });

    testWidgets('takes panes keyed by their index without a clash', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPanes(
          children: <NebaPane>[
            NebaPane(key: ValueKey<int>(0), child: Text('One')),
            NebaPane(key: ValueKey<int>(1), child: Text('Two')),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(handles(), findsOneWidget);
    });

    testWidgets('gives a pane its child at the pane\'s size, clipped to it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPanes(
          children: <NebaPane>[
            NebaPane(child: SizedBox(key: Key('inside'))),
            NebaPane(child: SizedBox()),
          ],
        ),
      );

      expect(tester.getSize(find.byKey(const Key('inside'))), const Size(200, 208));
      expect(
        find.ancestor(of: find.byKey(const Key('inside')), matching: find.byType(ClipRect)),
        findsOneWidget,
      );
    });

    testWidgets('takes the track from size, the provider, then md', (WidgetTester tester) async {
      const Map<NebaSize, double> tracks = <NebaSize, double>{
        NebaSize.xs: 4,
        NebaSize.sm: 6,
        NebaSize.md: 8,
        NebaSize.lg: 10,
        NebaSize.xl: 12,
      };

      for (final MapEntry<NebaSize, double> track in tracks.entries) {
        await pump(
          tester,
          NebaPanes(size: track.key, children: <NebaPane>[pane('One'), pane('Two')]),
        );

        expect(rectOf(tester, 'One').width, (408 - track.value) / 2);
        // The target stays 24 pixels across however thin the track.
        expect(tester.getSize(handles()).width, 24);
      }

      await pump(
        tester,
        NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]),
        defaults: const NebaDefaults(size: NebaSize.xl),
      );
      expect(rectOf(tester, 'One').width, (408 - 12) / 2);
    });

    testWidgets('asks for a bounded width and height', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          SingleChildScrollView(child: NebaPanes(children: <NebaPane>[pane('One'), pane('Two')])),
        ),
      );

      final Object? error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(error.toString(), contains('NebaPanes was given an unbounded width or height'));
    });
  });

  group('handles', () {
    testWidgets('draws a hairline in the border colour at rest', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      final (BoxDecoration tint, BoxDecoration line) = colorsOf(tester);
      expect(tint.color, const Color(0x00000000));
      expect(line.color, tokens.border);
      expect(
        tester.getSize(
          find.descendant(of: handles(), matching: find.byType(AnimatedContainer)).last,
        ),
        const Size(1, 208),
      );
    });

    testWidgets('lights the track and the hairline under the pointer, in its family', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPanes(color: NebaColor.success, children: <NebaPane>[pane('One'), pane('Two')]),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(handles()));
      addTearDown(mouse.removePointer);
      await tester.pump();

      final NebaColorRoles success = tokens.roles(NebaColor.success);
      final (BoxDecoration tint, BoxDecoration line) = colorsOf(tester);
      expect(tint.color, success.soft);
      expect(line.color, success.accent);
    });

    testWidgets('lights on the frame of a press and drains back slowly', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await tester.pump();

      AnimatedContainer track = tester.widget<AnimatedContainer>(
        find.descendant(of: handles(), matching: find.byType(AnimatedContainer)).first,
      );
      expect((track.decoration! as BoxDecoration).color, primary.soft);
      expect(track.duration, Duration.zero);

      await press.up();
      await tester.pump();

      track = tester.widget<AnimatedContainer>(
        find.descendant(of: handles(), matching: find.byType(AnimatedContainer)).first,
      );
      expect((track.decoration! as BoxDecoration).color, const Color(0x00000000));
      expect(track.duration, NebaScale.durationFill);
      await tester.pumpAndSettle();
    });

    testWidgets('shows the focus ring for keyboard focus only, inside the track', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      NebaFocusRing ring() {
        return tester.widget<NebaFocusRing>(
          find.descendant(of: handles(), matching: find.byType(NebaFocusRing)),
        );
      }

      expect(ring().visible, isFalse);
      expect(ring().offset, -focusRingWidth);
      expect(ring().color, primary.ring);

      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      handleFocus(tester).requestFocus();
      await tester.pump();

      expect(ring().visible, isTrue);
      expect(colorsOf(tester).$2.color, primary.accent);
    });

    testWidgets('names each handle in the locale\'s words, or by handleLabel', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      addTearDown(resetNebaMessages);

      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));
      expect(find.bySemanticsLabel('Resize panes'), findsOneWidget);

      registerNebaMessages('ko', ko);
      await pump(
        tester,
        NebaPanes(locale: const Locale('ko'), children: <NebaPane>[pane('One'), pane('Two')]),
      );
      expect(find.bySemanticsLabel('패널 크기 조절'), findsOneWidget);

      await pump(
        tester,
        NebaPanes(handleLabel: 'Resize sidebar', children: <NebaPane>[pane('One'), pane('Two')]),
      );
      expect(find.bySemanticsLabel('Resize sidebar'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a name of its own, per handle', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaPanes(
          handleLabelBuilder: (int index) => 'Resize column ${index + 1}',
          children: <NebaPane>[pane('One'), pane('Two'), pane('Three')],
        ),
      );

      expect(find.bySemanticsLabel('Resize column 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Resize column 2'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is a slider whose value is the share of the pane before it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));
      // How far one key press goes depends on how long a pixel is, which the
      // handles hear about once the layout has run.
      await tester.pump();

      expect(
        tester.getSemantics(handles()),
        matchesSemantics(
          label: 'Resize panes',
          value: '50%',
          increasedValue: '54%',
          decreasedValue: '46%',
          textDirection: TextDirection.ltr,
          isSlider: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasFocusAction: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );

      tester.semantics.increase(find.semantics.byLabel('Resize panes'));
      await tester.pump();
      expect(shares(tester), <int>[54]);
      semantics.dispose();
    });

    testWidgets('says its share once a split with a length has measured itself', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', defaultSize: const NebaPaneSize.pixels(120)),
            pane('Two'),
          ],
        ),
      );
      await tester.pump();

      expect(tester.getSemantics(handles()).value, '30%');
      semantics.dispose();
    });
  });

  group('resizing', () {
    testWidgets('takes the focus at the handle', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      expect(handleFocus(tester).canRequestFocus, isTrue);
      expect(handleFocus(tester).skipTraversal, isFalse);
    });

    testWidgets('moves the boundary with the arrow keys', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // One press is 16 pixels, which is four percent of the 400 on offer.
      expect(shares(tester), <int>[54]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(shares(tester), <int>[46]);
    });

    testWidgets('moves a flat handle with the up and down arrows', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          orientation: NebaOrientation.vertical,
          children: <NebaPane>[pane('One'), pane('Two')],
        ),
      );

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Sixteen of the 200 there are to share.
      expect(shares(tester, vertical: true), <int>[58]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(shares(tester, vertical: true), <int>[42]);
    });

    testWidgets('moves the boundary towards the arrow pressed under right to left', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]),
        textDirection: TextDirection.rtl,
      );

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      // The first pane is on the right, so moving the boundary left grows it.
      expect(shares(tester), <int>[54]);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(shares(tester), <int>[46]);
    });

    testWidgets('holds a pane at its own minimum', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', minSize: const NebaPaneSize.pixels(192)),
            pane('Two'),
          ],
        ),
      );

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(shares(tester), <int>[48]);
    });

    // A pane's floor is its neighbour's ceiling: dragging one open has to stop
    // where the other would go under its own minimum.
    testWidgets('holds a pane at its neighbour\'s minimum', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One'),
            pane('Two', minSize: const NebaPaneSize.pixels(192)),
          ],
        ),
      );

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(shares(tester), <int>[52]);
    });

    testWidgets('holds a pane at its maximum, given as a length or a percentage', (
      WidgetTester tester,
    ) async {
      for (final NebaPaneSize max in const <NebaPaneSize>[
        NebaPaneSize.pixels(208),
        NebaPaneSize.percent(52),
      ]) {
        await pump(
          tester,
          NebaPanes(
            key: UniqueKey(),
            children: <NebaPane>[
              pane('One', maxSize: max),
              pane('Two'),
            ],
          ),
        );

        handleFocus(tester).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(shares(tester), <int>[52]);
      }
    });

    testWidgets('reports every pane, in percent, on each key press', (WidgetTester tester) async {
      final List<List<double>> resized = <List<double>>[];
      final List<List<double>> ended = <List<double>>[];

      await pump(
        tester,
        NebaPanes(
          onResize: resized.add,
          onResizeEnd: ended.add,
          children: <NebaPane>[pane('One'), pane('Two')],
        ),
      );

      handleFocus(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

      expect(resized.single.map((double share) => share.round()), <int>[54, 46]);
      expect(ended.single.map((double share) => share.round()), <int>[54, 46]);
    });

    testWidgets('does not move, and is out of the focus order, when not resizable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<double>> ended = <List<double>>[];

      await pump(
        tester,
        NebaPanes(
          resizable: false,
          onResizeEnd: ended.add,
          children: <NebaPane>[pane('One'), pane('Two')],
        ),
      );

      expect(handleFocus(tester).canRequestFocus, isFalse);
      // A rule as wide as its track, with no target past it.
      expect(tester.getRect(handles()), const Rect.fromLTWH(200, 0, 8, 208));
      expect(
        tester.getSemantics(handles()),
        matchesSemantics(
          label: 'Resize panes',
          value: '50%',
          textDirection: TextDirection.ltr,
          isSlider: true,
          hasEnabledState: true,
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(40, 0));
      await press.up();
      await tester.pump();

      expect(shares(tester), <int>[50]);
      expect(ended, isEmpty);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(handles()));
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(colorsOf(tester).$1.color, const Color(0x00000000));
      expect(colorsOf(tester).$2.color, tokens.border);
      semantics.dispose();
    });
  });

  group('dragging', () {
    testWidgets('follows the pointer, reporting every move and the end once', (
      WidgetTester tester,
    ) async {
      final List<List<double>> resized = <List<double>>[];
      final List<List<double>> ended = <List<double>>[];

      await pump(
        tester,
        NebaPanes(
          onResize: resized.add,
          onResizeEnd: ended.add,
          children: <NebaPane>[pane('One'), pane('Two')],
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(20, 0));
      await press.moveBy(const Offset(20, 0));
      await tester.pump();

      expect(shares(tester), <int>[60]);
      expect(resized, hasLength(2));
      expect(ended, isEmpty);

      await press.up();
      await tester.pump();

      expect(ended.single.map((double share) => share.round()), <int>[60, 40]);
    });

    testWidgets('takes the press from anywhere in its 24-pixel target', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      // Eight pixels into the first pane, which the target lies over.
      final TestGesture press = await tester.startGesture(const Offset(193, 100));
      await press.moveBy(const Offset(-40, 0));
      await press.up();
      await tester.pump();

      expect(shares(tester), <int>[40]);
    });

    testWidgets('moves the boundary the way the pointer went under right to left', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]),
        textDirection: TextDirection.rtl,
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(-40, 0));
      await press.up();
      await tester.pump();

      // The first pane is on the right, and the boundary went left with the
      // pointer, so it grew.
      expect(shares(tester), <int>[60]);
      expect(rectOf(tester, 'Two').width, 160);
    });

    // At half size, a hand that moves 20 pixels across the screen has moved
    // the boundary 40 of the split's own, which is ten percent of 400.
    testWidgets('follows the pointer inside a scaled ancestor', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: Transform.scale(
              scale: 0.5,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 408,
                height: 208,
                child: NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]),
              ),
            ),
          ),
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(20, 0));
      await press.up();
      await tester.pump();

      expect(shares(tester), <int>[60]);
    });

    testWidgets('holds a drag at the bounds', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('One', minSize: const NebaPaneSize.pixels(120)),
            pane('Two', minSize: const NebaPaneSize.percent(25)),
          ],
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(-300, 0));
      await tester.pump();
      expect(rectOf(tester, 'One').width, 120);

      await press.moveBy(const Offset(600, 0));
      await tester.pump();
      expect(rectOf(tester, 'Two').width, 100);

      await press.up();
    });

    // The React handle is `touch-action: none` with a captured pointer, so a
    // finger on it never starts a scroll; claiming the press is the same.
    testWidgets('claims the press from a scroll view around it', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          ListView(
            controller: controller,
            children: <Widget>[
              SizedBox(
                height: 300,
                child: NebaPanes(
                  orientation: NebaOrientation.vertical,
                  children: <NebaPane>[pane('One'), pane('Two')],
                ),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(0, -60));
      await press.up();
      await tester.pumpAndSettle();

      expect(controller.offset, 0);
      expect(rectOf(tester, 'One').height, 146 - 60);
    });

    // A field being typed in beside the split keeps the focus while the bar
    // is dragged, and a desktop draws no ring on a bar that was only dragged.
    testWidgets('leaves the focus where it was', (WidgetTester tester) async {
      final FocusNode field = FocusNode(debugLabel: 'field');
      addTearDown(field.dispose);

      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            NebaPane(
              child: Focus(focusNode: field, child: const Text('One')),
            ),
            pane('Two'),
          ],
        ),
      );
      field.requestFocus();
      await tester.pump();

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(40, 0));
      await press.up();
      await tester.pump();

      expect(shares(tester), <int>[60]);
      expect(field.hasFocus, isTrue);
      expect(handleFocus(tester).hasFocus, isFalse);
    });

    // A desktop shows a focus highlight for any focus, so a bar that took the
    // focus on a press would be left ringed after every drag.
    testWidgets('leaves no ring and no light after a mouse drag on a desktop', (
      WidgetTester tester,
    ) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });

      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(handles()),
        kind: PointerDeviceKind.mouse,
      );
      await mouse.moveBy(const Offset(40, 0));
      await mouse.up();
      await mouse.moveTo(const Offset(700, 500));
      await tester.pumpAndSettle();

      expect(shares(tester), <int>[60]);
      expect(
        tester
            .widget<NebaFocusRing>(
              find.descendant(of: handles(), matching: find.byType(NebaFocusRing)),
            )
            .visible,
        isFalse,
      );
      expect(colorsOf(tester).$1.color, const Color(0x00000000));
      expect(colorsOf(tester).$2.color, tokens.border);
      await mouse.removePointer();
    });

    testWidgets('ignores a secondary button', (WidgetTester tester) async {
      await pump(tester, NebaPanes(children: <NebaPane>[pane('One'), pane('Two')]));

      final TestGesture press = await tester.startGesture(
        tester.getCenter(handles()),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await press.moveBy(const Offset(40, 0));
      await press.up();
      await tester.pump();

      expect(shares(tester), <int>[50]);
    });

    // A drag the split never finished must not tell its owner it did, from a
    // widget already on its way out of the tree.
    testWidgets('reports no end when it is removed mid-drag', (WidgetTester tester) async {
      final List<List<double>> ended = <List<double>>[];

      await pump(
        tester,
        NebaPanes(onResizeEnd: ended.add, children: <NebaPane>[pane('One'), pane('Two')]),
      );

      final TestGesture press = await tester.startGesture(tester.getCenter(handles()));
      await press.moveBy(const Offset(40, 0));
      await tester.pump();

      await tester.pumpWidget(host(const SizedBox()));
      await press.moveBy(const Offset(40, 0));
      await press.up();
      await tester.pump();

      expect(ended, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('nesting', () {
    testWidgets('lays out a split inside a pane', (WidgetTester tester) async {
      await pump(
        tester,
        NebaPanes(
          children: <NebaPane>[
            pane('Sidebar'),
            const NebaPane(
              child: NebaPanes(
                orientation: NebaOrientation.vertical,
                children: <NebaPane>[
                  NebaPane(child: Text('Editor')),
                  NebaPane(child: Text('Terminal')),
                ],
              ),
            ),
          ],
        ),
      );

      expect(handles(), findsNWidgets(2));
      expect(rectOf(tester, 'Editor'), const Rect.fromLTWH(208, 0, 200, 100));
      expect(rectOf(tester, 'Terminal'), const Rect.fromLTWH(208, 108, 200, 100));
    });
  });
}
