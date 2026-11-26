/// `NebaFlex`, a row or a column with a gutter.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/types.dart';

/// A row or a column of [children] with a gutter between them, the shape most
/// small layouts are: a field and its button, an avatar and a name.
///
/// It draws nothing. The gutter is on the spacing scale, `spacing: 4` being
/// 16 logical pixels, the scale `NebaGridContainer` counts in. A child that
/// should take the room left over is wrapped in an [Expanded], as in any
/// Flutter row.
///
/// ```dart
/// NebaFlex(
///   spacing: 2,
///   alignItems: NebaAlignItems.center,
///   children: <Widget>[avatar, name],
/// )
/// ```
class NebaFlex extends StatelessWidget {
  /// A row, or a column, of [children].
  const NebaFlex({
    this.direction = NebaOrientation.horizontal,
    this.reverse = false,
    this.spacing = 0,
    this.rowSpacing,
    this.columnSpacing,
    this.justifyContent = NebaJustifyContent.start,
    this.alignItems = NebaAlignItems.stretch,
    this.alignContent = NebaJustifyContent.start,
    this.wrap = false,
    this.inline = false,
    this.children = const <Widget>[],
    super.key,
  });

  /// Whether the children run in a row or a column.
  final NebaOrientation direction;

  /// Whether the children run the other way along [direction]. A visual
  /// order only: focus and semantics follow the order of [children].
  final bool reverse;

  /// The gutter between children and between wrapped runs, on the spacing
  /// scale.
  final double spacing;

  /// The vertical gutter, when it differs from [spacing].
  final double? rowSpacing;

  /// The horizontal gutter, when it differs from [spacing].
  final double? columnSpacing;

  /// Where the leftover space along [direction] goes.
  final NebaJustifyContent justifyContent;

  /// Where the children sit across [direction]. Stretched by default.
  final NebaAlignItems alignItems;

  /// Where wrapped runs go across [direction], when [wrap] is on.
  final NebaJustifyContent alignContent;

  /// Whether the children wrap onto a new run when one is full.
  final bool wrap;

  /// Whether a row is as wide as its children rather than as wide as it may
  /// be, CSS `inline-flex`.
  final bool inline;

  /// What runs in the row or the column.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // A hidden NebaShow takes no gap and no cell, as `display: none` takes none.
    final List<Widget> present = nebaPresentChildren(context, children);
    final bool horizontal = direction == NebaOrientation.horizontal;
    final double rowGap = (rowSpacing ?? spacing) * NebaScale.spacingUnit;
    final double columnGap = (columnSpacing ?? spacing) * NebaScale.spacingUnit;
    final TextDirection textDirection = Directionality.of(context);
    final TextDirection runDirection = horizontal && reverse
        ? (textDirection == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr)
        : textDirection;
    final VerticalDirection verticalDirection = !horizontal && reverse
        ? VerticalDirection.up
        : VerticalDirection.down;

    if (wrap) {
      return Wrap(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        spacing: horizontal ? columnGap : rowGap,
        runSpacing: horizontal ? rowGap : columnGap,
        alignment: _wrapAlignment(justifyContent),
        runAlignment: _wrapAlignment(alignContent),
        crossAxisAlignment: switch (alignItems) {
          NebaAlignItems.center => WrapCrossAlignment.center,
          NebaAlignItems.end => WrapCrossAlignment.end,
          NebaAlignItems.start ||
          NebaAlignItems.stretch ||
          NebaAlignItems.baseline => WrapCrossAlignment.start,
        },
        textDirection: runDirection,
        verticalDirection: verticalDirection,
        children: present,
      );
    }

    final CrossAxisAlignment cross = switch (alignItems) {
      NebaAlignItems.start => CrossAxisAlignment.start,
      NebaAlignItems.center => CrossAxisAlignment.center,
      NebaAlignItems.end => CrossAxisAlignment.end,
      NebaAlignItems.stretch => CrossAxisAlignment.stretch,
      NebaAlignItems.baseline => CrossAxisAlignment.baseline,
    };
    final Widget flex = Flex(
      direction: horizontal ? Axis.horizontal : Axis.vertical,
      spacing: horizontal ? columnGap : rowGap,
      mainAxisAlignment: switch (justifyContent) {
        NebaJustifyContent.center => MainAxisAlignment.center,
        NebaJustifyContent.end => MainAxisAlignment.end,
        NebaJustifyContent.spaceBetween => MainAxisAlignment.spaceBetween,
        NebaJustifyContent.spaceAround => MainAxisAlignment.spaceAround,
        NebaJustifyContent.spaceEvenly => MainAxisAlignment.spaceEvenly,
        NebaJustifyContent.start || NebaJustifyContent.stretch => MainAxisAlignment.start,
      },
      // A column is as tall as its children, as a block flex column is; a row
      // is as wide as it may be unless it is inline.
      mainAxisSize: horizontal && !inline ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: cross,
      textDirection: runDirection,
      verticalDirection: verticalDirection,
      textBaseline: alignItems == NebaAlignItems.baseline ? TextBaseline.alphabetic : null,
      children: present,
    );

    if (cross != CrossAxisAlignment.stretch) {
      return flex;
    }

    // Stretching is to the line's thickness, which CSS takes from the thickest
    // child when the box has no size of its own across. A row asks its
    // children's intrinsic height for that; a block column is as wide as it
    // may be already, and an inline one asks their intrinsic width.
    if (horizontal) {
      return IntrinsicHeight(child: flex);
    }

    return inline ? IntrinsicWidth(child: flex) : flex;
  }

  static WrapAlignment _wrapAlignment(NebaJustifyContent value) {
    return switch (value) {
      NebaJustifyContent.center => WrapAlignment.center,
      NebaJustifyContent.end => WrapAlignment.end,
      NebaJustifyContent.spaceBetween => WrapAlignment.spaceBetween,
      NebaJustifyContent.spaceAround => WrapAlignment.spaceAround,
      NebaJustifyContent.spaceEvenly => WrapAlignment.spaceEvenly,
      NebaJustifyContent.start || NebaJustifyContent.stretch => WrapAlignment.start,
    };
  }
}
