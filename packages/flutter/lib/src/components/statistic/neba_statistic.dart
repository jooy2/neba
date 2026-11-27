/// `NebaStatistic`, a figure with its label and how it moved.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/chip/neba_chip.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How a [NebaStatistic] writes the change from its previous value.
enum NebaStatisticDelta {
  /// As a percentage of the previous value, or as an amount when there is no
  /// percentage to take, from a previous value of zero.
  percent,

  /// As an amount, in the figure's own format.
  absolute,

  /// Both, the percentage first.
  both,

  /// Not at all.
  none,
}

/// Which way a [NebaStatistic]'s figure is good news.
enum NebaStatisticBetterWhen {
  /// A figure that went up is good news: signups, revenue.
  up,

  /// A figure that went down is good news: latency, churn, open incidents.
  down,
}

/// A figure on a sheet, with what it counts, what it is in, and how it moved
/// since last time.
///
/// [value] is a number, which is formatted and compared with
/// [previousValue], or a [String] or a widget, drawn as it is. The change is a
/// chip in `success` when it went the way [betterWhen] says is good news, in
/// `danger` when it went the other way and in `secondary` when it did not
/// move, so an increase in latency is never green.
///
/// ```dart
/// const NebaStatistic(label: Text('Signups'), value: 3120, previousValue: 2740)
/// ```
class NebaStatistic extends StatelessWidget {
  /// A statistic of [value].
  const NebaStatistic({
    required this.value,
    this.label,
    this.format,
    this.prefix,
    this.unit,
    this.icon,
    this.previousValue,
    this.delta = NebaStatisticDelta.percent,
    this.betterWhen = NebaStatisticBetterWhen.up,
    this.caption,
    this.align = NebaAlign.start,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.padded = true,
    this.transition,
    this.child,
    super.key,
  }) : assert(value is num || value is String || value is Widget);

  /// The figure: a [num], formatted, or a [String] or a [Widget], drawn as it
  /// is and never compared.
  final Object value;

  /// What the figure counts.
  final Widget? label;

  /// How a number is written, the figure and an absolute change alike.
  /// Defaults to digits grouped by threes with at most three after the point.
  final String Function(num value)? format;

  /// What goes before the figure, a currency sign.
  final Widget? prefix;

  /// What goes after it, on its baseline: `ms`, `/ 250`.
  final Widget? unit;

  /// A glyph before the label, usually a `NebaIcon`.
  final Widget? icon;

  /// The value to compare with, for the change under the figure.
  final num? previousValue;

  /// How the change is written.
  final NebaStatisticDelta delta;

  /// Which way the figure is good news.
  final NebaStatisticBetterWhen betterWhen;

  /// A line under the figure, beside the change: "vs. last month".
  final Widget? caption;

  /// Where the parts line up across the sheet.
  final NebaAlign align;

  /// The weight of the sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline], as a [NebaBox]'s does.
  final NebaVariant? variant;

  /// The figure's type, the sheet's padding and the chip's size. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet.
  final NebaColor color;

  /// How much padding the sheet has. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads its content.
  final bool padded;

  /// How the statistic arrives when it is first built.
  final NebaTransition? transition;

  /// Anything of the caller's own under the rest: a progress bar, a
  /// sparkline.
  final Widget? child;

  /// The figure's text size and line height at each step.
  static const Map<NebaSize, (double, double)> valueText = <NebaSize, (double, double)>{
    NebaSize.xs: (18, 22),
    NebaSize.sm: (22, 26),
    NebaSize.md: (28, 32),
    NebaSize.lg: (36, 40),
    NebaSize.xl: (46, 52),
  };

  /// A prefix's and a unit's text size at each step.
  static const Map<NebaSize, double> affixText = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 14,
    NebaSize.md: 16,
    NebaSize.lg: 20,
    NebaSize.xl: 24,
  };

  static const Map<NebaSize, double> _footerGap = <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 4,
    NebaSize.xl: 6,
  };

  /// The change from [previousValue] to [value] as it is written under the
  /// figure, and which way it went, or `null` when there is nothing to write.
  static ({String text, int direction})? changeOf({
    required Object value,
    required num? previousValue,
    NebaStatisticDelta delta = NebaStatisticDelta.percent,
    String Function(num value)? format,
  }) {
    final num? current = value is num ? value : null;
    final num? previous = previousValue;

    if (delta == NebaStatisticDelta.none ||
        current == null ||
        previous == null ||
        !current.isFinite ||
        !previous.isFinite) {
      return null;
    }

    final String Function(num value) figure = format ?? nebaFormatNumber;
    final num difference = current - previous;
    final double? ratio = previous == 0 ? null : difference / previous.abs();
    final bool byPercent = delta != NebaStatisticDelta.absolute && ratio != null;
    String percentOf(double ratio) => nebaFormatPercent(ratio.abs(), maxFractionDigits: 1);

    // Flat when what is written would read as no change at all, so a figure
    // that moved by less than it is written to never shows an arrow.
    final int direction = byPercent
        ? (percentOf(ratio) == percentOf(0) ? 0 : ratio.sign.toInt())
        : (figure(difference.abs()) == figure(0) ? 0 : difference.sign.toInt());
    final String sign = direction > 0
        ? '+'
        : direction < 0
        ? '-'
        : '';
    final String absolute = '$sign${figure(difference.abs())}';
    final String? percent = ratio == null ? null : '$sign${percentOf(ratio)}';

    final String text = switch (delta) {
      NebaStatisticDelta.absolute => absolute,
      NebaStatisticDelta.both => <String>[?percent, absolute].join(' · '),
      _ => percent ?? absolute,
    };

    return (text: text, direction: direction);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final double meta = NebaScale.metaText[size]!;
    final (double valueSize, double valueLeading) = valueText[size]!;
    final CrossAxisAlignment cross = switch (align) {
      NebaAlign.start => CrossAxisAlignment.start,
      NebaAlign.center => CrossAxisAlignment.center,
      NebaAlign.end => CrossAxisAlignment.end,
    };
    final TextAlign textAlign = switch (align) {
      NebaAlign.start => TextAlign.start,
      NebaAlign.center => TextAlign.center,
      NebaAlign.end => TextAlign.end,
    };
    final WrapAlignment wrapAlign = switch (align) {
      NebaAlign.start => WrapAlignment.start,
      NebaAlign.center => WrapAlignment.center,
      NebaAlign.end => WrapAlignment.end,
    };
    final Widget? label = this.label;
    final Widget? icon = this.icon;
    final Widget? prefix = this.prefix;
    final Widget? unit = this.unit;
    final Widget? caption = this.caption;
    final Object value = this.value;

    final Widget shown = switch (value) {
      num() => Text((format ?? nebaFormatNumber)(value), textAlign: textAlign),
      String() => Text(value, textAlign: textAlign),
      Widget() => value,
      _ => const SizedBox.shrink(),
    };

    Widget affix(Widget child) {
      return DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: affixText[size],
          fontWeight: FontWeight.w500,
          color: tokens.mutedFg,
        ),
        child: child,
      );
    }

    final ({String text, int direction})? change = changeOf(
      value: value,
      previousValue: previousValue,
      delta: delta,
      format: format,
    );
    final NebaColor changeColor = change == null || change.direction == 0
        ? NebaColor.secondary
        : (change.direction > 0) == (betterWhen == NebaStatisticBetterWhen.up)
        ? NebaColor.success
        : NebaColor.danger;

    return NebaBox(
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      child: Column(
        crossAxisAlignment: cross,
        mainAxisSize: MainAxisSize.min,
        spacing: NebaScale.sheetSectionGap[size]!,
        children: <Widget>[
          if (label != null || icon != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: meta, fontWeight: FontWeight.w500, color: tokens.mutedFg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: IconTheme.merge(
                data: IconThemeData(color: tokens.mutedFg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: <Widget>[
                    ?icon,
                    if (label != null) Flexible(child: label),
                  ],
                ),
              ),
            ),
          // The unit on the figure's baseline, so "42%" reads as one number.
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: valueSize,
              height: valueLeading / valueSize,
              fontWeight: FontWeight.w600,
              color: tokens.fg,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 4,
              children: <Widget>[
                if (prefix != null) affix(prefix),
                Flexible(child: shown),
                if (unit != null) affix(unit),
              ],
            ),
          ),
          if (change != null || caption != null)
            Wrap(
              spacing: 8,
              runSpacing: _footerGap[size]!,
              alignment: wrapAlign,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (change != null)
                  NebaChip(
                    size: size,
                    variant: NebaVariant.text,
                    color: changeColor,
                    startIcon: NebaGlyph(
                      change.direction > 0
                          ? NebaGlyphs.trendUp
                          : change.direction < 0
                          ? NebaGlyphs.trendDown
                          : NebaGlyphs.minus,
                    ),
                    child: Text(
                      change.text,
                      style: const TextStyle(
                        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                if (caption != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: meta, color: tokens.mutedFg),
                    textAlign: textAlign,
                    child: caption,
                  ),
              ],
            ),
          ?child,
        ],
      ),
    );
  }
}
