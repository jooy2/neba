/// `NebaPopconfirm`, a question asked beside the control that raised it.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/popover/neba_popover.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A question asked where the answer will be acted on: a [NebaPopover] with
/// a question, the family's severity mark beside it, and a button to cancel
/// and one to confirm.
///
/// The small sibling of `NebaConfirmProvider`, and the difference is reach
/// rather than danger. A confirm takes the page away, which is right when the
/// consequence reaches past what is on screen; a popconfirm stays beside the
/// control that raised it, which is right when the consequence is that
/// control's own row, still in sight while the reader decides.
///
/// It closes once [onConfirm] completes, so an asynchronous one keeps the
/// bubble up, its confirming button busy, until the work is done. One that
/// fails leaves the bubble open with its button ready again, and the error is
/// not caught: it reaches the zone it was raised in, and the app's own error
/// reporting with it.
///
/// ```dart
/// NebaPopconfirm(
///   title: const Text('Remove this domain?'),
///   description: const Text('It stops resolving immediately.'),
///   onConfirm: () => remove(id),
///   trigger: NebaIconButton(onPressed: () {}, label: 'Remove', icon: trash),
/// )
/// ```
class NebaPopconfirm extends StatefulWidget {
  /// A question hanging off [trigger].
  const NebaPopconfirm({
    this.trigger,
    this.title,
    this.description,
    this.onConfirm,
    this.onCancel,
    this.confirmLabel,
    this.cancelLabel,
    this.color = NebaColor.danger,
    this.size,
    this.icon,
    this.showIcon = true,
    this.side = NebaSide.top,
    this.align = NebaAlign.center,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.locale,
    this.width = 280,
    super.key,
  }) : assert(width > 0);

  /// The control the question hangs off and that raises it: a Neba control,
  /// such as a [NebaIconButton], whose press opens and closes the bubble
  /// besides doing its own work. A button that is only a trigger takes
  /// `onPressed: () {}`, as a button with none is disabled.
  final Widget? trigger;

  /// The question, usually a [Text], in the medium weight. A [Text] is also
  /// the name a screen reader announces for the bubble.
  final Widget? title;

  /// What answering costs, usually a [Text]: the consequence, not a
  /// restatement of the title. Muted, under the title.
  final Widget? description;

  /// Called when the reader confirms. The bubble closes once what it returns
  /// completes; a future that completes with an error leaves it open.
  final FutureOr<void> Function()? onConfirm;

  /// Called when the reader presses the cancelling button. Escape and a
  /// press outside do not call it: walking away from a question is not
  /// answering it no.
  final VoidCallback? onCancel;

  /// The confirming button's label. Defaults to the [locale]'s "Confirm".
  final Widget? confirmLabel;

  /// The cancelling button's label. Defaults to the [locale]'s "Cancel".
  final Widget? cancelLabel;

  /// The colour family of the mark, the confirming button and the bubble's
  /// edge. [NebaColor.danger] by default, because that is what a popconfirm
  /// is usually for.
  final NebaColor color;

  /// The step the bubble and its two buttons sit on. Defaults to
  /// `NebaProvider`'s, then [NebaSize.sm].
  final NebaSize? size;

  /// A mark of your own in place of the family's severity mark, drawn at the
  /// size and in the colour the [IconTheme] around it hands down.
  final Widget? icon;

  /// Whether a mark is drawn beside the question at all. On by default, and
  /// not decoration: a question that says "this is destructive" only in red
  /// says it only to some readers, so the shape carries the meaning too.
  final bool showIcon;

  /// Which edge of the trigger the bubble appears on. Above it by default: a
  /// question about a row reads better there than laid over the rows below.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// Whether the bubble is open. With [onOpenChange] the caller owns the
  /// state; without it the popconfirm keeps its own.
  final bool? open;

  /// Whether a popconfirm that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the bubble opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The language the two default labels are in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The widest the bubble gets, in logical pixels.
  final double width;

  @override
  State<NebaPopconfirm> createState() => _NebaPopconfirmState();
}

class _NebaPopconfirmState extends State<NebaPopconfirm> {
  late bool _ownOpen = widget.defaultOpen;
  bool _running = false;

  bool get _open => widget.open ?? _ownOpen;

  void _setOpen(bool open) {
    if (widget.open == null) {
      setState(() => _ownOpen = open);
    }

    widget.onOpenChange?.call(open);
  }

  Future<void> _confirm() async {
    setState(() => _running = true);

    try {
      await widget.onConfirm?.call();

      // A bubble already closed by Escape while the work ran is left closed.
      if (mounted && _open) {
        _setOpen(false);
      }
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.sm;
    final Map<String, String> messages = nebaMessages(context, 'confirm', locale: widget.locale);
    final double gap = NebaScale.gap[size]!;
    final double text = MediaQuery.textScalerOf(context).scale(NebaScale.sheetBodyText[size]!);
    final double line = MediaQuery.textScalerOf(context).scale(NebaScale.sheetBodyLeading[size]!);
    // The mark tracks the text beside it, as `1.2em` does, and sits in the
    // middle of the title's first line.
    final double glyph = text * 1.2;
    final Widget? title = widget.title;
    final Widget? description = widget.description;
    final Widget? mark = !widget.showIcon
        ? null
        : widget.icon ?? NebaGlyph(NebaGlyphs.severity(widget.color));
    final Color accent = tokens.roles(widget.color).accent;

    final Widget question = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: gap,
      children: <Widget>[
        if (mark != null)
          Padding(
            padding: EdgeInsets.only(top: (line - glyph) / 2),
            child: ExcludeSemantics(
              child: IconTheme.merge(
                data: IconThemeData(size: glyph, color: accent),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: accent),
                  child: SizedBox.square(
                    dimension: glyph,
                    child: Center(child: mark),
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: <Widget>[
              if (title != null)
                DefaultTextStyle.merge(
                  style: TextStyle(fontWeight: FontWeight.w500, color: tokens.fg),
                  child: title,
                ),
              if (description != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg),
                  child: description,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    NebaPopoverClose(
                      builder: (BuildContext context, VoidCallback close) {
                        return NebaButton(
                          onPressed: () {
                            widget.onCancel?.call();
                            close();
                          },
                          size: size,
                          variant: NebaVariant.text,
                          color: NebaColor.secondary,
                          child: widget.cancelLabel ?? Text(messages['cancel']!),
                        );
                      },
                    ),
                    NebaButton(
                      onPressed: () => unawaited(_confirm()),
                      size: size,
                      color: widget.color,
                      loading: _running,
                      child: widget.confirmLabel ?? Text(messages['confirm']!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return NebaPopover(
      trigger: widget.trigger,
      open: _open,
      onOpenChange: _setOpen,
      side: widget.side,
      align: widget.align,
      size: size,
      color: widget.color,
      width: widget.width,
      semanticLabel: title is Text ? title.data : null,
      child: question,
    );
  }
}
