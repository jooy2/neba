/// What the agent widgets share, the React package's `internal/run.tsx` and
/// the agent half of `internal/styles.ts`: how a [NebaRunStatus] looks, the
/// clock behind an elapsed time, the header a run folds behind, the block a
/// tool's own text is set in, and the numbered mark a source is cited by.
///
/// A transcript draws a tool call above a plan above a thinking panel, all at
/// once, so none of these answers is one widget's to hold on its own: a tick
/// on one row in a different green from the tick on the next is a transcript
/// whose reader cannot tell whether the difference means anything.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

// ---------------------------------------------------------------------------
// The status
// ---------------------------------------------------------------------------

/// The colour family [status] is drawn in, given the widget's own [color].
///
/// Two of the four are not the caller's to choose: something that failed is
/// danger and something that finished is success, on every row of the page.
/// [NebaRunStatus.running] takes the widget's family, and
/// [NebaRunStatus.pending] is secondary, the one family that says nothing has
/// happened yet without saying how it went.
NebaColor nebaRunColor(NebaRunStatus status, NebaColor color) {
  switch (status) {
    case NebaRunStatus.success:
      return NebaColor.success;
    case NebaRunStatus.error:
      return NebaColor.danger;
    case NebaRunStatus.pending:
      return NebaColor.secondary;
    case NebaRunStatus.running:
      return color;
  }
}

/// The ring a step that has not started is drawn as: a circle of short
/// dashes, the React package's `CircleIcon` with its `stroke-dasharray` of
/// 2 and 2.5 written out as arcs, since a glyph here has no dash pattern.
final List<NebaGlyphPart> nebaPendingRing = <NebaGlyphPart>[
  NebaGlyphPart.stroke(_dashedCircle(8, 8, 6.25, 2, 2.5), cap: StrokeCap.round),
];

String _dashedCircle(double cx, double cy, double r, double dash, double gap) {
  final double length = 2 * math.pi * r;
  final StringBuffer data = StringBuffer();

  String point(double along) {
    final double angle = along / r;

    return '${(cx + r * math.cos(angle)).toStringAsFixed(3)} '
        '${(cy + r * math.sin(angle)).toStringAsFixed(3)}';
  }

  // From three o'clock, clockwise on the screen, as SVG draws a circle.
  for (double start = 0; start < length; start += dash + gap) {
    final double end = math.min(start + dash, length);

    data.write('M${point(start)}A$r $r 0 0 1 ${point(end)}');
  }

  return data.toString();
}

/// The mark for [status]: a dashed ring, the turning ring, a tick in a circle
/// or a cross in one. The shape carries the state as well as the colour, so
/// a reader who cannot tell the families apart can still tell the rows apart.
class NebaRunMark extends StatelessWidget {
  /// The mark for [status], [size] across, in the ambient icon colour.
  const NebaRunMark({required this.status, this.size, super.key});

  /// Which mark.
  final NebaRunStatus status;

  /// The width and height; the ambient icon size when left out.
  final double? size;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case NebaRunStatus.running:
        return NebaSpinner(size: size);
      case NebaRunStatus.success:
        return NebaGlyph(NebaGlyphs.success, size: size);
      case NebaRunStatus.error:
        return NebaGlyph(NebaGlyphs.danger, size: size);
      case NebaRunStatus.pending:
        return NebaGlyph(nebaPendingRing, size: size);
    }
  }
}

/// The words a status is read out in, from the `run` namespace with [labels]
/// laid over them.
String nebaRunWord(Map<String, String> run, NebaRunStatus status, Map<String, String>? labels) {
  return labels?[status.name] ?? run[status.name]!;
}

/// [child] with [word] read after it and drawn nowhere: the status a mark
/// shows as a shape, said in words for a reader who has no shape to look at.
/// Beside rather than around it, so the name is still heard first.
Widget nebaWithStatusWord(Widget child, String word) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Flexible(child: child),
      Semantics(label: word, child: const SizedBox.shrink()),
    ],
  );
}

// ---------------------------------------------------------------------------
// The clock
// ---------------------------------------------------------------------------

/// A length of time, as the React package writes one in English: under a
/// second in milliseconds, over it in seconds, to one decimal place for the
/// first ten and to none after that. `340ms`, `4.2s`, `247s`.
///
/// The widgets layer has no `Intl`, so this is English whatever the locale,
/// as `format.dart`'s numbers are.
String nebaFormatDuration(Duration duration) {
  final int micros = duration.inMicroseconds;

  if (micros < 0) {
    return '';
  }

  final double ms = micros / Duration.microsecondsPerMillisecond;

  if (ms < 1000) {
    return '${ms.round()}ms';
  }

  final double seconds = ms / 1000;

  return '${nebaFormatNumber(seconds, maxFractionDigits: seconds < 10 ? 1 : 0)}s';
}

final Stopwatch _watch = Stopwatch()..start();

Duration _watchNow() => _watch.elapsed;

Duration Function() _now = _watchNow;

/// Replaces the clock every run is timed on, for a test that moves time on
/// by hand; `null` puts the real one back.
@visibleForTesting
set debugNebaRunNow(Duration Function()? now) {
  _now = now ?? _watchNow;
}

final Set<VoidCallback> _tickers = <VoidCallback>{};
Timer? _tickTimer;

/// Calls [tick] once a second, on one timer for every run on the page, until
/// the function it returns is called.
///
/// One timer rather than one per run, so twenty running calls tick together
/// in one frame instead of twenty frames of their own, and a page with
/// nothing running keeps no timer at all.
VoidCallback nebaOnSecond(VoidCallback tick) {
  _tickers.add(tick);
  _tickTimer ??= Timer.periodic(const Duration(seconds: 1), (Timer _) {
    for (final VoidCallback listener in _tickers.toList()) {
      listener();
    }
  });

  return () {
    _tickers.remove(tick);

    if (_tickers.isEmpty) {
      _tickTimer?.cancel();
      _tickTimer = null;
    }
  };
}

/// When a run started and how long it took, without counting in between: the
/// React package's `useRunClock`, kept by the state of the widget around the
/// run.
///
/// A `duration` the caller knows wins outright. Without one, the start is
/// taken when the run starts and the run is measured once more when it ends,
/// which is what turns a live count into a total: left at the last tick, a run
/// of 4.9 seconds would say 4. A new run clears the last one's total, so a
/// retried call counts its own attempt.
class NebaRunWatch {
  bool _measuring = false;
  Duration? _since;
  Duration? _measured;

  /// Follows whether the run is [running] and the [duration] the caller knows.
  /// Call it when the widget is first built and on every update.
  void update({required bool running, required Duration? duration}) {
    final bool measure = running && duration == null;

    if (measure == _measuring) {
      return;
    }

    _measuring = measure;

    if (measure) {
      _since = _now();
      _measured = null;
    } else {
      final Duration? since = _since;

      if (since != null) {
        _measured = _now() - since;
      }

      _since = null;
    }
  }

  /// When the run that is going now started, on the run clock, or `null`.
  Duration? get since => _measuring ? _since : null;

  /// How long it took: [duration] when the caller knows it, the run measured
  /// as it ended otherwise, or `null` while there is neither.
  Duration? total(Duration? duration) => duration ?? _measured;
}

/// The time a run has taken, as text: the [total] once there is one, and the
/// running count from [since] until then. Nothing at all while there is
/// neither, and nothing for the first second of a run, because a counter
/// that starts at zero claims a precision the tick does not have.
///
/// A widget of its own, so the one thing that changes every second is the
/// only thing built every second. Whole seconds, because the shared clock
/// ticks at a moment of its own rather than of this run's.
class NebaRunTime extends StatefulWidget {
  /// The time from [since], or [total].
  const NebaRunTime({required this.since, required this.total, this.style, super.key});

  /// When the run started, on the run clock.
  final Duration? since;

  /// How long it took, once that is known.
  final Duration? total;

  /// The text's style, over the ambient one.
  final TextStyle? style;

  @override
  State<NebaRunTime> createState() => _NebaRunTimeState();
}

class _NebaRunTimeState extends State<NebaRunTime> {
  Duration? _counted;
  VoidCallback? _stop;

  Duration? get _from => widget.total == null ? widget.since : null;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(NebaRunTime oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Duration? was = oldWidget.total == null ? oldWidget.since : null;

    if (was != _from) {
      _counted = null;
      _listen();
    }
  }

  @override
  void dispose() {
    _stop?.call();
    super.dispose();
  }

  void _listen() {
    _stop?.call();
    _stop = null;

    if (_from != null) {
      _stop = nebaOnSecond(_tick);
    }
  }

  void _tick() {
    final Duration? from = _from;

    if (from == null || !mounted) {
      return;
    }

    final Duration spent = _now() - from;

    if (spent >= const Duration(seconds: 1)) {
      final Duration counted = Duration(seconds: spent.inSeconds);

      if (counted != _counted) {
        setState(() => _counted = counted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Duration? shown = widget.total ?? (_from == null ? null : _counted);

    if (shown == null) {
      return const SizedBox.shrink();
    }

    return Text(
      nebaFormatDuration(shown),
      maxLines: 1,
      softWrap: false,
      style: const TextStyle(
        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
      ).merge(widget.style),
    );
  }
}

// ---------------------------------------------------------------------------
// The fold
// ---------------------------------------------------------------------------

/// The header a ToolCall, a Reasoning and a Sources fold their panel behind:
/// a row that spans the sheet, washed in [roles]' soft colour under the
/// pointer and ringed inside its own edge on keyboard focus, heard as a
/// button that is expanded or collapsed.
///
/// Not `NebaDisclosureHeader`, which lays out a Collapsible's title and
/// subtitle and turns its ink when open: what these three put on the line is
/// their own, a tool's name and its time, a sentence that changes as the
/// stream does, a heading and a count, and none of them changes colour on
/// opening. The panel under it is the same `NebaDisclosurePanel`.
class NebaFoldTrigger extends StatelessWidget {
  /// A trigger around [child], for a panel that is [open] or not.
  const NebaFoldTrigger({
    required this.open,
    required this.onToggle,
    required this.roles,
    required this.padding,
    required this.child,
    this.hoverInk,
    super.key,
  });

  /// Whether the panel is open.
  final bool open;

  /// Opens or closes the panel.
  final VoidCallback onToggle;

  /// The family of the wash and the ring.
  final NebaColorRoles roles;

  /// The room around [child].
  final EdgeInsetsGeometry padding;

  /// The ink under the pointer, when it changes there.
  final Color? hoverInk;

  /// The row: whatever is on the line, the chevron at its end.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color ink = DefaultTextStyle.of(context).style.color ?? NebaTheme.of(context).fg;
    final Color? hoverInk = this.hoverInk;

    final Widget trigger = NebaInteractive(
      onTap: onToggle,
      cursor: SystemMouseCursors.click,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        // The text's ink on the glyphs too, so a mark and a chevron the row
        // does not colour itself follow it, under the pointer included.
        final Widget content = NebaInk(
          color: interaction.hovered && hoverInk != null ? hoverInk : ink,
          child: Padding(padding: padding, child: child),
        );

        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: BorderRadius.zero,
          // Inside rather than off: the sheet clips the trigger so the panel
          // can be a window, and a ring outside it would be clipped away.
          offset: -focusRingWidth,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: interaction.hovered ? roles.soft : edgeless),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? wash, Widget? child) {
              return DecoratedBox(
                decoration: BoxDecoration(color: wash),
                child: child,
              );
            },
            child: content,
          ),
        );
      },
    );

    return Semantics(container: true, button: true, enabled: true, expanded: open, child: trigger);
  }
}

/// The open state of a fold a caller may drive, the stream may move, and the
/// reader may press: what a ToolCall, a Reasoning and a Sources keep alike.
mixin NebaFoldState<T extends StatefulWidget> on State<T> {
  /// The state an uncontrolled fold keeps.
  late bool foldOpen;

  /// The caller's own `open`, which wins while it is not `null`.
  bool? get controlledOpen;

  /// Called when the reader opens or closes the fold.
  ValueChanged<bool>? get onFoldChange;

  /// Whether the fold is open, as drawn.
  bool get isOpen => controlledOpen ?? foldOpen;

  /// What the trigger does: the uncontrolled state follows the press, and the
  /// caller hears of it either way.
  void toggleFold() {
    final bool next = !isOpen;

    if (controlledOpen == null) {
      setState(() => foldOpen = next);
    }

    onFoldChange?.call(next);
  }
}

// ---------------------------------------------------------------------------
// The text a tool hands back
// ---------------------------------------------------------------------------

/// The text of [value] when it is a plain [Text], which is drawn as a
/// [NebaPreformatted] block: the React package's string test, where a string
/// is what a tool hands back and a node is something the caller built.
String? nebaPreformattedText(Widget value) {
  return value is Text ? value.data : null;
}

/// A block of text that arrived already formatted: what a tool was called
/// with, what it answered, the command an Approval asks about.
///
/// Indented JSON, a stack trace and a diff each mean something by where their
/// lines break, so the block scrolls rather than wraps, both ways, up to
/// [maxHeight]. It sits in the groove rather than on a tinted sheet, because
/// what is in here was not coloured against an accent.
class NebaPreformatted extends StatelessWidget {
  /// [text] in the monospaced face, scrolling past [maxHeight].
  const NebaPreformatted({required this.text, required this.maxHeight, this.color, super.key});

  /// The text, with its own line breaks.
  final String text;

  /// The tallest the block gets before it scrolls.
  final double maxHeight;

  /// The ink, when it is not the text's around it: an error's accent.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final TextStyle ambient = DefaultTextStyle.of(context).style;
    final double size = (ambient.fontSize ?? 14) * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.groove,
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
        ),
        child: SingleChildScrollView(
          primary: false,
          child: SingleChildScrollView(
            primary: false,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              softWrap: false,
              style: TextStyle(
                fontFamily: NebaScale.monoFonts.first,
                fontFamilyFallback: NebaScale.monoFonts.sublist(1),
                fontSize: size,
                height: 1.5,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The citation mark
// ---------------------------------------------------------------------------

/// The number a source is cited by: a Sources row's and an InlineCitation's,
/// one drawing so the `2` in a sentence and the `2` in the list underneath
/// cannot stop matching.
///
/// A rounded square of [roles]' soft wash at 0.8 times the type around it, in
/// semibold tabular figures, never narrower than one and a half of its own
/// letters. [wash] replaces the soft colour, for a mark under the pointer.
class NebaCitationMark extends StatelessWidget {
  /// The mark for [index].
  const NebaCitationMark({required this.index, required this.roles, this.wash, super.key});

  /// The number.
  final int index;

  /// The family of the wash and the number.
  final NebaColorRoles roles;

  /// The wash, in place of the family's soft colour.
  final Color? wash;

  @override
  Widget build(BuildContext context) {
    final double em = (DefaultTextStyle.of(context).style.fontSize ?? 14) * 0.8;

    return Container(
      constraints: BoxConstraints(minWidth: em * 1.5),
      padding: EdgeInsets.symmetric(horizontal: em * 0.35, vertical: em * 0.05),
      decoration: BoxDecoration(
        color: wash ?? roles.soft,
        borderRadius: BorderRadius.circular(em * 0.3),
      ),
      child: Text(
        '$index',
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontSize: em,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: roles.onTint,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
