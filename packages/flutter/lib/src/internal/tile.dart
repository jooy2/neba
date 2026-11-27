/// A row of items with one tile behind the current item, sliding to the next
/// one when the current item changes: the React package's
/// `src/internal/tile.ts` and the measurement around it, in a render object.
///
/// The React package measures the current item's offsets after it renders and
/// writes them onto the tile as four custom properties, which a transition on
/// `left`, `top`, `width` and `height` animates. Here the row lays its items
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
/// - **Only a change of the current item animates.** The row resizing under a
///   tile that was already in the right place moves it there at once, so it
///   never lags behind a window being dragged.
///
/// A SegmentedButton draws one, and a FloatingBottomNavigation will draw the
/// same.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// [children] in a row with [tile] behind the one at [current].
///
/// The row is as wide as its items, or with [fill] as wide as a bounded width
/// it is given, shared between them as a `NebaJoinedRun` shares it. Under a
/// right-to-left direction the first item is at the right.
class NebaTileRun extends StatefulWidget {
  /// A row of [children] with [tile] behind the one at [current].
  const NebaTileRun({
    required this.tile,
    required this.children,
    this.current,
    this.fill = false,
    super.key,
  });

  /// What is drawn behind the current item, laid out at its size.
  final Widget tile;

  /// The items.
  final List<Widget> children;

  /// The index of the item the tile is behind, or `null` for none.
  final int? current;

  /// Whether the row takes the whole bounded width it is given and shares it.
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
    required this.fill,
    required this.textDirection,
    required super.children,
  });

  final Animation<double> animation;
  final int? current;
  final bool fill;
  final TextDirection textDirection;

  @override
  _RenderTileRow createRenderObject(BuildContext context) {
    return _RenderTileRow(
      animation: animation,
      current: current,
      fill: fill,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTileRow renderObject) {
    renderObject
      ..animation = animation
      ..current = current
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
    required bool fill,
    required TextDirection textDirection,
  }) : _animation = animation,
       _current = current,
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

  /// Each item's size: its own, or with [fill] its share of a bounded width.
  ///
  /// An item is measured by its dry layout and then laid out once, tightly,
  /// for the reason `NebaJoinedRun` gives: laid out tight, an item is its own
  /// relayout boundary, and a loose layout first would leave the row deaf to
  /// an item that grew.
  List<Size> _sizes(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) measure,
  ) {
    final List<RenderBox> items = _items;
    final BoxConstraints natural = BoxConstraints(maxHeight: constraints.maxHeight);

    List<Size> sizes = <Size>[for (final RenderBox item in items) item.getDryLayout(natural)];

    if (_fill && constraints.hasBoundedWidth && items.isNotEmpty) {
      final List<double> widths = nebaShareWidth(constraints.maxWidth, <double>[
        for (final Size size in sizes) size.width,
      ]);
      sizes = <Size>[
        for (int i = 0; i < items.length; i++)
          items[i].getDryLayout(
            BoxConstraints.tightFor(width: widths[i]).copyWith(maxHeight: constraints.maxHeight),
          ),
      ];
    }

    return <Size>[
      for (int i = 0; i < items.length; i++) measure(items[i], BoxConstraints.tight(sizes[i])),
    ];
  }

  static Size _total(List<Size> sizes) {
    double width = 0;
    double height = 0;

    for (final Size size in sizes) {
      width += size.width;
      height = size.height > height ? size.height : height;
    }

    return Size(width, height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(
      _total(_sizes(constraints, (RenderBox child, BoxConstraints c) => child.getDryLayout(c))),
    );
  }

  @override
  void performLayout() {
    final List<RenderBox> items = _items;
    final List<Size> sizes = _sizes(constraints, (RenderBox child, BoxConstraints c) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });
    final Size total = _total(sizes);
    size = constraints.constrain(total);

    final bool reversed = _textDirection == TextDirection.rtl;
    final double run = total.width;
    double position = 0;
    final List<Rect> rects = <Rect>[];

    for (int i = 0; i < items.length; i++) {
      final Size itemSize = sizes[i];
      final double x = reversed ? run - position - itemSize.width : position;
      final Offset offset = Offset(x, (total.height - itemSize.height) / 2);

      (items[i].parentData! as _TileRowParentData).offset = offset;
      rects.add(offset & itemSize);
      position += itemSize.width;
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
      // The row moved under a tile that was already in place.
      _from = target;
      _to = target;
    }

    final Rect rect = Rect.lerp(_from, _to, _animation.value)!;
    _shown = rect;
    tile.layout(BoxConstraints.tight(rect.size));
    (tile.parentData! as _TileRowParentData).offset = rect.topLeft;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _items.fold<double>(0, (double sum, RenderBox item) {
      return sum + item.getMinIntrinsicWidth(height);
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _items.fold<double>(0, (double sum, RenderBox item) {
      return sum + item.getMaxIntrinsicWidth(height);
    });
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _items.fold<double>(0, (double tallest, RenderBox item) {
      final double height = item.getMinIntrinsicHeight(double.infinity);
      return height > tallest ? height : tallest;
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _items.fold<double>(0, (double tallest, RenderBox item) {
      final double height = item.getMaxIntrinsicHeight(double.infinity);
      return height > tallest ? height : tallest;
    });
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
