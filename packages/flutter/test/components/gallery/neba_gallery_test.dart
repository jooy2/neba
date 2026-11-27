// NebaGallery: the suite the React package runs on Gallery, asked the way
// Flutter asks it — where each tile is laid out in the four arrangements,
// what reaches each tile's picture, the captions and the pointer treatments
// as the widgets that draw them, the viewer, and what a screen reader hears —
// rather than the elements, the classes and the styles it writes.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/picture.dart';
import 'package:neba/src/internal/viewer.dart';

/// A picture that never arrives, which is all a layout needs.
class _Picture extends ImageProvider<_Picture> {
  _Picture(this.name);

  final String name;

  @override
  Future<_Picture> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_Picture>(this);
  }

  @override
  ImageStreamCompleter loadImage(_Picture key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(Completer<ImageInfo>().future);
  }

  @override
  bool operator ==(Object other) => other is _Picture && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => '_Picture($name)';
}

NebaGalleryItem _item(
  String name, {
  double? ratio,
  String? title,
  String? description,
  int rotate = 0,
  int cols = 1,
  int rows = 1,
  ImageProvider? full,
}) {
  return NebaGalleryItem(
    image: _Picture(name),
    alt: 'Picture $name',
    ratio: ratio,
    title: title,
    description: description,
    rotate: rotate,
    cols: cols,
    rows: rows,
    full: full,
  );
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  /// [gallery] at the top of a window [width] wide with an overlay above it.
  Widget scene(
    Widget gallery, {
    double width = 400,
    double window = 800,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return MediaQuery(
      data: MediaQueryData(size: Size(window, 900)),
      child: Directionality(
        textDirection: textDirection,
        child: Overlay.wrap(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: gallery),
          ),
        ),
      ),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget gallery, {
    double width = 400,
    double window = 800,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      scene(gallery, width: width, window: window, textDirection: textDirection),
    );
  }

  Finder tile(String name) {
    return find.byWidgetPredicate(
      (Widget widget) => widget is NebaImage && widget.image == _Picture(name),
    );
  }

  Rect rectOf(WidgetTester tester, String name) => tester.getRect(tile(name));

  group('rendering', () {
    testWidgets('is a list named by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b')], label: 'Field notes'),
      );

      expect(find.bySemanticsLabel('Field notes'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets("falls back to the locale's word when it is not named", (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a')]));

      expect(find.bySemanticsLabel('Gallery'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('draws every picture with its own alt', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b')]));

      expect(tester.widget<NebaImage>(tile('a')).alt, 'Picture a');
      expect(tester.widget<NebaImage>(tile('b')).alt, 'Picture b');
    });

    testWidgets('draws a picture that is in the set twice, twice', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('a')]));

      expect(tester.takeException(), isNull);
      expect(tile('a'), findsNWidgets(2));
    });

    testWidgets('draws nothing but the empty state for an empty set', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaGallery(items: <NebaGalleryItem>[], empty: Text('No photographs yet')),
      );

      expect(find.text('No photographs yet'), findsOneWidget);
      expect(find.byType(NebaImage), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('grid holds one shape whatever shape the files are', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', ratio: 2 / 3),
            _item('b', ratio: 3 / 2),
          ],
          columns: 2,
          gap: 0,
          ratio: 1,
        ),
      );

      expect(rectOf(tester, 'a'), const Rect.fromLTWH(0, 0, 200, 200));
      expect(rectOf(tester, 'b'), const Rect.fromLTWH(200, 0, 200, 200));
    });

    testWidgets('grid wraps onto rows with the gap between them', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a'), _item('b'), _item('c')],
          columns: 2,
          gap: 10,
        ),
      );

      expect(rectOf(tester, 'a'), const Rect.fromLTWH(0, 0, 195, 195));
      expect(rectOf(tester, 'b'), const Rect.fromLTWH(205, 0, 195, 195));
      expect(rectOf(tester, 'c'), const Rect.fromLTWH(0, 205, 195, 195));
      expect(tester.getSize(find.byType(NebaGallery)), const Size(400, 400));
    });

    testWidgets('masonry keeps each picture in its own proportion', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', ratio: 2), _item('b', ratio: 0.5)],
          layout: NebaGalleryLayout.masonry,
          columns: 2,
          gap: 0,
        ),
      );

      expect(rectOf(tester, 'a').size, const Size(200, 100));
      expect(rectOf(tester, 'b').size, const Size(200, 400));
    });

    testWidgets('masonry deals into the shortest column rather than down the first', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', ratio: 0.5),
            _item('b', ratio: 2),
            _item('c', ratio: 2),
            _item('d', ratio: 1),
          ],
          layout: NebaGalleryLayout.masonry,
          columns: 2,
          gap: 0,
        ),
      );

      // The first row is the first two items; the third goes under the
      // second, which is the shorter column, and so does the fourth.
      expect(rectOf(tester, 'a').topLeft, Offset.zero);
      expect(rectOf(tester, 'b').topLeft, const Offset(200, 0));
      expect(rectOf(tester, 'c').topLeft, const Offset(200, 100));
      expect(rectOf(tester, 'd').topLeft, const Offset(200, 200));
    });

    testWidgets('justified fills each row to the edge at one height', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', ratio: 1),
            _item('b', ratio: 2),
            _item('c', ratio: 2),
          ],
          layout: NebaGalleryLayout.justified,
          rowHeight: 100,
          gap: 0,
        ),
      );

      // 100 and 200 fit beside each other and the third does not, so the
      // first row grows from 300 to 400, each tile by its share of the ratios,
      // and the last keeps the row height.
      final Rect a = rectOf(tester, 'a');
      final Rect b = rectOf(tester, 'b');

      expect(a.height, closeTo(b.height, 0.001));
      expect(a.width + b.width, closeTo(400, 0.001));
      expect(b.width / a.width, closeTo(2, 0.001));
      expect(a.height, closeTo(400 / 3, 0.001));
      expect(rectOf(tester, 'c').size, const Size(200, 100));
    });

    testWidgets('justified keeps a short last row at the row height', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', ratio: 2),
            _item('b', ratio: 2),
            _item('c', ratio: 1),
          ],
          layout: NebaGalleryLayout.justified,
          rowHeight: 100,
          gap: 0,
        ),
      );

      expect(rectOf(tester, 'c'), const Rect.fromLTWH(0, 100, 100, 100));
    });

    testWidgets('quilted lets a tile take more than one cell', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', cols: 2, rows: 2),
            _item('b'),
            _item('c'),
            _item('d'),
          ],
          layout: NebaGalleryLayout.quilted,
          columns: 3,
          rowHeight: 50,
          gap: 10,
        ),
      );

      final double cell = (400 - 20) / 3;

      expect(rectOf(tester, 'a').size.width, closeTo(cell * 2 + 10, 0.001));
      expect(rectOf(tester, 'a').size.height, 110);
      expect(rectOf(tester, 'b').topLeft.dx, closeTo(2 * (cell + 10), 0.001));
      expect(rectOf(tester, 'c').topLeft, Offset(2 * (cell + 10), 60));
      // The fourth finds no room beside the large one and starts a row.
      expect(rectOf(tester, 'd').topLeft, const Offset(0, 120));
    });

    testWidgets('runs from the end under a right-to-left direction', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b')], columns: 2, gap: 0),
        textDirection: TextDirection.rtl,
      );

      expect(rectOf(tester, 'a').left, 200);
      expect(rectOf(tester, 'b').left, 0);
    });

    testWidgets('answers a parent that measures it before laying it out', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        IntrinsicHeight(
          child: NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b')], columns: 2, gap: 0),
        ),
      );

      expect(tester.getSize(find.byType(NebaGallery)), const Size(400, 200));
    });
  });

  group('a turned item', () {
    testWidgets('masonry reserves it on its side', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', ratio: 2, rotate: 90)],
          layout: NebaGalleryLayout.masonry,
          columns: 2,
          gap: 0,
        ),
      );

      expect(rectOf(tester, 'a').size, const Size(200, 400));
    });

    testWidgets('justified grows it in proportion to its turned width', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', ratio: 2, rotate: 90), _item('b', ratio: 1)],
          layout: NebaGalleryLayout.justified,
          rowHeight: 100,
          gap: 0,
        ),
      );

      expect(rectOf(tester, 'a').width, closeTo(50, 0.001));
    });

    testWidgets('grid keeps the layout shape and turns the picture inside it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', ratio: 2, rotate: 90)],
          columns: 2,
          ratio: 1,
        ),
      );

      final NebaImage image = tester.widget<NebaImage>(tile('a'));
      expect(image.ratio, 1);
      expect(image.rotate, 90);
    });
  });

  group('what reaches each picture', () {
    testWidgets('hands an item its own turn, mirror, position and stand-in', (
      WidgetTester tester,
    ) async {
      final _Picture tiny = _Picture('tiny');

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            NebaGalleryItem(
              image: _Picture('a'),
              alt: 'Picture a',
              rotate: 180,
              flip: NebaImageFlip.vertical,
              position: Alignment.topCenter,
              placeholder: NebaImagePlaceholder.image(tiny, blur: 8),
            ),
          ],
        ),
      );

      final NebaImage image = tester.widget<NebaImage>(tile('a'));
      expect(image.rotate, 180);
      expect(image.flip, NebaImageFlip.vertical);
      expect(image.position, Alignment.topCenter);
      expect(image.placeholder?.image, tiny);
    });

    testWidgets('hands every picture the fit, the letterbox and the treatments', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a')],
          fit: BoxFit.contain,
          letterbox: NebaImageLetterbox.blur,
          filter: NebaImageFilter.sepia,
          frame: const NebaImageFrame(mat: 4),
          watermark: const NebaImageWatermark('© Neba'),
          protect: true,
        ),
      );

      final NebaImage image = tester.widget<NebaImage>(tile('a'));
      expect(image.fit, BoxFit.contain);
      expect(image.letterbox, NebaImageLetterbox.blur);
      expect(image.filter, NebaImageFilter.sepia);
      expect(image.frame?.mat, 4);
      expect(image.watermark?.text, '© Neba');
      expect(image.protect, isTrue);
    });

    testWidgets('draws the first tiles as priority pictures when told how many', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b'), _item('c')], priority: 2),
      );

      expect(tester.widget<NebaImage>(tile('a')).priority, isTrue);
      expect(tester.widget<NebaImage>(tile('b')).priority, isTrue);
      expect(tester.widget<NebaImage>(tile('c')).priority, isFalse);
    });

    testWidgets('prioritises nothing by default', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a')]));

      expect(tester.widget<NebaImage>(tile('a')).priority, isFalse);
    });
  });

  group('columns and gap', () {
    testWidgets('takes two, three and four columns by the window', (WidgetTester tester) async {
      final List<NebaGalleryItem> items = <NebaGalleryItem>[
        for (int i = 0; i < 4; i++) _item('$i'),
      ];

      Future<double> widthAt(double window) async {
        await pump(tester, NebaGallery(items: items, gap: 0), width: 600, window: window);

        return rectOf(tester, '0').width;
      }

      expect(await widthAt(400), 300);
      expect(await widthAt(800), 200);
      expect(await widthAt(1100), 150);
    });

    testWidgets('puts the md step of the gap ladder between tiles by default', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a'), _item('b')], columns: 2));

      expect(rectOf(tester, 'b').left - rectOf(tester, 'a').right, NebaGallery.gaps[NebaSize.md]);
    });
  });

  group('caption', () {
    final List<NebaGalleryItem> captioned = <NebaGalleryItem>[
      _item('a', title: 'Alpine lake', description: 'Ronda'),
    ];

    testWidgets('draws none by default', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: captioned));

      expect(find.text('Alpine lake'), findsNothing);
    });

    testWidgets('writes the words under the picture', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: captioned, caption: NebaGalleryCaption.below));

      expect(find.text('Alpine lake'), findsOneWidget);
      expect(find.text('Ronda'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Alpine lake')).dy,
        greaterThan(rectOf(tester, 'a').bottom),
      );
    });

    testWidgets('writes them across the foot of the picture', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: captioned, caption: NebaGalleryCaption.overlay));

      expect(tester.getBottomLeft(find.text('Ronda')).dy, lessThan(rectOf(tester, 'a').bottom));
    });

    testWidgets('brings a hover caption up under a mouse, and keeps it up without one', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaGallery(items: captioned, caption: NebaGalleryCaption.hover));

      double opacity() {
        return tester
            .widget<AnimatedOpacity>(
              find.ancestor(of: find.text('Alpine lake'), matching: find.byType(AnimatedOpacity)),
            )
            .opacity;
      }

      // No mouse is connected, so there is nothing to hover with.
      expect(opacity(), 1);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 800));
      addTearDown(mouse.removePointer);
      await tester.pump();

      expect(opacity(), 0);

      await mouse.moveTo(rectOf(tester, 'a').center);
      await tester.pump();

      expect(opacity(), 1);
    });
    testWidgets('keeps a hover caption down on a desktop before its mouse has moved', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', title: 'Alpine lake')],
          caption: NebaGalleryCaption.hover,
        ),
      );

      final double opacity = tester
          .widget<AnimatedOpacity>(
            find.ancestor(of: find.text('Alpine lake'), matching: find.byType(AnimatedOpacity)),
          )
          .opacity;
      debugDefaultTargetPlatformOverride = null;

      expect(opacity, 0);
    });
  });

  group('hover', () {
    Future<TestGesture> hoverOver(WidgetTester tester, String name) async {
      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: rectOf(tester, name).center);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await tester.pump(NebaScale.durationFill);

      return mouse;
    }

    testWidgets('lifts the tile onto the shadow ladder', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a')]));

      BoxDecoration frame() {
        return tester
                .widget<AnimatedContainer>(
                  find.ancestor(of: tile('a'), matching: find.byType(AnimatedContainer)),
                )
                .decoration!
            as BoxDecoration;
      }

      expect(frame().boxShadow, tokens.elevation(0));

      await hoverOver(tester, 'a');

      expect(frame().boxShadow, tokens.elevation(2));
    });

    testWidgets('zooms the photograph inside a frame that never moves', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a')], hover: NebaGalleryHover.zoom),
      );

      final Rect before = rectOf(tester, 'a');
      await hoverOver(tester, 'a');

      final NebaPictureTreatment treatment = tester.widget<NebaPictureTreatment>(
        find.byType(NebaPictureTreatment),
      );
      expect(treatment.scale, NebaGallery.zoomScale);
      expect(rectOf(tester, 'a'), before);
      expect(find.ancestor(of: tile('a'), matching: find.byType(ClipRRect)), findsWidgets);
    });

    testWidgets('dims the picture', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a')], hover: NebaGalleryHover.dim),
      );
      await hoverOver(tester, 'a');

      expect(
        tester.widget<NebaPictureTreatment>(find.byType(NebaPictureTreatment)).brightness,
        NebaGallery.dimBrightness,
      );
    });

    testWidgets('answers the keyboard focus wherever it answers the pointer', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a')],
          hover: NebaGalleryHover.zoom,
          onItemSelect: (NebaGalleryItem item, int index) {},
        ),
      );

      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);

      Focus.of(tester.element(tile('a'))).requestFocus();
      await tester.pump();
      await tester.pump();

      expect(
        tester.widget<NebaPictureTreatment>(find.byType(NebaPictureTreatment)).scale,
        NebaGallery.zoomScale,
      );
    });

    testWidgets('lays nothing on the picture when told to do nothing', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGallery(items: <NebaGalleryItem>[_item('a')], hover: NebaGalleryHover.none),
      );

      expect(find.byType(NebaPictureTreatment), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
    });
  });

  group('choosing a tile', () {
    testWidgets('draws no button when there is nothing to choose', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaGallery(items: <NebaGalleryItem>[_item('a')]));

      expect(find.bySemanticsLabel(RegExp('Image 1 of 1')), findsNothing);
      expect(find.bySemanticsLabel('Picture a'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('names a tile by its picture and its place in the set', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a'), _item('b')],
          onItemSelect: (NebaGalleryItem item, int index) {},
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Picture b — Image 2 of 2')),
        matchesSemantics(
          isButton: true,
          label: 'Picture b — Image 2 of 2',
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('names a tile by the caption drawn on it, and its place in the set', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a', title: 'Alpine lake', description: 'Ronda')],
          caption: NebaGalleryCaption.below,
          onItemSelect: (NebaGalleryItem item, int index) {},
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Alpine lake Image 1 of 1')),
        matchesSemantics(
          isButton: true,
          label: 'Alpine lake Image 1 of 1',
          hint: 'Ronda',
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('reports the item and its index', (WidgetTester tester) async {
      final List<int> chosen = <int>[];

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[_item('a'), _item('b')],
          columns: 2,
          onItemSelect: (NebaGalleryItem item, int index) => chosen.add(index),
        ),
      );
      await tester.tap(tile('b'));

      expect(chosen, <int>[1]);
    });

    testWidgets('is tabbed through in the order of the items, masonry or not', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaGallery(
          items: <NebaGalleryItem>[
            _item('a', ratio: 0.5),
            _item('b', ratio: 2),
            _item('c', ratio: 2),
          ],
          layout: NebaGalleryLayout.masonry,
          columns: 2,
          onItemSelect: (NebaGalleryItem item, int index) {},
        ),
      );

      Focus.of(tester.element(tile('a'))).requestFocus();
      await tester.pump();
      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();

      expect(Focus.of(tester.element(tile('b'))).hasFocus, isTrue);

      FocusManager.instance.primaryFocus!.nextFocus();
      await tester.pump();

      expect(Focus.of(tester.element(tile('c'))).hasFocus, isTrue);
      semantics.dispose();
    });
  });

  group('the viewer', () {
    final List<NebaGalleryItem> three = <NebaGalleryItem>[
      _item('a', title: 'Alpine lake'),
      _item('b', full: _Picture('b-full')),
      _item('c', ratio: 2, rotate: 90),
    ];

    Future<void> open(WidgetTester tester, String name) async {
      await tester.tap(tile(name));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    NebaViewerPicture shown(WidgetTester tester) {
      return tester.widget<NebaViewerPicture>(find.byType(NebaViewerPicture));
    }

    testWidgets('opens the picture that was chosen', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'a');

      expect(find.byType(NebaViewerSheet), findsOneWidget);
      expect(shown(tester).image, _Picture('a'));
      expect(
        find.descendant(of: find.byType(NebaViewerSheet), matching: find.text('Alpine lake')),
        findsOneWidget,
      );
      expect(find.text('Image 1 of 3'), findsOneWidget);
    });

    testWidgets('moves between pictures on the arrow keys, and stops at the ends', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'a');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(find.text('Image 1 of 3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('Image 2 of 3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('Image 3 of 3'), findsOneWidget);
    });

    testWidgets('moves to the next picture on the left arrow under RTL', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(items: three, preview: true, columns: 3),
        textDirection: TextDirection.rtl,
      );
      await open(tester, 'a');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(find.text('Image 2 of 3'), findsOneWidget);
    });

    testWidgets('says what the picture is as well as where it is', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'a');

      expect(find.bySemanticsLabel('Alpine lake, Image 1 of 3'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(find.bySemanticsLabel('Picture b, Image 2 of 3'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('keeps the focus on a button the press ran out', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'b');

      final Finder next = find.byWidgetPredicate(
        (Widget widget) => widget is NebaIconButton && widget.label == 'Next image',
      );
      await tester.tap(next);
      await tester.pump();

      expect(find.text('Image 3 of 3'), findsOneWidget);
      expect(tester.widget<NebaIconButton>(next).disabled, isTrue);
      expect(tester.widget<NebaIconButton>(next).focusableWhenDisabled, isTrue);
    });

    testWidgets('opens the larger file when the item has one, turned as it is', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'b');

      expect(shown(tester).image, _Picture('b-full'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(shown(tester).quarters, 1);
    });

    testWidgets('carries the watermark and the protection into the viewer', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaGallery(
          items: three,
          preview: true,
          columns: 3,
          watermark: const NebaImageWatermark('© Neba'),
          protect: true,
        ),
      );
      await open(tester, 'a');

      expect(shown(tester).watermark?.text, '© Neba');
      expect(shown(tester).protect, isTrue);
    });

    testWidgets('closes on Escape', (WidgetTester tester) async {
      await pump(tester, NebaGallery(items: three, preview: true, columns: 3));
      await open(tester, 'a');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NebaViewerSheet), findsNothing);
    });
  });
}
