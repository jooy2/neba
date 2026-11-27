/// `NebaDialog`, a sheet that takes the page until it is answered.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/sheet_sections.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Builds what opens a [NebaDialog], handed the callback that opens it.
typedef NebaDialogTriggerBuilder = Widget Function(BuildContext context, VoidCallback open);

/// Builds a control that closes the [NebaDialog] it is inside, handed the
/// callback that closes it.
typedef NebaDialogCloseBuilder = Widget Function(BuildContext context, VoidCallback close);

/// A sheet that takes the page until it is answered.
///
/// It opens in the middle of the window over a scrim in the app's root
/// [Overlay], arriving and leaving in opacity only. While it is open the page
/// behind takes no press, the focus is held inside it and goes back to what
/// had it when it closes, and Escape and a press on the scrim close it unless
/// it is not [dismissible].
///
/// The sections are arguments rather than children: a [title], a
/// [description] under it and the × beside them, the body ([child]), which is
/// the only part that scrolls, and the [actions] at the foot, which stay put
/// while it does. The sheet is as wide as its [size] allows, or [width], and
/// never taller than the window.
///
/// It needs an [Overlay] above it, which a `WidgetsApp` with a navigator has
/// and `Overlay.wrap` gives anything else.
///
/// ```dart
/// NebaDialog(
///   title: const Text('Delete this workspace?'),
///   triggerBuilder: (BuildContext context, VoidCallback open) =>
///       NebaButton(onPressed: open, child: const Text('Delete workspace')),
///   actions: <Widget>[
///     NebaDialogClose(
///       builder: (BuildContext context, VoidCallback close) =>
///           NebaButton(onPressed: close, child: const Text('Delete')),
///     ),
///   ],
///   child: const Text('This cannot be undone.'),
/// )
/// ```
class NebaDialog extends StatefulWidget {
  /// A dialog holding [child] as its body.
  const NebaDialog({
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.triggerBuilder,
    this.title,
    this.description,
    this.actions,
    this.dividers = false,
    this.showClose = true,
    this.locale,
    this.closeLabel,
    this.width,
    this.fullWidth = true,
    this.fullScreen = false,
    this.modal = NebaModal.on,
    this.dismissible = true,
    this.initialFocus,
    this.finalFocus,
    this.role = SemanticsRole.dialog,
    this.semanticLabel,
    this.child,
    super.key,
  }) : assert(width == null || width > 0),
       assert(role == SemanticsRole.dialog || role == SemanticsRole.alertDialog);

  /// The type of every section, the padding, the corners and the widest the
  /// sheet gets. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline round the sheet, the dividers and the focus
  /// rings. The sheet itself stays undyed.
  final NebaColor color;

  /// How much padding each section has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Whether the dialog is shown, for a controlled dialog that hears about
  /// every change through [onOpenChange].
  final bool? open;

  /// Whether an uncontrolled dialog starts open.
  final bool defaultOpen;

  /// Called with the new state when the dialog opens or closes: from the
  /// trigger, the ×, a [NebaDialogClose], Escape or the scrim.
  final ValueChanged<bool>? onOpenChange;

  /// Builds what opens the dialog, which stays where the dialog was written.
  /// Optional: a controlled dialog opened from somewhere else needs none.
  final NebaDialogTriggerBuilder? triggerBuilder;

  /// The heading, usually a [Text], one step above the body in semibold. It is
  /// a heading at level 2 and the name a screen reader announces for the
  /// dialog.
  final Widget? title;

  /// A line under the title, in the muted ink one step down the type scale.
  final Widget? description;

  /// The bottom row, end-aligned and wrapping when it runs out of room. A
  /// [NebaDialogClose] makes one of them close the dialog.
  final List<Widget>? actions;

  /// Draws a hairline between the header, the body and the actions instead of
  /// separating them with space, which is what says the header stayed put
  /// while the body scrolls.
  final bool dividers;

  /// Shows the × beside the title. On by default: a modal takes the page
  /// away until it is answered, and the way out should be in sight.
  final bool showClose;

  /// The language the × is named in. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// What a screen reader hears for the ×. Defaults to the [locale]'s
  /// "Close".
  final String? closeLabel;

  /// The widest the sheet gets, in logical pixels, in place of the one [size]
  /// gives.
  final double? width;

  /// Whether the sheet takes the whole width it is allowed, rather than the
  /// width of what is on it. On by default: a dialog's container is the
  /// window, and a dialog that shrank to fit two words would be a tooltip.
  final bool fullWidth;

  /// Fills the window edge to edge, with square corners, and keeps what is
  /// on it clear of the system's insets.
  final bool fullScreen;

  /// How much of the page it takes away. [NebaModal.trapFocus] leaves the
  /// page pressable while the focus is held inside, and a press on it closes
  /// the dialog; [NebaModal.off] lets Tab leave as well.
  final NebaModal modal;

  /// Whether Escape, a press outside the sheet and a screen reader's dismiss
  /// gesture close it. A dialog that is not needs [actions] that answer it,
  /// because there is no other way out.
  final bool dismissible;

  /// What takes the focus when the dialog opens. By default the first thing
  /// in it that takes the focus, which is the × when it is shown.
  final FocusNode? initialFocus;

  /// Where the focus goes when the dialog closes. By default what held it
  /// before the dialog opened.
  final FocusNode? finalFocus;

  /// [SemanticsRole.dialog], or [SemanticsRole.alertDialog] for a question
  /// that has to be answered before anything else happens, which a screen
  /// reader announces with more urgency.
  final SemanticsRole role;

  /// The name a screen reader announces for a dialog with no [title]:
  /// React's `aria-label`.
  final String? semanticLabel;

  /// The body: the only part that scrolls.
  final Widget? child;

  /// The widest the sheet gets at each size, the React package's
  /// `maxWidthClasses`: wider apart than the control ladder, because they
  /// answer how long a line of text is comfortable inside it.
  static const Map<NebaSize, double> maxWidths = <NebaSize, double>{
    NebaSize.xs: 320,
    NebaSize.sm: 384,
    NebaSize.md: 512,
    NebaSize.lg: 672,
    NebaSize.xl: 896,
  };

  /// The room kept between a sheet that is not [fullScreen] and the edges of
  /// the window, besides the system's insets.
  static const double margin = 16;

  @override
  State<NebaDialog> createState() => _NebaDialogState();
}

class _NebaDialogState extends State<NebaDialog> {
  late bool _ownOpen = widget.defaultOpen;

  bool get _open => widget.open ?? _ownOpen;

  void _setOpen(bool next) {
    // A second press on the × while the sheet is on its way out says nothing
    // new.
    if (next == _open) {
      return;
    }

    if (widget.open == null) {
      setState(() => _ownOpen = next);
    }

    widget.onOpenChange?.call(next);
  }

  void _show() => _setOpen(true);

  void _close() => _setOpen(false);

  @override
  Widget build(BuildContext context) {
    final NebaDialogTriggerBuilder? trigger = widget.triggerBuilder;

    return _NebaDialogScope(
      close: _close,
      child: NebaModalLayer(
        open: _open,
        onDismiss: _close,
        modal: widget.modal,
        dismissible: widget.dismissible,
        label: widget.semanticLabel,
        role: widget.role,
        initialFocus: widget.initialFocus,
        finalFocus: widget.finalFocus,
        builder: _arriving,
        child: trigger == null
            ? null
            : Builder(builder: (BuildContext context) => trigger(context, _show)),
      ),
    );
  }

  /// The sheet, arriving in opacity alone.
  Widget _arriving(BuildContext context, Animation<double> arrival) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final MediaQueryData media = nebaModalMedia(context);
    // The status bar, a notch, the home indicator and the keyboard.
    final EdgeInsets screen = media.padding + media.viewInsets;
    final bool fullScreen = widget.fullScreen;

    final Widget sections = NebaSheetSections(
      size: size,
      density: density,
      color: widget.color,
      title: widget.title,
      namesRoute: true,
      description: widget.description,
      close: widget.showClose
          ? NebaSheetClose(
              onPressed: _close,
              label:
                  widget.closeLabel ??
                  nebaMessages(context, 'action', locale: widget.locale)['close']!,
              em: MediaQuery.textScalerOf(context).scale(NebaScale.sheetBodyText[size]!),
              color: widget.color,
            )
          : null,
      actions: widget.actions ?? const <Widget>[],
      dividers: widget.dividers,
      fill: fullScreen,
      insets: fullScreen ? screen : EdgeInsets.zero,
      child: widget.child,
    );

    Widget sheet = NebaSheet(
      fill: tokens.panelPress,
      edge: tokens.roles(widget.color).line,
      plate: NebaPlate.glass,
      elevation: 3,
      borderRadius: fullScreen ? BorderRadius.zero : BorderRadius.circular(tokens.radius[size]!),
      child: sections,
    );

    if (fullScreen) {
      sheet = SizedBox.expand(child: sheet);
    } else {
      if (!widget.fullWidth) {
        sheet = IntrinsicWidth(child: sheet);
      }

      // Centred in what is left of the window, and never taller than it: the
      // body scrolls instead, so the header and the actions stay in sight.
      sheet = Padding(
        padding: const EdgeInsets.all(NebaDialog.margin) + screen,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.width ?? NebaDialog.maxWidths[size]!),
            child: sheet,
          ),
        ),
      );
    }

    return FadeTransition(opacity: arrival, child: sheet);
  }
}

/// What a [NebaDialogClose] closes.
class _NebaDialogScope extends InheritedWidget {
  const _NebaDialogScope({required this.close, required super.child});

  final VoidCallback close;

  @override
  bool updateShouldNotify(_NebaDialogScope oldWidget) => close != oldWidget.close;
}

/// A control that closes the [NebaDialog] it is inside: the React package's
/// `DialogClose`.
///
/// [builder] is handed the callback that closes it, so a Cancel button in an
/// uncontrolled dialog's [NebaDialog.actions] needs no state of its own:
///
/// ```dart
/// NebaDialogClose(
///   builder: (BuildContext context, VoidCallback close) =>
///       NebaButton(onPressed: close, child: const Text('Cancel')),
/// )
/// ```
///
/// The callback closes the dialog whether or not it is `dismissible`, since a
/// button is an answer rather than a way round one. Outside a dialog it does
/// nothing.
class NebaDialogClose extends StatelessWidget {
  /// A control built by [builder].
  const NebaDialogClose({required this.builder, super.key});

  /// Builds the control.
  final NebaDialogCloseBuilder builder;

  @override
  Widget build(BuildContext context) {
    final _NebaDialogScope? scope = context.dependOnInheritedWidgetOfExactType<_NebaDialogScope>();

    return builder(context, scope?.close ?? _nothing);
  }

  static void _nothing() {}
}
