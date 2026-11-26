/// `NebaStack`, things laid over each other so a set reads as a pile.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which way a [NebaStack] grows.
enum NebaStackDirection {
  /// Each item sits under the one before it along the reading direction: a
  /// row of faces, a row of coins.
  horizontal,

  /// The same down the page: a pile seen from the front.
  vertical,

  /// Along the reading direction like [horizontal], dropping each item as it
  /// goes, which is a fanned deck: the item behind shows its corner rather
  /// than its edge. How far it drops is [NebaStack.drop].
  diagonal,
}

/// Which end of a [NebaStack]'s children is at the front of the pile.
enum NebaStackFront {
  /// The first child is on top, so a pile read from its leading edge is read
  /// front to back.
  first,

  /// The last child is on top.
  last,
}

/// Things laid over each other, so a set reads as a pile rather than a row:
/// faces on a shared task, cards in a deck, sheets on a desk.
///
/// The pile takes exactly the room it covers, so what comes after it is laid
/// out against the right width. Each child is passed through untouched;
/// [ring] is drawn by the first Neba widget inside each child that draws a
/// shape, so it follows that shape.
///
/// ```dart
/// NebaStack(ring: true, children: <Widget>[first, second, third])
/// ```
class NebaStack extends StatelessWidget {
  /// A pile of [children].
  const NebaStack({
    required this.children,
    this.direction = NebaStackDirection.horizontal,
    this.overlap,
    this.drop,
    this.size,
    this.max,
    this.total,
    this.overflow,
    this.front = NebaStackFront.first,
    this.scaleStep = 1,
    this.opacityStep = 1,
    this.ring = false,
    this.transition,
    this.stagger = Duration.zero,
    this.durationStep = Duration.zero,
    this.reverse = false,
    super.key,
  }) : assert(max == null || max >= 0),
       assert(total == null || total >= 0);

  /// Which way the pile grows.
  final NebaStackDirection direction;

  /// How far each item sits under the one before it, in logical pixels,
  /// along the axis the pile runs on. Left out, it is a fraction of [size]:
  /// 6, 8, 10, 12 and 14 from `xs` to `xl`, about a third of a control.
  final double? overlap;

  /// How far each item falls on the other axis, in logical pixels. Only
  /// [NebaStackDirection.diagonal] reads it, and it defaults to [overlap].
  final double? drop;

  /// The size of the things being stacked, read only to work out the default
  /// [overlap]. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// How many items are drawn before the rest become one [overflow] item.
  /// Left out, every one is drawn.
  final int? max;

  /// How many there are altogether, when the pile was handed only the first
  /// few. Without it the count is the number of [children].
  final int? total;

  /// What stands in for the ones that did not fit, given how many those are:
  /// one more item at the back of the pile.
  final Widget Function(int hidden)? overflow;

  /// Which end of [children] is at the front.
  final NebaStackFront front;

  /// What each item's size is multiplied by against the one before it in
  /// [children]: `0.94` takes six per cent off at every step. It draws the
  /// item smaller and leaves its room as it was.
  final double scaleStep;

  /// The same for opacity: `0.8` leaves each item four fifths as solid as the
  /// one before it. It multiplies with an entrance's own fade.
  final double opacityStep;

  /// Draws a two-pixel ring in the page's surface colour around each item,
  /// because two shapes of a similar tone laid over each other have no edge
  /// between them at all. The first Neba widget in each child that draws a
  /// shape draws it, around that shape.
  final bool ring;

  /// How each item arrives when it is first built.
  final NebaTransition? transition;

  /// Added to each item's delay in turn, which deals the pile rather than
  /// showing it at once.
  final Duration stagger;

  /// Added to each item's duration in turn. Negative speeds them up, and a
  /// duration never goes below zero.
  final Duration durationStep;

  /// Deals the items from the last to the first. Only the order reverses.
  final bool reverse;

  /// The things being stacked. Each one is one item.
  final List<Widget> children;

  /// The default [overlap] at each size, the React package's `overlapSizes`.
  static const Map<NebaSize, double> overlaps = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 10,
    NebaSize.lg: 12,
    NebaSize.xl: 14,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final double step = overlap ?? overlaps[size]!;
    final double fall = drop ?? step;

    final int? max = this.max;
    final List<Widget> shown = max == null || max >= children.length
        ? children
        : children.sublist(0, max);
    final int hidden = math.max(0, (total ?? children.length) - shown.length);
    final Widget? extra = hidden > 0 ? overflow?.call(hidden) : null;
    final List<Widget> drawn = <Widget>[...shown, ?extra];
    final NebaTransition? transition = this.transition;

    return _StackLayout(
      direction: direction,
      overlap: step,
      drop: direction == NebaStackDirection.diagonal ? fall : 0,
      frontFirst: front == NebaStackFront.first,
      textDirection: Directionality.of(context),
      children: <Widget>[
        for (int index = 0; index < drawn.length; index += 1)
          KeyedSubtree(
            // The child's own key, one level up, so reordering a pile moves an
            // item rather than rebuilding it. The overflow item was never a
            // child, so it takes a key no child's can be.
            key: identical(drawn[index], extra)
                ? const _OverflowKey()
                : drawn[index].key == null
                ? null
                : ValueKey<Key>(drawn[index].key!),
            child: _item(
              child: drawn[index],
              index: index,
              order: reverse ? drawn.length - 1 - index : index,
              ring: ring ? tokens.surface : null,
              transition: transition,
            ),
          ),
      ],
    );
  }

  Widget _item({
    required Widget child,
    required int index,
    required int order,
    required Color? ring,
    required NebaTransition? transition,
  }) {
    final Widget depth = Opacity(
      opacity: math.pow(opacityStep, index).toDouble().clamp(0, 1),
      alwaysIncludeSemantics: true,
      child: Transform.scale(
        scale: math.pow(scaleStep, index).toDouble(),
        child: NebaRingScope(color: ring, child: child),
      ),
    );

    if (transition == null) {
      return depth;
    }

    return NebaEntrance(
      transition: transition,
      delayOffset: stagger * order,
      durationOffset: durationStep * order,
      child: depth,
    );
  }
}

/// The key of the item that stands in for the ones that did not fit.
class _OverflowKey extends LocalKey {
  const _OverflowKey();
}

class _StackLayout extends MultiChildRenderObjectWidget {
  const _StackLayout({
    required this.direction,
    required this.overlap,
    required this.drop,
    required this.frontFirst,
    required this.textDirection,
    super.children,
  });

  final NebaStackDirection direction;
  final double overlap;
  final double drop;
  final bool frontFirst;
  final TextDirection textDirection;

  @override
  _RenderStack createRenderObject(BuildContext context) {
    return _RenderStack(
      vertical: direction == NebaStackDirection.vertical,
      overlap: overlap,
      drop: drop,
      frontFirst: frontFirst,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderStack renderObject) {
    renderObject
      ..vertical = direction == NebaStackDirection.vertical
      ..overlap = overlap
      ..drop = drop
      ..frontFirst = frontFirst
      ..textDirection = textDirection;
  }
}

class _StackParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays each item under the one before it and paints them back to front.
///
/// The overlap is taken out of the room the pile covers rather than painted
/// over it, which is what the React package's negative margins do: a pile of
/// three 40-pixel faces overlapping by 10 is 100 pixels wide, not 120.
class _RenderStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _StackParentData> {
  _RenderStack({
    required bool vertical,
    required double overlap,
    required double drop,
    required bool frontFirst,
    required TextDirection textDirection,
  }) : _vertical = vertical,
       _overlap = overlap,
       _drop = drop,
       _frontFirst = frontFirst,
       _textDirection = textDirection;

  bool get vertical => _vertical;
  bool _vertical;
  set vertical(bool value) {
    if (value != _vertical) {
      _vertical = value;
      markNeedsLayout();
    }
  }

  double get overlap => _overlap;
  double _overlap;
  set overlap(double value) {
    if (value != _overlap) {
      _overlap = value;
      markNeedsLayout();
    }
  }

  double get drop => _drop;
  double _drop;
  set drop(double value) {
    if (value != _drop) {
      _drop = value;
      markNeedsLayout();
    }
  }

  bool get frontFirst => _frontFirst;
  bool _frontFirst;
  set frontFirst(bool value) {
    if (value != _frontFirst) {
      _frontFirst = value;
      markNeedsPaint();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _StackParentData) {
      child.parentData = _StackParentData();
    }
  }

  List<RenderBox> get _children {
    final List<RenderBox> children = <RenderBox>[];
    RenderBox? child = firstChild;

    while (child != null) {
      children.add(child);
      child = childAfter(child);
    }

    return children;
  }

  /// The pile's size, given each item's, and where each item goes.
  ({Size size, List<Offset> offsets}) _arrange(BoxConstraints constraints, List<Size> sizes) {
    double run = 0;
    double across = 0;
    final List<double> starts = <double>[];
    final List<double> falls = <double>[];

    for (int index = 0; index < sizes.length; index += 1) {
      if (index > 0) {
        run -= overlap;
      }

      final Size size = sizes[index];
      final double fall = drop * index;

      starts.add(run);
      falls.add(fall);
      run += vertical ? size.height : size.width;
      across = math.max(across, fall + (vertical ? size.width : size.height));
    }

    final Size size = constraints.constrain(
      vertical ? Size(across, math.max(0, run)) : Size(math.max(0, run), across),
    );
    final bool rtl = textDirection == TextDirection.rtl;
    final List<Offset> offsets = <Offset>[
      for (int index = 0; index < sizes.length; index += 1)
        vertical
            ? Offset(rtl ? size.width - sizes[index].width : 0, starts[index])
            : Offset(
                rtl ? size.width - starts[index] - sizes[index].width : starts[index],
                falls[index],
              ),
    ];

    return (size: size, offsets: offsets);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints inner = constraints.loosen();
    final List<Size> sizes = <Size>[
      for (final RenderBox child in _children) child.getDryLayout(inner),
    ];

    return _arrange(constraints, sizes).size;
  }

  @override
  void performLayout() {
    final BoxConstraints inner = constraints.loosen();
    final List<RenderBox> children = _children;

    for (final RenderBox child in children) {
      child.layout(inner, parentUsesSize: true);
    }

    final ({Size size, List<Offset> offsets}) arranged = _arrange(constraints, <Size>[
      for (final RenderBox child in children) child.size,
    ]);

    size = arranged.size;

    for (int index = 0; index < children.length; index += 1) {
      (children[index].parentData! as _StackParentData).offset = arranged.offsets[index];
    }
  }

  double _runIntrinsic(double Function(RenderBox child) extent, {required bool along}) {
    final List<RenderBox> children = _children;
    double total = 0;

    for (int index = 0; index < children.length; index += 1) {
      final double size = extent(children[index]);

      total = along
          ? total + size - (index > 0 ? overlap : 0)
          : math.max(total, size + drop * index);
    }

    return math.max(0, total);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _runIntrinsic((RenderBox child) => child.getMinIntrinsicWidth(height), along: !vertical);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _runIntrinsic((RenderBox child) => child.getMaxIntrinsicWidth(height), along: !vertical);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _runIntrinsic((RenderBox child) => child.getMinIntrinsicHeight(width), along: vertical);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _runIntrinsic((RenderBox child) => child.getMaxIntrinsicHeight(width), along: vertical);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    // The first item's, as an inline-flex box takes its first item's: a pile
    // of faces in a line of text sits on the line.
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  /// The items from the back of the pile to the front.
  Iterable<RenderBox> get _backToFront {
    final List<RenderBox> children = _children;

    return frontFirst ? children.reversed : children;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final RenderBox child in _backToFront) {
      final _StackParentData data = child.parentData! as _StackParentData;

      context.paintChild(child, data.offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Front to back, so a press lands on the item that is drawn on top.
    for (final RenderBox child in _backToFront.toList().reversed) {
      final _StackParentData data = child.parentData! as _StackParentData;
      final bool hit = result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );

      if (hit) {
        return true;
      }
    }

    return false;
  }
}
