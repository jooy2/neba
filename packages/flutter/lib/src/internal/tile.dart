/// A run of items with one tile behind the current item, sliding to the next
/// one when the current item changes: the React package's
/// `src/internal/tile.ts` and the measurement around it, in a render object.
///
/// The React package measures the current item's offsets after it renders and
/// writes them onto the tile as four custom properties, which a transition on
/// `left`, `top`, `width` and `height` animates. Here the run lays its items
/// out itself, so it knows the current item's rectangle in the same pass, and
/// the tile is laid out at the rectangle between where it was and where it is
/// going. It is the rectangle that moves, never a transform: the tile is an
/// empty sheet, and nothing on it is resampled while it travels.
///
/// - **The first placement is instant.** A tile that was not drawn has
///   nowhere to travel from, so it appears under its item rather than flying
///   in from a corner.
/// - **No current item hides the tile**, and the next placement is a first
///   one again.
/// - **Only a change of the current item animates.** The run resizing under a
///   tile that was already in the right place moves it there at once, so it
///   never lags behind a window being dragged.
///
/// The items run in a row or down a column, and may wrap onto further lines,
/// as a CSS `flex-wrap` row does. A SegmentedButton draws one row, a Tabs bar
/// any of the four, and a FloatingBottomNavigation will draw a row.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// [children] in a row or a column with [tile] behind the one at [current].
///
/// A row is as wide as its items, or with [fill] as wide as the width it is
/// given, shared between them as a `NebaJoinedRun` shares it: a bounded
/// width, or the minimum width of an unbounded one, which is how a row inside
/// a scroll view fills the view while it fits. Each item keeps its own height
/// and is centred across the row. A column is as wide as its widest item, and
/// every item takes that width, as a CSS column stretches its items. Under a
/// right-to-left direction the first item is at the right.
///
/// With [wrap], a row starts a new line below when the next item would run
/// past a bounded width, and a column a new line beside it when the next item
/// would run past a bounded height; [fill] then shares each line's width
/// between its items, and a line in a column is as wide as its widest item.
class NebaTileRun extends StatefulWidget {
  /// A run of [children] with [tile] behind the one at [current].
  const NebaTileRun({
    required this.tile,
    required this.children,
    this.current,
    this.axis = Axis.horizontal,
    this.wrap = false,
    this.fill = false,
    super.key,
  });

  /// What is drawn behind the current item, laid out at its size.
  final Widget tile;

  /// The items.
  final List<Widget> children;

  /// The index of the item the tile is behind, or `null` for none.
  final int? current;

  /// Whether the items run in a row or down a column.
  final Axis axis;

  /// Whether the items wrap onto further lines when they run out of room.
  final bool wrap;

  /// Whether a row takes the whole width it is given and shares it.
  final bool fill;

  @override
  State<NebaTileRun> createState() => _NebaTileRunState();
}

class _NebaTileRunState extends State<NebaTileRun> with SingleTickerProviderStateMixin {
  /// The move from one item to the next, at rest at its end.
  late final AnimationController _move = AnimationController(vsync: this, value: 1);
  late final CurvedAnimation _eased = CurvedAnimation(parent: _move, curve: NebaScale.ease);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Zero for a reader who asked for less motion, which lands every move at
    // its end on the frame it starts.
    _move.duration = nebaDuration(context, NebaScale.duration);
  }

  @override
  void didUpdateWidget(NebaTileRun oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.current != widget.current) {
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _eased.dispose();
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _TileRow(
      animation: _eased,
      current: widget.current,
      axis: widget.axis,
      wrap: widget.wrap,
      fill: widget.fill,
      textDirection: Directionality.of(context),
      children: <Widget>[widget.tile, ...widget.children],
    );
  }
}

class _TileRowParentData extends ContainerBoxParentData<RenderBox> {}

class _TileRow extends MultiChildRenderObjectWidget {
  const _TileRow({
    required this.animation,
    required this.current,
    required this.axis,
    required this.wrap,
    required this.fill,
    required this.textDirection,
    required super.children,
  });

  final Animation<double> animation;
  final int? current;
  final Axis axis;
  final bool wrap;
  final bool fill;
  final TextDirection textDirection;

  @override
  _RenderTileRow createRenderObject(BuildContext context) {
    return _RenderTileRow(
      animation: animation,
      current: current,
      axis: axis,
      wrap: wrap,
      fill: fill,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTileRow renderObject) {
    renderObject
      ..animation = animation
      ..current = current
      ..axis = axis
      ..wrap = wrap
      ..fill = fill
      ..textDirection = textDirection;
  }
}

/// The first child is the tile, and the rest are the items.
class _RenderTileRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TileRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TileRowParentData> {
  _RenderTileRow({
    required Animation<double> animation,
    required int? current,
    required Axis axis,
    required bool wrap,
    required bool fill,
    required TextDirection textDirection,
  }) : _animation = animation,
       _current = current,
       _axis = axis,
       _wrap = wrap,
       _fill = fill,
       _textDirection = textDirection;

  Animation<double> _animation;
  set animation(Animation<double> value) {
    if (_animation != value) {
      if (attached) {
        _animation.removeListener(markNeedsLayout);
        value.addListener(markNeedsLayout);
      }
      _animation = value;
      markNeedsLayout();
    }
  }

  int? _current;
  set current(int? value) {
    if (_current != value) {
      _current = value;
      _moved = true;
      markNeedsLayout();
    }
  }

  Axis _axis;
  set axis(Axis value) {
    if (_axis != value) {
      _axis = value;
      markNeedsLayout();
    }
  }

  bool _wrap;
  set wrap(bool value) {
    if (_wrap != value) {
      _wrap = value;
      markNeedsLayout();
    }
  }

  bool _fill;
  set fill(bool value) {
    if (_fill != value) {
      _fill = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// Where a move started, where it is going, and where the tile was drawn
  /// last; all `null` while no item is current.
  Rect? _from;
  Rect? _to;
  Rect? _shown;

  /// Whether [current] changed since the last layout, which is the one thing
  /// that makes the tile travel rather than jump.
  bool _moved = false;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TileRowParentData) {
      child.parentData = _TileRowParentData();
    }
  }

  RenderBox? get _tile => firstChild;

  List<RenderBox> get _items {
    final List<RenderBox> items = getChildrenAsList();

    return items.isEmpty ? items : items.sublist(1);
  }

  /// Where each item goes and how big the run is, with every item sized and
  /// placed by [measure].
  ///
  /// An item is measured by its dry layout and then laid out once, tightly,
  /// for the reason `NebaJoinedRun` gives: laid out tight, an item is its own
  /// relayout boundary, and a loose layout first would leave the run deaf to
  /// an item that grew.
  (List<Rect>, Size) _arrange(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) measure,
  ) {
    final List<RenderBox> items = _items;
    final bool row = _axis == Axis.horizontal;
    // A row's items at their own widths, and a column's at theirs however
    // wide the column may grow: an item that can stretch would otherwise take
    // the whole width on offer before its neighbours were measured.
    final BoxConstraints natural = row
        ? BoxConstraints(maxHeight: constraints.maxHeight)
        : const BoxConstraints();
    final List<Size> naturals = <Size>[
      for (final RenderBox item in items) item.getDryLayout(natural),
    ];

    // The lines, as runs of indices, broken where the next item would pass
    // the length the run may have.
    final double room = !_wrap
        ? double.infinity
        : (row ? constraints.maxWidth : constraints.maxHeight);
    final List<List<int>> lines = <List<int>>[];
    double along = 0;

    for (int i = 0; i < items.length; i++) {
      final double length = row ? naturals[i].width : naturals[i].height;

      if (lines.isEmpty || (along > 0 && along + length > room)) {
        lines.add(<int>[]);
        along = 0;
      }

      lines.last.add(i);
      along += length;
    }

    // A row fills a bounded width, or the minimum width of an unbounded one:
    // the width of the scroll view it is in.
    final double? share = row && _fill
        ? (constraints.hasBoundedWidth
              ? constraints.maxWidth
              : (constraints.minWidth > 0 ? constraints.minWidth : null))
        : null;
    final List<Size> sizes = List<Size>.of(naturals);

    for (final List<int> line in lines) {
      if (row && share != null) {
        final List<double> widths = nebaShareWidth(share, <double>[
          for (final int i in line) naturals[i].width,
        ]);

        for (int k = 0; k < line.length; k++) {
          sizes[line[k]] = items[line[k]].getDryLayout(
            BoxConstraints.tightFor(width: widths[k]).copyWith(maxHeight: constraints.maxHeight),
          );
        }
      } else if (!row) {
        // A column's items take its widest one's width, held to the width
        // the column may have.
        double widest = 0;

        for (final int i in line) {
          widest = naturals[i].width > widest ? naturals[i].width : widest;
        }

        if (widest > constraints.maxWidth) {
          widest = constraints.maxWidth;
        }

        for (final int i in line) {
          sizes[i] = Size(widest, naturals[i].height);
        }
      }
    }

    final List<Size> laid = <Size>[
      for (int i = 0; i < items.length; i++) measure(items[i], BoxConstraints.tight(sizes[i])),
    ];

    // Each line's length along the run and its thickness across it.
    final List<double> lengths = <double>[];
    final List<double> thicknesses = <double>[];

    for (final List<int> line in lines) {
      double length = 0;
      double thickness = 0;

      for (final int i in line) {
        length += row ? laid[i].width : laid[i].height;
        final double across = row ? laid[i].height : laid[i].width;
        thickness = across > thickness ? across : thickness;
      }

      lengths.add(length);
      thicknesses.add(thickness);
    }

    final double longest = lengths.fold<double>(0, (double a, double b) => b > a ? b : a);
    final double thick = thicknesses.fold<double>(0, (double a, double b) => a + b);
    final Size total = row
        ? Size(share != null && share > longest ? share : longest, thick)
        : Size(thick, longest);

    final bool reversed = _textDirection == TextDirection.rtl;
    final List<Rect> rects = List<Rect>.filled(items.length, Rect.zero);
    double across = 0;

    for (int l = 0; l < lines.length; l++) {
      double position = 0;

      for (final int i in lines[l]) {
        final Size size = laid[i];

        if (row) {
          final double x = reversed ? total.width - position - size.width : position;
          rects[i] = Offset(x, across + (thicknesses[l] - size.height) / 2) & size;
          position += size.width;
        } else {
          final double x = reversed ? total.width - across - size.width : across;
          rects[i] = Offset(x, position) & size;
          position += size.height;
        }
      }

      across += thicknesses[l];
    }

    return (rects, total);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final (List<Rect> _, Size total) = _arrange(
      constraints,
      (RenderBox child, BoxConstraints c) => child.getDryLayout(c),
    );

    return constraints.constrain(total);
  }

  @override
  void performLayout() {
    final List<RenderBox> items = _items;
    final (List<Rect> rects, Size total) = _arrange(constraints, (
      RenderBox child,
      BoxConstraints c,
    ) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });
    size = constraints.constrain(total);

    for (int i = 0; i < items.length; i++) {
      (items[i].parentData! as _TileRowParentData).offset = rects[i].topLeft;
    }

    _placeTile(rects);
  }

  void _placeTile(List<Rect> rects) {
    final RenderBox? tile = _tile;

    if (tile == null) {
      return;
    }

    final int? current = _current;
    final Rect? target = current != null && current >= 0 && current < rects.length
        ? rects[current]
        : null;
    final bool moved = _moved;
    _moved = false;

    if (target == null) {
      // Nothing is current: the tile goes, and the next placement is a first.
      _from = null;
      _to = null;
      _shown = null;
      tile.layout(BoxConstraints.tight(Size.zero));
      return;
    }

    final Rect? shown = _shown;

    if (shown == null) {
      // A first placement, which has nowhere to travel from.
      _from = target;
      _to = target;
    } else if (moved) {
      // From wherever the tile is now, so a move that interrupts another
      // starts from the frame the tile was drawn at.
      _from = shown;
      _to = target;
    } else if (_to != target) {
      // The run moved under a tile that was already in place.
      _from = target;
      _to = target;
    }

    final Rect rect = Rect.lerp(_from, _to, _animation.value)!;
    _shown = rect;
    tile.layout(BoxConstraints.tight(rect.size));
    (tile.parentData! as _TileRowParentData).offset = rect.topLeft;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsic(width: true, min: true);

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsic(width: true, min: false);

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsic(width: false, min: true);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsic(width: false, min: false);

  /// The items' extents added up along the run and the largest across it; a
  /// run that wraps needs no more along it than its longest item.
  double _intrinsic({required bool width, required bool min}) {
    final bool along = width == (_axis == Axis.horizontal);
    double sum = 0;
    double largest = 0;

    for (final RenderBox item in _items) {
      final double extent = width
          ? (min
                ? item.getMinIntrinsicWidth(double.infinity)
                : item.getMaxIntrinsicWidth(double.infinity))
          : (min
                ? item.getMinIntrinsicHeight(double.infinity)
                : item.getMaxIntrinsicHeight(double.infinity));
      sum += extent;
      largest = extent > largest ? extent : largest;
    }

    return along && !(_wrap && min) ? sum : largest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? tile = _tile;

    // The tile first, so every item is drawn over it.
    if (tile != null && _shown != null) {
      context.paintChild(tile, (tile.parentData! as _TileRowParentData).offset + offset);
    }

    for (final RenderBox item in _items) {
      context.paintChild(item, (item.parentData! as _TileRowParentData).offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The items only: the tile takes no pointer.
    for (final RenderBox item in _items.reversed) {
      final _TileRowParentData data = item.parentData! as _TileRowParentData;
      final bool hit = result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return item.hitTest(result, position: transformed);
        },
      );

      if (hit) {
        return true;
      }
    }

    return false;
  }
}
