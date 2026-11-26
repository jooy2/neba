/// `NebaGrid`, one item of a `NebaGridContainer`.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/grid_container/neba_grid_container.dart';
import 'package:neba/src/internal/grid.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/grid.dart' show NebaGridSpan;

/// One item of a [NebaGridContainer]: [span] columns of its row, an [offset]
/// of whole columns before it, and its own [alignSelf] across the row.
///
/// It has to be a direct child of the container, because what it carries is
/// read by the container's layout rather than drawn.
class NebaGrid extends ParentDataWidget<NebaGridParentData> {
  /// An item spanning [span] columns, every column of the row by default.
  const NebaGrid({
    this.span,
    this.offset = 0,
    this.alignSelf = NebaAlignSelf.auto,
    required super.child,
    super.key,
  }) : assert(offset >= 0);

  /// How wide the item is: a number of columns, its content's width, or its
  /// content's width and whatever its row has left. Every column by default.
  final NebaGridSpan? span;

  /// How many columns of margin come before the item.
  final int offset;

  /// How the item sits across its row, overriding the container's
  /// `alignItems`.
  final NebaAlignSelf alignSelf;

  @override
  void applyParentData(RenderObject renderObject) {
    final NebaGridParentData data = renderObject.parentData! as NebaGridParentData;
    final bool changed =
        !data.isItem ||
        data.span != span ||
        data.offsetColumns != offset ||
        data.alignSelf != alignSelf;

    if (changed) {
      data
        ..isItem = true
        ..span = span
        ..offsetColumns = offset
        ..alignSelf = alignSelf;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => NebaGridContainer;
}
