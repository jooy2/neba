/// What a button inherits from the group around it, and which of its corners
/// face a neighbour: the React package's `src/internal/button-group.ts`, and
/// the `:first-child` and `:last-child` rules of its ButtonGroup, in Dart.
///
/// Here rather than in the group's folder so that a button reads it without
/// the two widgets importing each other, and so that a toggle and a toggle
/// group can share it later: the six values are the same.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/types.dart';

/// The six values a [NebaButtonGroupScope] hands down. Every one is optional
/// and means "not set here": a button falls back to its own default, not to
/// one the group invented.
class NebaButtonGroupScope extends InheritedWidget {
  /// The group's values for [child].
  const NebaButtonGroupScope({
    required super.child,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled,
    super.key,
  });

  /// The group's variant.
  final NebaVariant? variant;

  /// The group's size.
  final NebaSize? size;

  /// The group's colour family.
  final NebaColor? color;

  /// The group's density.
  final NebaDensity? density;

  /// The group's elevation.
  final NebaElevation? elevation;

  /// Whether the whole group is disabled.
  final bool? disabled;

  /// The group around [context], or `null` when there is none.
  static NebaButtonGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaButtonGroupScope>();
  }

  @override
  bool updateShouldNotify(NebaButtonGroupScope oldWidget) {
    return variant != oldWidget.variant ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        elevation != oldWidget.elevation ||
        disabled != oldWidget.disabled;
  }
}

/// Which sides of a control face a neighbour in a joined run, so the corners
/// on them are squared off and the run reads as one cut piece.
@immutable
class NebaJoin {
  /// A control joined on the given sides.
  const NebaJoin({this.start = false, this.end = false, this.top = false, this.bottom = false});

  /// A control on its own.
  static const NebaJoin none = NebaJoin();

  /// The inline-start side, which is the right under a right-to-left text
  /// direction.
  final bool start;

  /// The inline-end side.
  final bool end;

  /// The top.
  final bool top;

  /// The bottom.
  final bool bottom;

  /// Corners of [radius], squared off on every joined side.
  BorderRadius corners(double radius, TextDirection direction) {
    const Radius square = Radius.zero;
    final Radius round = Radius.circular(radius);

    return BorderRadiusDirectional.only(
      topStart: start || top ? square : round,
      topEnd: end || top ? square : round,
      bottomStart: start || bottom ? square : round,
      bottomEnd: end || bottom ? square : round,
    ).resolve(direction);
  }

  @override
  bool operator ==(Object other) {
    return other is NebaJoin &&
        other.start == start &&
        other.end == end &&
        other.top == top &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(start, end, top, bottom);
}

/// Tells the control below which of its sides are joined.
class NebaJoinScope extends InheritedWidget {
  /// [join] for [child].
  const NebaJoinScope({required this.join, required super.child, super.key});

  /// The joined sides.
  final NebaJoin join;

  /// The joined sides of the control at [context]: none outside a run.
  static NebaJoin of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaJoinScope>()?.join ?? NebaJoin.none;
  }

  @override
  bool updateShouldNotify(NebaJoinScope oldWidget) => join != oldWidget.join;
}

/// A control's place in a [NebaJoinedRun]: its index and how many there are.
class NebaRunIndex extends InheritedWidget {
  /// The [index]-th of [count] controls.
  const NebaRunIndex({required this.index, required this.count, required super.child, super.key});

  /// Where the control is in the run, from the start.
  final int index;

  /// How many controls the run holds.
  final int count;

  /// The place of the control at [context], or `null` outside a run.
  static NebaRunIndex? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaRunIndex>();
  }

  @override
  bool updateShouldNotify(NebaRunIndex oldWidget) {
    return index != oldWidget.index || count != oldWidget.count;
  }
}

/// What a toggle group tells the toggles in it: which values are on, what to
/// call when one is pressed, and which toggle is the set's one stop in the
/// focus order.
class NebaToggleGroupScope extends InheritedWidget {
  /// The group's state for [child].
  const NebaToggleGroupScope({
    required this.selected,
    required this.onToggle,
    required this.tabStop,
    required this.register,
    required this.unregister,
    required super.child,
    super.key,
  });

  /// The values that are on.
  final Set<String> selected;

  /// Turns the toggle with [value] on or off.
  final void Function(String value, bool pressed) onToggle;

  /// The index of the toggle the focus order stops at; the arrow keys reach
  /// the others.
  final int tabStop;

  /// Hands the group the focus node of the toggle at an index, and whether
  /// it can take the focus.
  final void Function(int index, FocusNode node, {required bool enabled}) register;

  /// Takes a toggle's focus node back.
  final void Function(int index, FocusNode node) unregister;

  /// The group around [context], or `null` when there is none.
  static NebaToggleGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaToggleGroupScope>();
  }

  @override
  bool updateShouldNotify(NebaToggleGroupScope oldWidget) {
    return !setEquals(selected, oldWidget.selected) ||
        tabStop != oldWidget.tabStop ||
        onToggle != oldWidget.onToggle;
  }
}

/// A run of controls that read as one cut piece: each is told which of its
/// sides face a neighbour, [overlap] pulls each one back over the one before
/// so two hairlines share a single line, a column is as wide as its widest
/// control, and the one under the pointer or holding the focus is painted over
/// its neighbours, so nothing covers its focus ring.
class NebaJoinedRun extends StatelessWidget {
  /// A run of [children] along [axis].
  const NebaJoinedRun({
    required this.children,
    this.axis = Axis.horizontal,
    this.overlap = 0,
    this.fill = false,
    super.key,
  });

  /// The controls.
  final List<Widget> children;

  /// Which way they run.
  final Axis axis;

  /// How far each control is pulled back over the one before it.
  final double overlap;

  /// Whether the run takes the whole width it is given and shares it evenly,
  /// when it runs horizontally and the width is bounded.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final int last = children.length - 1;
    final bool horizontal = axis == Axis.horizontal;

    return _Run(
      axis: axis,
      overlap: overlap,
      fill: fill,
      textDirection: Directionality.of(context),
      children: <Widget>[
        for (int i = 0; i <= last; i++)
          _Item(
            child: NebaRunIndex(
              index: i,
              count: children.length,
              child: NebaJoinScope(
                join: NebaJoin(
                  start: horizontal && i > 0,
                  end: horizontal && i < last,
                  top: !horizontal && i > 0,
                  bottom: !horizontal && i < last,
                ),
                child: children[i],
              ),
            ),
          ),
      ],
    );
  }
}

/// One control in a run, raised over its neighbours while the pointer is over
/// it or the focus is inside it.
class _Item extends StatefulWidget {
  const _Item({required this.child});

  final Widget child;

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return _Raised(
      raised: _hovered || _focused,
      // Opaque, so the press and the pointer land on the control painted on
      // top and not on the one it overlaps as well.
      child: MouseRegion(
        onEnter: (PointerEnterEvent e) => setState(() => _hovered = true),
        onExit: (PointerExitEvent e) => setState(() => _hovered = false),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (bool focused) => setState(() => _focused = focused),
          child: widget.child,
        ),
      ),
    );
  }
}

class _RunParentData extends ContainerBoxParentData<RenderBox> {
  bool raised = false;
}

class _Raised extends ParentDataWidget<_RunParentData> {
  const _Raised({required this.raised, required super.child});

  final bool raised;

  @override
  void applyParentData(RenderObject renderObject) {
    final _RunParentData data = renderObject.parentData! as _RunParentData;

    if (data.raised != raised) {
      data.raised = raised;
      renderObject.parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _Run;
}

class _Run extends MultiChildRenderObjectWidget {
  const _Run({
    required this.axis,
    required this.overlap,
    required this.fill,
    required this.textDirection,
    required super.children,
  });

  final Axis axis;
  final double overlap;
  final bool fill;
  final TextDirection textDirection;

  @override
  _RenderRun createRenderObject(BuildContext context) {
    return _RenderRun(axis: axis, overlap: overlap, fill: fill, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderRun renderObject) {
    renderObject
      ..axis = axis
      ..overlap = overlap
      ..fill = fill
      ..textDirection = textDirection;
  }
}

class _RenderRun extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RunParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RunParentData> {
  _RenderRun({
    required Axis axis,
    required double overlap,
    required bool fill,
    required TextDirection textDirection,
  }) : _axis = axis,
       _overlap = overlap,
       _fill = fill,
       _textDirection = textDirection;

  Axis _axis;
  set axis(Axis value) {
    if (_axis != value) {
      _axis = value;
      markNeedsLayout();
    }
  }

  double _overlap;
  set overlap(double value) {
    if (_overlap != value) {
      _overlap = value;
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

  bool get _horizontal => _axis == Axis.horizontal;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RunParentData) {
      child.parentData = _RunParentData();
    }
  }

  /// Each child's size: its own along the run, unless the run fills a bounded
  /// width, and down a column the widest child's across it.
  ///
  /// A child is measured by its dry layout and then laid out once, tightly.
  /// Measuring it by laying it out loosely first would not do: laid out tight,
  /// a child is its own relayout boundary, so when it grew the run would never
  /// hear about it. A dry layout that changes tells the parent.
  List<Size> _sizes(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) measure,
  ) {
    final List<RenderBox> children = getChildrenAsList();
    final int count = children.length;
    final bool share = _fill && _horizontal && constraints.hasBoundedWidth && count > 0;

    BoxConstraints natural(RenderBox child) {
      return _horizontal
          ? BoxConstraints(maxHeight: constraints.maxHeight)
          : BoxConstraints(maxWidth: constraints.maxWidth);
    }

    List<Size> loose = <Size>[
      for (final RenderBox child in children) child.getDryLayout(natural(child)),
    ];

    if (share) {
      final List<double> widths = _shareWidth(
        constraints.maxWidth + _overlap * (count - 1),
        <double>[for (final Size size in loose) size.width],
      );
      loose = <Size>[
        for (int i = 0; i < count; i++)
          children[i].getDryLayout(
            BoxConstraints.tightFor(width: widths[i]).copyWith(maxHeight: constraints.maxHeight),
          ),
      ];
    }

    final double thickest = loose.fold<double>(
      0,
      (double widest, Size size) => _horizontal
          ? (size.height > widest ? size.height : widest)
          : (size.width > widest ? size.width : widest),
    );

    // Across a row each control keeps its own height, as a CSS stretch leaves
    // an explicit height alone; down a column each takes the widest width, as
    // a stretch gives an automatic width.
    return <Size>[
      for (int i = 0; i < count; i++)
        measure(
          children[i],
          _horizontal
              ? BoxConstraints.tightFor(width: loose[i].width, height: loose[i].height)
              : BoxConstraints.tightFor(width: thickest, height: loose[i].height),
        ),
    ];
  }

  /// [available] shared evenly, the way CSS shares a row of `flex: 1` items:
  /// an item whose content needs more than an even share keeps its own width,
  /// as `min-width: auto` keeps it, and the others share what is left.
  static List<double> _shareWidth(double available, List<double> naturals) {
    final List<double?> fixed = List<double?>.filled(naturals.length, null);
    double remaining = available;
    bool changed = true;

    while (changed) {
      changed = false;
      final int open = fixed.where((double? width) => width == null).length;

      if (open == 0) {
        break;
      }

      final double even = remaining / open;

      for (int i = 0; i < naturals.length; i++) {
        if (fixed[i] == null && naturals[i] > even) {
          fixed[i] = naturals[i];
          remaining -= naturals[i];
          changed = true;
        }
      }
    }

    final int open = fixed.where((double? width) => width == null).length;
    final double even = open == 0 ? 0 : remaining / open;

    return <double>[for (final double? width in fixed) width ?? even];
  }

  Size _total(List<Size> sizes) {
    if (sizes.isEmpty) {
      return Size.zero;
    }

    double along = -_overlap * (sizes.length - 1);
    double across = 0;

    for (final Size size in sizes) {
      along += _horizontal ? size.width : size.height;
      final double thickness = _horizontal ? size.height : size.width;
      across = thickness > across ? thickness : across;
    }

    return _horizontal ? Size(along, across) : Size(across, along);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(
      _total(_sizes(constraints, (RenderBox child, BoxConstraints c) => child.getDryLayout(c))),
    );
  }

  @override
  void performLayout() {
    final List<Size> sizes = _sizes(constraints, (RenderBox child, BoxConstraints c) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });
    final Size total = _total(sizes);
    size = constraints.constrain(total);

    final bool reversed = _horizontal && _textDirection == TextDirection.rtl;
    double position = 0;
    RenderBox? child = firstChild;

    for (final Size childSize in sizes) {
      final _RunParentData data = child!.parentData! as _RunParentData;

      if (_horizontal) {
        final double x = reversed ? total.width - position - childSize.width : position;
        data.offset = Offset(x, 0);
        position += childSize.width - _overlap;
      } else {
        data.offset = Offset(0, position);
        position += childSize.height - _overlap;
      }

      child = data.nextSibling;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth(height, min: true);

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth(height, min: false);

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width, min: true);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width, min: false);

  double _intrinsicWidth(double height, {required bool min}) {
    final List<double> widths = <double>[
      for (final RenderBox child in getChildrenAsList())
        min ? child.getMinIntrinsicWidth(height) : child.getMaxIntrinsicWidth(height),
    ];

    return _combine(widths, along: _horizontal);
  }

  double _intrinsicHeight(double width, {required bool min}) {
    final List<double> heights = <double>[
      for (final RenderBox child in getChildrenAsList())
        min ? child.getMinIntrinsicHeight(width) : child.getMaxIntrinsicHeight(width),
    ];

    return _combine(heights, along: !_horizontal);
  }

  double _combine(List<double> extents, {required bool along}) {
    if (extents.isEmpty) {
      return 0;
    }

    if (along) {
      return extents.fold<double>(0, (double sum, double e) => sum + e) -
          _overlap * (extents.length - 1);
    }

    return extents.fold<double>(0, (double widest, double e) => e > widest ? e : widest);
  }

  /// The children in the order they are painted: the raised ones last.
  Iterable<RenderBox> get _painted sync* {
    final List<RenderBox> children = getChildrenAsList();

    yield* children.where((RenderBox child) => !(child.parentData! as _RunParentData).raised);
    yield* children.where((RenderBox child) => (child.parentData! as _RunParentData).raised);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final RenderBox child in _painted) {
      final _RunParentData data = child.parentData! as _RunParentData;
      context.paintChild(child, data.offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in _painted.toList().reversed) {
      final _RunParentData data = child.parentData! as _RunParentData;
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
