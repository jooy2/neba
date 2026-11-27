/// What the two bottom bars share: the React package's
/// `src/internal/bottom-navigation.ts`.
///
/// Two bars provide it, `NebaBottomNavigation` and
/// `NebaFloatingBottomNavigation`, and one item reads it. Keeping it in either
/// bar's file would make the other import its sibling to draw a row of
/// destinations.
///
/// The library talking to itself, except for [NebaBottomNavigationLabels],
/// which both bars export as the React package exports its
/// `BottomNavigationLabels`.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/types.dart';

/// Which destinations' names a bottom bar draws.
enum NebaBottomNavigationLabels {
  /// Every one. The only one that works for a reader who has not used the app
  /// before, and the default on the bar that spans the bottom edge.
  all,

  /// Only the destination that is current. A name that is not drawn is still
  /// read by a screen reader.
  selected,

  /// None: glyphs only, with every name read but never drawn.
  none,
}

/// What a `NebaBottomNavigationItem` takes from the bar it is in: whether it
/// is the current destination, what to call when it is pressed, and the
/// bar's own axes, which belong to the set rather than to an item.
class NebaBottomNavigationSlot extends InheritedWidget {
  /// The bar's word to one item, [child].
  const NebaBottomNavigationSlot({
    required this.selected,
    required this.onChoose,
    required this.size,
    required this.density,
    required this.color,
    required this.labels,
    required this.disabled,
    required this.floating,
    required super.child,
    super.key,
  });

  /// Whether the item is the destination the reader is on.
  final bool selected;

  /// Makes the item the current destination.
  final VoidCallback onChoose;

  /// The bar's size.
  final NebaSize size;

  /// The bar's density.
  final NebaDensity density;

  /// The family the current destination is drawn in.
  final NebaColor color;

  /// Which names the bar draws.
  final NebaBottomNavigationLabels labels;

  /// Whether the whole bar is disabled.
  final bool disabled;

  /// Whether the bar is the floating one, which sizes its items by their
  /// content and cuts them as stadiums, and draws the current one's highlight
  /// itself, behind them all.
  final bool floating;

  /// The slot around the item at [context], or `null` outside a bar.
  static NebaBottomNavigationSlot? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaBottomNavigationSlot>();
  }

  @override
  bool updateShouldNotify(NebaBottomNavigationSlot oldWidget) {
    return selected != oldWidget.selected ||
        onChoose != oldWidget.onChoose ||
        size != oldWidget.size ||
        density != oldWidget.density ||
        color != oldWidget.color ||
        labels != oldWidget.labels ||
        disabled != oldWidget.disabled ||
        floating != oldWidget.floating;
  }
}

/// A bar's floor, padding included, and the one number the two bars agree
/// on: `md` is 56 logical pixels, tall enough for a glyph with a word under
/// it. A floating bar is the same object lifted off the edge, so it is the
/// same height.
const Map<NebaSize, double> nebaBarMinHeight = <NebaSize, double>{
  NebaSize.xs: 40,
  NebaSize.sm: 48,
  NebaSize.md: 56,
  NebaSize.lg: 64,
  NebaSize.xl: 72,
};
