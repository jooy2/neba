// nebaPlaceFloating: Base UI's positioner, checked on the numbers rather
// than through a widget — the side, the alignment, the flip, the slide and
// the wedge.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/floating.dart';

void main() {
  const Size bounds = Size(400, 400);
  const Rect anchor = Rect.fromLTWH(100, 100, 40, 20);
  const Size popup = Size(60, 30);

  NebaFloatingPlacement place({
    Rect anchor = anchor,
    Size popup = popup,
    Size bounds = bounds,
    NebaSide side = NebaSide.bottom,
    NebaAlign align = NebaAlign.center,
    TextDirection textDirection = TextDirection.ltr,
    double sideOffset = 6,
    double alignOffset = 0,
    NebaFloatingArrow? arrow,
  }) {
    return nebaPlaceFloating(
      anchor: anchor,
      popup: popup,
      bounds: bounds,
      side: side,
      align: align,
      textDirection: textDirection,
      sideOffset: sideOffset,
      alignOffset: alignOffset,
      arrow: arrow,
    );
  }

  group('side and align', () {
    test('goes on each side, the offset away, centred on the anchor', () {
      expect(place().rect, const Rect.fromLTWH(90, 126, 60, 30));
      expect(place(side: NebaSide.top).rect, const Rect.fromLTWH(90, 64, 60, 30));
      expect(place(side: NebaSide.left).rect, const Rect.fromLTWH(34, 95, 60, 30));
      expect(place(side: NebaSide.right).rect, const Rect.fromLTWH(146, 95, 60, 30));
    });

    test('lines up with the start or the end edge, which flip right to left', () {
      expect(place(align: NebaAlign.start).rect.left, 100);
      expect(place(align: NebaAlign.end).rect.right, 140);
      expect(place(align: NebaAlign.start, textDirection: TextDirection.rtl).rect.right, 140);
      expect(place(align: NebaAlign.end, textDirection: TextDirection.rtl).rect.left, 100);
    });

    test('puts start at the top on a side edge, in either direction', () {
      for (final TextDirection direction in TextDirection.values) {
        expect(
          place(side: NebaSide.right, align: NebaAlign.start, textDirection: direction).rect.top,
          100,
        );
      }
    });

    test('moves inwards from the aligned edge by alignOffset', () {
      expect(place(align: NebaAlign.start, alignOffset: 10).rect.left, 110);
      expect(place(align: NebaAlign.end, alignOffset: 10).rect.right, 130);
      expect(
        place(align: NebaAlign.start, alignOffset: 10, textDirection: TextDirection.rtl).rect.right,
        130,
      );
    });
  });

  group('room', () {
    test('flips to the opposite side when its own has no room', () {
      final NebaFloatingPlacement placement = place(anchor: const Rect.fromLTWH(100, 370, 40, 20));

      expect(placement.side, NebaSide.top);
      expect(placement.rect.bottom, 370 - 6);
    });

    test('takes the side along its axis that spills least when nothing fits', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(100, 40, 40, 20),
        popup: const Size(390, 390),
      );

      expect(placement.side, NebaSide.bottom);
    });

    test('turns sideways only once neither side along its axis has room', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(100, 40, 40, 20),
        popup: const Size(60, 80),
        bounds: const Size(400, 100),
      );

      expect(placement.side, NebaSide.right);
    });

    test('tries its other alignment before the other side', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(340, 100, 40, 20),
        align: NebaAlign.start,
      );

      expect(placement.side, NebaSide.bottom);
      expect(placement.rect.right, 380);
    });

    test('slides along its edge to keep the padding from the window', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(0, 100, 20, 20),
        popup: const Size(100, 30),
      );

      expect(placement.rect.left, nebaCollisionPadding);
    });

    test('stops sliding where it would stop facing the anchor', () {
      const Rect tiny = Rect.fromLTWH(0, 100, 4, 20);

      expect(place(anchor: tiny, popup: const Size(100, 30)).rect.left, 4);
      // With a wedge it keeps the wedge's half-width and the padding over it.
      expect(
        place(
          anchor: tiny,
          popup: const Size(100, 30),
          arrow: const NebaFloatingArrow(size: 10, fill: Color(0xFFFFFFFF)),
        ).rect.left,
        4 - 10,
      );
    });
  });

  group('the wedge', () {
    test('sits against the facing edge of the padding box, over the anchor', () {
      final NebaFloatingPlacement placement = place(
        popup: const Size(100, 40),
        arrow: const NebaFloatingArrow(size: 10, fill: Color(0xFFFFFFFF), border: 1),
      );
      final List<Offset> wedge = placement.arrow!;

      // Pointing up, its tip on the sheet's top edge, its base five pixels in:
      // where `top: -1px` puts it inside a bordered popup.
      expect(wedge[1], const Offset(50, 0));
      expect(wedge[0], const Offset(55, 5));
      expect(wedge[2], const Offset(45, 5));
      expect(placement.rect.left + wedge[1].dx, anchor.center.dx);
    });

    test('pokes a pixel out of a borderless plate', () {
      final NebaFloatingPlacement placement = place(
        side: NebaSide.top,
        popup: const Size(100, 28),
        arrow: const NebaFloatingArrow(size: 8, fill: Color(0xFFFFFFFF)),
      );

      expect(placement.arrow![1].dy, 29);
    });

    test('measures a wedge on a side edge by its height, as the browser does', () {
      final NebaFloatingPlacement placement = place(
        side: NebaSide.right,
        popup: const Size(100, 40),
        arrow: const NebaFloatingArrow(size: 10, fill: Color(0xFFFFFFFF), border: 1),
      );
      final List<Offset> wedge = placement.arrow!;

      // Pointing left, over the anchor's centre, wholly inside the sheet.
      expect(wedge[1].dy + placement.rect.top, moreOrLessEquals(anchor.center.dy));
      expect(wedge[1].dx, lessThan(wedge[0].dx));
      expect(wedge.every((Offset point) => point.dx >= 0), isTrue);
    });

    test('keeps the arrow padding from the corners', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(100, 100, 300, 20),
        popup: const Size(100, 40),
        align: NebaAlign.start,
        arrow: const NebaFloatingArrow(size: 10, fill: Color(0xFFFFFFFF), border: 1),
      );

      // The anchor's centre is past the popup's end, so the wedge stops five
      // pixels from the padding box's end.
      expect(placement.arrow![1].dx, 1 + 98 - 5 - 5);
    });

    test('moves an aligned popup over until its wedge can reach a small anchor', () {
      final NebaFloatingPlacement placement = place(
        anchor: const Rect.fromLTWH(100, 100, 16, 20),
        popup: const Size(100, 40),
        align: NebaAlign.start,
        arrow: const NebaFloatingArrow(size: 10, fill: Color(0xFFFFFFFF), border: 1),
      );

      expect(placement.rect.left, 100 - 3);
      expect(placement.rect.left + placement.arrow![1].dx, 108);
    });
  });
}
