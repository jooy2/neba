/// `NebaAgentSteps` and `NebaAgentStep`, a chain of steps that grows as it
/// runs.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/agent.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a step takes from the chain around it.
class _NebaAgentStepsScope extends InheritedWidget {
  const _NebaAgentStepsScope({
    required this.size,
    required this.density,
    required this.color,
    required this.locale,
    required this.labels,
    required super.child,
  });

  final NebaSize size;
  final NebaDensity density;
  final NebaColor color;
  final Locale? locale;
  final Map<String, String>? labels;

  static _NebaAgentStepsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaAgentStepsScope>();
  }

  @override
  bool updateShouldNotify(_NebaAgentStepsScope oldWidget) {
    return size != oldWidget.size ||
        density != oldWidget.density ||
        color != oldWidget.color ||
        locale != oldWidget.locale ||
        !_sameLabels(labels, oldWidget.labels);
  }
}

bool _sameLabels(Map<String, String>? a, Map<String, String>? b) {
  if (identical(a, b)) {
    return true;
  }

  if (a == null || b == null || a.length != b.length) {
    return false;
  }

  return a.entries.every((MapEntry<String, String> entry) => b[entry.key] == entry.value);
}

/// Whether the line under a step would run into nothing. `last` when there
/// is no chain around it, because a rail leaving a step with nothing after it
/// runs into the page.
class _NebaAgentStepPlace extends InheritedWidget {
  const _NebaAgentStepPlace({required this.last, required super.child, super.key});

  final bool last;

  static bool lastOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaAgentStepPlace>()?.last ?? true;
  }

  @override
  bool updateShouldNotify(_NebaAgentStepPlace oldWidget) => last != oldWidget.last;
}

/// A chain of steps that grows as it runs.
///
/// A `NebaTimeline` and a `NebaHowToSteps` draw a list that is known in
/// advance. This one does not know how many items it has: steps are appended
/// as they happen, the one at the bottom is usually still running, and each
/// can hold whatever it did, a `NebaToolCall` of its own included. The order
/// is the content, so it is a list to a screen reader, and nothing in it is
/// a control.
///
/// ```dart
/// NebaAgentSteps(
///   running: true,
///   runningTitle: const Text('Writing the answer'),
///   children: <Widget>[
///     const NebaAgentStep(title: Text('Read the request'), duration: Duration(milliseconds: 120)),
///   ],
/// )
/// ```
class NebaAgentSteps extends StatelessWidget {
  /// A chain of [children].
  const NebaAgentSteps({
    required this.children,
    this.running = false,
    this.runningTitle,
    this.size,
    this.color,
    this.density,
    this.locale,
    this.labels,
    super.key,
  });

  /// The steps, usually [NebaAgentStep]s, in the order they happened.
  final List<Widget> children;

  /// Whether there is more to come, drawn as one more running step under the
  /// last one. A prop of the chain rather than one more step, because that
  /// step has no name yet.
  final bool running;

  /// The title of that step, while [running]: "Deciding what to do next".
  /// Left out, the step has none, since its status is already read out and
  /// the turning ring already says it.
  final Widget? runningTitle;

  /// The marks, the type and the gaps. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family a running step is drawn in. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The room between two steps, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The language a step's status is read out in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those four words, written out over the [locale]'s, by status name:
  /// `pending`, `running`, `success` and `error`.
  final Map<String, String>? labels;

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final int count = children.length + (running ? 1 : 0);

    return _NebaAgentStepsScope(
      size: size,
      density: density,
      color: color ?? NebaColor.primary,
      locale: locale ?? defaults.locale,
      labels: labels,
      child: Semantics(
        container: true,
        role: SemanticsRole.list,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < children.length; i++)
              _NebaAgentStepPlace(key: children[i].key, last: i == count - 1, child: children[i]),
            // Keyed by how many steps came before it: the step stands for
            // whichever one is under way, so a step appended in front of it is
            // a new one starting, with a clock of its own.
            if (running)
              _NebaAgentStepPlace(
                key: ValueKey<String>('running ${children.length}'),
                last: true,
                child: NebaAgentStep(status: NebaRunStatus.running, title: runningTitle),
              ),
          ],
        ),
      ),
    );
  }
}

/// One step of a [NebaAgentSteps] chain: a mark for its [status], a [title]
/// and a [meta] beside it, the time it took, and what it did under them.
///
/// Its place in the chain is not an argument: the only thing a step has to
/// know about its neighbours is whether the line under it would run into
/// nothing, and the chain says so. A step on its own still draws, as one step
/// with nothing before or after it.
class NebaAgentStep extends StatefulWidget {
  /// A step called [title].
  const NebaAgentStep({
    this.title,
    this.status = NebaRunStatus.success,
    this.duration,
    this.meta,
    this.icon,
    this.showIcon = true,
    this.color,
    this.child,
    super.key,
  });

  /// What the step is, usually a [Text].
  final Widget? title;

  /// How far it has got.
  final NebaRunStatus status;

  /// How long it took. Left out, a running step counts its own from the
  /// second it starts, as a `NebaToolCall` does.
  final Duration? duration;

  /// Anything else on the title line: a file name, a count, a model.
  final Widget? meta;

  /// The mark, in place of the one that goes with [status]. The status is
  /// still read out.
  final Widget? icon;

  /// Whether a mark is drawn at all; `false` leaves the circle empty, React's
  /// `icon={false}`.
  final bool showIcon;

  /// The family of a running step, over the chain's.
  final NebaColor? color;

  /// What the step did, under the title: a search query, a file that was
  /// read, a `NebaToolCall` of its own.
  final Widget? child;

  /// The mark's width and height at each size, on the tick ladder, since a
  /// mark is not a control.
  static const Map<NebaSize, double> markSizes = NebaScale.tickSize;

  /// Between the mark and the step beside it.
  static const Map<NebaSize, double> markGaps = <NebaSize, double>{
    NebaSize.xs: 8,
    NebaSize.sm: 10,
    NebaSize.md: 12,
    NebaSize.lg: 14,
    NebaSize.xl: 16,
  };

  /// How far apart two steps sit, the one thing density touches: tighter than
  /// a timeline's, because a chain that is still growing reads as having
  /// stopped when its rows are far apart.
  static const Map<NebaDensity, Map<NebaSize, double>> stepGaps =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 12,
          NebaSize.sm: 14,
          NebaSize.md: 16,
          NebaSize.lg: 20,
          NebaSize.xl: 24,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 14,
        },
      };

  @override
  State<NebaAgentStep> createState() => _NebaAgentStepState();
}

class _NebaAgentStepState extends State<NebaAgentStep> {
  final NebaRunWatch _watch = NebaRunWatch();

  @override
  void initState() {
    super.initState();
    _watch.update(running: widget.status == NebaRunStatus.running, duration: widget.duration);
  }

  @override
  void didUpdateWidget(NebaAgentStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _watch.update(running: widget.status == NebaRunStatus.running, duration: widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final _NebaAgentStepsScope? chain = _NebaAgentStepsScope.maybeOf(context);
    final bool last = _NebaAgentStepPlace.lastOf(context);
    final NebaSize size = chain?.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = chain?.density ?? defaults.density ?? NebaDensity.standard;
    final NebaRunStatus status = widget.status;
    final NebaColor family = nebaRunColor(
      status,
      widget.color ?? chain?.color ?? NebaColor.primary,
    );
    final NebaColorRoles roles = tokens.roles(family);
    final Map<String, String> run = nebaMessages(
      context,
      'run',
      locale: chain == null ? defaults.locale : chain.locale,
    );
    final double mark = NebaAgentStep.markSizes[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double metaSize = NebaScale.metaText[size]!;
    final double bodySize = NebaScale.sheetBodyText[size]!;

    // What has finished is ordinary reading text, what is happening now and
    // what failed carry the family, and what has not started is muted.
    final Color titleInk = switch (status) {
      NebaRunStatus.pending => tokens.mutedFg,
      NebaRunStatus.running || NebaRunStatus.error => roles.accent,
      NebaRunStatus.success => tokens.fg,
    };

    final Widget? title = widget.title;
    final Widget? meta = widget.meta;
    final Widget? child = widget.child;
    final Widget word = Semantics(
      label: nebaRunWord(run, status, chain?.labels),
      child: const SizedBox.shrink(),
    );

    final Widget line = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: 8,
      children: <Widget>[
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: <Widget>[
              // The status is read first, as the React package's hidden word
              // comes before the title, and takes no gap of its own.
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    word,
                    if (title != null)
                      Flexible(
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: titleSize,
                            height: NebaScale.sheetTitleLeading[size]! / titleSize,
                            fontWeight: FontWeight.w500,
                            color: titleInk,
                          ),
                          child: title,
                        ),
                      ),
                  ],
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
      ],
    );

    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: NebaAgentStep.markGaps[size]!,
      children: <Widget>[
        // Opaque, so the rail passes behind the mark rather than through it.
        ExcludeSemantics(
          child: Container(
            width: mark,
            height: mark,
            decoration: BoxDecoration(color: tokens.surface, shape: BoxShape.circle),
            child: IconTheme.merge(
              data: IconThemeData(color: roles.accent, size: mark),
              child: widget.showIcon
                  ? widget.icon ?? NebaRunMark(status: status, size: mark)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 2,
            children: <Widget>[
              line,
              if (child != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: tokens.mutedFg,
                    fontSize: bodySize,
                    height: NebaScale.sheetBodyLeading[size]! / bodySize,
                  ),
                  child: child,
                ),
            ],
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      role: chain != null ? SemanticsRole.listItem : null,
      // The step under way, as `aria-current="step"` says it.
      selected: status == NebaRunStatus.running ? true : null,
      child: Stack(
        children: <Widget>[
          // The rail, from under the mark to the bottom of the step, which is
          // where the next mark begins.
          if (!last)
            PositionedDirectional(
              start: mark / 2 - 1,
              top: mark,
              bottom: 0,
              width: 2,
              child: ColoredBox(color: tokens.border),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : NebaAgentStep.stepGaps[density]![size]!),
            child: content,
          ),
        ],
      ),
    );
  }
}
