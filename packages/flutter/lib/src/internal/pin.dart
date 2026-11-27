/// Where a widget that floats over a region sits: the React package's
/// `fixed`, `sticky` and `absolute` for a FloatingActionButton and a
/// FloatingBottomNavigation, said in Flutter's terms.
///
/// Flutter has no positioning against the window or against a positioned
/// ancestor. A screen there is a `Stack` (a `Scaffold` lays its floating
/// button over its body in one), so a widget that floats takes the whole of
/// the space it is laid out in and puts its child at an edge or a corner of
/// it, an offset in from each edge it is against. Laid out with no bound on an
/// axis, it is only as large as its child along that axis. A press anywhere
/// but on the child goes through to what is underneath, because nothing here
/// takes a pointer of its own.
///
/// It is deliberately not the overlay. A button in the root overlay would stay
/// on screen over the next route, and over a dialog the screen it belongs to
/// opened.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// [child] at [alignment] in the space it is given, [offset] in from each
/// edge it is against and, with [safeArea], clear of the system insets on
/// those edges too.
///
/// The edges are read off [alignment]: `bottomEnd` is against the bottom and
/// the trailing edge, `bottomCenter` against the bottom alone.
class NebaPin extends StatelessWidget {
  /// [child] pinned to [alignment].
  const NebaPin({
    required this.alignment,
    required this.offset,
    required this.safeArea,
    required this.child,
    super.key,
  });

  /// The edge or the corner [child] is pinned to.
  final AlignmentDirectional alignment;

  /// How far in from each edge [child] is against.
  final double offset;

  /// Whether the system insets of those edges are added to [offset].
  final bool safeArea;

  /// What floats.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets screen = safeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool start = alignment.start < 0;
    final bool end = alignment.start > 0;
    final bool left = rtl ? end : start;
    final bool right = rtl ? start : end;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(
          left: left ? offset + screen.left : 0,
          top: alignment.y < 0 ? offset + screen.top : 0,
          right: right ? offset + screen.right : 0,
          bottom: alignment.y > 0 ? offset + screen.bottom : 0,
        ),
        child: child,
      ),
    );
  }
}
