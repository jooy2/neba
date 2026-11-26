/// What a widget that answers a breakpoint decides, and how the containers in
/// the library leave a hidden one out.
///
/// The React package hides with `display: none`, which takes an element out
/// of a flex row and a grid entirely: it gets no gap and no cell. A Flutter
/// container cannot see that a child built nothing, so the library's own
/// containers ask each child that answers a breakpoint whether it is shown
/// before they lay anything out.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/types.dart';

/// Whether a window [width] is at or above [above] and below [below].
///
/// [above] is inclusive and [below] exclusive, so the same breakpoint in both
/// covers every width exactly once.
bool nebaShownAt(double width, {NebaBreakpoint? above, NebaBreakpoint? below}) {
  return (above == null || width >= above.width) && (below == null || width < below.width);
}

/// A widget whose children are there at some window widths and not at others.
abstract interface class NebaWidthGate {
  /// Whether the widget is shown at a window [width].
  bool shownAt(double width);
}

/// [children] without the ones a [NebaWidthGate] hides at the window's width.
///
/// A list with no gate in it is handed back as it is, and only then does the
/// container depend on the window's size, so one that holds none is never
/// rebuilt by a resize.
List<Widget> nebaPresentChildren(BuildContext context, List<Widget> children) {
  if (!children.any((Widget child) => child is NebaWidthGate)) {
    return children;
  }

  final double width = MediaQuery.sizeOf(context).width;

  return <Widget>[
    for (final Widget child in children)
      if (child is! NebaWidthGate || (child as NebaWidthGate).shownAt(width)) child,
  ];
}
