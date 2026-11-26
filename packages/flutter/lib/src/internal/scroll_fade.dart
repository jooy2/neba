/// The fade a scrolling box draws at each edge that has more beyond it.
///
/// A ScrollArea's content and a Tabs bar's row of tabs fade out where they
/// run on, and only there: the fade is a statement about the content, so it
/// is gone at the top while the top is showing.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// The content faded out at each edge with more beyond it.
///
/// A mask rather than a gradient painted over the content: a gradient would
/// have to fade to a colour, and over a translucent sheet there is none.
class NebaEdgeFade extends StatelessWidget {
  /// [child], faded in by [reach] at the edges [vertical] and [horizontal]
  /// say have more beyond them.
  const NebaEdgeFade({
    super.key,
    required this.reach,
    required this.vertical,
    required this.horizontal,
    required this.child,
  });

  /// How far the fade reaches in from an edge.
  final double reach;

  /// Whether there is more above, and more below.
  final (bool, bool) vertical;

  /// Whether there is more before the start, and more after the end, in the
  /// reading direction.
  final (bool, bool) horizontal;

  /// What is faded.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    // A horizontal view's start is the right edge under RTL.
    final (bool, bool) across = rtl ? (horizontal.$2, horizontal.$1) : horizontal;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) => _ramp(bounds, Axis.vertical, vertical),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) => _ramp(bounds, Axis.horizontal, across),
        child: child,
      ),
    );
  }

  /// The mask along [axis], with [edges] faded.
  Shader _ramp(Rect bounds, Axis axis, (bool, bool) edges) {
    final double extent = axis == Axis.vertical ? bounds.height : bounds.width;
    final double start = edges.$1 && extent > 0 ? (reach / extent).clamp(0, 0.5) : 0;
    final double end = edges.$2 && extent > 0 ? (reach / extent).clamp(0, 0.5) : 0;
    const Color shown = Color(0xFF000000);
    const Color gone = Color(0x00000000);

    return LinearGradient(
      begin: axis == Axis.vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: axis == Axis.vertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: <Color>[start > 0 ? gone : shown, shown, shown, end > 0 ? gone : shown],
      stops: <double>[0, start, 1 - end, 1],
    ).createShader(bounds);
  }
}
