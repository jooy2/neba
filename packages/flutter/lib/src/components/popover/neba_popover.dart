/// `NebaPopover`, a sheet that opens beside the control that opened it.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A sheet that opens beside the control that opened it.
///
/// Unlike a tooltip it stays up until it is dismissed and can be reached, so
/// what is inside can be pressed and typed into; unlike a dialog it leaves
/// the page behind working. A press on [trigger] opens it and a second press
/// closes it, as does Escape, a press outside it, and the focus leaving it.
/// The focus moves into it when it opens and comes back to the trigger when
/// it closes.
///
/// ```dart
/// NebaPopover(
///   trigger: NebaButton(onPressed: () {}, child: const Text('Share')),
///   title: const Text('Share this page'),
///   child: const Text('Anyone with the link can read it.'),
/// )
/// ```
class NebaPopover extends StatefulWidget {
  /// A popover showing [child] when [trigger] is pressed.
  const NebaPopover({
    this.trigger,
    this.title,
    this.description,
    this.child,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.side = NebaSide.bottom,
    this.align = NebaAlign.center,
    this.sideOffset = 6,
    this.alignOffset = 0,
    this.arrow = false,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = NebaModal.off,
    this.dismissible = true,
    this.showClose = false,
    this.locale,
    this.closeLabel,
    this.width,
    this.semanticLabel,
    super.key,
  });

  /// What the popup hangs off and what opens it: a Neba control, such as a
  /// [NebaButton], whose press opens and closes the popover besides doing
  /// its own work. A button that is only a trigger takes `onPressed: () {}`,
  /// as a button with none is disabled.
  ///
  /// Optional: a popover that is only ever opened through [open] needs none,
  /// and hangs off the point where it is written.
  final Widget? trigger;

  /// The heading, usually a [Text], which also names the popup for a screen
  /// reader.
  final Widget? title;

  /// A line under the heading, one step down the type scale and muted.
  final Widget? description;

  /// The body.
  final Widget? child;

  /// The type, the corners, the padding and the widest the popup gets.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the edge, the close button's wash and the focus ring.
  /// The sheet itself stays undyed.
  final NebaColor color;

  /// How much padding the popup has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which edge of the trigger it appears on. It flips to the opposite side
  /// when there is no room.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// The distance from the trigger, in logical pixels.
  final double sideOffset;

  /// A shift along that edge, in logical pixels.
  final double alignOffset;

  /// Draws the little wedge pointing at the trigger. Off by default: this
  /// sheet is translucent over a blurred backdrop, and a wedge sticking out
  /// of it cannot carry that backdrop with it.
  final bool arrow;

  /// Whether the popover is open. With [onOpenChange] the caller owns the
  /// state; without it the popover keeps its own.
  final bool? open;

  /// Whether a popover that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the popover opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// How much of the page behind is taken away. [NebaModal.off], the
  /// default, leaves it scrollable and pressable.
  final NebaModal modal;

  /// Whether Escape, a press outside and the focus leaving close the popup.
  /// Turn it off only for a popup with a way out of its own: the × or a
  /// [NebaPopoverClose] still closes it.
  final bool dismissible;

  /// Shows the × in the corner. A modal popover without one still gets a
  /// close button, hidden until it takes the keyboard focus.
  final bool showClose;

  /// The language the × is named in. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// What a screen reader hears for the ×. Defaults to the [locale]'s word
  /// for it.
  final String? closeLabel;

  /// The widest the popup gets, in logical pixels, in place of the one
  /// [size] gives.
  final double? width;

  /// The name a screen reader announces for the popup, in place of the words
  /// of a [title] that is a [Text]: React's `aria-label`, for a popup whose
  /// heading is in its body or is not a [Text].
  final String? semanticLabel;

  /// The widest a popup gets at each size, one rung narrower than a dialog.
  static const Map<NebaSize, double> maxWidths = <NebaSize, double>{
    NebaSize.xs: 224,
    NebaSize.sm: 256,
    NebaSize.md: 320,
    NebaSize.lg: 384,
    NebaSize.xl: 512,
  };

  @override
  State<NebaPopover> createState() => _NebaPopoverState();
}

class _NebaPopoverState extends State<NebaPopover> {
  late bool _open = widget.defaultOpen;

  bool get _isOpen => widget.open ?? _open;

  void _change(bool open, NebaFloatingReason reason) {
    // The ways out that are not deliberate are the ones `dismissible` takes
    // away; the × and a NebaPopoverClose still get through.
    if (!open &&
        !widget.dismissible &&
        (reason == NebaFloatingReason.escape ||
            reason == NebaFloatingReason.outsidePress ||
            reason == NebaFloatingReason.focusOut)) {
      return;
    }

    if (open == _isOpen) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
  }

  void _close() => _change(false, NebaFloatingReason.closePress);

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool open = _isOpen;
    final Widget? title = widget.title;
    final String? name = widget.semanticLabel ?? (title is Text ? title.data : null);
    final String closeLabel =
        widget.closeLabel ?? nebaMessages(context, 'action', locale: widget.locale)['close']!;

    // A label names the popup only with `namesRoute` beside it: on the web a
    // dialog's own label is its `aria-label` then, and is dropped without.
    final Widget popup = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.dialog,
      namesRoute: name == null ? null : true,
      label: name,
      child: FocusTraversalGroup(
        // The order the widgets are written in, as the DOM orders a tab
        // stop: the hidden × is last however high up it is drawn.
        policy: WidgetOrderTraversalPolicy(),
        child: _NebaPopoverScope(
          close: _close,
          child: NebaFloatingSheet(
            size: size,
            color: widget.color,
            density: density,
            maxWidth: widget.width ?? NebaPopover.maxWidths[size]!,
            title: title,
            description: widget.description,
            headerEnd: widget.showClose
                ? NebaSheetClose(onPressed: _close, label: closeLabel, color: widget.color)
                : null,
            corner: widget.modal != NebaModal.off && !widget.showClose
                ? NebaSheetClose(
                    onPressed: _close,
                    label: closeLabel,
                    color: widget.color,
                    hiddenUntilFocused: true,
                  )
                : null,
            child: widget.child,
          ),
        ),
      ),
    );

    return NebaFloating(
      open: open,
      onOpenChange: _change,
      side: widget.side,
      align: widget.align,
      sideOffset: widget.sideOffset,
      alignOffset: widget.alignOffset,
      arrow: widget.arrow
          ? NebaFloatingSheet.arrowOf(NebaTheme.of(context), widget.color, size)
          : null,
      openOnPress: true,
      moveFocus: true,
      modal: widget.modal,
      intentionalOutsidePress: widget.modal != NebaModal.trapFocus,
      popup: popup,
      // One node, so the trigger says it is expanded as `aria-expanded` does.
      child: MergeSemantics(
        child: Semantics(expanded: open, child: widget.trigger ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// The popover a [NebaPopoverClose] closes.
class _NebaPopoverScope extends InheritedWidget {
  const _NebaPopoverScope({required this.close, required super.child});

  final VoidCallback close;

  @override
  bool updateShouldNotify(_NebaPopoverScope oldWidget) => close != oldWidget.close;
}

/// Hands a control inside a [NebaPopover] the callback that closes it, which
/// gets through even when the popover is not `dismissible`.
///
/// For the Cancel and the Apply of a popover that keeps its own state, which
/// would otherwise have to be controlled only so a button could close it.
///
/// ```dart
/// NebaPopoverClose(
///   builder: (BuildContext context, VoidCallback close) =>
///       NebaButton(onPressed: close, child: const Text('Apply')),
/// )
/// ```
class NebaPopoverClose extends StatelessWidget {
  /// Builds a control with the popover's close callback.
  const NebaPopoverClose({required this.builder, super.key});

  /// Builds the control, given the callback that closes the popover. Call
  /// it from the control's own callback, after anything else it does.
  final Widget Function(BuildContext context, VoidCallback close) builder;

  @override
  Widget build(BuildContext context) {
    final _NebaPopoverScope? scope = context
        .dependOnInheritedWidgetOfExactType<_NebaPopoverScope>();

    assert(
      scope != null,
      'A NebaPopoverClose closes the NebaPopover it is inside, and is in none.',
    );

    return builder(context, scope?.close ?? () {});
  }
}
