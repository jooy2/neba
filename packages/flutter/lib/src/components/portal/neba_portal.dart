/// `NebaPortal`, a child drawn in an overlay rather than where it was written.
library;

import 'package:flutter/widgets.dart';

/// A child drawn in an [Overlay] above everything else rather than where it
/// was written: for a subtree that has to escape a clip, a scroll or a sheet
/// its own position would trap it in.
///
/// The child is built where it was written, so it keeps the theme, the
/// `NebaProvider` defaults and every other inherited value from there; only
/// where it is laid out and painted changes. It is laid out against the whole
/// overlay, so a `Positioned` or an `Align` places it.
///
/// ```dart
/// NebaPortal(
///   child: Align(alignment: Alignment.topCenter, child: banner),
/// )
/// ```
class NebaPortal extends StatefulWidget {
  /// [child], drawn in an overlay.
  const NebaPortal({
    required this.child,
    this.rootOverlay = true,
    this.disabled = false,
    super.key,
  });

  /// What is drawn elsewhere.
  final Widget child;

  /// Whether the child goes into the app's root overlay, above every route
  /// and every nested navigator, rather than into the nearest one above the
  /// portal.
  final bool rootOverlay;

  /// Draws the child in place instead.
  ///
  /// Decide it once, when the portal is first built: a child in an overlay and
  /// one in place sit at different points in the tree, so changing this
  /// builds everything inside again and throws away what was in it.
  final bool disabled;

  @override
  State<NebaPortal> createState() => _NebaPortalState();
}

class _NebaPortalState extends State<NebaPortal> {
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _controller.show();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) {
      return widget.child;
    }

    Widget overlayChild(BuildContext context) => widget.child;

    // Nothing is drawn in place: the portal itself takes no room.
    return OverlayPortal(
      controller: _controller,
      overlayLocation: widget.rootOverlay
          ? OverlayChildLocation.rootOverlay
          : OverlayChildLocation.nearestOverlay,
      overlayChildBuilder: overlayChild,
    );
  }
}
