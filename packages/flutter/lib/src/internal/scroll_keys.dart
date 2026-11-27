/// The keys a focused scroll box answers, and how a step of scrolling moves.
///
/// A browser scrolls a focused scroll container with the arrow keys, Page Up
/// and Page Down, Home and End. A Flutter scroll view answers them only
/// through the shortcuts a `WidgetsApp` installs, and only for a focus inside
/// it, so ScrollArea and ScrollZone take the focus themselves and answer the
/// keys here, the same way. A ScrollZone's buttons move by the same step
/// animation.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// How far an arrow key scrolls: forty pixels, as a browser scrolls a line.
const double nebaScrollLine = 40;

/// How much of the viewport Page Up and Page Down scroll, as a browser does:
/// most of it, so a line of the last page is still on screen.
const double nebaScrollPage = 0.875;

/// Moves [position] to [target], held inside its extent, over the house
/// duration, or at once for a reader who asked for less motion.
void nebaScrollTo(BuildContext context, ScrollPosition position, double target) {
  final double clamped = target.clamp(position.minScrollExtent, position.maxScrollExtent);
  final Duration duration = nebaDuration(context, NebaScale.duration);

  if (duration == Duration.zero) {
    position.jumpTo(clamped);
  } else {
    position.animateTo(clamped, duration: duration, curve: NebaScale.ease);
  }
}

/// Scrolls [vertical] or [horizontal] by the key [event] names, and says
/// whether a key the box answers was pressed.
///
/// The arrows move a line along the axis they point down, those across in the
/// reading direction; the page keys, Home and End move the vertical scroll,
/// or the horizontal one when there is no vertical one. A key for an axis the
/// box does not scroll is left to whatever is around it.
KeyEventResult nebaScrollKey(
  BuildContext context,
  KeyEvent event, {
  ScrollController? vertical,
  ScrollController? horizontal,
}) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }

  final bool rtl = Directionality.of(context) == TextDirection.rtl;
  final ScrollController? either = vertical ?? horizontal;
  final LogicalKeyboardKey key = event.logicalKey;

  bool moved = false;

  void by(ScrollController? controller, double Function(ScrollPosition position) delta) {
    if (controller == null || !controller.hasClients) {
      return;
    }

    final ScrollPosition position = controller.position;

    nebaScrollTo(context, position, position.pixels + delta(position));
    moved = true;
  }

  if (key == LogicalKeyboardKey.arrowDown) {
    by(vertical, (_) => nebaScrollLine);
  } else if (key == LogicalKeyboardKey.arrowUp) {
    by(vertical, (_) => -nebaScrollLine);
  } else if (key == LogicalKeyboardKey.arrowRight) {
    by(horizontal, (_) => rtl ? -nebaScrollLine : nebaScrollLine);
  } else if (key == LogicalKeyboardKey.arrowLeft) {
    by(horizontal, (_) => rtl ? nebaScrollLine : -nebaScrollLine);
  } else if (key == LogicalKeyboardKey.pageDown) {
    by(either, (ScrollPosition p) => p.viewportDimension * nebaScrollPage);
  } else if (key == LogicalKeyboardKey.pageUp) {
    by(either, (ScrollPosition p) => -p.viewportDimension * nebaScrollPage);
  } else if (key == LogicalKeyboardKey.home) {
    by(either, (ScrollPosition p) => p.minScrollExtent - p.pixels);
  } else if (key == LogicalKeyboardKey.end) {
    by(either, (ScrollPosition p) => p.maxScrollExtent - p.pixels);
  }

  return moved ? KeyEventResult.handled : KeyEventResult.ignored;
}
