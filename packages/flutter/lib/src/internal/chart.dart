/// The arithmetic every chart is made of: the React package's
/// `src/internal/chart.ts`.
///
/// Every chart draws a different mark and asks the same questions first: what
/// is the range, where does a value land in the plot, what are the clean
/// numbers to tick at, and what colour is series four. Answering them here
/// keeps a chart's own file about its mark. Nothing in it builds a widget;
/// what it knows is data and pixels, and `chart_frame.dart` is where those
/// become a drawing.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

// ---------------------------------------------------------------------------
// Ladders
// ---------------------------------------------------------------------------

/// How tall a plot is when nobody said, in logical pixels. The axis band is
/// drawn inside this rather than added to it, so a card sized to the chart is
/// a card the chart fits in.
const Map<NebaSize, double> chartPlotHeights = <NebaSize, double>{
  NebaSize.xs: 120,
  NebaSize.sm: 160,
  NebaSize.md: 220,
  NebaSize.lg: 280,
  NebaSize.xl: 360,
};

/// A sparkline's own ladder, sized against the line of text it sits beside
/// rather than against the page.
const Map<NebaSize, double> sparklineHeights = <NebaSize, double>{
  NebaSize.xs: 16,
  NebaSize.sm: 20,
  NebaSize.md: 28,
  NebaSize.lg: 40,
  NebaSize.xl: 56,
};

/// The weight of a line. `md` is 2: thin enough to stay a line where two of
/// them cross, heavy enough to hold a hue at 3:1.
const Map<NebaSize, double> chartLineWidths = <NebaSize, double>{
  NebaSize.xs: 1.5,
  NebaSize.sm: 1.75,
  NebaSize.md: 2,
  NebaSize.lg: 2.25,
  NebaSize.xl: 2.5,
};

/// The radius of a marker. `md` is 4, so a dot is 8 pixels across before its
/// ring.
const Map<NebaSize, double> chartMarkerRadii = <NebaSize, double>{
  NebaSize.xs: 3,
  NebaSize.sm: 3.5,
  NebaSize.md: 4,
  NebaSize.lg: 4.5,
  NebaSize.xl: 5,
};

/// Tick and label type, which is the meta text ladder.
const Map<NebaSize, double> chartFontSizes = NebaScale.metaText;

/// How thick a bar is allowed to get. A cap and not a width: past it the band
/// a bar sits in keeps the rest as air.
const Map<NebaSize, double> chartBarMaxThickness = <NebaSize, double>{
  NebaSize.xs: 14,
  NebaSize.sm: 18,
  NebaSize.md: 24,
  NebaSize.lg: 30,
  NebaSize.xl: 36,
};

/// How much of a band the bars in it take, before the cap applies. `density`
/// is the only thing that moves it.
const Map<NebaDensity, double> chartBarBandRatio = <NebaDensity, double>{
  NebaDensity.standard: 0.62,
  NebaDensity.compact: 0.82,
};

/// The gap the surface shows through between two touching marks.
const double chartMarkGap = 2;

/// The corner cut off the data end of a bar. Square at the baseline.
const double chartBarRadius = 4;

/// How far a series not being pointed at fades while another one is.
const double chartDimmedOpacity = 0.28;

// ---------------------------------------------------------------------------
// Colour
// ---------------------------------------------------------------------------

/// A [NebaColor] family as its accent, a [Color] as itself, and anything else
/// as `null`.
Color? chartResolveColor(Object? color, NebaTokens tokens) {
  if (color is NebaColor) {
    return tokens.roles(color).accent;
  }

  return color is Color ? color : null;
}

/// The colour of the series at [index] in the list it was passed in: its own
/// [NebaChartSeries.color], or the palette slot at that index.
///
/// The index is the series' place in that list and never its place among the
/// ones currently shown, so hiding a series from the legend never repaints
/// the others. Past the eighth slot the palette repeats, and
/// [chartWarnPaletteOverflow] says so.
Color chartSeriesColor(NebaChartSeries series, int index, NebaTokens tokens) {
  final List<Color> palette = tokens.chart.series;

  return chartResolveColor(series.color, tokens) ?? palette[index % palette.length];
}

/// The ink a value label wears beside its own mark: the mark's colour one step
/// toward the page's ink, which is what a series slot needs to clear 4.5:1 as
/// twelve-pixel text rather than 3:1 as a line.
Color chartLabelInk(Color color, NebaTokens tokens) => mixOklab(color, 0.85, tokens.fg);

final Set<int> _warnedCounts = <int>{};

/// Says so, once per count and only in a debug build, when a chart is given
/// more series than the palette has slots. Nothing in the picture tells a
/// reader that the ninth line is not the first one again.
void chartWarnPaletteOverflow(int count, int slots) {
  if (!kDebugMode || count <= slots || _warnedCounts.contains(count)) {
    return;
  }

  _warnedCounts.add(count);
  debugPrint(
    'Neba: a chart was given $count series and its palette has $slots colours, so the colours '
    'repeat from the ninth series. Fold the smallest into an "Other" series, or draw a second '
    'chart.',
  );
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

/// A datum unpacked into the shape the drawing reads.
@immutable
class NebaChartValue {
  /// A value of [value], `null` for a gap.
  const NebaChartValue({this.value, this.x, this.z, this.color, this.label});

  /// The value, `null` for a gap.
  final double? value;

  /// The point's own place on the category axis.
  final Object? x;

  /// The point's second magnitude.
  final double? z;

  /// The point's own colour, a [NebaColor] or a [Color].
  final Object? color;

  /// What the point says instead of its value.
  final String? label;

  /// A copy at [value], with everything else kept.
  NebaChartValue withValue(double? value, {String? label}) {
    return NebaChartValue(value: value, x: x, z: z, color: color, label: label ?? this.label);
  }
}

/// One datum, whichever way it was written: a [num], `null`, or a
/// [NebaChartPoint].
///
/// A number that is not finite is a gap here rather than at every call site:
/// it comes from a division somewhere upstream, it means what a gap means,
/// and a scale handed one draws nothing at all.
NebaChartValue chartValueOf(Object? datum) {
  if (datum is num) {
    return NebaChartValue(value: datum.isFinite ? datum.toDouble() : null);
  }

  if (datum is NebaChartPoint) {
    final double? y = datum.y;

    return NebaChartValue(
      value: y == null || !y.isFinite ? null : y,
      x: datum.x,
      z: datum.z,
      color: datum.color,
      label: datum.label,
    );
  }

  return const NebaChartValue();
}

/// Every series unpacked, in the order it was given.
List<List<NebaChartValue>> chartValuesOf(List<NebaChartSeries> series) {
  return <List<NebaChartValue>>[
    for (final NebaChartSeries one in series)
      <NebaChartValue>[for (final Object? datum in one.data) chartValueOf(datum)],
  ];
}

/// The same series with every gap read as a nought.
///
/// Done to the data and not to the drawing, so the picture, the scale, the
/// tooltip and the table under the chart all say the same thing.
List<NebaChartSeries> chartZeroGaps(List<NebaChartSeries> series) {
  Object zeroed(Object? datum) {
    if (datum is num) {
      return datum.isFinite ? datum : 0;
    }

    if (datum is NebaChartPoint) {
      final double? y = datum.y;

      return y == null || !y.isFinite
          ? NebaChartPoint(y: 0, x: datum.x, z: datum.z, color: datum.color, label: datum.label)
          : datum;
    }

    return 0;
  }

  return <NebaChartSeries>[
    for (final NebaChartSeries one in series)
      NebaChartSeries(
        data: <Object?>[for (final Object? datum in one.data) zeroed(datum)],
        name: one.name,
        color: one.color,
        hidden: one.hidden,
        axis: one.axis,
      ),
  ];
}

/// Every category renormalised to a hundred, for a chart stacked to full.
///
/// The total counts only the series still shown, so hiding one leaves the
/// rest filling the band, and the number the caller passed survives as the
/// point's label, written through [format], so the tooltip and the table can
/// still say it.
List<List<NebaChartValue>> chartFullShares(
  List<List<NebaChartValue>> values,
  List<bool> visible,
  String Function(double value) format,
) {
  final List<double> totals = <double>[];

  for (int index = 0; index < values.length; index++) {
    if (index < visible.length && !visible[index]) {
      continue;
    }

    final List<NebaChartValue> row = values[index];

    for (int category = 0; category < row.length; category++) {
      while (totals.length <= category) {
        totals.add(0);
      }

      totals[category] += (row[category].value ?? 0).abs();
    }
  }

  return <List<NebaChartValue>>[
    for (final List<NebaChartValue> row in values)
      <NebaChartValue>[
        for (int category = 0; category < row.length; category++)
          if (row[category].value case final double value)
            row[category].withValue(
              category >= totals.length || totals[category] == 0
                  ? 0
                  : value / totals[category] * 100,
              label: row[category].label ?? format(value),
            )
          else
            row[category],
      ],
  ];
}

/// How many categories the widest series has.
int chartCategoryCount(List<NebaChartSeries> series) {
  return series.fold<int>(0, (int most, NebaChartSeries one) => math.max(most, one.data.length));
}

/// What the category axis says at [index]: [categories] first, then the `x`
/// of the first series that gives one, then the index.
Object chartCategoryAt(int index, List<Object>? categories, List<List<NebaChartValue>> values) {
  if (categories != null && index < categories.length) {
    return categories[index];
  }

  for (final List<NebaChartValue> one in values) {
    final Object? found = index < one.length ? one[index].x : null;

    if (found != null) {
      return found;
    }
  }

  return index;
}

/// The lowest and the highest of the values, or `null` when every one of them
/// is a gap and there is nothing to measure.
///
/// A stack measures its totals rather than its parts, with the values above
/// zero and those below it summed apart, so a series that goes negative does
/// not shorten the column above it.
({double min, double max})? chartExtentOf(
  List<List<NebaChartValue>> values, {
  required bool stacked,
}) {
  double low = double.infinity;
  double high = double.negativeInfinity;
  bool seen = false;

  if (stacked) {
    final int length = values.fold<int>(
      0,
      (int most, List<NebaChartValue> one) => math.max(most, one.length),
    );

    for (int category = 0; category < length; category++) {
      double above = 0;
      double below = 0;

      for (final List<NebaChartValue> one in values) {
        final double? value = category < one.length ? one[category].value : null;

        if (value == null) {
          continue;
        }

        seen = true;

        if (value >= 0) {
          above += value;
        } else {
          below += value;
        }
      }

      low = math.min(low, below);
      high = math.max(high, above);
    }
  } else {
    for (final List<NebaChartValue> one in values) {
      for (final NebaChartValue entry in one) {
        final double? value = entry.value;

        if (value == null) {
          continue;
        }

        seen = true;
        low = math.min(low, value);
        high = math.max(high, value);
      }
    }
  }

  return seen ? (min: low, max: high) : null;
}

/// A whole number as an [int] and anything else as itself, so a caller's
/// `'$value%'` writes `100%` rather than `100.0%`, as a script writes it.
num chartNumber(double value) {
  return value.isFinite && value == value.roundToDouble() && value.abs() < 1e15
      ? value.toInt()
      : value;
}

/// How a category is written when nobody said: a [DateTime] as its month and
/// day, a [num] as a script writes it, and anything else as it is.
String chartCategoryText(Object category) {
  if (category is DateTime) {
    return nebaFormatMonthDay(category);
  }

  if (category is num) {
    return chartNumber(category.toDouble()).toString();
  }

  return category.toString();
}

// ---------------------------------------------------------------------------
// Ticks
// ---------------------------------------------------------------------------

/// The power of ten at or below [value], found without the rounding error a
/// logarithm divided by `ln 10` carries: that is `2.9999999999999996` for a
/// thousand.
int _magnitude(double value) {
  int power = (math.log(value) / math.ln10).floor();

  if (math.pow(10, power + 1) <= value) {
    power += 1;
  } else if (math.pow(10, power) > value) {
    power -= 1;
  }

  return power;
}

/// 1, 2, 5, 10: the steps a reader can do arithmetic on in their head.
double _niceStep(double rough) {
  final double magnitude = math.pow(10, _magnitude(rough)).toDouble();
  final double normalised = rough / magnitude;

  if (normalised <= 1) {
    return magnitude;
  }

  if (normalised <= 2) {
    return 2 * magnitude;
  }

  if (normalised <= 5) {
    return 5 * magnitude;
  }

  return 10 * magnitude;
}

/// A step that lands on both ends of a range the caller pinned, from the 1, 2,
/// 2.5 and 5 family, closest to [tickCount] intervals. With both ends fixed
/// the step is what has to give, or the top tick is the one left unwritten.
double _dividingStep(double range, int tickCount) {
  final int count = math.max(1, tickCount);
  final double magnitude = math.pow(10, _magnitude(range / count)).toDouble();
  double best = _niceStep(range / count);
  double closest = double.infinity;

  for (final double scale in <double>[0.1, 1, 10]) {
    for (final double unit in <double>[1, 2, 2.5, 5]) {
      final double step = unit * scale * magnitude;
      final double intervals = range / step;
      final int whole = intervals.round();

      // The tolerance is a floating-point guard: 0.5 / 0.1 is
      // 4.999999999999999.
      if (whole < 1 || (intervals - whole).abs() > 1e-9) {
        continue;
      }

      final double distance = (whole - count).abs().toDouble();

      if (distance < closest) {
        closest = distance;
        best = step;
      }
    }
  }

  return best;
}

/// [value] rounded to twelve places, so a tick never prints as
/// `0.30000000000000004`.
double _clean(double value) => double.parse(value.toStringAsFixed(12));

/// A value scale: where it starts, where it ends, and what it ticks at.
@immutable
class NebaChartScale {
  /// A scale from [min] to [max] with [ticks].
  const NebaChartScale({required this.min, required this.max, required this.ticks});

  /// Where it starts.
  final double min;

  /// Where it ends.
  final double max;

  /// The values it is labelled at.
  final List<double> ticks;

  /// [value] as a fraction of the scale: `0` at [min] and `1` at [max].
  double fraction(double value) {
    final double span = max - min;

    return (value - min) / (span == 0 ? 1 : span);
  }
}

/// Where a value axis runs before it is rounded: the data or the pinned ends,
/// with zero taken in and a flat series opened into a band.
({double low, double high}) _valueRange(
  ({double min, double max})? extent, {
  double? min,
  double? max,
  bool includeZero = true,
}) {
  double low = min ?? extent?.min ?? 0;
  double high = max ?? extent?.max ?? 1;

  if (includeZero && min == null) {
    low = math.min(low, 0);
  }

  if (includeZero && max == null) {
    high = math.max(high, 0);
  }

  // A flat series has no extent to divide by. With one end pinned the band
  // opens past it, which also takes a series that lies wholly on the far side
  // of that end.
  final bool minPinned = min != null && max == null;
  final bool maxPinned = max != null && min == null;

  if (high <= low && (minPinned || maxPinned)) {
    final double anchor = minPinned ? low : high;
    final double band = anchor.abs() > 0 ? anchor.abs() : 2;

    if (minPinned) {
      high = low + band;
    } else {
      low = high - band;
    }
  } else if (high == low) {
    final double pad = high.abs() > 0 ? high.abs() * 0.5 : 1;

    low -= pad;
    high += pad;
  }

  return (low: low, high: high);
}

/// The scale a value axis runs on, rounded outward to clean numbers.
///
/// Outward is the part that matters: a maximum of 4,830 becomes 5,000, so the
/// top tick is a number and the tallest mark stops short of the frame. Zero
/// is taken in unless [includeZero] is off, because a bar's length is only
/// proportional to its value from a baseline of zero; a line crops.
NebaChartScale chartValueScale(
  ({double min, double max})? extent, {
  double? min,
  double? max,
  int? tickCount,
  bool includeZero = true,
}) {
  final int count = tickCount ?? 5;
  final ({double low, double high}) range = _valueRange(
    extent,
    min: min,
    max: max,
    includeZero: includeZero,
  );
  final double low = range.low;
  final double high = range.high;
  final bool pinned = min != null && max != null;
  final double step = pinned
      ? _dividingStep(high - low, count)
      : _niceStep((high - low) / math.max(1, count));
  // The same guard on the ends: `2.4 / 0.2` is 11.999999999999998, which
  // would floor to a step below the data.
  final double start = min != null ? low : _clean((low / step + 1e-9).floorToDouble() * step);
  final double end = max != null ? high : _clean((high / step - 1e-9).ceilToDouble() * step);
  final List<double> ticks = <double>[];

  // Counted rather than added up, so the error of a step that is not a power
  // of two does not pile up from one tick to the next.
  for (int index = 0; start + index * step <= end + step * 1e-9; index++) {
    ticks.add(_clean(start + index * step));
  }

  return NebaChartScale(min: start, max: end, ticks: ticks);
}

/// A second value axis' scale, cut into exactly [intervals] steps so each of
/// its ticks sits on one of the first axis' gridlines.
///
/// The count is the fixed thing and the step gives: the smallest 1-2-5 step
/// whose run of intervals, started on a multiple of itself, still covers the
/// data. Both ends pinned leaves nothing to round.
NebaChartScale chartAlignedScale(
  ({double min, double max})? extent,
  int intervals, {
  double? min,
  double? max,
  bool includeZero = true,
}) {
  final int count = math.max(1, intervals);
  final ({double low, double high}) range = _valueRange(
    extent,
    min: min,
    max: max,
    includeZero: includeZero,
  );
  final double low = range.low;
  final double high = range.high;
  double step = _niceStep((high - low) / count);
  double start;

  if (min != null && max != null) {
    step = (high - low) / count;
    start = low;
  } else if (max != null) {
    start = high - count * step;
  } else if (min != null) {
    start = low;
  } else {
    start = (low / step + 1e-9).floorToDouble() * step;

    // A run started below the data may stop short of its top; the next step
    // up covers more, and one of them always covers it all.
    while (start + count * step < high - step * 1e-9) {
      step = _niceStep(step * 1.000001);
      start = (low / step + 1e-9).floorToDouble() * step;
    }
  }

  final List<double> ticks = <double>[
    for (int index = 0; index <= count; index++) _clean(start + index * step),
  ];

  return NebaChartScale(min: ticks.first, max: ticks.last, ticks: ticks);
}

/// Every how many category labels one is written, so the labels clear each
/// other at [labelWidth] along [available] pixels. Never zero.
int chartTickStride(int count, double available, double labelWidth) {
  if (count <= 1 || available <= 0) {
    return 1;
  }

  final int fits = math.max(1, (available / math.max(1, labelWidth)).floor());

  return math.max(1, (count / fits).ceil());
}

/// Whether the label at [index] survives the stride: every [stride]th, and the
/// last one when [roomForLast] says it clears the one before it.
bool chartShowsTick(int index, int count, int stride, {required bool roomForLast}) {
  return index % stride == 0 || (roomForLast && index == count - 1);
}

/// Whether the last label clears the last one the stride kept, [step] pixels
/// apart per category.
bool chartFitsLast(int count, int stride, double step, double labelWidth) {
  final int over = (count - 1) % stride;

  return over > 0 && over * step >= labelWidth + 8;
}

/// Whether [rune] is a character drawn about a full em wide: Hangul, CJK and
/// the forms around them.
bool _isWide(int rune) {
  return (rune >= 0x1100 && rune <= 0x11FF) ||
      (rune >= 0x2E80 && rune <= 0xA4CF) ||
      (rune >= 0xAC00 && rune <= 0xD7FF) ||
      (rune >= 0xF900 && rune <= 0xFAFF) ||
      (rune >= 0xFE30 && rune <= 0xFE4F);
}

/// Roughly how wide [text] renders at [fontSize].
///
/// An estimate on purpose, as it is in the React package: what it decides is
/// how much room to reserve and how many labels fit, where a few pixels
/// generous costs nothing, and the two packages make the same decisions from
/// the same numbers. 0.6 of an em is the average advance of a digit in a UI
/// sans-serif; a CJK character is close to a whole one.
double chartTextWidth(String text, double fontSize) {
  double width = 0;

  for (final int rune in text.runes) {
    width += _isWide(rune) ? 1 : 0.6;
  }

  return width * fontSize;
}

/// [text] cut to [maxWidth] with an ellipsis, by the estimate in
/// [chartTextWidth]. A label that fits, or a width of none, is left alone.
String chartTruncate(String text, double maxWidth, double fontSize) {
  if (maxWidth <= 0 || chartTextWidth(text, fontSize) <= maxWidth) {
    return text;
  }

  final double room = maxWidth - chartTextWidth('…', fontSize);
  final StringBuffer cut = StringBuffer();
  double width = 0;

  for (final int rune in text.runes) {
    final double next = width + (_isWide(rune) ? 1 : 0.6) * fontSize;

    if (next > room) {
      break;
    }

    width = next;
    cut.writeCharCode(rune);
  }

  return cut.isEmpty ? '…' : '${cut.toString().trimRight()}…';
}

/// What an axis' labels measure once they are turned by a `tickAngle`.
///
/// Flat, a label needs its own width along the axis, so a long name means
/// fewer labels. Turned, two neighbours only have to clear each other across
/// the text, `fontSize / sin`, which no longer depends on how long the name
/// is: that is why turning them fits more of them in.
@immutable
class NebaChartTurn {
  const NebaChartTurn._({
    required this.angle,
    required double fontSize,
    required double sin,
    required double cos,
  }) : _fontSize = fontSize,
       _sin = sin,
       _cos = cos;

  /// The angle, held to a quarter turn either way. `0` is flat.
  final double angle;

  final double _fontSize;
  final double _sin;
  final double _cos;

  /// Whether the labels are turned at all.
  bool get tilted => angle != 0;

  /// How deep the band of labels runs, for a widest label of [widest] pixels.
  double depth(double widest) {
    return tilted ? widest * _sin + _fontSize * _cos : _fontSize;
  }

  /// How much of the axis one label takes, so two of them clear.
  double room(double widest) {
    // Guarded, because a label barely off the horizontal would otherwise ask
    // for the whole axis and leave one name on it.
    return tilted ? _fontSize / math.max(0.2, _sin) + 4 : math.max(widest, 1) + 12;
  }

  /// The widest a label may render before the band runs past [depth] pixels.
  double cut(double depth) {
    return tilted ? math.max(0, (depth - _fontSize * _cos) / math.max(0.05, _sin)) : depth;
  }

  /// How far below the axis a label is pinned: under its baseline flat, by
  /// the middle of the type turned.
  double get offset => tilted ? 8 + _fontSize / 2 * _cos : _fontSize + 6;

  /// How far a label hangs past its own tick, along the axis.
  double overhang(double widest) => tilted ? widest * _cos : widest / 2;

  /// Which end of a label sits on its tick: `-1` its end, `0` its middle and
  /// `1` its start.
  int get anchor => !tilted ? 0 : (angle < 0 ? -1 : 1);
}

/// The turn of an axis whose labels are set at [fontSize] and turned by
/// [angle] degrees.
NebaChartTurn chartTurnedAxis(double angle, double fontSize) {
  final double turn = angle.clamp(-90, 90).toDouble();
  final double radians = turn.abs() * math.pi / 180;

  return NebaChartTurn._(
    angle: turn,
    fontSize: fontSize,
    sin: math.sin(radians),
    cos: math.cos(radians),
  );
}

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

/// A band scale: one slot per category, with the marks centred in it.
@immutable
class NebaChartBand {
  /// [count] slots along [length], whose marks take [ratio] of each.
  factory NebaChartBand(int count, double length, double ratio) {
    final double step = count > 0 ? length / count : length;

    return NebaChartBand._(step, step * ratio);
  }

  const NebaChartBand._(this.step, this.band);

  /// How wide one slot is.
  final double step;

  /// How wide the marks in a slot are allowed to be, together.
  final double band;

  /// The centre of category [index], along the axis.
  double centre(int index) => step * (index + 0.5);
}

/// Adds the run of [points] to [path] in [curve]: from a `moveTo` at its first
/// point, or a `lineTo` it when [join] says the run continues the path.
void _addRun(Path path, List<Offset> points, NebaChartCurve curve, {bool join = false}) {
  final Offset first = points.first;

  if (join) {
    path.lineTo(first.dx, first.dy);
  } else {
    path.moveTo(first.dx, first.dy);
  }

  if (curve == NebaChartCurve.step) {
    for (int index = 1; index < points.length; index++) {
      final Offset before = points[index - 1];
      final Offset point = points[index];
      final double middle = (before.dx + point.dx) / 2;

      path
        ..lineTo(middle, before.dy)
        ..lineTo(middle, point.dy)
        ..lineTo(point.dx, point.dy);
    }
  } else if (curve == NebaChartCurve.smooth && points.length > 2) {
    _addMonotone(path, points);
  } else {
    for (int index = 1; index < points.length; index++) {
      path.lineTo(points[index].dx, points[index].dy);
    }
  }
}

/// The cubic segments of a monotone interpolation through [points].
///
/// Fritsch–Carlson: the tangent at each point is the harmonic mean of the
/// slopes either side of it, and zero wherever they disagree in sign. That
/// clamp is what makes the curve monotone, so a minimum in the data is the
/// minimum on screen.
void _addMonotone(Path path, List<Offset> points) {
  final int count = points.length;
  final List<double> slopes = <double>[
    for (int index = 0; index < count - 1; index++)
      points[index + 1].dx == points[index].dx
          ? 0
          : (points[index + 1].dy - points[index].dy) / (points[index + 1].dx - points[index].dx),
  ];
  final List<double> tangents = <double>[
    slopes.first,
    for (int index = 1; index < count - 1; index++)
      slopes[index - 1] * slopes[index] <= 0
          ? 0
          : 2 * slopes[index - 1] * slopes[index] / (slopes[index - 1] + slopes[index]),
    slopes.last,
  ];

  for (int index = 0; index < count - 1; index++) {
    final Offset from = points[index];
    final Offset to = points[index + 1];
    final double third = (to.dx - from.dx) / 3;

    path.cubicTo(
      from.dx + third,
      from.dy + tangents[index] * third,
      to.dx - third,
      to.dy - tangents[index + 1] * third,
      to.dx,
      to.dy,
    );
  }
}

/// The runs of [points] between its gaps.
List<List<Offset>> _runsOf(List<Offset?> points) {
  final List<List<Offset>> runs = <List<Offset>>[];
  List<Offset> run = <Offset>[];

  for (final Offset? point in points) {
    if (point == null) {
      if (run.isNotEmpty) {
        runs.add(run);
        run = <Offset>[];
      }
    } else {
      run.add(point);
    }
  }

  if (run.isNotEmpty) {
    runs.add(run);
  }

  return runs;
}

/// A line through [points] in [curve], broken at every `null`.
///
/// A gap starts a new subpath rather than being bridged: a line across a
/// missing month invents a number. A lone point between two gaps is a
/// segment a hundredth of a pixel long, which a round cap draws as the dot it
/// is.
Path chartLinePath(List<Offset?> points, NebaChartCurve curve) {
  final Path path = Path();

  for (final List<Offset> run in _runsOf(points)) {
    if (run.length == 1) {
      path
        ..moveTo(run.first.dx, run.first.dy)
        ..lineTo(run.first.dx + 0.01, run.first.dy);
    } else {
      _addRun(path, run, curve);
    }
  }

  return path;
}

/// The same line closed down to [floor], one point under each of [points], or
/// to the height [baseline] when there is no floor, for an area.
///
/// Built run by run, so a gap in the line is a gap in the fill too. The
/// underside runs back the other way in the same curve, or a smoothed band and
/// its own floor disagree about where the band is between two points.
Path chartAreaPath(
  List<Offset?> points,
  NebaChartCurve curve, {
  List<Offset?>? floor,
  double baseline = 0,
}) {
  final Path path = Path();
  int start = 0;

  void flush(int end) {
    final List<Offset> run = <Offset>[for (int index = start; index < end; index++) ?points[index]];

    if (run.isEmpty) {
      return;
    }

    final List<Offset> under = floor == null
        ? <Offset>[for (final Offset point in run.reversed) Offset(point.dx, baseline)]
        : <Offset>[
            for (int index = end - 1; index >= start; index--)
              if (index < floor.length) ?floor[index],
          ];

    if (under.isEmpty) {
      return;
    }

    _addRun(path, run, curve);
    _addRun(path, under, curve, join: true);
    path.close();
  }

  for (int index = 0; index < points.length; index++) {
    if (points[index] == null) {
      flush(index);
      start = index + 1;
    }
  }

  flush(points.length);

  return path;
}

/// Which way a bar's value grows, and so which end of it is rounded.
enum NebaChartBarEnd {
  /// Up the plot.
  up,

  /// Down the plot.
  down,

  /// Along it to the right.
  right,

  /// Along it to the left.
  left,
}

/// A bar with the two corners at its data end rounded by [radius], shrunk to
/// fit so a bar two pixels tall is still a bar, and square where it meets the
/// baseline.
Path chartBarPath(Rect rect, double radius, NebaChartBarEnd end) {
  final double r = math.max(0, math.min(radius, math.min(rect.width / 2, rect.height / 2)));

  if (r == 0 || rect.width <= 0 || rect.height <= 0) {
    return Path()..addRect(rect);
  }

  final Radius corner = Radius.circular(r);

  return Path()..addRRect(switch (end) {
    NebaChartBarEnd.up => RRect.fromRectAndCorners(rect, topLeft: corner, topRight: corner),
    NebaChartBarEnd.down => RRect.fromRectAndCorners(rect, bottomLeft: corner, bottomRight: corner),
    NebaChartBarEnd.right => RRect.fromRectAndCorners(rect, topRight: corner, bottomRight: corner),
    NebaChartBarEnd.left => RRect.fromRectAndCorners(rect, topLeft: corner, bottomLeft: corner),
  });
}

/// Which points of [one] get a value label, decided once for the whole series
/// rather than asked per point.
bool Function(int index) chartLabelledPoints(
  List<NebaChartValue> one,
  NebaChartValueLabels valueLabels,
) {
  switch (valueLabels) {
    case NebaChartValueLabels.none:
      return (int index) => false;
    case NebaChartValueLabels.all:
      return (int index) => true;
    case NebaChartValueLabels.last:
      int last = -1;

      for (int index = one.length - 1; index >= 0; index--) {
        if (one[index].value != null) {
          last = index;
          break;
        }
      }

      return (int index) => index == last;
    case NebaChartValueLabels.extremes:
      double low = double.infinity;
      double high = double.negativeInfinity;

      for (final NebaChartValue entry in one) {
        final double? value = entry.value;

        if (value != null) {
          low = math.min(low, value);
          high = math.max(high, value);
        }
      }

      return (int index) {
        final double? value = one[index].value;

        return value != null && (value == low || value == high);
      };
  }
}
