/// Where a bar sits against an edge: what `position`, `side` and `safeArea`
/// mean on a Toolbar and a Pill.
///
/// A Flutter widget is laid out where its parent puts it, so a bar cannot
/// stick to the edge of a scroll view it is in the way a CSS `sticky` box
/// does: it would paint under every sibling that follows it. A `sticky` bar is
/// therefore drawn as it looks once it is held there, and the scroll view
/// holds it. A `fixed` one leaves the flow, as CSS `fixed` does, for the
/// nearest overlay.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/portal/neba_portal.dart';
import 'package:neba/src/types.dart';

/// Whether a bar at [position] is held against an edge: everything but
/// [NebaPosition.static].
bool nebaIsPinned(NebaPosition position) => position != NebaPosition.static;

/// The screen's inset on [side] a pinned bar keeps clear of, a phone's notch
/// or its home indicator: the padding `MediaQuery` reports where the bar is
/// built, which is the React package's `env(safe-area-inset-*)`. Nothing
/// when the bar is not pinned or [safeArea] is off, and nothing under a
/// `SafeArea` that has already paid for it.
double nebaSafeInset(
  BuildContext context, {
  required NebaPosition position,
  required NebaSide side,
  required bool safeArea,
}) {
  if (!safeArea || !nebaIsPinned(position)) {
    return 0;
  }

  final EdgeInsets padding = MediaQuery.paddingOf(context);

  return side == NebaSide.bottom ? padding.bottom : padding.top;
}

/// [child] where [position] puts it: in place, or, when it is
/// [NebaPosition.fixed], in the nearest [Overlay] against [side], across
/// the overlay's width or centred in it, taking no room where it was written.
class NebaPinnedBar extends StatelessWidget {
  /// [child], placed by [position].
  const NebaPinnedBar({required this.position, required this.side, required this.child, super.key})
    : assert(side == NebaSide.top || side == NebaSide.bottom);

  /// How the bar sits.
  final NebaPosition position;

  /// The edge a fixed bar is held against: [NebaSide.top] or
  /// [NebaSide.bottom].
  final NebaSide side;

  /// The bar. A fixed one is laid out against the whole overlay, so a bar
  /// that fills its width spans it and one that does not is centred in it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (position != NebaPosition.fixed) {
      return child;
    }

    // The overlay of the route the bar is in, so a route pushed over it
    // covers it as it covers the rest of the page.
    return NebaPortal(
      rootOverlay: false,
      child: Align(
        alignment: side == NebaSide.bottom ? Alignment.bottomCenter : Alignment.topCenter,
        child: child,
      ),
    );
  }
}
