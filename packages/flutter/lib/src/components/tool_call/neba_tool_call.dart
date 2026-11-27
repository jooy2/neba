/// `NebaToolCall`, one tool invocation in an agent transcript.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One tool invocation: what was called, what with, what came back, and how
/// long it took.
///
/// The header is always there, and the rest folds away behind it into a
/// panel that opens to its height, as a `NebaCollapsible`'s does. What makes
/// it more than a Collapsible is that a call that is still happening opens
/// and closes it: a call that fails opens itself, because a reader should not
/// have to go looking for the reason something did not work, and its result
/// is not there when the row is first drawn.
///
/// [status] decides the mark, the colour family and which block the panel
/// shows. The status is a shape and a colour on the screen and words for a
/// screen reader.
///
/// ```dart
/// const NebaToolCall(
///   name: Text('search_docs'),
///   status: NebaRunStatus.success,
///   duration: Duration(milliseconds: 412),
///   args: Text('{ "query": "acrylic surface" }'),
///   result: Text('{ "hits": 4 }'),
/// )
/// ```
class NebaToolCall extends StatefulWidget {
  /// A call to the tool [name].
  const NebaToolCall({
    required this.name,
    this.status = NebaRunStatus.pending,
    this.args,
    this.result,
    this.error,
    this.duration,
    this.meta,
    this.icon,
    this.showIcon = true,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.keepMounted = true,
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

  /// What was called, usually a [Text]. Set in the monospaced face, because a
  /// tool name is an identifier rather than a phrase.
  final Widget name;

  /// How far the call has got: the mark, the colour family and what the
  /// panel shows, an [error] where a success shows [result].
  final NebaRunStatus status;

  /// What the tool was called with. A plain [Text] is drawn as preformatted
  /// text in the monospaced face, with its own line breaks kept and a scroll
  /// rather than a wrap; any other widget is drawn as it is.
  final Widget? args;

  /// What it answered, under the same rule.
  final Widget? result;

  /// What went wrong, shown in place of [result] while [status] is
  /// [NebaRunStatus.error], under the word a failure is read as. Without it a
  /// failed call shows its [result], which is often the error the tool itself
  /// returned.
  final Widget? error;

  /// How long the call took. Left out, a running call counts its own time
  /// from the moment it started running, says nothing for the first second,
  /// and stops counting the moment a duration arrives.
  final Duration? duration;

  /// Anything else on the header line, after the name and before the time: a
  /// server name, a file, a retry count.
  final Widget? meta;

  /// The mark at the start, in place of the one that goes with [status].
  final Widget? icon;

  /// Whether a mark is drawn at all; `false` drops it, React's `icon={false}`.
  final bool showIcon;

  /// Whether the panel is showing, for a controlled tool call. Leave it
  /// `null` and the tool call keeps its own state, starting from
  /// [defaultOpen]; a controlled one does not open itself when it fails.
  final bool? open;

  /// Where an uncontrolled tool call starts. A call that fails opens itself
  /// whatever this says.
  final bool defaultOpen;

  /// Called with the new state when the header opens or closes the panel.
  final ValueChanged<bool>? onOpenChange;

  /// Whether a closed panel keeps what it holds built. Off for a transcript
  /// of many calls with long results, where a closed panel is only worth
  /// building once it is opened.
  final bool keepMounted;

  /// The sheet's weight: `outline`, `solid`, or `text` for none at all, which
  /// is what a long column of calls wants. The sheet itself is never dyed.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The padding, the corners and the type. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family a running call is drawn in. A pending call is always
  /// secondary, a finished one success and a failed one danger. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// How much padding the header and the panel have at their [size].
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`: a tool call belongs to
  /// the transcript it sits in rather than floating over it.
  final NebaElevation? elevation;

  /// The language the status and the two headings are said in. Defaults to
  /// `NebaProvider`'s, then the app's; a language that was never registered
  /// falls back to English.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `pending`, `running`, `success`, `error`, `arguments` and `result`.
  final Map<String, String>? labels;

  /// Anything to put under the result: a follow-up action, a note.
  final Widget? child;

  /// The tallest a block of preformatted text gets before it scrolls.
  static const double blockMaxHeight = 256;

  @override
  State<NebaToolCall> createState() => _NebaToolCallState();
}

class _NebaToolCallState extends State<NebaToolCall> with NebaFoldState<NebaToolCall> {
  final NebaRunWatch _watch = NebaRunWatch();

  @override
  bool? get controlledOpen => widget.open;

  @override
  ValueChanged<bool>? get onFoldChange => widget.onOpenChange;

  @override
  void initState() {
    super.initState();
    foldOpen = widget.defaultOpen;
    _watch.update(running: widget.status == NebaRunStatus.running, duration: widget.duration);
  }

  @override
  void didUpdateWidget(NebaToolCall oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A call that has just failed opens itself. On the change into the error
    // rather than while it lasts, so a reader who closes it again keeps it
    // closed, and an error already there when the row appeared stays where
    // the caller put it.
    if (oldWidget.status != widget.status &&
        widget.status == NebaRunStatus.error &&
        widget.open == null) {
      foldOpen = true;
    }

    _watch.update(running: widget.status == NebaRunStatus.running, duration: widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor family = nebaRunColor(widget.status, widget.color ?? NebaColor.primary);
    final NebaColorRoles roles = tokens.roles(family);
    final Locale? locale = widget.locale ?? defaults.locale;
    final Map<String, String> run = nebaMessages(context, 'run', locale: locale);
    final Map<String, String> tool = nebaMessages(context, 'tool', locale: locale);
    final Map<String, String>? labels = widget.labels;
    final double padding = NebaBox.padding[density]![size]!;
    final double metaSize = NebaScale.metaText[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final NebaRunStatus status = widget.status;

    // An error is not a result, and a heading that called it one said the
    // call had come back with something.
    final bool failed = status == NebaRunStatus.error && widget.error != null;
    final Widget? body = failed ? widget.error : widget.result;
    final bool hasBody = widget.args != null || body != null || widget.child != null;
    final bool open = isOpen;

    final TextStyle ambient = DefaultTextStyle.of(context).style;
    final double em = ambient.fontSize ?? 14;
    final Widget? mark = widget.showIcon
        ? widget.icon ?? NebaRunMark(status: status, size: em * 1.2)
        : null;
    final Widget? meta = widget.meta;

    final double gap = NebaScale.gap[size]!;
    final Widget header = Row(
      spacing: gap,
      children: <Widget>[
        if (mark != null)
          IconTheme.merge(
            data: IconThemeData(color: roles.accent, size: em * 1.2),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: roles.accent),
              child: mark,
            ),
          ),
        Expanded(
          child: Row(
            spacing: gap,
            children: <Widget>[
              Flexible(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontFamily: NebaScale.monoFonts.first,
                    fontFamilyFallback: NebaScale.monoFonts.sublist(1),
                    fontSize: titleSize,
                    height: NebaScale.sheetTitleLeading[size]! / titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  child: nebaWithStatusWord(widget.name, nebaRunWord(run, status, labels)),
                ),
              ),
              if (meta != null)
                Flexible(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    child: meta,
                  ),
                ),
            ],
          ),
        ),
        NebaRunTime(
          since: _watch.since,
          total: _watch.total(widget.duration),
          style: TextStyle(fontSize: metaSize, color: tokens.mutedFg),
        ),
        if (hasBody) NebaDisclosureChevron(open: open, color: tokens.mutedFg, size: em * 1.2),
      ],
    );

    Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: header,
    );

    if (!hasBody) {
      return NebaDisclosureSheet(
        variant: variant,
        color: family,
        size: size,
        elevation: widget.elevation ?? 0,
        child: Padding(padding: EdgeInsets.all(padding), child: content),
      );
    }

    content = NebaFoldTrigger(
      open: open,
      onToggle: toggleFold,
      roles: roles,
      padding: EdgeInsets.all(padding),
      child: content,
    );

    final double bodySize = NebaScale.sheetBodyText[size]!;
    final Widget? args = widget.args;
    final Widget? child = widget.child;

    return NebaDisclosureSheet(
      variant: variant,
      color: family,
      size: size,
      elevation: widget.elevation ?? 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          content,
          NebaDisclosurePanel(
            open: open,
            keepMounted: widget.keepMounted,
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, NebaDisclosureBody.bottom(density)),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: tokens.fg,
                  fontSize: bodySize,
                  height: NebaScale.sheetBodyLeading[size]! / bodySize,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: <Widget>[
                    if (args != null)
                      _Block(
                        size: size,
                        label: labels?['arguments'] ?? tool['arguments']!,
                        value: args,
                      ),
                    if (body != null)
                      _Block(
                        size: size,
                        label: failed
                            ? nebaRunWord(run, NebaRunStatus.error, null)
                            : labels?['result'] ?? tool['result']!,
                        value: body,
                        accent: status == NebaRunStatus.error ? roles.accent : null,
                      ),
                    ?child,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One labelled block inside the panel: a plain [Text] in the groove, set as
/// it arrived, or a widget the caller built, as it is.
class _Block extends StatelessWidget {
  const _Block({required this.size, required this.label, required this.value, this.accent});

  final NebaSize size;
  final String label;
  final Widget value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double metaSize = NebaScale.metaText[size]!;
    final Widget value = this.value;
    final Color? accent = this.accent;
    final String? text = nebaPreformattedText(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: <Widget>[
        // Capitals are how it is drawn, as CSS `uppercase`, and not what it
        // says: a screen reader still hears the word.
        Text(
          label.toUpperCase(),
          semanticsLabel: label,
          style: TextStyle(
            fontSize: metaSize,
            fontWeight: FontWeight.w500,
            letterSpacing: metaSize * 0.025,
            color: tokens.mutedFg,
          ),
        ),
        if (text != null)
          NebaPreformatted(text: text, maxHeight: NebaToolCall.blockMaxHeight, color: accent)
        else if (accent != null)
          DefaultTextStyle.merge(
            style: TextStyle(color: accent),
            child: value,
          )
        else
          value,
      ],
    );
  }
}
