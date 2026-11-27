/// The focus ring, the React package's `focus-visible:[outline:2px_solid_…]`.
///
/// Two pixels wide, two pixels off the control, following its corners, in the
/// family's `ring` colour, and only for keyboard focus. What changes is the
/// colour and never the width, as in the React package: the ring is always
/// there and goes from transparent to its colour over the house duration, so
/// it never snaps in and never changes the control's size. A field's shell
/// draws it flush, with no offset, because the hairline under it is already
/// the ring's colour.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// The ring's width.
const double focusRingWidth = 2;

/// How far the ring stands off a control, CSS `outline-offset: 2px`.
const double focusRingOffset = 2;

/// Whether a mouse, a pen or a finger has gone down since the last key, which
/// is what CSS `:focus-visible` reads to decide that a ring after a click is
/// noise.
///
/// Flutter's own highlight mode cannot answer it: a mouse leaves the focus
/// manager in its traditional mode, so a button clicked on a desktop or the
/// web kept a ring as if it had been reached with Tab. A key pressed after the
/// click brings the ring back, as a browser does.
abstract final class NebaInputModality {
  static final ValueNotifier<bool> _pointer = ValueNotifier<bool>(false);
  static bool _hearsKeys = false;
  static bool _hearsPointers = false;

  /// True once a pointer has gone down after the last key.
  static ValueListenable<bool> get pointer {
    if (!_hearsKeys) {
      _hearsKeys = true;
      HardwareKeyboard.instance.addHandler(_onKey);
    }

    if (!_hearsPointers) {
      _hearsPointers = true;
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    }

    return _pointer;
  }

  static bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pointer.value = false;
    }

    return false;
  }

  static void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _pointer.value = true;
    }
  }

  /// Forgets the last input, for a test that starts from nothing. The test
  /// binding drops every keyboard handler after each test, so the key
  /// listener is attached again on the next use.
  @visibleForTesting
  static void reset() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _hearsKeys = false;
    _pointer.value = false;
  }
}

/// [child] with a focus ring drawn around it while [visible].
class NebaFocusRing extends StatelessWidget {
  /// A ring in [color] around [child], whose corners are [borderRadius].
  const NebaFocusRing({
    required this.visible,
    required this.color,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.offset = focusRingOffset,
    this.keyboardOnly = true,
    super.key,
  });

  /// Whether the ring is shown.
  final bool visible;

  /// The ring's colour.
  final Color color;

  /// The control's corners. The ring's follow them, grown by the offset.
  final BorderRadius borderRadius;

  /// How far outside the control the ring stands. A negative offset draws it
  /// inside, as CSS `outline-offset: -2px` does, for a control whose
  /// neighbours an outer ring would be drawn over.
  final double offset;

  /// Whether the ring stays off after a pointer press, as `:focus-visible`
  /// keeps it off. A field's shell turns this off: its ring answers any focus,
  /// as `:focus-within` does, because a caret is the field being entered.
  final bool keyboardOnly;

  /// The control.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!keyboardOnly) {
      return _ring(context, visible);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: NebaInputModality.pointer,
      builder: (BuildContext context, bool pointer, Widget? _) =>
          _ring(context, visible && !pointer),
    );
  }

  Widget _ring(BuildContext context, bool shown) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: shown ? color : color.withValues(alpha: 0)),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? ring, Widget? child) {
        return CustomPaint(
          foregroundPainter: _RingPainter(ring ?? color, borderRadius, offset),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.borderRadius, this.offset);

  final Color color;
  final BorderRadius borderRadius;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) {
      return;
    }

    final RRect ring = borderRadius
        .toRRect(Offset.zero & size)
        .inflate(offset + focusRingWidth / 2);

    canvas.drawRRect(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focusRingWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.offset != offset;
  }
}
