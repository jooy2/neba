/// What every control the pointer and the keyboard can act on has to know
/// about them: whether it is hovered, pressed or focused from the keyboard,
/// and where the pointer is on it.
///
/// One widget answers all four, so a button, a chip and a menu row agree on
/// what "pressed" means. The pointer's position is a [ValueListenable] rather
/// than state, because it changes on every frame the pointer moves and only
/// the light that follows it needs to know: the React package writes it to
/// two custom properties for the same reason, so that nothing re-renders.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The state a control is drawn in.
@immutable
class NebaInteraction {
  /// A control's state.
  const NebaInteraction({
    this.enabled = true,
    this.hovered = false,
    this.pressed = false,
    this.focusVisible = false,
  });

  /// Whether the control takes input at all.
  final bool enabled;

  /// Whether a mouse or a stylus is over it. A finger never hovers.
  final bool hovered;

  /// Whether a pointer is holding it down.
  final bool pressed;

  /// Whether it has the focus and the focus came from the keyboard, as
  /// `:focus-visible` says: a ring after a click is noise.
  final bool focusVisible;

  @override
  bool operator ==(Object other) {
    return other is NebaInteraction &&
        other.enabled == enabled &&
        other.hovered == hovered &&
        other.pressed == pressed &&
        other.focusVisible == focusVisible;
  }

  @override
  int get hashCode => Object.hash(enabled, hovered, pressed, focusVisible);
}

/// Builds a control from its [NebaInteraction] and the pointer's position on
/// it, which is `null` while no pointer is over it.
typedef NebaInteractiveBuilder =
    Widget Function(
      BuildContext context,
      NebaInteraction interaction,
      ValueListenable<Offset?> pointer,
    );

/// A control the pointer and the keyboard can act on.
///
/// The press lands on the pointer going down, not on the tap being
/// recognised, because press is instant: the fill changes on the frame of the
/// click. [onTap] is a tap as Flutter recognises one, so a press dragged off
/// the control and released does nothing. Enter and Space activate it from the
/// keyboard.
class NebaInteractive extends StatefulWidget {
  /// A control drawn by [builder].
  const NebaInteractive({
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.cursor,
    super.key,
  });

  /// Draws the control.
  final NebaInteractiveBuilder builder;

  /// Called on a tap, and on Enter or Space.
  final VoidCallback? onTap;

  /// Whether the control takes input. A disabled one is not focusable.
  final bool enabled;

  /// The control's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the control takes the focus when it is first built.
  final bool autofocus;

  /// The pointer's cursor over the control. A click cursor when it is enabled.
  final MouseCursor? cursor;

  @override
  State<NebaInteractive> createState() => _NebaInteractiveState();
}

class _NebaInteractiveState extends State<NebaInteractive> {
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  bool _hovered = false;
  bool _pointerDown = false;
  bool _focusVisible = false;

  static final Map<ShortcutActivator, Intent> _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
  };

  @override
  void didUpdateWidget(NebaInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled && (_pointerDown || _hovered)) {
      _pointerDown = false;
      _hovered = false;
      _pointer.value = null;
    }
  }

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  void _setPointerDown(bool down, [Offset? position]) {
    if (position != null) {
      _pointer.value = position;
    }

    if (_pointerDown != down) {
      setState(() => _pointerDown = down);
    }
  }

  void _setHovered(bool hovered, [Offset? position]) {
    if (hovered) {
      _pointer.value = position;
    } else if (!_pointerDown) {
      _pointer.value = null;
    }

    if (_hovered != hovered) {
      setState(() => _hovered = hovered);
    }
  }

  void _activate() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final NebaInteraction interaction = NebaInteraction(
      enabled: enabled,
      hovered: enabled && _hovered,
      pressed: enabled && _pointerDown,
      focusVisible: enabled && _focusVisible,
    );

    return FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      shortcuts: _shortcuts,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _activate();
            return null;
          },
        ),
      },
      mouseCursor: widget.cursor ?? (enabled ? SystemMouseCursors.click : MouseCursor.defer),
      onShowFocusHighlight: (bool visible) => setState(() => _focusVisible = visible),
      child: Listener(
        onPointerDown: enabled
            ? (PointerDownEvent e) => _setPointerDown(true, e.localPosition)
            : null,
        onPointerMove: enabled ? (PointerMoveEvent e) => _pointer.value = e.localPosition : null,
        onPointerUp: enabled ? (PointerUpEvent e) => _setPointerDown(false) : null,
        onPointerCancel: enabled ? (PointerCancelEvent e) => _setPointerDown(false) : null,
        // Hover is tracked here rather than through the detector's hover
        // highlight, which only reports while the focus manager is in its
        // keyboard mode: a mouse over a control is hovering it either way.
        child: MouseRegion(
          onEnter: enabled ? (PointerEnterEvent e) => _setHovered(true, e.localPosition) : null,
          onHover: enabled ? (PointerHoverEvent e) => _pointer.value = e.localPosition : null,
          onExit: enabled ? (PointerExitEvent e) => _setHovered(false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled && widget.onTap != null ? _activate : null,
            child: widget.builder(context, interaction, _pointer),
          ),
        ),
      ),
    );
  }
}
