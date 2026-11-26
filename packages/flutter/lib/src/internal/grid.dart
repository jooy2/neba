/// The twelve-column grid's layout, the React package's `.neba-grid` and
/// `.neba-grid-item` rules worked out in Dart.
///
/// A grid is a wrapping row. An item that spans a number of columns is
/// `(width + gap) / columns × span − gap` wide, so the gutters line up from
/// row to row; an `auto` item is as wide as its content; a `grow` item starts
/// there and takes what its row has left. An offset is a margin of whole
/// columns at the item's start. A row then lays out the way a CSS flex line
/// does: what is left over is placed by `justifyContent`, and the items sit
/// across the row by `alignItems` unless one says otherwise.
///
/// Flutter's [Wrap] has no item that grows, which is why this is a render
/// object of its own.
///
/// The library talking to itself: `NebaGridSpan` is exported through
/// `NebaGrid`, and nothing else here is.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:neba/src/types.dart';

/// How wide a grid item is: a number of columns, its content's width, or its
/// content's width and whatever its row has left.
@immutable
class NebaGridSpan {
  /// [count] columns of the grid's row.
  const NebaGridSpan.columns(int this.count) : assert(count > 0), grows = false;

  const NebaGridSpan._(this.grows) : count = null;

  /// As wide as the item's content.
  static const NebaGridSpan auto = NebaGridSpan._(false);

  /// As wide as the item's content, plus whatever the row has left.
  static const NebaGridSpan grow = NebaGridSpan._(true);

  /// The number of columns, for a span that is one.
  final int? count;

  /// Whether the item takes what its row has left.
  final bool grows;

  @override
  bool operator ==(Object other) {
    return other is NebaGridSpan && other.count == count && other.grows == grows;
  }

  @override
  int get hashCode => Object.hash(count, grows);

  @override
  String toString() {
    final int? columns = count;

    return columns != null ? 'NebaGridSpan.columns($columns)' : (grows ? 'grow' : 'auto');
  }
}

/// What a grid item tells the grid about itself.
class NebaGridParentData extends ContainerBoxParentData<RenderBox> {
  /// Whether the child is a grid item. A child that is not is as wide as its
  /// content, as a plain element in a flex row is.
  bool isItem = false;

  /// The item's span, or `null` for every column of the row.
  NebaGridSpan? span;

  /// The columns of margin at the item's start. (`offset` is the position
  /// [ContainerBoxParentData] already holds.)
  int offsetColumns = 0;

  /// How the item sits across its row.
  NebaAlignSelf alignSelf = NebaAlignSelf.auto;
}

/// The grid: a row that wraps, with the column arithmetic of a twelve-column
/// layout.
class RenderNebaGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, NebaGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, NebaGridParentData> {
  /// A grid of [columns] columns.
  RenderNebaGrid({
    required int columns,
    required double columnGap,
    required double rowGap,
    required NebaJustifyContent justifyContent,
    required NebaAlignItems alignItems,
    required NebaJustifyContent alignContent,
    required bool wrap,
    required TextDirection textDirection,
  }) : _columns = columns,
       _columnGap = columnGap,
       _rowGap = rowGap,
       _justifyContent = justifyContent,
       _alignItems = alignItems,
       _alignContent = alignContent,
       _wrap = wrap,
       _textDirection = textDirection;

  int _columns;

  /// How many columns a row divides into.
  int get columns => _columns;
  set columns(int value) {
    if (_columns != value) {
      _columns = value;
      markNeedsLayout();
    }
  }

  double _columnGap;

  /// The gap between items in a row.
  double get columnGap => _columnGap;
  set columnGap(double value) {
    if (_columnGap != value) {
      _columnGap = value;
      markNeedsLayout();
    }
  }

  double _rowGap;

  /// The gap between rows.
  double get rowGap => _rowGap;
  set rowGap(double value) {
    if (_rowGap != value) {
      _rowGap = value;
      markNeedsLayout();
    }
  }

  NebaJustifyContent _justifyContent;

  /// Where a row's leftover space goes.
  NebaJustifyContent get justifyContent => _justifyContent;
  set justifyContent(NebaJustifyContent value) {
    if (_justifyContent != value) {
      _justifyContent = value;
      markNeedsLayout();
    }
  }

  NebaAlignItems _alignItems;

  /// How items sit across their row.
  NebaAlignItems get alignItems => _alignItems;
  set alignItems(NebaAlignItems value) {
    if (_alignItems != value) {
      _alignItems = value;
      markNeedsLayout();
    }
  }

  NebaJustifyContent _alignContent;

  /// Where the rows go when the grid is taller than they are.
  NebaJustifyContent get alignContent => _alignContent;
  set alignContent(NebaJustifyContent value) {
    if (_alignContent != value) {
      _alignContent = value;
      markNeedsLayout();
    }
  }

  bool _wrap;

  /// Whether items wrap onto a new row when one is full.
  bool get wrap => _wrap;
  set wrap(bool value) {
    if (_wrap != value) {
      _wrap = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;

  /// Which way a row runs.
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! NebaGridParentData) {
      child.parentData = NebaGridParentData();
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

  @override
  double computeMinIntrinsicWidth(double height) {
    return _children.fold(0, (double widest, RenderBox child) {
      return math.max(widest, child.getMinIntrinsicWidth(height));
    });
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final List<RenderBox> children = _children;
    final double content = children.fold(0, (double sum, RenderBox child) {
      return sum + child.getMaxIntrinsicWidth(height);
    });

    return content + columnGap * math.max(0, children.length - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) => _layout(width, dry: true).height;

  @override
  double computeMaxIntrinsicHeight(double width) => _layout(width, dry: true).height;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final double width = _widthFor(constraints);

    return constraints.constrain(Size(width, _layout(width, dry: true).height));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  double _widthFor(BoxConstraints constraints) {
    return constraints.hasBoundedWidth
        ? constraints.maxWidth
        : computeMaxIntrinsicWidth(double.infinity);
  }

  @override
  void performLayout() {
    final double width = _widthFor(constraints);
    final _Layout layout = _layout(width, dry: false);
    double height = layout.height;
    final double extra = math.max(0, constraints.minHeight - height);

    // Rows in a grid taller than they are: `alignContent` places them.
    if (extra > 0 && layout.lines.isNotEmpty) {
      final List<double> shifts = _distribute(alignContent, extra, layout.lines.length);

      for (int i = 0; i < layout.lines.length; i++) {
        for (final _Item item in layout.lines[i]) {
          final NebaGridParentData data = item.child.parentData! as NebaGridParentData;
          data.offset = data.offset + Offset(0, shifts[i]);
        }
      }

      height += extra;
    }

    size = constraints.constrain(Size(width, height));
  }

  /// How far each of [count] runs moves along its axis for [mode] to spend
  /// [free] space, cumulative from the first.
  List<double> _distribute(NebaJustifyContent mode, double free, int count) {
    double leading;
    double between;

    switch (mode) {
      case NebaJustifyContent.center:
        leading = free / 2;
        between = 0;
      case NebaJustifyContent.end:
        leading = free;
        between = 0;
      case NebaJustifyContent.spaceBetween:
        leading = 0;
        between = count > 1 ? free / (count - 1) : 0;
      case NebaJustifyContent.spaceAround:
        between = free / count;
        leading = between / 2;
      case NebaJustifyContent.spaceEvenly:
        between = free / (count + 1);
        leading = between;
      case NebaJustifyContent.start:
      case NebaJustifyContent.stretch:
        leading = 0;
        between = 0;
    }

    return <double>[for (int i = 0; i < count; i++) leading + between * i];
  }

  /// Lays every child out across [width]; with [dry], measures without
  /// laying anything out or moving it.
  _Layout _layout(double width, {required bool dry}) {
    final int columns = math.max(1, this.columns);
    final double track = (width + columnGap) / columns;
    final List<List<_Item>> lines = <List<_Item>>[];
    List<_Item> line = <_Item>[];
    double used = 0;

    for (final RenderBox child in _children) {
      final NebaGridParentData data = child.parentData! as NebaGridParentData;
      final NebaGridSpan? span = data.isItem ? data.span : NebaGridSpan.auto;
      final double margin = track * math.min(data.offsetColumns, columns);
      final int? count = span == null ? columns : span.count;
      final double basis = count != null
          ? math.max(0, track * math.min(count, columns) - columnGap)
          : math.min(child.getMaxIntrinsicWidth(double.infinity), math.max(0, width - margin));
      final _Item item = _Item(child, margin, basis, grow: span?.grows ?? false);
      final double outer = margin + basis;

      if (line.isNotEmpty && wrap && used + columnGap + outer > width + 0.01) {
        lines.add(line);
        line = <_Item>[];
        used = 0;
      }

      used += (line.isEmpty ? 0 : columnGap) + outer;
      line.add(item);
    }

    if (line.isNotEmpty) {
      lines.add(line);
    }

    double top = 0;

    for (int index = 0; index < lines.length; index++) {
      final List<_Item> row = lines[index];
      final double taken =
          row.fold(0.0, (double sum, _Item item) => sum + item.margin + item.width) +
          columnGap * (row.length - 1);
      double free = math.max(0, width - taken);
      final List<_Item> growing = row.where((_Item item) => item.grow).toList();

      if (free > 0 && growing.isNotEmpty) {
        for (final _Item item in growing) {
          item.width += free / growing.length;
        }

        free = 0;
      }

      double lineHeight = 0;
      double ascent = 0;
      double descent = 0;

      for (final _Item item in row) {
        final BoxConstraints loose = BoxConstraints.tightFor(width: item.width);
        final NebaAlignItems align = _alignOf(item);

        item.height = dry ? item.child.getDryLayout(loose).height : _place(item.child, loose);

        if (align == NebaAlignItems.baseline && !dry) {
          final double base = item.child.getDistanceToBaseline(TextBaseline.alphabetic) ?? 0;
          item.baseline = base;
          ascent = math.max(ascent, base);
          descent = math.max(descent, item.height - base);
        } else {
          lineHeight = math.max(lineHeight, item.height);
        }
      }

      lineHeight = math.max(lineHeight, ascent + descent);

      if (!dry) {
        final List<double> shifts = _distribute(justifyContent, free, row.length);
        double cursor = 0;

        for (int i = 0; i < row.length; i++) {
          final _Item item = row[i];
          final NebaAlignItems align = _alignOf(item);

          if (align == NebaAlignItems.stretch && item.height < lineHeight) {
            _place(item.child, BoxConstraints.tightFor(width: item.width, height: lineHeight));
            item.height = lineHeight;
          }

          final double y = switch (align) {
            NebaAlignItems.center => (lineHeight - item.height) / 2,
            NebaAlignItems.end => lineHeight - item.height,
            NebaAlignItems.baseline => ascent - item.baseline,
            NebaAlignItems.start || NebaAlignItems.stretch => 0,
          };
          final double start = shifts[i] + cursor + item.margin;
          final double x = textDirection == TextDirection.rtl ? width - start - item.width : start;

          (item.child.parentData! as NebaGridParentData).offset = Offset(x, top + y);
          cursor += item.margin + item.width + columnGap;
        }
      }

      top += lineHeight + (index < lines.length - 1 ? rowGap : 0);
    }

    return _Layout(lines, top);
  }

  NebaAlignItems _alignOf(_Item item) {
    final NebaGridParentData data = item.child.parentData! as NebaGridParentData;

    return switch (data.alignSelf) {
      NebaAlignSelf.auto => alignItems,
      NebaAlignSelf.start => NebaAlignItems.start,
      NebaAlignSelf.center => NebaAlignItems.center,
      NebaAlignSelf.end => NebaAlignItems.end,
      NebaAlignSelf.stretch => NebaAlignItems.stretch,
      NebaAlignSelf.baseline => NebaAlignItems.baseline,
    };
  }

  double _place(RenderBox child, BoxConstraints constraints) {
    child.layout(constraints, parentUsesSize: true);

    return child.size.height;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class _Item {
  _Item(this.child, this.margin, this.width, {required this.grow});

  final RenderBox child;
  final double margin;
  final bool grow;
  double width;
  double height = 0;
  double baseline = 0;
}

class _Layout {
  const _Layout(this.lines, this.height);

  final List<List<_Item>> lines;
  final double height;
}
