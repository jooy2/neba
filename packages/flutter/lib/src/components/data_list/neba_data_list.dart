/// `NebaDataList` and `NebaDataListItem`, things and what they are called.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a [NebaDataListItem] takes from the [NebaDataList] around it, and
/// whether it is the list's first pair, which is the one with no space and no
/// rule above it.
class _NebaDataListScope extends InheritedWidget {
  const _NebaDataListScope({
    required this.size,
    required this.density,
    required this.orientation,
    required this.dividers,
    required this.first,
    required super.child,
    super.key,
  });

  final NebaSize size;
  final NebaDensity density;
  final NebaOrientation orientation;
  final bool dividers;
  final bool first;

  static _NebaDataListScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaDataListScope>();
  }

  @override
  bool updateShouldNotify(_NebaDataListScope oldWidget) {
    return size != oldWidget.size ||
        density != oldWidget.density ||
        orientation != oldWidget.orientation ||
        dividers != oldWidget.dividers ||
        first != oldWidget.first;
  }
}

/// A list of things and what they are called: a details panel, a summary of a
/// record, the metadata under a heading.
///
/// It is a set of pairs rather than a grid of rows, and a screen reader hears
/// each pair as one item, its label and then its value. Laid out
/// [NebaOrientation.horizontal], every label sits in one column, as wide as
/// the widest label up to half the list, so every value starts at the same
/// place. It draws no surface; put it in a `NebaCard` or a `NebaBox` when one
/// is wanted.
///
/// ```dart
/// NebaDataList(
///   children: <Widget>[
///     NebaDataListItem(label: Text('Status'), child: Text('Live')),
///     NebaDataListItem(label: Text('Region'), child: Text('Frankfurt')),
///   ],
/// )
/// ```
class NebaDataList extends StatelessWidget {
  /// A list of [children], usually [NebaDataListItem]s.
  const NebaDataList({
    required this.children,
    this.orientation = NebaOrientation.horizontal,
    this.labelWidth,
    this.dividers = false,
    this.size,
    this.density,
    super.key,
  }) : assert(labelWidth == null || labelWidth >= 0);

  /// The pairs, usually [NebaDataListItem]s.
  final List<Widget> children;

  /// Where the label sits: beside the value in a column of its own, the
  /// shape of a details panel, or above it, for a narrow column and for
  /// values long enough that a label beside them would leave the row empty.
  final NebaOrientation orientation;

  /// How wide the label column is when [NebaOrientation.horizontal], in
  /// logical pixels. Left out, it is as wide as the widest label, up to half
  /// the list, past which a label wraps.
  final double? labelWidth;

  /// Draws a hairline between the pairs. In a vertical list it runs above
  /// each label and never between a label and its value.
  final bool dividers;

  /// The type scale of the labels and the values. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The gaps between the rows and the columns, and nothing else. Defaults
  /// to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Between the label column and the values, per density.
  static const Map<NebaDensity, Map<NebaSize, double>> columnGap =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 12,
          NebaSize.sm: 16,
          NebaSize.md: 20,
          NebaSize.lg: 24,
          NebaSize.xl: 32,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 8,
          NebaSize.sm: 10,
          NebaSize.md: 12,
          NebaSize.lg: 16,
          NebaSize.xl: 20,
        },
      };

  /// Between one pair and the next, per density. With [dividers] the same
  /// again falls between the hairline and the pair under it.
  static const Map<NebaDensity, Map<NebaSize, double>> rowGap =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 8,
          NebaSize.sm: 10,
          NebaSize.md: 12,
          NebaSize.lg: 14,
          NebaSize.xl: 16,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 6,
          NebaSize.md: 8,
          NebaSize.lg: 8,
          NebaSize.xl: 10,
        },
      };

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final List<Widget> pairs = nebaPresentChildren(context, children);
    final List<Widget> scoped = <Widget>[
      for (int i = 0; i < pairs.length; i++)
        _NebaDataListScope(
          // After the pair's own key, so a pair put in front of the others
          // leaves their state where it was.
          key: pairs[i].key == null ? null : ValueKey<Key>(pairs[i].key!),
          size: size,
          density: density,
          orientation: orientation,
          dividers: dividers,
          first: i == 0,
          child: pairs[i],
        ),
    ];

    if (orientation == NebaOrientation.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: scoped,
      );
    }

    return _DataGrid(
      labelWidth: labelWidth,
      columnGap: columnGap[density]![size]!,
      rowGap: rowGap[density]![size]!,
      children: scoped,
    );
  }
}

/// One pair of a [NebaDataList]: what it is called, and what it is.
///
/// It has no size of its own; the list's [NebaDataList.size] and
/// [NebaDataList.density] reach it.
///
/// ```dart
/// NebaDataListItem(label: Text('Region'), child: Text('Frankfurt'))
/// ```
class NebaDataListItem extends StatelessWidget {
  /// A pair of [label] and [child].
  const NebaDataListItem({required this.label, this.child, super.key});

  /// What the value is called, usually a [Text]. Muted, one step down the
  /// type scale.
  final Widget label;

  /// The value: a [Text], or any widget, a chip, a link or an avatar.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final _NebaDataListScope? list = _NebaDataListScope.maybeOf(context);
    final NebaSize size = list?.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = list?.density ?? defaults.density ?? NebaDensity.standard;
    final bool horizontal =
        (list?.orientation ?? NebaOrientation.horizontal) == NebaOrientation.horizontal;
    final bool first = list?.first ?? true;
    final bool ruled = (list?.dividers ?? false) && !first;
    final double gap = NebaDataList.rowGap[density]![size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final double meta = NebaScale.metaText[size]!;
    final double text = NebaScale.controlText[size]!;
    final BorderSide hairline = BorderSide(color: tokens.border);

    // Each part as wide as its column and as tall as what is in it, so a
    // chip or an avatar keeps its own width.
    Widget part(Widget child) {
      return Align(alignment: AlignmentDirectional.topStart, heightFactor: 1, child: child);
    }

    // A hairline and the space under it above a pair that is not the first.
    // Built for every pair, a first one included, so a pair that moves to
    // the top of the list keeps what is inside it.
    Widget rule(Widget child) {
      return Container(
        decoration: BoxDecoration(border: Border(top: ruled ? hairline : BorderSide.none)),
        padding: EdgeInsets.only(top: ruled ? gap : 0),
        child: child,
      );
    }

    final Widget label = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: meta,
        height: leading / meta,
        // CSS shares a line's leading evenly above and below it.
        leadingDistribution: TextLeadingDistribution.even,
        color: tokens.mutedFg,
      ),
      child: part(this.label),
    );
    final Widget value = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: text,
        height: leading / text,
        leadingDistribution: TextLeadingDistribution.even,
        color: tokens.fg,
      ),
      child: part(child ?? const SizedBox.shrink()),
    );

    if (horizontal) {
      return _DataPair(
        textDirection: Directionality.of(context),
        children: <Widget>[
          rule(Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: label)),
          rule(value),
        ],
      );
    }

    // A stacked label sits nearer its own value than the pair before it: the
    // space goes above the label, and inside a pair there is only two pixels.
    Widget pair = Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(padding: const EdgeInsets.only(bottom: 2), child: label),
          value,
        ],
      ),
    );

    pair = rule(pair);

    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : gap),
      child: pair,
    );
  }
}

/// The constraints a horizontal pair is laid out with: the list's width, and
/// the label column every pair in the list shares.
///
/// The column travels down with the constraints, as everything a child is
/// told about its layout does, so a pair is laid out again whenever it
/// changes. A pair handed plain [BoxConstraints], by a widget between it and
/// the list, works its column out from its own label.
class _PairConstraints extends BoxConstraints {
  const _PairConstraints({required this.column, required this.gap, required super.maxWidth});

  final double column;
  final double gap;

  @override
  bool operator ==(Object other) {
    return other is _PairConstraints &&
        other.column == column &&
        other.gap == gap &&
        super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, column, gap);
}

/// The pairs of a horizontal [NebaDataList], one under the other, with the
/// label column worked out across all of them.
class _DataGrid extends MultiChildRenderObjectWidget {
  const _DataGrid({
    required this.labelWidth,
    required this.columnGap,
    required this.rowGap,
    required super.children,
  });

  final double? labelWidth;
  final double columnGap;
  final double rowGap;

  @override
  _RenderDataGrid createRenderObject(BuildContext context) {
    return _RenderDataGrid(labelWidth: labelWidth, columnGap: columnGap, rowGap: rowGap);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderDataGrid renderObject) {
    renderObject
      ..labelWidth = labelWidth
      ..columnGap = columnGap
      ..rowGap = rowGap;
  }
}

class _GridParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderDataGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridParentData> {
  _RenderDataGrid({required double? labelWidth, required double columnGap, required double rowGap})
    : _labelWidth = labelWidth,
      _columnGap = columnGap,
      _rowGap = rowGap;

  double? _labelWidth;
  set labelWidth(double? value) {
    if (value != _labelWidth) {
      _labelWidth = value;
      markNeedsLayout();
    }
  }

  double _columnGap;
  set columnGap(double value) {
    if (value != _columnGap) {
      _columnGap = value;
      markNeedsLayout();
    }
  }

  double _rowGap;
  set rowGap(double value) {
    if (value != _rowGap) {
      _rowGap = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridParentData) {
      child.parentData = _GridParentData();
    }
  }

  Iterable<RenderBox> get _children sync* {
    RenderBox? child = firstChild;

    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  Iterable<_RenderDataPair> get _pairs => _children.whereType<_RenderDataPair>();

  /// The label column at a list [width]: [_labelWidth] when it is given, and
  /// otherwise CSS's `fit-content(50%)`, as wide as the widest label but no
  /// wider than half the list unless a single word needs more.
  double _column(double width) {
    final double? fixed = _labelWidth;

    if (fixed != null) {
      return width.isFinite ? math.min(fixed, width) : fixed;
    }

    double widest = 0;
    double narrowest = 0;

    for (final _RenderDataPair pair in _pairs) {
      widest = math.max(widest, pair.labelWidth(minimum: false));
      narrowest = math.max(narrowest, pair.labelWidth(minimum: true));
    }

    return width.isFinite ? math.min(widest, math.max(narrowest, width / 2)) : widest;
  }

  BoxConstraints _constraintsFor(double width) {
    return _PairConstraints(column: _column(width), gap: _columnGap, maxWidth: width);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double labels = 0;
    double values = 0;
    double others = 0;
    bool paired = false;

    for (final RenderBox child in _children) {
      if (child is _RenderDataPair) {
        paired = true;
        labels = math.max(labels, child.labelWidth(minimum: true));
        values = math.max(values, child.valueWidth(minimum: true));
      } else {
        others = math.max(others, child.getMinIntrinsicWidth(height));
      }
    }

    return paired ? math.max(others, (_labelWidth ?? labels) + _columnGap + values) : others;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double column = _column(double.infinity);
    double width = 0;

    for (final RenderBox child in _children) {
      width = math.max(
        width,
        child is _RenderDataPair
            ? column + _columnGap + child.valueWidth(minimum: false)
            : child.getMaxIntrinsicWidth(height),
      );
    }

    return width;
  }

  double _sumHeights(double Function(RenderBox child) height) {
    double total = 0;

    for (final RenderBox child in _children) {
      total += height(child);
    }

    return total + _rowGap * math.max(0, childCount - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _sumHeights((RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _sumHeights((RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints inner = _constraintsFor(constraints.maxWidth);
    double width = 0;
    final double height = _sumHeights((RenderBox child) {
      final Size size = child.getDryLayout(inner);
      width = math.max(width, size.width);
      return size.height;
    });

    return constraints.constrain(Size(width, height));
  }

  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) {
    final RenderBox? first = firstChild;

    return first?.getDryBaseline(_constraintsFor(constraints.maxWidth), baseline);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  void performLayout() {
    final BoxConstraints inner = _constraintsFor(constraints.maxWidth);
    double y = 0;
    double width = 0;

    for (final RenderBox child in _children) {
      child.layout(inner, parentUsesSize: true);
      (child.parentData! as _GridParentData).offset = Offset(0, y);
      y += child.size.height + _rowGap;
      width = math.max(width, child.size.width);
    }

    size = constraints.constrain(Size(width, childCount == 0 ? 0 : y - _rowGap));
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

/// A label and its value side by side on one baseline, the label in the
/// list's column and the value in what is left.
class _DataPair extends MultiChildRenderObjectWidget {
  const _DataPair({required this.textDirection, required super.children});

  final TextDirection textDirection;

  @override
  _RenderDataPair createRenderObject(BuildContext context) {
    return _RenderDataPair(textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderDataPair renderObject) {
    renderObject.textDirection = textDirection;
  }
}

class _PairParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderDataPair extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PairParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PairParentData> {
  _RenderDataPair({required TextDirection textDirection}) : _textDirection = textDirection;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  double? _baseline;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PairParentData) {
      child.parentData = _PairParentData();
    }
  }

  RenderBox get _label => firstChild!;
  RenderBox get _value => lastChild!;

  /// The label's widest line, or its widest word.
  double labelWidth({required bool minimum}) {
    return minimum
        ? _label.getMinIntrinsicWidth(double.infinity)
        : _label.getMaxIntrinsicWidth(double.infinity);
  }

  /// The value's widest line, or its widest word.
  double valueWidth({required bool minimum}) {
    return minimum
        ? _value.getMinIntrinsicWidth(double.infinity)
        : _value.getMaxIntrinsicWidth(double.infinity);
  }

  /// The column and the gap: the list's, or this pair's own when it was laid
  /// out outside one.
  (double, double) _columns(BoxConstraints constraints) {
    if (constraints is _PairConstraints) {
      return (constraints.column, constraints.gap);
    }

    final double width = constraints.maxWidth;
    final double widest = labelWidth(minimum: false);
    final double column = width.isFinite
        ? math.min(widest, math.max(labelWidth(minimum: true), width / 2))
        : widest;

    return (column, NebaDataList.columnGap[NebaDensity.standard]![NebaSize.md]!);
  }

  /// Where the label and the value go and how big the pair is, from how each
  /// part is laid out at its width.
  ({Size size, double baseline, double valueWidth, double column, double gap}) _arrange(
    BoxConstraints constraints,
    ({Size size, double baseline}) Function(RenderBox child, double width) lay,
  ) {
    final (double column, double gap) = _columns(constraints);
    final double valueWidth = constraints.hasBoundedWidth
        ? math.max(0, constraints.maxWidth - column - gap)
        : this.valueWidth(minimum: false);
    final ({Size size, double baseline}) label = lay(_label, column);
    final ({Size size, double baseline}) value = lay(_value, valueWidth);
    // On one baseline, as CSS grid's `align-items: baseline` puts them.
    final double above = math.max(label.baseline, value.baseline);
    final double below = math.max(
      label.size.height - label.baseline,
      value.size.height - value.baseline,
    );

    return (
      size: constraints.constrain(Size(column + gap + valueWidth, above + below)),
      baseline: above,
      valueWidth: valueWidth,
      column: column,
      gap: gap,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return labelWidth(minimum: true) +
        _columns(const BoxConstraints()).$2 +
        valueWidth(minimum: true);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return labelWidth(minimum: false) +
        _columns(const BoxConstraints()).$2 +
        valueWidth(minimum: false);
  }

  double _intrinsicHeight(double width, double Function(RenderBox child, double width) height) {
    final (double column, double gap) = _columns(BoxConstraints(maxWidth: width));

    return math.max(height(_label, column), height(_value, math.max(0, width - column - gap)));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _intrinsicHeight(width, (RenderBox child, double w) => child.getMinIntrinsicHeight(w));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _intrinsicHeight(width, (RenderBox child, double w) => child.getMaxIntrinsicHeight(w));
  }

  ({Size size, double baseline}) _dry(RenderBox child, double width) {
    final BoxConstraints tight = BoxConstraints.tightFor(width: width);
    final Size size = child.getDryLayout(tight);

    return (
      size: size,
      baseline: child.getDryBaseline(tight, TextBaseline.alphabetic) ?? size.height,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _arrange(constraints, _dry).size;

  @override
  double? computeDryBaseline(BoxConstraints constraints, TextBaseline baseline) {
    return _arrange(constraints, _dry).baseline;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => _baseline;

  @override
  void performLayout() {
    final ({Size size, double baseline, double valueWidth, double column, double gap}) laid =
        _arrange(constraints, (RenderBox child, double width) {
          child.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);

          return (
            size: child.size,
            baseline:
                child.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true) ??
                child.size.height,
          );
        });
    final double above = laid.baseline;
    final bool rtl = _textDirection == TextDirection.rtl;
    final double width = laid.size.width;
    final double labelTop =
        above -
        (_label.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true) ??
            _label.size.height);
    final double valueTop =
        above -
        (_value.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true) ??
            _value.size.height);

    (_label.parentData! as _PairParentData).offset = Offset(
      rtl ? width - laid.column : 0,
      labelTop,
    );
    (_value.parentData! as _PairParentData).offset = Offset(
      rtl ? 0 : laid.column + laid.gap,
      valueTop,
    );

    _baseline = above;
    size = laid.size;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    // One node for the pair, which reads its label and then its value; a
    // link or a button in the value stays a node of its own inside it.
    config.isSemanticBoundary = true;
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
