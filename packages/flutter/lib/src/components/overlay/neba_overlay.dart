/// `NebaOverlay`, a sheet over the whole page that stops it being used.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How much of the page a [NebaOverlay] takes away.
///
/// The four are one axis, how legible what is behind stays, and they are
/// tuned with the blur as much as with the colour.
enum NebaOverlayTone {
  /// The neutral dim a dialog puts behind itself, the same to the pixel, so a
  /// dialog opened over an overlay shows no seam. The page stays readable; it
  /// has only stopped being reachable.
  scrim,

  /// Frosted: a lighter dim over a 14-pixel blur, so the page is there as
  /// shape and colour but not as words. For "this is being replaced".
  blur,

  /// The page's own surface, opaque. For a screen that is gone.
  solid,

  /// Nothing drawn at all. It still takes the pointer, which is the whole
  /// reason to reach for it.
  clear,
}

/// A sheet over the whole page that stops it being used, with whatever is
/// put on it on top: most often a spinner and a line saying what is being
/// waited for.
///
/// What a [NebaDialog] has and this has not is the point: no surface, no
/// border, no title and no actions. It covers the window in the app's root
/// [Overlay] while [open], arriving and leaving in opacity, holds the focus
/// and gives it back, and is not [dismissible] by default, because an
/// overlay is not asking anything: it is saying wait.
///
/// ```dart
/// NebaOverlay(
///   open: saving,
///   tone: NebaOverlayTone.blur,
///   label: 'Saving',
///   child: const NebaProgressCircular(size: NebaSize.lg),
/// )
/// ```
class NebaOverlay extends StatefulWidget {
  /// An overlay with [child] on it.
  const NebaOverlay({
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.tone = NebaOverlayTone.scrim,
    this.dismissible = false,
    this.modal = NebaModal.on,
    this.align = NebaAlign.center,
    this.size,
    this.locale,
    this.label,
    this.child,
    super.key,
  });

  /// Whether the overlay is shown, for a controlled overlay that hears about
  /// every change through [onOpenChange].
  final bool? open;

  /// Whether an uncontrolled overlay starts shown.
  final bool defaultOpen;

  /// Called with the new state when the overlay is dismissed.
  final ValueChanged<bool>? onOpenChange;

  /// How much of the page is taken away.
  final NebaOverlayTone tone;

  /// Whether Escape, a press outside what is on it and a screen reader's
  /// dismiss gesture close it. Off by default, the other way round from a
  /// dialog: a save that a stray press can dismiss is a save the reader will
  /// believe finished. Turn it on for an overlay whose job is to catch a
  /// press outside something.
  final bool dismissible;

  /// How much of the page it takes away. [NebaModal.trapFocus] leaves the
  /// page pressable while the focus is held inside, so the
  /// [NebaOverlayTone.clear] tone, whose job is to take the pointer, takes
  /// nothing with it; [NebaModal.off] lets Tab leave as well.
  final NebaModal modal;

  /// Where what is on it sits down the window: at the top, in the middle or
  /// at the foot.
  final NebaAlign align;

  /// The room between what is on it and the edges of the window: 12, 16, 24,
  /// 32 or 40 logical pixels. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The language the overlay is named in. Defaults to `NebaProvider`'s,
  /// then the app's.
  final Locale? locale;

  /// The name a screen reader announces for the overlay. An overlay that
  /// holds nothing readable, a bare spinner or a `clear` sheet, still has to
  /// say what it is, so this defaults to the [locale]'s "Loading".
  final String? label;

  /// What sits on top of the scrim: a spinner, a line of text, a small card.
  final Widget? child;

  /// The room between what is on it and the edges of the window at each
  /// size.
  static const Map<NebaSize, double> insets = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 16,
    NebaSize.md: 24,
    NebaSize.lg: 32,
    NebaSize.xl: 40,
  };

  @override
  State<NebaOverlay> createState() => _NebaOverlayState();
}

class _NebaOverlayState extends State<NebaOverlay> {
  late bool _ownOpen = widget.defaultOpen;

  bool get _open => widget.open ?? _ownOpen;

  void _close() {
    if (!_open) {
      return;
    }

    if (widget.open == null) {
      setState(() => _ownOpen = false);
    }

    widget.onOpenChange?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return NebaModalLayer(
      open: _open,
      onDismiss: _close,
      modal: widget.modal,
      dismissible: widget.dismissible,
      label: widget.label ?? nebaMessages(context, 'overlay', locale: widget.locale)['label'],
      scrim: _scrimOf(widget.tone, NebaTheme.of(context)),
      builder: _arriving,
    );
  }

  /// What is on the overlay, arriving in opacity alone.
  Widget _arriving(BuildContext context, Animation<double> arrival) {
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final MediaQueryData media = nebaModalMedia(context);
    final Alignment alignment = switch (widget.align) {
      NebaAlign.start => Alignment.topCenter,
      NebaAlign.center => Alignment.center,
      NebaAlign.end => Alignment.bottomCenter,
    };

    return FadeTransition(
      opacity: arrival,
      child: Padding(
        // Clear of the status bar, a notch, the home indicator and the
        // keyboard, besides the room the size gives.
        padding: EdgeInsets.all(NebaOverlay.insets[size]!) + media.padding + media.viewInsets,
        child: Align(alignment: alignment, child: widget.child),
      ),
    );
  }
}

/// The page dimmed with [tone] in [tokens]: the [NebaOverlayTone.scrim]
/// matches a dialog's, and [NebaOverlayTone.clear] draws nothing.
NebaScrim _scrimOf(NebaOverlayTone tone, NebaTokens tokens) {
  return switch (tone) {
    NebaOverlayTone.scrim => NebaScrim.of(tokens),
    NebaOverlayTone.blur => NebaScrim(
      color: mixOklab(tokens.scrim, 0.55, transparent),
      blurSigma: 14,
      saturation: 1.4,
    ),
    NebaOverlayTone.solid => NebaScrim(color: tokens.surface),
    NebaOverlayTone.clear => const NebaScrim(),
  };
}
