/// A field's label on the field's own top edge, and the edge drawn around it:
/// the React package's `internal/notch.tsx` and the rules under "The notch" in
/// its stylesheet.
///
/// A label standing on the edge needs a gap in everything that edge is drawn
/// with: the hairline, the plate's top light and the focus ring. None of the
/// three can be cut out of a `NebaSheet`, so a notched shell draws its sheet
/// with no edge of its own and [NebaNotch] draws one in three pieces: the
/// start, as wide as the corner's radius, so the gap opens where the top edge
/// stops curving; the gap, as wide as the label; and the end, which takes the
/// rest. The gap is the label's own laid-out width rather than a measured
/// string, so it is right in the first frame and follows the label when the
/// text or the font changes.
///
/// A `float` label at rest sits inside the field where the text would start,
/// set in the control's own type, with the gap closed over it. It travels to
/// the edge on its position and its font size, set again at every size on the
/// way rather than scaled, so no frame of it is a resampled picture of the
/// word. Every press goes through it to the field underneath.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;
import 'dart:ui' show ClipOp, lerpDouble;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The space on each side of the label, inside the gap.
const Map<NebaSize, double> notchGap = <NebaSize, double>{
  NebaSize.xs: 3,
  NebaSize.sm: 3,
  NebaSize.md: 4,
  NebaSize.lg: 4,
  NebaSize.xl: 5,
};

/// The label's line box on the edge. The label is centred on the edge line by
/// it, so half of it is how far the label stands above the field.
const Map<NebaSize, double> notchFloatLeading = <NebaSize, double>{
  NebaSize.xs: 12,
  NebaSize.sm: 14,
  NebaSize.md: 16,
  NebaSize.lg: 16,
  NebaSize.xl: 18,
};

/// The room a field's end adornments take from a resting label: each one's
/// width in ems of the control's text, and the shell's gap in front of it.
/// An icon is 1.2 ems. Nothing at the end is no room at all.
double nebaNotchRestEnd(NebaSize size, List<double> widths) {
  if (widths.isEmpty) {
    return 0;
  }

  final double ems = widths.fold(0, (double total, double width) => total + width);

  return ems * NebaScale.controlText[size]! + widths.length * NebaScale.gap[size]!;
}

/// The numbers a notch at one size is laid out with.
@immutable
class NebaNotchGeometry {
  /// A notch's numbers, written out.
  const NebaNotchGeometry({
    required this.radius,
    required this.gap,
    required this.floatSize,
    required this.floatLeading,
    required this.restSize,
    required this.restLeading,
    required this.restX,
    this.firstLine,
    this.restEnd = 0,
  });

  /// The numbers for a field of [size], [density] and [variant].
  ///
  /// [firstLine] is how far the first line of text sits below the shell's
  /// inner edge, for a field whose text starts at the top rather than in the
  /// middle, a multiline one; [restEnd] is what is drawn at the shell's end,
  /// from [nebaNotchRestEnd].
  factory NebaNotchGeometry.of({
    required NebaTokens tokens,
    required NebaSize size,
    required NebaDensity density,
    required NebaVariant variant,
    double? firstLine,
    double restEnd = 0,
  }) {
    // An outline shell keeps a hairline's room, transparent while the notch
    // draws its edge, and the notch is measured from its outer edge.
    final double border = variant == NebaVariant.outline ? 1 : 0;
    final double radius = tokens.radius[size]!;
    final double gap = notchGap[size]!;

    return NebaNotchGeometry(
      radius: radius,
      gap: gap,
      floatSize: NebaScale.metaText[size]!,
      floatLeading: notchFloatLeading[size]!,
      restSize: NebaScale.controlText[size]!,
      restLeading: NebaScale.controlLeading[size]!,
      // Where the text starts, measured from where the label already is.
      restX: border + NebaScale.paddingX[density]![size]! - radius - gap,
      firstLine: firstLine == null ? null : border + firstLine,
      restEnd: restEnd,
    );
  }

  /// The corner's radius, and the width of the edge before the gap.
  final double radius;

  /// The space on each side of the label, inside the gap.
  final double gap;

  /// The label's size on the edge.
  final double floatSize;

  /// The label's line box on the edge.
  final double floatLeading;

  /// The label's size at rest: the control's own text.
  final double restSize;

  /// The label's line box at rest.
  final double restLeading;

  /// How far a resting label moves along from where it stands on the edge, to
  /// start where the text does.
  final double restX;

  /// Where a resting label's line box starts, from the field's top edge; a
  /// single line is centred instead.
  final double? firstLine;

  /// What a resting label stops short of at the field's end.
  final double restEnd;

  /// Where the label's line box starts on the edge: centred on the hairline.
  double get edgeTop => 0.5 - floatLeading / 2;

  /// Where a resting label's line box starts in a field [height] tall.
  double restTop(double height) => firstLine ?? height / 2 - restLeading / 2;

  @override
  bool operator ==(Object other) {
    return other is NebaNotchGeometry &&
        other.radius == radius &&
        other.gap == gap &&
        other.floatSize == floatSize &&
        other.floatLeading == floatLeading &&
        other.restSize == restSize &&
        other.restLeading == restLeading &&
        other.restX == restX &&
        other.firstLine == firstLine &&
        other.restEnd == restEnd;
  }

  @override
  int get hashCode => Object.hash(
    radius,
    gap,
    floatSize,
    floatLeading,
    restSize,
    restLeading,
    restX,
    firstLine,
    restEnd,
  );
}

/// The colours of a notch's edge in one state.
@immutable
class NebaNotchLook {
  /// An edge in [line], with [top] along its top.
  const NebaNotchLook({required this.line, required this.top});

  /// What the edge of a [variant] field looks like: an outline's hairline in
  /// its family, the ring's colour while the field holds the focus; a solid
  /// field's white plate edge; nothing for `text`. A read-only edge does not
  /// answer the pointer or the focus, and a disabled one goes grey or away.
  factory NebaNotchLook.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required NebaVariant variant,
    required bool disabled,
    required bool readOnly,
    required bool hovered,
    required bool focused,
  }) {
    return switch (variant) {
      NebaVariant.outline => NebaNotchLook(
        line: disabled
            ? tokens.disabledBorder
            : readOnly
            ? roles.line
            : focused
            ? roles.ring
            : hovered
            ? roles.lineHover
            : roles.line,
        top: disabled ? transparent : tokens.plateTop,
      ),
      NebaVariant.solid => NebaNotchLook(
        line: disabled ? transparent : tokens.plateEdge,
        top: disabled ? transparent : tokens.plateTop,
      ),
      NebaVariant.text => const NebaNotchLook(line: transparent, top: transparent),
    };
  }

  /// The hairline.
  final Color line;

  /// The light along the top, under the hairline as a sheet's plate is.
  final Color top;

  @override
  bool operator ==(Object other) {
    return other is NebaNotchLook && other.line == line && other.top == top;
  }

  @override
  int get hashCode => Object.hash(line, top);
}

/// [child], a field's shell drawn with no edge of its own, with its edge drawn
/// around [label] standing on it.
class NebaNotch extends StatelessWidget {
  /// A notch around [label] on [child]'s top edge.
  const NebaNotch({
    required this.label,
    required this.geometry,
    required this.look,
    required this.resting,
    required this.ring,
    required this.ink,
    required this.restInk,
    required this.child,
    super.key,
  });

  /// The label, usually a `Text`. One line, cut short with an ellipsis.
  final Widget label;

  /// The numbers it is laid out with.
  final NebaNotchGeometry geometry;

  /// The edge's colours.
  final NebaNotchLook look;

  /// Whether the label is down in the field rather than on the edge.
  final bool resting;

  /// The focus ring's colour, transparent while it is not shown.
  final Color ring;

  /// The label's colour on the edge.
  final Color ink;

  /// The label's colour at rest, the placeholder's.
  final Color restInk;

  /// The shell.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaNotchGeometry g = geometry;
    final _NotchPaint target = _NotchPaint(
      rest: resting ? 1 : 0,
      line: look.line,
      top: look.top,
      ring: ring,
      ink: resting ? restInk : ink,
    );

    return TweenAnimationBuilder<_NotchPaint>(
      tween: _NotchPaintTween(end: target),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, _NotchPaint paint, Widget? shell) {
        final double size = lerpDouble(g.floatSize, g.restSize, paint.rest)!;
        final double leading = lerpDouble(g.floatLeading, g.restLeading, paint.rest)!;

        return _NotchLayout(
          geometry: g,
          paint: paint,
          textDirection: Directionality.of(context),
          children: <Widget>[
            shell!,
            IgnorePointer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: g.gap),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: size,
                    height: leading / size,
                    leadingDistribution: TextLeadingDistribution.even,
                    fontWeight: FontWeight.w500,
                    color: paint.ink,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: label,
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// The width a notched field keeps for its label, the React package's
/// `NotchFrame` sizer: the label at the size it is drawn on the edge, with the
/// corner and the gap on each side of it, and for a label that can rest, at
/// the size it rests at, from where the text starts to short of what is drawn
/// at the end. Never painted; `NebaFieldWidth` reads its width.
class NebaNotchSizer extends StatelessWidget {
  /// The room [label] needs on a field of [size], [density] and [variant].
  const NebaNotchSizer({
    required this.label,
    required this.size,
    required this.density,
    required this.variant,
    this.rests = false,
    this.restEnd = 0,
    super.key,
  });

  /// The label.
  final Widget label;

  /// The field's size.
  final NebaSize size;

  /// The field's density.
  final NebaDensity density;

  /// The field's variant.
  final NebaVariant variant;

  /// Whether the label can come down into the field.
  final bool rests;

  /// What a resting label stops short of at the field's end.
  final double restEnd;

  @override
  Widget build(BuildContext context) {
    final NebaNotchGeometry g = NebaNotchGeometry.of(
      tokens: NebaTheme.of(context),
      size: size,
      density: density,
      variant: variant,
      restEnd: restEnd,
    );
    final double side = g.radius + g.gap;
    final Widget label = this.label;

    Widget copy(double fontSize, double start, double end) {
      final TextStyle size = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
      final Widget sample;

      if (label is Text) {
        // The same words drawn as a `RichText`, which reserves the same width
        // and leaves nothing for a `find.text` to match twice in a caller's
        // tests. Only a label that is not a `Text` is built a second time.
        final TextStyle style = DefaultTextStyle.of(context).style.merge(label.style).merge(size);

        sample = RichText(
          maxLines: 1,
          softWrap: false,
          textScaler: label.textScaler ?? MediaQuery.textScalerOf(context),
          text: TextSpan(
            style: style,
            text: label.data,
            children: label.textSpan == null ? null : <InlineSpan>[label.textSpan!],
          ),
        );
      } else {
        sample = DefaultTextStyle.merge(style: size, maxLines: 1, softWrap: false, child: label);
      }

      return Padding(
        padding: EdgeInsetsDirectional.only(start: math.max(0, start), end: math.max(0, end)),
        child: sample,
      );
    }

    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          copy(g.floatSize, side, side),
          if (rests) copy(g.restSize, side + g.restX, side + g.restEnd),
        ],
      ),
    );
  }
}

/// Everything about a notch that eases: how far down the label is, and the
/// colours.
@immutable
class _NotchPaint {
  const _NotchPaint({
    required this.rest,
    required this.line,
    required this.top,
    required this.ring,
    required this.ink,
  });

  /// `0` on the edge, `1` at rest.
  final double rest;
  final Color line;
  final Color top;
  final Color ring;
  final Color ink;

  /// The gap's own top line: open on the edge, closed over a resting label.
  Color get gapLine => line.withValues(alpha: line.a * rest);

  /// The gap's own top light.
  Color get gapTop => top.withValues(alpha: top.a * rest);

  static _NotchPaint lerp(_NotchPaint a, _NotchPaint b, double t) {
    return _NotchPaint(
      rest: lerpDouble(a.rest, b.rest, t)!,
      line: Color.lerp(a.line, b.line, t)!,
      top: Color.lerp(a.top, b.top, t)!,
      ring: Color.lerp(a.ring, b.ring, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _NotchPaint &&
        other.rest == rest &&
        other.line == line &&
        other.top == top &&
        other.ring == ring &&
        other.ink == ink;
  }

  @override
  int get hashCode => Object.hash(rest, line, top, ring, ink);
}

class _NotchPaintTween extends Tween<_NotchPaint> {
  _NotchPaintTween({super.end});

  @override
  _NotchPaint lerp(double t) => _NotchPaint.lerp(begin!, end!, t);
}

/// The shell and the label, with the edge painted between the two.
class _NotchLayout extends MultiChildRenderObjectWidget {
  const _NotchLayout({
    required this.geometry,
    required this.paint,
    required this.textDirection,
    required super.children,
  });

  final NebaNotchGeometry geometry;
  final _NotchPaint paint;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderNotch(geometry: geometry, paint: paint, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderNotch renderObject) {
    renderObject
      ..geometry = geometry
      ..notchPaint = paint
      ..textDirection = textDirection;
  }
}

class _NotchParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderNotch extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _NotchParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _NotchParentData> {
  _RenderNotch({
    required NebaNotchGeometry geometry,
    required _NotchPaint paint,
    required TextDirection textDirection,
  }) : _geometry = geometry,
       _paint = paint,
       _textDirection = textDirection;

  NebaNotchGeometry _geometry;
  set geometry(NebaNotchGeometry value) {
    if (_geometry != value) {
      _geometry = value;
      markNeedsLayout();
    }
  }

  _NotchPaint _paint;
  set notchPaint(_NotchPaint value) {
    if (_paint == value) {
      return;
    }

    final bool moved = _paint.rest != value.rest;
    _paint = value;

    if (moved) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  RenderBox get _shell => firstChild!;
  RenderBox get _label => childAfter(firstChild!)!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _NotchParentData) {
      child.parentData = _NotchParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _shell.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _shell.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _shell.getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _shell.getMaxIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => _shell.getDryLayout(constraints);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _shell.getDistanceToActualBaseline(baseline);
  }

  @override
  void performLayout() {
    final NebaNotchGeometry g = _geometry;
    final double rest = _paint.rest;

    _shell.layout(constraints, parentUsesSize: true);
    size = _shell.size;

    // At rest the label starts where the text does and stops short of what
    // is drawn at the end, so its column gives up both.
    final double less = rest * (g.restX + g.restEnd);
    _label.layout(
      BoxConstraints(maxWidth: math.max(0, size.width - 2 * g.radius - less)),
      parentUsesSize: true,
    );

    final double start = g.radius + rest * g.restX;
    final double x = _textDirection == TextDirection.ltr
        ? start
        : size.width - start - _label.size.width;
    final double y = lerpDouble(g.edgeTop, g.restTop(size.height), rest)!;

    (_label.parentData! as _NotchParentData).offset = Offset(x, y);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The label lets every press through, so only the shell is hit.
    return _shell.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(_shell, offset);
    _paintEdge(context.canvas, offset);

    final _NotchParentData label = _label.parentData! as _NotchParentData;
    context.paintChild(_label, offset + label.offset);
  }

  void _paintEdge(Canvas canvas, Offset offset) {
    final NebaNotchGeometry g = _geometry;
    final _NotchPaint paint = _paint;
    final Rect box = offset & size;
    final RRect shape = RRect.fromRectAndRadius(box, Radius.circular(g.radius));
    final double width = _label.size.width;
    final double gapStart = _textDirection == TextDirection.ltr
        ? box.left + g.radius
        : box.right - g.radius - width;
    final double gapEnd = gapStart + width;

    // Each layer is drawn twice: everywhere but over the gap in its own
    // colour, and over the gap in the gap's, which is transparent while the
    // label stands there. The two clips share their edges exactly, so nothing
    // doubles up and nothing is left out where they meet.
    void split(Rect gap, Color whole, Color inGap, void Function(Color color) draw) {
      if (whole.a > 0) {
        canvas.save();
        canvas.clipRect(gap, clipOp: ClipOp.difference, doAntiAlias: false);
        draw(whole);
        canvas.restore();
      }

      if (inGap.a > 0) {
        canvas.save();
        canvas.clipRect(gap, doAntiAlias: false);
        draw(inGap);
        canvas.restore();
      }
    }

    // The top light, a sheet's plate: the shape minus itself a pixel down.
    final Path topBand = Path.combine(
      PathOperation.difference,
      Path()..addRRect(shape),
      Path()..addRRect(shape.shift(const Offset(0, 1))),
    );
    split(Rect.fromLTRB(gapStart, box.top, gapEnd, box.top + 1), paint.top, paint.gapTop, (
      Color color,
    ) {
      canvas.drawPath(topBand, Paint()..color = color);
    });

    // The hairline, a pixel just inside the edge.
    split(Rect.fromLTRB(gapStart, box.top, gapEnd, box.top + 1), paint.line, paint.gapLine, (
      Color color,
    ) {
      canvas.drawRRect(
        shape.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color,
      );
    });

    // The ring, flush outside the edge, as a field's ring is. A field with the
    // focus in it has its label on the edge, so the top of the gap is always
    // open while the ring is drawn.
    split(
      Rect.fromLTRB(gapStart, box.top - focusRingWidth, gapEnd, box.top),
      paint.ring,
      transparent,
      (Color color) {
        canvas.drawRRect(
          shape.inflate(focusRingWidth / 2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = focusRingWidth
            ..color = color,
        );
      },
    );
  }
}
