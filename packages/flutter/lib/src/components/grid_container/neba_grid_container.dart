/// `NebaGridContainer`, the row a twelve-column layout is made of.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/grid.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A row that divides into [columns] columns and wraps, with a gutter between
/// its items. Each item is a `NebaGrid`, which says how many columns it spans.
///
/// It decides how the content divides itself up, and nothing else: it draws
/// no surface, and how far the content sits from the edge of the window is a
/// `NebaContainer`'s to decide.
///
/// ```dart
/// NebaGridContainer(
///   children: <Widget>[
///     NebaGrid(span: NebaGridSpan.columns(8), child: body),
///     NebaGrid(span: NebaGridSpan.columns(4), child: sidebar),
///   ],
/// )
/// ```
class NebaGridContainer extends StatelessWidget {
  /// A grid of [children].
  const NebaGridContainer({
    this.columns = 12,
    this.spacing = 2,
    this.rowSpacing,
    this.columnSpacing,
    this.justifyContent = NebaJustifyContent.start,
    this.alignItems = NebaAlignItems.stretch,
    this.alignContent = NebaJustifyContent.start,
    this.wrap = true,
    this.padded = true,
    this.size,
    this.density,
    this.children = const <Widget>[],
    super.key,
  }) : assert(columns > 0);

  /// How many columns a row divides into. Every span and offset inside is
  /// read against it.
  final int columns;

  /// The gutter between items and between rows, on the spacing scale: `2` is
  /// 8 logical pixels.
  final double spacing;

  /// The gutter between rows, when it differs from [spacing].
  final double? rowSpacing;

  /// The gutter between items in a row, when it differs from [spacing].
  final double? columnSpacing;

  /// Where a row's leftover space goes.
  final NebaJustifyContent justifyContent;

  /// How items sit across their row.
  final NebaAlignItems alignItems;

  /// Where the rows go when the grid is taller than they are.
  final NebaJustifyContent alignContent;

  /// Whether items wrap onto a new row when one is full.
  final bool wrap;

  /// Whether the grid pads its content, on `NebaBox`'s steps. Off inside
  /// something that already pads.
  final bool padded;

  /// The padding's step. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The padding at [size]. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The items, each a `NebaGrid`. Anything else is as wide as its content.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final Widget grid = _GridLayout(
      columns: columns,
      columnGap: (columnSpacing ?? spacing) * NebaScale.spacingUnit,
      rowGap: (rowSpacing ?? spacing) * NebaScale.spacingUnit,
      justifyContent: justifyContent,
      alignItems: alignItems,
      alignContent: alignContent,
      wrap: wrap,
      children: children,
    );

    if (!padded) {
      return grid;
    }

    return Padding(padding: EdgeInsets.all(NebaBox.padding[density]![size]!), child: grid);
  }
}

class _GridLayout extends MultiChildRenderObjectWidget {
  const _GridLayout({
    required this.columns,
    required this.columnGap,
    required this.rowGap,
    required this.justifyContent,
    required this.alignItems,
    required this.alignContent,
    required this.wrap,
    super.children,
  });

  final int columns;
  final double columnGap;
  final double rowGap;
  final NebaJustifyContent justifyContent;
  final NebaAlignItems alignItems;
  final NebaJustifyContent alignContent;
  final bool wrap;

  @override
  RenderNebaGrid createRenderObject(BuildContext context) {
    return RenderNebaGrid(
      columns: columns,
      columnGap: columnGap,
      rowGap: rowGap,
      justifyContent: justifyContent,
      alignItems: alignItems,
      alignContent: alignContent,
      wrap: wrap,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderNebaGrid renderObject) {
    renderObject
      ..columns = columns
      ..columnGap = columnGap
      ..rowGap = rowGap
      ..justifyContent = justifyContent
      ..alignItems = alignItems
      ..alignContent = alignContent
      ..wrap = wrap
      ..textDirection = Directionality.of(context);
  }
}
