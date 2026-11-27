/// `NebaReasoning`, a thinking panel that the stream opens and closes.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A thinking panel that the stream opens and closes.
///
/// On a `NebaSpoiler` and a `NebaCollapsible` the reader owns the open state.
/// Here the stream does: the panel opens as the thinking starts arriving,
/// stays open while the reader can follow it, and folds itself away into one
/// line when it stops, "Thought for 4.2s", which is what a reader wants from
/// reasoning they did not need to read. A reader who folds it away
/// mid-stream is not overruled by the next token, because the panel follows
/// the moments [streaming] changes rather than its value.
///
/// The panel is deliberately not a live region: thinking is long and revised
/// as it arrives, and a screen reader reading every revision aloud would bury
/// the answer it is on the way to.
///
/// ```dart
/// NebaReasoning(
///   streaming: streaming,
///   child: Text(thought),
/// )
/// ```
class NebaReasoning extends StatefulWidget {
  /// A panel holding [child], the thinking.
  const NebaReasoning({
    this.streaming = false,
    this.duration,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.autoOpen = true,
    this.autoClose = true,
    this.keepMounted = true,
    this.label,
    this.icon,
    this.showIcon = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.locale,
    this.labels,
    this.child,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Whether the thinking is still arriving: what the header says, what the
  /// mark does and, unless [autoOpen] is off, whether the panel is open.
  final bool streaming;

  /// How long the thinking took. Left out, the panel times its own stream
  /// from the moment [streaming] turned on and measures it once more when it
  /// stops; a panel that never streamed has no figure and says so in words.
  final Duration? duration;

  /// Whether the panel is showing, for a controlled Reasoning. Leave it
  /// `null` and the panel keeps its own state, starting from [defaultOpen].
  final bool? open;

  /// Where an uncontrolled Reasoning starts, before any stream has run.
  final bool defaultOpen;

  /// Called when the header opens or closes the panel. The stream opening and
  /// closing it under [autoOpen] does not call it.
  final ValueChanged<bool>? onOpenChange;

  /// Opens the panel when the stream starts and closes it when it ends. Off,
  /// the panel stays where the reader put it.
  final bool autoOpen;

  /// Whether [autoOpen] also closes the panel when the stream ends. Off, the
  /// thinking stays open once it has arrived, so the answer already being
  /// read under it does not move up the page.
  final bool autoClose;

  /// Whether a closed panel keeps the thinking built.
  final bool keepMounted;

  /// Replaces what the header says, which is otherwise the [locale]'s
  /// sentence for where the stream is.
  final Widget? label;

  /// The mark at the start, in place of the turning ring the stream draws
  /// while it runs.
  final Widget? icon;

  /// Whether a mark is drawn at all; `false` drops it, React's `icon={false}`.
  final bool showIcon;

  /// The sheet's weight: `text`, the default, since thinking is an aside and a
  /// bordered box around every aside is a conversation made of boxes; or
  /// `outline` and `solid`, for a panel that is the only thing on the screen.
  final NebaVariant? variant;

  /// The padding, the corners and the type. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hover wash, the ring and the rule down the panel.
  /// Defaults to [NebaColor.secondary].
  final NebaColor? color;

  /// How much padding the header and the panel have at their [size].
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// The language the header's own sentences are written in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those sentences, written out over the [locale]'s, by the React package's
  /// keys: `thinking`, `thought` with a `{duration}` in it, and `done`.
  final Map<String, String>? labels;

  /// The thinking.
  final Widget? child;

  @override
  State<NebaReasoning> createState() => _NebaReasoningState();
}

class _NebaReasoningState extends State<NebaReasoning> with NebaFoldState<NebaReasoning> {
  final NebaRunWatch _watch = NebaRunWatch();

  @override
  bool? get controlledOpen => widget.open;

  @override
  ValueChanged<bool>? get onFoldChange => widget.onOpenChange;

  @override
  void initState() {
    super.initState();
    // A Reasoning built mid-stream is already thinking, so it starts open:
    // there is no change coming to open it.
    foldOpen = widget.defaultOpen || (widget.autoOpen && widget.streaming);
    _watch.update(running: widget.streaming, duration: widget.duration);
  }

  @override
  void didUpdateWidget(NebaReasoning oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool streaming = widget.streaming;

    // The moments the stream starts and stops, rather than whether it is
    // running, so a reader who folded the panel mid-stream keeps it folded.
    // The stop is the one `autoClose` can take away.
    if (oldWidget.streaming != streaming &&
        widget.autoOpen &&
        widget.open == null &&
        (streaming || widget.autoClose)) {
      foldOpen = streaming;
    }

    _watch.update(running: streaming, duration: widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.secondary;
    final NebaColorRoles roles = tokens.roles(color);
    final Map<String, String> messages = nebaMessages(
      context,
      'reasoning',
      locale: widget.locale ?? defaults.locale,
    );
    final Map<String, String>? labels = widget.labels;
    final double padding = NebaBox.padding[density]![size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double em = titleSize;
    final bool open = isOpen;

    // The total only: while the stream runs the header says "Thinking", so a
    // count here would rebuild the panel every second for a number that is
    // not on the screen.
    final Duration? total = _watch.total(widget.duration);
    String word(String key) => labels?[key] ?? messages[key]!;
    final String sentence;

    if (widget.streaming) {
      sentence = word('thinking');
    } else if (total == null) {
      sentence = word('done');
    } else {
      sentence = fillNebaMessage(word('thought'), <String, String>{
        'duration': nebaFormatDuration(total),
      });
    }

    final Widget heading = widget.label ?? Text(sentence);
    final Widget? mark = !widget.showIcon
        ? null
        : widget.icon ?? (widget.streaming ? NebaSpinner(size: em * 1.2) : null);

    final Widget header = DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.mutedFg,
        fontSize: titleSize,
        height: NebaScale.sheetTitleLeading[size]! / titleSize,
      ),
      child: NebaFoldTrigger(
        open: open,
        onToggle: toggleFold,
        roles: roles,
        padding: EdgeInsets.all(padding),
        hoverInk: roles.onTint,
        child: Row(
          spacing: NebaScale.gap[size]!,
          children: <Widget>[
            if (mark != null)
              IconTheme.merge(
                data: IconThemeData(size: em * 1.2),
                child: mark,
              ),
            Expanded(
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                child: heading,
              ),
            ),
            NebaDisclosureChevron(open: open, size: em * 1.2),
          ],
        ),
      ),
    );

    final double bodySize = NebaScale.sheetBodyText[size]!;

    return NebaDisclosureSheet(
      variant: variant,
      color: color,
      size: size,
      elevation: widget.elevation ?? 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          NebaDisclosurePanel(
            open: open,
            keepMounted: widget.keepMounted,
            // The rule down the inside edge rather than a second sheet: what
            // is in here is prose, and a box around prose inside a box around
            // a message is two frames to look past to read one paragraph.
            child: Container(
              decoration: BoxDecoration(
                border: BorderDirectional(start: BorderSide(color: roles.line, width: 2)),
              ),
              padding: EdgeInsetsDirectional.fromSTEB(
                padding,
                0,
                padding,
                NebaDisclosureBody.bottom(density),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.mutedFg,
                  fontSize: bodySize,
                  height: NebaScale.sheetBodyLeading[size]! / bodySize,
                ),
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
