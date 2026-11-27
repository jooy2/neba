/// The wheel over a strip, turned onto the axis the strip runs along: the
/// React package's `src/internal/wheel.ts`; and the wheel over a focused
/// number field, which steps it, as Base UI's `allowWheelScrub` does.
///
/// A mouse has one wheel and it points down the page, which is the one axis a
/// horizontal strip does not run along, so a shelf of cards or a tab bar with
/// more tabs than room would be the one thing on a screen a mouse cannot reach
/// into. While the pointer is over a strip that has somewhere to go, the wheel
/// is the strip's and nothing else's, at its ends too: handing the wheel back
/// the moment the strip runs out is what makes the page lurch mid-flick.
/// Moving the pointer off the strip is how the page is scrolled past.
///
/// A strip that fits takes nothing, which is what makes it safe to leave on.
/// A wheel held with Ctrl is a zoom and is left alone, and a trackpad swiping
/// sideways is already travel along the strip, which the strip's own scroll
/// view answers before this is asked.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Under this much room left over, a strip is not scrolled and holds nothing.
const double nebaWheelSlack = 1;

/// Answers a wheel [event] over a strip that [position] scrolls along [axis],
/// and returns which way along the strip it went, as the sign of the change
/// in scroll offset, or `null` when the strip took nothing.
///
/// Call it from a `Listener`'s `onPointerSignal` around the strip's scroll
/// view. A wheel is offered to the deepest scroll view under the pointer
/// first, so the strip's own view and anything nearer the pointer have had
/// their chance when this runs, and what it registers is what none of them
/// took.
///
/// With [turn], a wheel rolled down the page over a horizontal strip moves the
/// strip along. Whatever the strip scrolls by itself stays the strip's at its
/// ends rather than carrying on into the page behind, as CSS
/// `overscroll-behavior: contain` keeps it.
int? nebaStripWheel(
  PointerSignalEvent event,
  ScrollPosition position, {
  required Axis axis,
  required bool turn,
  required TextDirection textDirection,
}) {
  if (event is! PointerScrollEvent) {
    return null;
  }

  // A strip that fits is not a scroll container as far as the reader is
  // concerned, and holding the page there would be holding it for nothing.
  if (position.maxScrollExtent - position.minScrollExtent <= nebaWheelSlack) {
    return null;
  }

  final Offset delta = event.scrollDelta;
  final bool horizontal = axis == Axis.horizontal;

  if (turn &&
      horizontal &&
      delta.dy != 0 &&
      delta.dy.abs() >= delta.dx.abs() &&
      !HardwareKeyboard.instance.isControlPressed) {
    GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent event) {
      // Ahead is ahead in either writing direction: the scroll offset is
      // already counted from the leading edge.
      position.pointerScroll(delta.dy);
    });

    return delta.dy.sign.toInt();
  }

  final bool flipped =
      HardwareKeyboard.instance.isShiftPressed && event.kind == PointerDeviceKind.mouse;
  final double along = horizontal ? (flipped ? delta.dy : delta.dx) : (flipped ? 0 : delta.dy);

  if (along == 0) {
    return null;
  }

  GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent event) {});

  final bool rtl = horizontal && textDirection == TextDirection.rtl;

  return (rtl ? -along : along).sign.toInt();
}

/// Answers a wheel [event] over a field that steps, a number field holding
/// the focus, by calling [step] with `1` for a wheel rolled up and `-1` for
/// one rolled down, and claims it so nothing behind the field scrolls.
///
/// Call it from a `Listener`'s `onPointerSignal` around the number, once the
/// field knows the focus is in it: a field nobody has put the caret in leaves
/// the page its scroll. [step] runs only if the field wins the event, which
/// the deepest listener under the pointer does.
///
/// A wheel held with Ctrl is a zoom and is left alone. With Shift held, a
/// wheel the platform has already turned sideways still steps, by its
/// sideways travel; without it, a sideways swipe is not a step.
void nebaFieldWheel(PointerSignalEvent event, ValueChanged<int> step) {
  if (event is! PointerScrollEvent || HardwareKeyboard.instance.isControlPressed) {
    return;
  }

  final Offset delta = event.scrollDelta;
  final bool shift = HardwareKeyboard.instance.isShiftPressed;
  final bool sideways = delta.dx.abs() > delta.dy.abs();
  final double along = shift && sideways ? delta.dx : delta.dy;

  if (along == 0 || (!shift && sideways)) {
    return;
  }

  GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent event) {
    step(along > 0 ? -1 : 1);
  });
}
