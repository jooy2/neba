/// `NebaPieChart`, parts of a whole as slices of a circle.
library;

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a [NebaPieChart] is drawn as.
enum NebaPieShape {
  /// A filled disc.
  pie,

  /// A ring, with room in the middle for the total.
  donut,

  /// Half a ring, opened along the bottom: for a tile that is wider than it
  /// is tall.
  semi,
}

/// How much of the middle is cut out, per shape, when `hole` says nothing.
const Map<NebaPieShape, double> _holes = <NebaPieShape, double>{
  NebaPieShape.pie: 0,
  NebaPieShape.donut: 0.62,
  NebaPieShape.semi: 0.62,
};

/// As far as the hole may be opened: past this the chart has stopped being a
/// picture of shares and become a border.
const double _widestHole = 0.92;

/// How far a slice the reader is not reading fades.
const double _dimmed = 0.32;

/// Parts of a whole, at a glance.
///
/// The narrowest chart in the library and the easiest one to misuse. An angle
/// is a poor thing to compare: two slices within a few percent of each other
/// are indistinguishable, and a reader cannot rank six of them. So a pie is
/// right for one question, whether one of these is most of it. Anything finer
/// than that, and anything past six slices, is a `NebaBarChart`.
///
/// A slice's colour follows its place in [data], so a filter that drops one
/// moves every slice after it onto the next colour; a point's own `color`
/// holds it.
///
/// ```dart
/// const NebaPieChart(
///   label: 'Sessions by traffic source',
///   shape: NebaPieShape.donut,
///   categories: <Object>['Organic', 'Direct', 'Paid'],
///   data: <num>[18420, 9260, 6140],
/// )
/// ```
class NebaPieChart extends StatefulWidget {
  /// A pie of [data].
  const NebaPieChart({
    required this.data,
    this.categories,
    this.shape = NebaPieShape.pie,
    this.startAngle = 0,
    this.hole,
    this.gap = chartMarkGap,
    this.center,
    this.valueLabels = NebaChartValueLabels.none,
    this.height,
    this.format,
    this.locale,
    this.label,
    this.legend,
    this.tooltip,
    this.empty,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.padded = false,
    this.transition,
    super.key,
  }) : assert(legend == null || legend is bool || legend is NebaChartLegend),
       assert(tooltip == null || tooltip is bool || tooltip is NebaChartTooltip),
       assert(valueLabels == NebaChartValueLabels.none || valueLabels == NebaChartValueLabels.all);

  /// The slices: each a [num], `null` for a slice with no value, or a
  /// [NebaChartPoint] that carries its own name and colour.
  ///
  /// One series and not a list of them, because that is what a pie is: the
  /// slices are the entities here, so each takes a palette slot of its own and
  /// the legend lists them.
  final List<Object?> data;

  /// What each slice is called: a [String], a [num] or a [DateTime]. Points
  /// may carry their own `x` instead.
  final List<Object>? categories;

  /// A filled disc, a ring or half a ring.
  final NebaPieShape shape;

  /// Where the first slice starts, in degrees clockwise from twelve o'clock.
  /// Ignored by [NebaPieShape.semi], which is defined by where it opens.
  final double startAngle;

  /// How much of the middle is cut out, as a fraction of the radius, from `0`
  /// for a filled disc to `0.92` for a hairline ring. [shape] sets it when
  /// left out: `0` for a pie and `0.62` for a donut and a semi.
  final double? hole;

  /// The surface showing between two touching slices, in logical pixels: a
  /// constant on screen, so it is the same width on a small pie as on a large
  /// one. `0` closes it, and it is never taken off a slice too narrow to spare
  /// it.
  final double gap;

  /// What goes in the hole: the total, or the one figure the chart is about.
  final Widget? center;

  /// [NebaChartValueLabels.all] writes each slice's share on it, where the
  /// slice is wide enough for the text; [NebaChartValueLabels.none], the
  /// default, writes nothing. The other two do not apply to a pie.
  final NebaChartValueLabels valueLabels;

  /// How tall the drawing is. The size ladder when left out: 120, 160, 220,
  /// 280 and 360 logical pixels.
  final double? height;

  /// How a number is written in the tooltip, the legend and the table.
  /// Without it, past ten thousand a number is compacted (`12.4K`).
  final String Function(num value)? format;

  /// The language of the chart's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartLegend]. Shown from two slices up when
  /// left out, interactive: pressing a slice's entry takes it out and the
  /// rest fill the circle.
  final Object? legend;

  /// `true`, `false` or a [NebaChartTooltip].
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type and the height. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet and the focus ring. A slice's colour does not
  /// come from here.
  final NebaColor color;

  /// How much padding the sheet has.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads the chart.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  @override
  State<NebaPieChart> createState() => _NebaPieChartState();
}

/// One slice that is drawn: its place in `data`, where it starts and ends in
/// degrees clockwise from twelve o'clock, and its share of the whole.
typedef _Arc = ({int index, double start, double end, double share});

/// Where the pie sits in its box.
typedef _Disc = ({Offset centre, double outer, double inner});

class _NebaPieChartState extends State<NebaPieChart> with SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode(debugLabel: 'NebaPieChart');
  final GlobalKey _plotKey = GlobalKey();
  late final NebaChartEmphasis _emphasis = NebaChartEmphasis(vsync: this);
  late final NebaChartPressOutside _outside = NebaChartPressOutside(
    plot: _plotKey,
    onPress: _clear,
  );
  final NebaChartVisibility _visibility = NebaChartVisibility();

  int? _active;
  int? _legendHover;
  bool _focused = false;

  // What the last build laid out, which the pointer is read against.
  List<_Arc> _arcs = const <_Arc>[];
  _Disc? _disc;
  double _pad = 0;

  Widget? _table;
  Object? _tableKey;

  @override
  void didUpdateWidget(NebaPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data.length != widget.data.length) {
      _legendHover = null;

      if ((_active ?? -1) >= widget.data.length) {
        _active = null;
        _outside.watch(false);
      }

      _emphasise();
    }
  }

  @override
  void dispose() {
    _outside.dispose();
    _focus.dispose();
    _emphasis.dispose();
    super.dispose();
  }

  bool get _tooltipOff => chartTooltipMode(widget.tooltip) == NebaChartTooltipMode.none;

  void _setActive(int? index) {
    if (index == _active) {
      return;
    }

    setState(() => _active = index);
    _emphasise();
    _outside.watch(index != null);
  }

  void _clear() => _setActive(null);

  void _hoverLegend(int? index) {
    if (index == _legendHover) {
      return;
    }

    setState(() => _legendHover = index);
    _emphasise();
  }

  /// A slice fades while the legend points at another one, and while another
  /// one is being read.
  void _emphasise() {
    if (!mounted) {
      return;
    }

    final int? hovered = _legendHover;
    final int? active = _active;

    _emphasis.retarget(
      opacity: <double>[
        for (int index = 0; index < widget.data.length; index++)
          (hovered != null && hovered != index) || (active != null && active != index)
              ? _dimmed
              : 1,
      ],
      active: null,
      duration: nebaDuration(context, NebaScale.duration),
    );
  }

  /// The slice under [local], or `null` over the hole, the gaps and the air
  /// around the pie.
  int? _sliceAt(Offset local) {
    final _Disc? disc = _disc;

    if (disc == null) {
      return null;
    }

    final Offset from = local - disc.centre;
    final double distance = from.distance;

    if (distance > disc.outer || distance < disc.inner) {
      return null;
    }

    final double degrees = math.atan2(from.dy, from.dx) * 180 / math.pi + 90;

    for (final _Arc arc in _arcs) {
      final double room = _room(arc);
      final double into = ((degrees - arc.start - room) % 360 + 360) % 360;

      if (into <= arc.end - arc.start - room * 2) {
        return arc.index;
      }
    }

    return null;
  }

  /// How much of the gap comes off each end of [arc]: none off a slice
  /// narrower than two of it, or a sliver would turn inside out, and none off
  /// a slice that is alone, which has nothing to be parted from.
  double _room(_Arc arc) {
    return _arcs.length > 1 && arc.end - arc.start > _pad * 2 ? _pad / 2 : 0;
  }

  void _point(Offset local) {
    if (_tooltipOff) {
      return;
    }

    // Moving off a slice into a gap or the hole keeps the one being read: a
    // reading changes when the pointer reaches another slice.
    final int? slice = _sliceAt(local);

    if (slice != null) {
      _setActive(slice);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final List<int> order = <int>[for (final _Arc arc in _arcs) arc.index];
    final int? active = _active;

    if (key == LogicalKeyboardKey.escape) {
      // Only a reading is dismissed; with none, Escape belongs to whatever
      // the chart sits in.
      if (active == null) {
        return KeyEventResult.ignored;
      }

      _clear();

      return KeyEventResult.handled;
    }

    // With the tooltip off there is no reading to move through.
    if (_tooltipOff || order.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.home) {
      _setActive(order.first);
    } else if (key == LogicalKeyboardKey.end) {
      _setActive(order.last);
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowLeft) {
      final int at = active == null ? -1 : order.indexOf(active);
      final int next = key == LogicalKeyboardKey.arrowRight ? at + 1 : at - 1;

      _setActive(order[(next + order.length) % order.length]);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  Widget _tableFor(
    List<NebaChartSeries> slices,
    List<NebaChartValue> values,
    String Function(double value) format,
  ) {
    final Object key = (widget.data, widget.categories, widget.label, widget.format);
    final Widget? cached = _table;

    if (cached != null && key == _tableKey) {
      return cached;
    }

    final Widget table = NebaChartDataTable(
      caption: widget.label,
      columns: <String>['', widget.label ?? '1'],
      points: values.length,
      rows: <List<String>>[
        for (int index = 0; index < slices.length; index++)
          <String>[
            slices[index].name ?? '',
            values[index].label ??
                switch (values[index].value) {
                  final double value => format(value),
                  null => '',
                },
          ],
      ],
    );

    _table = table;
    _tableKey = key;

    return table;
  }

  @override
  Widget build(BuildContext context) {
    final NebaPieChart widget = this.widget;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final Map<String, String> words = nebaMessages(context, 'chart', locale: widget.locale);
    final String Function(num value)? own = widget.format;
    final String Function(double value) format = own == null
        ? nebaFormatCompact
        : (double value) => own(chartNumber(value));
    final List<NebaChartValue> values = <NebaChartValue>[
      for (final Object? datum in widget.data) chartValueOf(datum),
    ];

    // A pie's slices are what the legend, the visibility and the palette are
    // keyed on, so each is a series of one value here: everywhere else in the
    // library the thing that takes a colour and a legend row is a series, and
    // a slice is playing exactly that part.
    final List<NebaChartSeries> slices = <NebaChartSeries>[
      for (int index = 0; index < values.length; index++)
        NebaChartSeries(
          name: chartCategoryText(
            chartCategoryAt(index, widget.categories, <List<NebaChartValue>>[values]),
          ),
          data: <Object?>[widget.data[index]],
          color: values[index].color,
        ),
    ];
    final List<bool> visible = _visibility.visibleOf(slices);
    final List<Color> colors = <Color>[
      for (int index = 0; index < slices.length; index++)
        chartSeriesColor(slices[index], index, tokens),
    ];

    chartWarnPaletteOverflow(slices.length, tokens.chart.series.length);

    // A negative has no share of a whole to be: it stays in the table and the
    // legend and takes nothing from the total.
    double total = 0;

    for (int index = 0; index < values.length; index++) {
      final double? value = values[index].value;

      if (visible[index] && value != null) {
        total += math.max(0, value);
      }
    }

    final bool semi = widget.shape == NebaPieShape.semi;
    final double plotHeight = widget.height ?? chartPlotHeights[size]!;
    final double fontSize = MediaQuery.textScalerOf(context).scale(chartFontSizes[size]!);
    final double holeFraction = (widget.hole ?? _holes[widget.shape]!)
        .clamp(0, _widestHole)
        .toDouble();
    // A semicircle takes the whole height as its radius, since it draws only
    // the top half of the circle.
    final bool nothing = total <= 0 || (semi ? plotHeight : plotHeight / 2) - 2 <= 0;
    final double sweep = semi ? 180 : 360;
    final List<_Arc> arcs = <_Arc>[];
    double angle = semi ? -90 : widget.startAngle;

    // In the order they were given, never sorted.
    for (int index = 0; index < values.length; index++) {
      final double value = values[index].value ?? 0;

      if (!visible[index] || value <= 0) {
        continue;
      }

      final double share = value / total;

      arcs.add((index: index, start: angle, end: angle + share * sweep, share: share));
      angle += share * sweep;
    }

    _arcs = arcs;

    final int? active = _active;
    final double? reading = active == null ? null : values[active].value;
    final List<NebaChartTooltipItem> items = active == null || reading == null
        ? const <NebaChartTooltipItem>[]
        : <NebaChartTooltipItem>[
            NebaChartTooltipItem(
              seriesIndex: active,
              name: slices[active].name,
              color: colors[active],
              value: reading,
              formatted:
                  '${format(reading)} · '
                  '${chartNumber((math.max(0, reading) / total * 100 * 10).round() / 10)}%',
              label: values[active].label,
            ),
          ];
    final String? heading = active == null ? null : slices[active].name;

    final Object? legend = widget.legend;
    final NebaChartLegend legendOptions = chartLegendOptions(legend);
    final Widget? legendBar = legend != false && slices.length > 1
        ? NebaChartLegendBar(
            names: <String>[for (final NebaChartSeries slice in slices) slice.name ?? ''],
            colors: colors,
            visible: visible,
            hovered: _legendHover,
            options: legendOptions,
            size: size,
            color: widget.color,
            onToggle: (int index) => setState(() => _visibility.toggle(slices, index)),
            onHover: _hoverLegend,
            values: legendOptions.showValue
                ? <String?>[
                    for (final NebaChartValue one in values)
                      switch (one.value) {
                        final double value => format(value),
                        null => null,
                      },
                  ]
                : null,
          )
        : null;

    final NebaChartTooltip options = chartTooltipOptions(widget.tooltip);

    final Widget plot = NebaChartBox(
      key: _plotKey,
      height: plotHeight,
      builder: (BuildContext context, double width) {
        final double outer = math.max(
          0,
          math.min(width / 2, semi ? plotHeight : plotHeight / 2) - 2,
        );

        if (nothing || outer <= 0) {
          _disc = null;

          return NebaChartEmpty(empty: widget.empty, size: size, locale: widget.locale);
        }

        // A semicircle's centre sits half a radius below the middle of the
        // box, which puts the arc itself in the middle: pinned to the bottom
        // edge, a wide card would draw a thin band with an empty half above.
        final Offset centre = Offset(
          width / 2,
          semi ? math.min(plotHeight, plotHeight / 2 + outer / 2) : plotHeight / 2,
        );
        final double inner = outer * holeFraction;

        _disc = (centre: centre, outer: outer, inner: inner);
        // The gap as the angle it subtends at the rim, so it is a constant on
        // screen rather than in the data, and capped: past about fifteen
        // degrees a gap is eating the data rather than parting it.
        _pad = math.min(15, math.max(0, widget.gap) / outer * 180 / math.pi);

        final TextStyle labelStyle = DefaultTextStyle.of(context).style.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          height: 1.2,
        );
        final List<NebaChartLabel> labels = <NebaChartLabel>[];

        if (widget.valueLabels == NebaChartValueLabels.all) {
          final double radius = inner > 0 ? (inner + outer) / 2 : outer * 0.68;

          for (final _Arc arc in _arcs) {
            // Measured before it is placed: a label wider than its slice is
            // dropped, never clipped and never spilled over its neighbour.
            final double room = (arc.end - arc.start) * math.pi / 180 * radius;

            if (room < fontSize * 2 || outer - inner < fontSize * 1.6) {
              continue;
            }

            labels.add(
              NebaChartLabel(
                chartTextPainter(
                  '${(arc.share * 100).round()}%',
                  // Inside a filled mark, chosen by the fill: white on every
                  // slice would vanish on the pale ones.
                  labelStyle.copyWith(
                    color: chartInkOn(values[arc.index].color, arc.index, tokens),
                  ),
                  Directionality.of(context),
                ),
                chartPolar(centre, radius, (arc.start + arc.end) / 2),
                central: true,
              ),
            );
          }
        }

        final Widget? center = widget.center;
        final Widget Function(BuildContext context, NebaChartTooltipContext reading)? builder =
            options.builder;
        final List<Widget> layers = <Widget>[
          CustomPaint(
            size: Size(width, plotHeight),
            painter: _PiePainter(
              slices: <({int index, Path path, Color color})>[
                for (final _Arc arc in _arcs)
                  (
                    index: arc.index,
                    path: chartArcPath(
                      centre,
                      outer,
                      inner,
                      arc.start + _room(arc),
                      arc.end - _room(arc),
                    ),
                    color: colors[arc.index],
                  ),
              ],
              labels: labels,
              emphasis: _emphasis,
            ),
          ),
          if (center != null && inner > 0)
            Positioned(
              left: centre.dx - inner,
              top: centre.dy - inner,
              width: inner * 2,
              height: semi ? inner : inner * 2,
              child: IgnorePointer(
                child: Center(
                  child: DefaultTextStyle.merge(textAlign: TextAlign.center, child: center),
                ),
              ),
            ),
          if (active != null && items.isNotEmpty && !_tooltipOff)
            if (builder != null)
              Positioned(
                left: width / 2,
                top: 0,
                child: IgnorePointer(
                  child: builder(
                    context,
                    NebaChartTooltipContext(
                      index: active,
                      category: slices[active].name ?? active,
                      items: items,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: centre.dx + 10,
                top: 8,
                child: NebaChartTooltipPanel(
                  heading: heading ?? '',
                  items: items,
                  size: size,
                  color: widget.color,
                ),
              ),
        ];

        return Stack(clipBehavior: Clip.none, children: layers);
      },
    );

    final Widget readable = NebaChartPlot(
      label: widget.label ?? words['label']!,
      hint: nothing
          ? null
          : chartSummary(
              words,
              chartSummarise(<List<NebaChartValue>>[
                for (int index = 0; index < values.length; index++)
                  if (visible[index]) <NebaChartValue>[values[index]],
              ], format),
            ),
      focusNode: _focus,
      focusable: !nothing,
      focused: _focused,
      color: widget.color,
      onKey: _onKey,
      onFocusChange: (bool focused) {
        setState(() => _focused = focused);

        if (!focused) {
          _clear();
        }
      },
      onHover: _point,
      onLeave: _clear,
      onTouch: _point,
      child: plot,
    );

    return NebaChartSurface(
      plot: readable,
      plotHeight: plotHeight,
      legend: legendBar,
      legendSide: legendOptions.side,
      legendAlign: legendOptions.align,
      variant: variant,
      size: size,
      color: widget.color,
      density: widget.density,
      elevation: widget.elevation,
      padded: widget.padded,
      transition: widget.transition,
      hidden: <Widget>[
        if (!nothing) _tableFor(slices, values, format),
        if (!_tooltipOff) NebaChartStatus(heading: heading, items: items),
      ],
    );
  }
}

/// The slices, each faded by the chart's emphasis, and the shares written on
/// them.
class _PiePainter extends CustomPainter {
  _PiePainter({required this.slices, required this.labels, required this.emphasis})
    : super(repaint: emphasis);

  final List<({int index, Path path, Color color})> slices;
  final List<NebaChartLabel> labels;
  final NebaChartEmphasis emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ({int index, Path path, Color color}) slice in slices) {
      final Color color = slice.color;

      canvas.drawPath(
        slice.path,
        Paint()..color = color.withValues(alpha: color.a * emphasis.opacityOf(slice.index)),
      );
    }

    for (final NebaChartLabel label in labels) {
      label.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) {
    return !identical(oldDelegate.slices, slices) ||
        !identical(oldDelegate.labels, labels) ||
        !identical(oldDelegate.emphasis, emphasis);
  }
}
