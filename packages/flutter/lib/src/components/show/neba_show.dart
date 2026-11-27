/// `NebaShow`, its child at some window widths and not at others.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/types.dart';

/// Its child at some window widths and not at others: a floor, a ceiling, or
/// both, on the same five-step ladder every breakpoint in the library uses.
///
/// [above] is inclusive and [below] exclusive, so `above: NebaBreakpoint.md`
/// and `below: NebaBreakpoint.md` are the two halves of one decision and cover
/// every width exactly once. Together they bound a range:
/// `above: NebaBreakpoint.sm, below: NebaBreakpoint.lg` is shown from 640 up
/// to but not including 1024 logical pixels.
///
/// The width is the window's, `MediaQuery.sizeOf`, as a CSS media query reads
/// the viewport's. A hidden child is not built at all, so a widget below it
/// that fetches or starts something does not run, and one that crosses the
/// breakpoint is built afresh. A shown one is built where the `NebaShow` is,
/// with nothing in between, so a `NebaShow` around a `NebaGrid` leaves the
/// cell a cell; `NebaFlex`, `NebaGridContainer` and a `NebaHeader`'s slots
/// leave a hidden one out entirely, gap and all.
///
/// ```dart
/// NebaShow(above: NebaBreakpoint.md, child: sidebar)
/// ```
class NebaShow extends StatelessWidget implements NebaWidthGate {
  /// [child], from [above] up to [below].
  const NebaShow({required this.child, this.above, this.below, super.key});

  /// The narrowest window [child] is shown in, inclusive. [NebaBreakpoint.xs]
  /// is a floor of zero, and so means always.
  final NebaBreakpoint? above;

  /// The window width at which [child] stops being shown, exclusive.
  /// [NebaBreakpoint.xs] shows it nowhere, since no width is below zero.
  final NebaBreakpoint? below;

  /// What is shown.
  final Widget child;

  /// Whether [child] is shown in a window [width] logical pixels wide.
  bool shownAt(double width) => nebaShownAt(width, above: above, below: below);

  /// Whether [child] is shown in the window [context] is laid out in.
  @override
  bool shownIn(BuildContext context) => shownAt(MediaQuery.sizeOf(context).width);

  @override
  Widget build(BuildContext context) {
    return shownIn(context) ? child : const SizedBox.shrink();
  }
}
