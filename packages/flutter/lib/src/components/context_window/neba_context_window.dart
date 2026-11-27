/// `NebaContextWindow`, how much of a model's context window has gone, and
/// what went into it.
library;

import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a context window is spent on, as a model reports it.
///
/// Every part is optional: a model with no reasoning trace and no cache
/// reports two of them, and a part that was not reported is not drawn, while
/// one reported as zero is.
@immutable
class NebaContextTokens {
  /// The parts a turn reported.
  const NebaContextTokens({this.input, this.output, this.reasoning, this.cached});

  /// Everything sent: the prompt, the history, the tool definitions.
  final double? input;

  /// Everything the model wrote back.
  final double? output;

  /// What it spent thinking, where the model bills that separately.
  final double? reasoning;

  /// The part of [input] that was served from a cache. A portion of the
  /// input rather than a fourth thing beside it, so it is drawn as a row and
  /// left out of the total.
  final double? cached;

  @override
  bool operator ==(Object other) {
    return other is NebaContextTokens &&
        other.input == input &&
        other.output == output &&
        other.reasoning == reasoning &&
        other.cached == cached;
  }

  @override
  int get hashCode => Object.hash(input, output, reasoning, cached);
}

/// How much of the context window has gone, and what went into it.
///
/// A `NebaMeter` draws the same reading as a bar and would do most of this.
/// What it cannot do is what makes this a widget: the counts are tokens, five
/// and six digits long and written compactly, `124K of 200K`; the split into
/// input, output, reasoning and cached is four numbers that only mean
/// something next to each other; and the money underneath is a third unit.
///
/// The ring, the name and the count are one reading to a screen reader, its
/// value the same sentence that is drawn; the split, the cost and [child] are
/// outside it. The four parts take the first four chart palette slots, since
/// they are entities rather than severities.
///
/// ```dart
/// const NebaContextWindow(
///   max: 200000,
///   tokens: NebaContextTokens(input: 94200, output: 12400),
///   cost: 0.42,
/// )
/// ```
class NebaContextWindow extends StatelessWidget {
  /// A window of [max] tokens.
  const NebaContextWindow({
    required this.max,
    this.used,
    this.tokens,
    this.cost,
    this.thresholds,
    this.label,
    this.breakdown = true,
    this.format,
    this.formatCost,
    this.size,
    this.color,
    this.locale,
    this.labels,
    this.child,
    super.key,
  });

  /// How many tokens the window holds.
  final double max;

  /// How many have gone. Left out, it is the [tokens]' input, output and
  /// reasoning added up, without the cached part, which is inside the input.
  final double? used;

  /// The split, drawn as a row per part under the ring, in a fixed order and
  /// only for the parts that were reported.
  final NebaContextTokens? tokens;

  /// What the turn cost, drawn beside the ring.
  final double? cost;

  /// Where the ring changes colour, in tokens and read in the order given:
  /// `NebaThreshold(from: 0.8 * max, color: NebaColor.warning)`.
  final List<NebaThreshold>? thresholds;

  /// What the gauge is called, usually a [Text]. Defaults to the [locale]'s
  /// word for it.
  final Widget? label;

  /// Draws the split under the ring. Off, the gauge is the ring and the counts
  /// beside it, which is what fits in a toolbar.
  final bool breakdown;

  /// Writes a count. Left out, a count is compacted from a thousand up with
  /// one digit after the point, `12.4K`, as the React package writes it in
  /// English; the widgets layer has no `Intl` to write it in another language.
  final String Function(double tokens)? format;

  /// Writes the [cost]. Left out, it is US dollars to the cent, `$0.42`; the
  /// React package's `currency` is a caller's function here.
  final String Function(double cost)? formatCost;

  /// The ring, the type and the gaps. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family the ring carries before any threshold is reached. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The language of the gauge's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `label`, `input`, `output`, `reasoning`, `cached`, `cost` and
  /// `usage` with a `{used}` and a `{max}` in it.
  final Map<String, String>? labels;

  /// Anything to put under the split: a model name, a way to clear the thread.
  final Widget? child;

  /// The ring's width and height at each size, one step above the progress
  /// ladder, because this one is read rather than glanced at.
  static const Map<NebaSize, double> ringDiameters = <NebaSize, double>{
    NebaSize.xs: 26,
    NebaSize.sm: 30,
    NebaSize.md: 36,
    NebaSize.lg: 44,
    NebaSize.xl: 54,
  };

  /// The ring's stroke, thickening with it so the hole stays in proportion.
  static const Map<NebaSize, double> ringStrokes = <NebaSize, double>{
    NebaSize.xs: 3,
    NebaSize.sm: 3.5,
    NebaSize.md: 4,
    NebaSize.lg: 5,
    NebaSize.xl: 6,
  };

  /// The square beside a row of the split.
  static const Map<NebaSize, double> swatchSizes = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 8,
    NebaSize.lg: 10,
    NebaSize.xl: 12,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _build(context, bounded: constraints.hasBoundedWidth);
      },
    );
  }

  Widget _build(BuildContext context, {required bool bounded}) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final Map<String, String> messages = nebaMessages(
      context,
      'context',
      locale: locale ?? defaults.locale,
    );
    String word(String key) => labels?[key] ?? messages[key]!;
    final String Function(double) count = format ?? _compact;

    final NebaContextTokens? split = this.tokens;
    // The cached part is drawn and not added: it is already inside the input,
    // and counting it again would report the window as fuller than it is.
    final double total = used ?? (split == null ? 0 : _spent(split));
    final double? fraction = progressFraction(total, 0, max);
    final NebaColor family = thresholdColor(total, color ?? NebaColor.primary, thresholds);
    final NebaColorRoles roles = tokens.roles(family);
    final String usage = fillNebaMessage(word('usage'), <String, String>{
      'used': count(total),
      'max': count(max),
    });

    final double metaSize = NebaScale.metaText[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final TextStyle meta = TextStyle(fontSize: metaSize, height: 1.5);
    final TextStyle figure = TextStyle(
      fontSize: titleSize,
      height: NebaScale.sheetTitleLeading[size]! / titleSize,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      color: tokens.fg,
    );
    final double diameter = ringDiameters[size]!;
    final double gap = NebaScale.gap[size]!;
    final double? cost = this.cost;
    final List<(String, double)> parts = split == null
        ? const <(String, double)>[]
        : _reported(split);
    final Widget? child = this.child;

    // A row of controls lays its children out at no width in particular, and
    // there the gauge is as wide as what it says rather than as wide as the
    // row, as a flex item with nothing to grow into is.
    Widget wrapFlexible(Widget child) => bounded ? Flexible(child: child) : child;
    Widget wrapExpanded(Widget child) => bounded ? Expanded(child: child) : child;

    // The reading: the ring, the name and the count, and nothing else, so
    // the split and anything under it stay what they are.
    final Widget reading = Semantics(
      container: true,
      value: usage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: gap,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: fraction ?? 0),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, double shown, Widget? _) {
              return TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: roles.fill),
                duration: nebaDuration(context, NebaScale.duration),
                curve: NebaScale.ease,
                builder: (BuildContext context, Color? fill, Widget? _) {
                  return CustomPaint(
                    size: Size.square(diameter),
                    painter: _RingPainter(
                      fraction: shown,
                      stroke: ringStrokes[size]!,
                      track: roles.soft,
                      fill: fill ?? roles.fill,
                    ),
                  );
                },
              );
            },
          ),
          // Shrinking only where there is a width to shrink within: in a row of
          // controls the reading is as wide as what it says.
          wrapFlexible(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle.merge(
                  style: meta.copyWith(fontWeight: FontWeight.w500, color: tokens.fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  child: label ?? Text(word('label')),
                ),
                // Read as the reading's value, so not a second time as text.
                ExcludeSemantics(
                  child: Text(
                    usage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: figure,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: bounded ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      spacing: NebaScale.stackGap[size]!,
      children: <Widget>[
        Row(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          spacing: gap,
          children: <Widget>[
            wrapExpanded(
              Align(alignment: AlignmentDirectional.centerStart, widthFactor: 1, child: reading),
            ),
            if (cost != null)
              Semantics(
                container: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(word('cost'), style: meta.copyWith(color: tokens.mutedFg)),
                    Text((formatCost ?? _dollars)(cost), style: figure),
                  ],
                ),
              ),
          ],
        ),
        if (breakdown && parts.isNotEmpty)
          Semantics(
            container: true,
            role: SemanticsRole.list,
            explicitChildNodes: true,
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              children: <Widget>[
                for (final (String key, double value) in parts)
                  Semantics(
                    container: true,
                    role: SemanticsRole.listItem,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: <Widget>[
                        Container(
                          width: swatchSizes[size],
                          height: swatchSizes[size],
                          decoration: BoxDecoration(
                            color: tokens.chart.series[_slots[key]!],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(word(key), style: meta.copyWith(color: tokens.mutedFg)),
                        Text(
                          count(value),
                          style: meta.copyWith(
                            color: tokens.fg,
                            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ?child,
      ],
    );
  }
}

/// The parts [tokens] reported, in the order they are drawn, each with the
/// message key it is called by.
List<(String, double)> _reported(NebaContextTokens tokens) {
  return <(String, double)>[
    if (tokens.input case final double value) ('input', value),
    if (tokens.output case final double value) ('output', value),
    if (tokens.reasoning case final double value) ('reasoning', value),
    if (tokens.cached case final double value) ('cached', value),
  ];
}

/// What the window holds of [tokens]: everything but the cached part.
double _spent(NebaContextTokens tokens) {
  return (tokens.input ?? 0) + (tokens.output ?? 0) + (tokens.reasoning ?? 0);
}

/// The palette slot each part takes, from the first: input and output are
/// the adjacent pair that was checked for colour-vision separation.
const Map<String, int> _slots = <String, int>{'input': 0, 'output': 1, 'reasoning': 2, 'cached': 3};

/// A count as `Intl.NumberFormat`'s `notation: 'compact'` writes it in
/// English with one digit after the point: `999`, `8.1K`, `124K`, `1.2M`.
String _compact(double value) => nebaFormatCompact(value, from: 1000, maxFractionDigits: 1);

/// A cost in US dollars to the cent, as `Intl` writes one in English.
String _dollars(double value) {
  final String fixed = value.abs().toStringAsFixed(2);
  final int point = fixed.indexOf('.');
  final String whole = nebaFormatNumber(double.parse(fixed.substring(0, point)));

  return '${value < 0 ? '-' : ''}\$$whole${fixed.substring(point)}';
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.stroke,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final double stroke;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    // The stroke straddles the path, so the radius comes in by half of it.
    final double radius = size.shortestSide / 2 - stroke / 2;
    final Rect circle = Rect.fromCircle(center: centre, radius: radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..isAntiAlias = true;

    canvas.drawCircle(centre, radius, paint..color = track);

    if (fraction > 0) {
      canvas.drawArc(
        circle,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        paint
          ..color = fill
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.stroke != stroke ||
        oldDelegate.track != track ||
        oldDelegate.fill != fill;
  }
}
