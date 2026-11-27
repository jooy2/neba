/// Everything a chart draws that is not its marks: the React package's
/// `src/internal/chart-frame.tsx`.
///
/// A line chart, an area chart and a bar chart differ in a path, a band and a
/// rounded end, and agree on everything else: the axes, the grid, the
/// crosshair, the legend, the reference lines, the tooltip, the empty state,
/// and the table a screen reader reads instead of the picture. So
/// [NebaCartesianChart] is the chart, and a widget hands it the two halves of
/// its marks: what they are once per layout, and how they are painted.
///
/// `chart.dart` is the arithmetic under this, and `chart_line.dart` the marks
/// a line and an area share.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

// ---------------------------------------------------------------------------
// Measurement
// ---------------------------------------------------------------------------

/// A box [height] tall and as wide as it is let be, or [width], whose
/// [builder] is handed the width it came to.
///
/// A drawing is laid out in pixels, so every tick and every band is arithmetic
/// on the width the chart is given. The box answers a parent that measures
/// before it lays out, an intrinsic width or a dry layout, on its own: the
/// builder inside could not, and a chart in a row of stretched cards would
/// otherwise fail the moment the row asked how tall it was. With no width to
/// fill, in a row that gives it none, it is [fallbackWidth] wide.
class NebaChartBox extends StatelessWidget {
  /// A box of [height] drawn by [builder].
  const NebaChartBox({
    required this.height,
    required this.builder,
    this.width,
    this.fallbackWidth = 320,
    super.key,
  });

  /// How tall the box is.
  final double height;

  /// How wide it is, when it does not fill what it is given.
  final double? width;

  /// How wide it is with no width to fill.
  final double fallbackWidth;

  /// What is drawn, at the width the box came to.
  final Widget Function(BuildContext context, double width) builder;

  @override
  Widget build(BuildContext context) {
    return _ChartBoxShield(
      height: height,
      width: width,
      fallbackWidth: fallbackWidth,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return builder(context, constraints.maxWidth);
        },
      ),
    );
  }
}

class _ChartBoxShield extends SingleChildRenderObjectWidget {
  const _ChartBoxShield({
    required this.height,
    required this.width,
    required this.fallbackWidth,
    super.child,
  });

  final double height;
  final double? width;
  final double fallbackWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChartBox(height: height, width: width, fallbackWidth: fallbackWidth);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChartBox renderObject) {
    renderObject
      ..height = height
      ..width = width
      ..fallbackWidth = fallbackWidth;
  }
}

class _RenderChartBox extends RenderProxyBox {
  _RenderChartBox({required double height, required double? width, required double fallbackWidth})
    : _height = height,
      _width = width,
      _fallbackWidth = fallbackWidth;

  double _height;
  double? _width;
  double _fallbackWidth;

  set height(double value) {
    if (value != _height) {
      _height = value;
      markNeedsLayout();
    }
  }

  set width(double? value) {
    if (value != _width) {
      _width = value;
      markNeedsLayout();
    }
  }

  set fallbackWidth(double value) {
    if (value != _fallbackWidth) {
      _fallbackWidth = value;
      markNeedsLayout();
    }
  }

  Size _sizeFor(BoxConstraints constraints) {
    final double width =
        _width ?? (constraints.hasBoundedWidth ? constraints.maxWidth : _fallbackWidth);

    return constraints.constrain(Size(width, _height));
  }

  @override
  double computeMinIntrinsicWidth(double height) => _width ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) => _width ?? _fallbackWidth;

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) => _sizeFor(constraints);

  @override
  double? computeDryBaseline(covariant BoxConstraints constraints, TextBaseline baseline) => null;

  @override
  void performLayout() {
    size = _sizeFor(constraints);
    child?.layout(BoxConstraints.tight(size));
  }
}

// ---------------------------------------------------------------------------
// Emphasis
// ---------------------------------------------------------------------------

/// How far each series has faded and how far each column's markers have
/// grown, eased from wherever they were when the reader pointed somewhere
/// else.
///
/// A mark changes its opacity and its radius when the reader points at it and
/// nothing else, the React package's `markTransitionClasses`: a series the
/// legend is not pointing at drops to [chartDimmedOpacity], and the markers at
/// the active category grow by a pixel. Both travel over `NebaScale.duration`
/// and land at once when the platform asked for less motion. It notifies on
/// every frame of the travel, so a painter that repaints on it never has the
/// widgets around it rebuilt.
class NebaChartEmphasis extends ChangeNotifier {
  /// An emphasis ticking on [vsync].
  NebaChartEmphasis({required TickerProvider vsync})
    : _controller = AnimationController(vsync: vsync, value: 1) {
    _controller.addListener(notifyListeners);
  }

  final AnimationController _controller;
  List<double> _fromOpacity = const <double>[];
  List<double> _toOpacity = const <double>[];
  Map<int, double> _fromGrowth = const <int, double>{};
  int? _active;

  double get _progress => NebaScale.ease.transform(_controller.value);

  /// The opacity series [series] is drawn at now.
  double opacityOf(int series) {
    final double from = series < _fromOpacity.length ? _fromOpacity[series] : 1;
    final double to = series < _toOpacity.length ? _toOpacity[series] : 1;

    return from + (to - from) * _progress;
  }

  /// How far the markers at category [index] have grown now, from `0` to `1`.
  double growthOf(int index) {
    final double from = _fromGrowth[index] ?? 0;
    final double to = index == _active ? 1 : 0;

    return from + (to - from) * _progress;
  }

  /// Heads for [opacity] per series and for the markers at [active], over
  /// [duration] from where everything is now.
  void retarget({required List<double> opacity, required int? active, required Duration duration}) {
    if (active == _active && listEquals(opacity, _toOpacity)) {
      return;
    }

    final int count = math.max(opacity.length, math.max(_toOpacity.length, _fromOpacity.length));
    final Map<int, double> growth = <int, double>{};

    for (final int index in <int>{..._fromGrowth.keys, ?_active}) {
      final double now = growthOf(index);

      if (now > 0) {
        growth[index] = now;
      }
    }

    _fromOpacity = <double>[for (int series = 0; series < count; series++) opacityOf(series)];
    _fromGrowth = growth;
    _toOpacity = List<double>.of(opacity);
    _active = active;

    if (duration == Duration.zero) {
      _controller.value = 1;
      notifyListeners();
    } else {
      _controller
        ..duration = duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Text on a canvas
// ---------------------------------------------------------------------------

/// [text] in [style], laid out on one line.
TextPainter chartTextPainter(String text, TextStyle style, TextDirection direction) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction,
    maxLines: 1,
  )..layout();
}

/// A label painted at a point: by its end (`-1`), its middle (`0`) or its
/// start (`1`) along the line of the text, on its baseline or by the middle
/// of its type when [central], turned by [angle] degrees about the point.
@immutable
class NebaChartLabel {
  /// [painter] at [at].
  const NebaChartLabel(
    this.painter,
    this.at, {
    this.anchor = 0,
    this.central = false,
    this.angle = 0,
  });

  /// The laid-out text.
  final TextPainter painter;

  /// The point it is pinned to.
  final Offset at;

  /// Which end of it sits on [at].
  final int anchor;

  /// Whether [at] is the middle of the type rather than its baseline.
  final bool central;

  /// How far it is turned about [at], in degrees.
  final double angle;

  /// Paints it on [canvas].
  void paint(Canvas canvas) {
    final double dx = switch (anchor) {
      -1 => -painter.width,
      0 => -painter.width / 2,
      _ => 0,
    };
    final double dy = central
        ? -painter.height / 2
        : -painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    if (angle == 0) {
      painter.paint(canvas, at + Offset(dx, dy));

      return;
    }

    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle * math.pi / 180);
    painter.paint(canvas, Offset(dx, dy));
    canvas.restore();
  }
}

/// A one-pixel rule from [from] to [to], dashed four on and four off unless
/// [solid].
void chartPaintRule(Canvas canvas, Offset from, Offset to, Color color, {bool solid = true}) {
  final Paint paint = Paint()
    ..color = color
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  if (solid) {
    canvas.drawLine(from, to, paint);

    return;
  }

  final double length = (to - from).distance;

  if (length == 0) {
    return;
  }

  final Offset unit = (to - from) / length;

  for (double at = 0; at < length; at += 8) {
    canvas.drawLine(from + unit * at, from + unit * math.min(length, at + 4), paint);
  }
}

// ---------------------------------------------------------------------------
// The layout a chart's marks are placed by
// ---------------------------------------------------------------------------

/// Where everything goes: the half of a chart settled before the pointer is
/// consulted, and what a chart's marks are traced from.
///
/// One object for as long as nothing in it changes, so the marks traced from
/// it hold while the pointer moves.
class NebaChartLayout {
  /// A layout of [values] in [plot].
  NebaChartLayout({
    required this.plot,
    required this.values,
    required this.visible,
    required this.colors,
    required this.scale,
    required this.secondScale,
    required List<bool> second,
    required this.inset,
    required this.count,
    required this.band,
    required this.categories,
    required this.size,
    required this.fontSize,
    required this.tokens,
    required this.textStyle,
    required this.textDirection,
    required this.format,
    required String Function(double value)? secondFormat,
  }) : _second = second,
       _secondFormat = secondFormat;

  /// The plot's box inside the chart, once the axes have taken their bands.
  final Rect plot;

  /// Every series unpacked, in the order it was passed.
  final List<List<NebaChartValue>> values;

  /// Which of them are drawn.
  final List<bool> visible;

  /// What colour each one is, by its place in the list it was passed in.
  final List<Color> colors;

  /// The value axis' scale.
  final NebaChartScale scale;

  /// The far edge's scale, on a chart given a second value axis.
  final NebaChartScale? secondScale;

  final List<bool> _second;

  /// Whether the categories sit on their ticks, as a line's do, rather than
  /// in the middle of a band, as a bar's do.
  final bool inset;

  /// How many categories there are.
  final int count;

  /// The band each category takes along the axis.
  final NebaChartBand band;

  /// What each category is called.
  final List<Object> categories;

  /// The chart's size step.
  final NebaSize size;

  /// The size the chart's text is set at, scaled as the platform asks.
  final double fontSize;

  /// The theme it is drawn in.
  final NebaTokens tokens;

  /// The text style a label starts from.
  final TextStyle textStyle;

  /// The direction its text is set in.
  final TextDirection textDirection;

  /// How a number is written.
  final String Function(double value) format;

  final String Function(double value)? _secondFormat;

  /// Whether series [series] is measured on the far edge.
  bool onSecond(int series) => series < _second.length && _second[series];

  /// How series [series]' numbers are written: through the far edge's
  /// `tickFormat` when it is measured there, and [format] otherwise.
  String Function(double value) formatFor(int series) {
    final String Function(double value)? second = _secondFormat;

    return onSecond(series) && second != null ? second : format;
  }

  /// The scale series [series] is measured on.
  NebaChartScale scaleFor(int? series) {
    final NebaChartScale? second = secondScale;

    return series != null && onSecond(series) && second != null ? second : scale;
  }

  /// Where category [index] sits along the plot, from its start: on its tick
  /// when [inset], in the middle of its band otherwise. A fraction of an
  /// index is a place between two categories.
  double categoryPx(num index) {
    if (!inset) {
      return band.step * (index + 0.5);
    }

    return count <= 1 ? plot.width / 2 : plot.width * index / (count - 1);
  }

  /// Where [value] of series [series] sits down the chart.
  double valuePx(double value, [int? series]) {
    return plot.top + (1 - scaleFor(series).fraction(value)) * plot.height;
  }

  /// Category [index] at [value] of series [series], in the chart's pixels.
  Offset point(int index, double value, [int? series]) {
    return Offset(plot.left + categoryPx(index), valuePx(value, series));
  }

  /// Where series [series]' baseline is: zero, held inside its scale.
  double zeroPxOf([int? series]) {
    final NebaChartScale on = scaleFor(series);

    return valuePx(0.clamp(on.min, on.max).toDouble(), series);
  }
}

/// What a chart's painter is handed on every build: the layout, the marks
/// traced from it, and what the pointer decided.
@immutable
class NebaChartMarks<T> {
  /// The marks of [traced] on [layout].
  const NebaChartMarks({
    required this.layout,
    required this.traced,
    required this.activeIndex,
    required this.emphasis,
  });

  /// Where everything goes.
  final NebaChartLayout layout;

  /// What the chart traced from [layout].
  final T traced;

  /// The category under the pointer or the keys, if any.
  final int? activeIndex;

  /// How far each series has faded and each column's markers have grown.
  final NebaChartEmphasis emphasis;
}

// ---------------------------------------------------------------------------
// Legend
// ---------------------------------------------------------------------------

/// The keys a series is remembered by: its name and which of the series with
/// that name it is, or its index when it has none. A refresh that brings the
/// same series back in another order keeps the one the reader hid hidden.
List<String> chartSeriesKeys(List<NebaChartSeries> series) {
  final Map<String, int> seen = <String, int>{};

  return <String>[
    for (int index = 0; index < series.length; index++)
      if (series[index].name case final String name)
        'name:${seen[name] = (seen[name] ?? -1) + 1}:$name'
      else
        'index:$index',
  ];
}

/// The widest numbers a legend row with `showValue` can hold, as their shapes
/// with every digit a nought: figures are tabular, so two numbers of one
/// shape take the same room, and a thousand values have a handful of shapes.
List<String> chartNumberShapes(List<NebaChartValue> row, String Function(double value) write) {
  final Set<String> shapes = <String>{};

  for (final NebaChartValue one in row) {
    final double? value = one.value;

    if (value != null && !value.isNaN) {
      shapes.add(write(value).replaceAll(RegExp('[0-9]'), '0'));
    }
  }

  final int longest = shapes.fold<int>(0, (int most, String shape) => math.max(most, shape.length));

  return <String>[
    for (final String shape in shapes)
      if (shape.length == longest) shape,
  ];
}

/// The dependable identity channel: a swatch in each series' colour and its
/// name in ink, a list of buttons that hide and show their series when it is
/// [interactive].
///
/// A hidden series stays in the list and fades rather than turning grey,
/// because grey is a ninth colour and a list that shortens when it is pressed
/// is a list that cannot be pressed twice.
class NebaChartLegendBar extends StatelessWidget {
  /// A legend of [names] in [colors].
  const NebaChartLegendBar({
    required this.names,
    required this.colors,
    required this.visible,
    required this.options,
    required this.size,
    required this.color,
    this.hovered,
    this.onToggle,
    this.onHover,
    this.values,
    this.reserve,
    super.key,
  });

  /// What each series is called.
  final List<String> names;

  /// Each series' colour.
  final List<Color> colors;

  /// Which series are drawn.
  final List<bool> visible;

  /// The series the reader is pointing at in the legend.
  final int? hovered;

  /// Where it sits and whether it does anything.
  final NebaChartLegend options;

  /// The type and the swatch on the size ladder.
  final NebaSize size;

  /// The family of the hover wash and the focus ring.
  final NebaColor color;

  /// Called with a series' index when its entry is pressed.
  final ValueChanged<int>? onToggle;

  /// Called with the series the reader points at or focuses, and `null` when
  /// they leave it.
  final ValueChanged<int?>? onHover;

  /// Each series' value at the active category.
  final List<String?>? values;

  /// The numbers each row keeps room for, whether or not one is showing.
  final List<List<String>>? reserve;

  @override
  Widget build(BuildContext context) {
    final bool vertical = options.side == NebaSide.left || options.side == NebaSide.right;
    final List<Widget> entries = <Widget>[
      for (int index = 0; index < names.length; index++)
        Semantics(
          container: true,
          role: SemanticsRole.listItem,
          child: _LegendEntry(
            name: names[index],
            swatch: colors[index],
            shown: index < visible.length && visible[index],
            dimmed: hovered != null && hovered != index,
            interactive: options.interactive,
            size: size,
            color: color,
            value: values?[index],
            reserve: reserve?[index],
            onToggle: onToggle == null ? null : () => onToggle?.call(index),
            onHover: onHover == null ? null : (bool on) => onHover?.call(on ? index : null),
          ),
        ),
    ];
    final Widget list = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: entries,
          )
        : Wrap(
            alignment: switch (options.align) {
              NebaAlign.start => WrapAlignment.start,
              NebaAlign.center => WrapAlignment.center,
              NebaAlign.end => WrapAlignment.end,
            },
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: entries,
          );

    return Semantics(
      container: true,
      role: SemanticsRole.list,
      explicitChildNodes: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: NebaScale.metaText[size]),
        child: list,
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({
    required this.name,
    required this.swatch,
    required this.shown,
    required this.dimmed,
    required this.interactive,
    required this.size,
    required this.color,
    required this.value,
    required this.reserve,
    required this.onToggle,
    required this.onHover,
  });

  final String name;
  final Color swatch;
  final bool shown;
  final bool dimmed;
  final bool interactive;
  final NebaSize size;
  final NebaColor color;
  final String? value;
  final List<String>? reserve;
  final VoidCallback? onToggle;
  final ValueChanged<bool>? onHover;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);
    final String? value = this.value;
    final List<String>? reserve = this.reserve;
    final TextStyle figures = TextStyle(
      color: tokens.mutedFg,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    // Always there when a row keeps room, and as wide as the widest number it
    // can show, so a row is the same size with a column active and without.
    final Widget? number = reserve != null
        ? Stack(
            children: <Widget>[
              for (final String sample in reserve)
                ExcludeSemantics(
                  child: Opacity(opacity: 0, child: Text(sample, style: figures)),
                ),
              Text(value ?? '', style: figures),
            ],
          )
        : value != null
        ? Text(value, style: figures)
        : null;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: swatch, borderRadius: BorderRadius.circular(3)),
        ),
        Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)),
        ?number,
      ],
    );
    final double opacity = shown ? (dimmed ? 0.55 : 1) : 0.4;
    final Duration duration = nebaDuration(context, NebaScale.duration);

    if (!interactive) {
      return AnimatedOpacity(
        opacity: shown ? 1 : 0.4,
        duration: duration,
        curve: NebaScale.ease,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: tokens.fg),
            child: content,
          ),
        ),
      );
    }

    final Widget entry = NebaInteractive(
      onTap: onToggle,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: radius,
          offset: 1,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: duration,
            curve: NebaScale.ease,
            child: AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: interaction.hovered ? roles.soft : roles.soft.withValues(alpha: 0),
                borderRadius: radius,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: tokens.fg),
                child: content,
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      container: true,
      button: true,
      selected: shown,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: onHover,
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) => onHover?.call(true),
          onExit: (PointerExitEvent event) => onHover?.call(false),
          child: entry,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tooltip
// ---------------------------------------------------------------------------

/// The panel beside the active category: a heading, and a row per series
/// with its swatch, its name and its value.
///
/// It is a readout and not a surface, so it takes no pointer and says nothing
/// to a screen reader: what a reader hears is the chart's live readout, which
/// is a sibling of the picture rather than inside it.
class NebaChartTooltipPanel extends StatelessWidget {
  /// A panel headed [heading] with [items].
  const NebaChartTooltipPanel({
    required this.heading,
    required this.items,
    required this.size,
    required this.color,
    super.key,
  });

  /// What the reading is of: the category.
  final String heading;

  /// A row per series.
  final List<NebaChartTooltipItem> items;

  /// The type on the size ladder.
  final NebaSize size;

  /// The family of the hairline.
  final NebaColor color;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    const TextStyle figures = TextStyle(
      fontWeight: FontWeight.w500,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    );

    return IgnorePointer(
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 96, maxWidth: 224),
          child: IntrinsicWidth(
            child: NebaSheet(
              fill: tokens.panelPress,
              edge: tokens.roles(color).line,
              plate: NebaPlate.glass,
              elevation: 2,
              borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.fg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 2,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(heading, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      for (final NebaChartTooltipItem item in items)
                        Row(
                          spacing: 6,
                          children: <Widget>[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            if (item.name case final String name)
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(color: tokens.mutedFg),
                                ),
                              )
                            else
                              const Spacer(),
                            Text(item.label ?? item.formatted, style: figures),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The table under every chart
// ---------------------------------------------------------------------------

/// How many data points a chart may hold before its hidden table fills in
/// after the first frame rather than with it.
const int chartDeferredTablePoints = 500;

/// How many cells of a deferred table go in per idle slice.
const int _deferredTableCells = 1000;

/// The chart as a table, for the readers a drawing does not reach: a header
/// row of [columns], then a row per category.
///
/// Not drawn and not a toggle: a tooltip that is the only way to a number
/// gates it behind a pointer, and a picture with a name says what it is of and
/// nothing else. It is a Flutter [Table] in the semantics tree, which the web
/// reads as a table with its header cells; the first cell of a row is a cell,
/// since Flutter has no row header. Past [chartDeferredTablePoints] the rows
/// are added in idle slices after the first frame.
class NebaChartDataTable extends StatefulWidget {
  /// A table of [rows] under [columns].
  const NebaChartDataTable({
    required this.columns,
    required this.rows,
    required this.points,
    this.caption,
    super.key,
  });

  /// The header row: the corner, then a name per series.
  final List<String> columns;

  /// A row per category, its name first.
  final List<List<String>> rows;

  /// How many data points the chart holds, which decides whether the rows
  /// wait.
  final int points;

  /// What the table is of.
  final String? caption;

  @override
  State<NebaChartDataTable> createState() => _NebaChartDataTableState();
}

class _NebaChartDataTableState extends State<NebaChartDataTable> {
  late int _shown = widget.points > chartDeferredTablePoints ? 0 : widget.rows.length;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(NebaChartDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rows already written stay written, and only the rows new to it wait.
    _shown = widget.points > chartDeferredTablePoints
        ? math.min(_shown, widget.rows.length)
        : widget.rows.length;
    _schedule();
  }

  @override
  void dispose() {
    _generation += 1;
    super.dispose();
  }

  void _schedule() {
    if (_shown >= widget.rows.length) {
      return;
    }

    final int generation = ++_generation;
    final int slice = math.max(1, _deferredTableCells ~/ math.max(1, widget.columns.length));

    SchedulerBinding.instance.scheduleTask<void>(() {
      if (!mounted || generation != _generation) {
        return;
      }

      setState(() => _shown = math.min(widget.rows.length, _shown + slice));
      _schedule();
    }, Priority.idle);
  }

  @override
  Widget build(BuildContext context) {
    Widget cell(String text, SemanticsRole role) {
      return Semantics(container: true, role: role, child: Text(text));
    }

    final Widget table = Table(
      defaultColumnWidth: const FixedColumnWidth(160),
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            for (final String name in widget.columns) cell(name, SemanticsRole.columnHeader),
          ],
        ),
        for (final List<String> row in widget.rows.take(_shown))
          TableRow(
            children: <Widget>[
              for (int index = 0; index < widget.columns.length; index++)
                cell(index < row.length ? row[index] : '', SemanticsRole.cell),
            ],
          ),
      ],
    );

    return NebaVisuallyHidden(
      child: Semantics(container: true, label: widget.caption, child: table),
    );
  }
}

/// The count and the extremes of every value in [rows], written by [format].
({int count, String min, String max}) chartSummarise(
  Iterable<List<NebaChartValue>> rows,
  String Function(double value) format,
) {
  int count = 0;
  double low = double.infinity;
  double high = double.negativeInfinity;

  for (final List<NebaChartValue> row in rows) {
    for (final NebaChartValue one in row) {
      final double? value = one.value;

      if (value == null || value.isNaN) {
        continue;
      }

      count += 1;
      low = math.min(low, value);
      high = math.max(high, value);
    }
  }

  return count == 0
      ? (count: 0, min: '', max: '')
      : (count: count, min: format(low), max: format(high));
}

/// What a reading says out loud: its heading, then each series' name and
/// value. Empty when nothing is being read.
String chartReadout(String? heading, List<NebaChartTooltipItem> items) {
  if (items.isEmpty) {
    return '';
  }

  final String values = items
      .map((NebaChartTooltipItem item) {
        final String name = item.name == null ? '' : '${item.name}: ';

        return '$name${item.label ?? item.formatted}';
      })
      .join(', ');

  return heading == null || heading.isEmpty ? values : '$heading, $values';
}

// ---------------------------------------------------------------------------
// The surface every chart sits on
// ---------------------------------------------------------------------------

/// A box with the plot in it, the legend on one of its four sides, and what a
/// screen reader reads instead of the picture after them.
///
/// The legend takes a row of its own outside the plot's height, or a column
/// beside it, twelve pixels off.
class NebaChartSurface extends StatelessWidget {
  /// [plot] with [legend] on [legendSide].
  const NebaChartSurface({
    required this.plot,
    required this.plotHeight,
    required this.legendSide,
    required this.legendAlign,
    required this.variant,
    required this.size,
    required this.color,
    required this.elevation,
    required this.padded,
    this.density,
    this.transition,
    this.legend,
    this.hidden = const <Widget>[],
    super.key,
  });

  /// The picture.
  final Widget plot;

  /// How tall the picture is, which a legend beside it is laid against.
  final double plotHeight;

  /// The legend, if there is one.
  final Widget? legend;

  /// Which edge of the plot the legend is on.
  final NebaSide legendSide;

  /// Where along that edge.
  final NebaAlign legendAlign;

  /// What is read instead of the picture: the table, the readout.
  final List<Widget> hidden;

  /// The sheet's weight.
  final NebaVariant variant;

  /// The sheet's corners and padding.
  final NebaSize size;

  /// The family of the sheet's hairline.
  final NebaColor color;

  /// How much padding the sheet has.
  final NebaDensity? density;

  /// The drop shadow.
  final NebaElevation elevation;

  /// Whether the sheet pads what is on it.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final Widget? legend = this.legend;
    Widget body;

    if (legend == null) {
      body = plot;
    } else if (legendSide == NebaSide.top || legendSide == NebaSide.bottom) {
      final bool top = legendSide == NebaSide.top;

      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: top ? <Widget>[legend, plot] : <Widget>[plot, legend],
      );
    } else {
      final bool left = legendSide == NebaSide.left;
      final Widget beside = ConstrainedBox(
        constraints: BoxConstraints(minHeight: plotHeight),
        child: Align(
          alignment: switch (legendAlign) {
            NebaAlign.start => AlignmentDirectional.topStart,
            NebaAlign.center => AlignmentDirectional.centerStart,
            NebaAlign.end => AlignmentDirectional.bottomStart,
          },
          widthFactor: 1,
          heightFactor: 1,
          child: legend,
        ),
      );

      body = _Beside(legendFirst: left, children: <Widget>[plot, beside]);
    }

    return NebaBox(
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[body, ...hidden],
      ),
    );
  }
}

/// A plot with a legend beside it: the legend laid out first, at most four
/// tenths of the width, and the plot given the rest, twelve pixels off.
///
/// A render object rather than a row inside a layout builder, so a parent that
/// measures its children before laying them out, a stretched card in a row,
/// is answered rather than refused.
class _Beside extends MultiChildRenderObjectWidget {
  const _Beside({required this.legendFirst, required super.children});

  /// Whether the legend is on the left.
  final bool legendFirst;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBeside(legendFirst);

  @override
  void updateRenderObject(BuildContext context, _RenderBeside renderObject) {
    renderObject.legendFirst = legendFirst;
  }
}

class _BesideData extends ContainerBoxParentData<RenderBox> {}

class _RenderBeside extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BesideData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BesideData> {
  _RenderBeside(this._legendFirst);

  static const double _gap = 12;
  static const double _share = 0.4;

  bool _legendFirst;

  set legendFirst(bool value) {
    if (value != _legendFirst) {
      _legendFirst = value;
      markNeedsLayout();
    }
  }

  RenderBox get _plot => firstChild!;

  RenderBox get _legend => lastChild!;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _BesideData) {
      child.parentData = _BesideData();
    }
  }

  Size _arrange(BoxConstraints constraints, {required bool dry}) {
    final double width = constraints.hasBoundedWidth ? constraints.maxWidth : 520;
    final BoxConstraints room = BoxConstraints(maxWidth: width * _share);
    final Size legend = dry ? _legend.getDryLayout(room) : _layout(_legend, room);
    final BoxConstraints rest = BoxConstraints.tightFor(
      width: math.max(0, width - legend.width - _gap),
    );
    final Size plot = dry ? _plot.getDryLayout(rest) : _layout(_plot, rest);

    if (!dry) {
      (_legend.parentData! as _BesideData).offset = Offset(_legendFirst ? 0 : plot.width + _gap, 0);
      (_plot.parentData! as _BesideData).offset = Offset(_legendFirst ? legend.width + _gap : 0, 0);
    }

    return constraints.constrain(Size(width, math.max(plot.height, legend.height)));
  }

  Size _layout(RenderBox child, BoxConstraints constraints) {
    child.layout(constraints, parentUsesSize: true);

    return child.size;
  }

  @override
  void performLayout() {
    size = _arrange(constraints, dry: false);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) => _arrange(constraints, dry: true);

  @override
  double computeMinIntrinsicWidth(double height) {
    return _plot.getMinIntrinsicWidth(height) + _gap + _legend.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _plot.getMaxIntrinsicWidth(height) + _gap + _legend.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      _plot.getMinIntrinsicHeight(width),
      _legend.getMinIntrinsicHeight(width * _share),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(
      _plot.getMaxIntrinsicHeight(width),
      _legend.getMaxIntrinsicHeight(width * _share),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

// ---------------------------------------------------------------------------
// Cartesian charts
// ---------------------------------------------------------------------------

/// The frame of a chart with two axes: the axes and the grid, the crosshair,
/// the legend, the tooltip and the table, with the marks left to the chart.
///
/// A chart hands it [trace], which works its marks out from a layout and is
/// run again only when the layout or [traceKey] changes, and [painter], which
/// paints them on every build from what [trace] returned. Everything else is
/// the frame's: which series are shown, which category is active, and the
/// emphasis that eases between them.
class NebaCartesianChart<T> extends StatefulWidget {
  /// A frame around the marks [trace] works out and [painter] paints.
  const NebaCartesianChart({
    required this.series,
    required this.trace,
    required this.traceKey,
    required this.painter,
    this.categories,
    this.xAxis,
    this.yAxis,
    this.secondaryAxis,
    this.references,
    this.stacked = false,
    this.stackedFull = false,
    this.zeroGaps = false,
    this.includeZero = true,
    this.inset = false,
    this.headroom = 0,
    this.bandRatio = 1,
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
  });

  /// The series, in the order their colours are handed out.
  final List<NebaChartSeries> series;

  /// What each category is called. Points may carry their own `x` instead.
  final List<Object>? categories;

  /// The category axis.
  final NebaChartAxis? xAxis;

  /// The value axis.
  final NebaChartAxis? yAxis;

  /// A second value axis on the far edge, for the series that ask for it.
  final NebaChartAxis? secondaryAxis;

  /// Lines and bands drawn across the plot.
  final List<NebaChartReference>? references;

  /// The value axis measures totals rather than parts.
  final bool stacked;

  /// Every category is renormalised to a hundred.
  final bool stackedFull;

  /// Every gap is read as a nought, in the data rather than the drawing.
  final bool zeroGaps;

  /// Whether the value axis keeps zero in its range.
  final bool includeZero;

  /// Whether the categories sit on their ticks rather than between them.
  final bool inset;

  /// Extra room above the plot, for labels riding the marks.
  final double headroom;

  /// How much of a band the marks take.
  final double bandRatio;

  /// How tall the drawing is. The size ladder when left out.
  final double? height;

  /// How a number is written everywhere it appears.
  final String Function(num value)? format;

  /// The language of the chart's own words.
  final Locale? locale;

  /// The chart's name, and the caption of its table.
  final String? label;

  /// `true`, `false` or a [NebaChartLegend].
  final Object? legend;

  /// `true`, `false` or a [NebaChartTooltip].
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight.
  final NebaVariant? variant;

  /// The type, the line weight, the markers and the height.
  final NebaSize? size;

  /// The family of the sheet and the focus ring.
  final NebaColor color;

  /// How much padding the sheet has.
  final NebaDensity? density;

  /// The drop shadow.
  final NebaElevation elevation;

  /// Whether the sheet pads the chart.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  /// Works the marks out from a layout.
  final T Function(NebaChartLayout layout) trace;

  /// What [trace] reads besides the layout, so a change to it traces again.
  final Object traceKey;

  /// Paints the marks.
  final CustomPainter Function(NebaChartMarks<T> marks) painter;

  @override
  State<NebaCartesianChart<T>> createState() => _NebaCartesianChartState<T>();
}

/// What a chart works out from its data, before it knows its width.
class _ChartData {
  _ChartData({
    required this.values,
    required this.given,
    required this.visible,
    required this.colors,
    required this.names,
    required this.count,
    required this.labels,
    required this.second,
    required this.extent,
    required this.scale,
    required this.secondScale,
    required this.tickTexts,
    required this.secondTickTexts,
    required this.categoryTexts,
    required this.format,
    required this.secondFormat,
    required this.described,
    required this.describedSecond,
  });

  final List<List<NebaChartValue>> values;
  final List<List<NebaChartValue>> given;
  final List<bool> visible;
  final List<Color> colors;
  final List<String> names;
  final int count;
  final List<Object> labels;
  final List<bool> second;
  final ({double min, double max})? extent;
  final NebaChartScale scale;
  final NebaChartScale? secondScale;
  final List<String> tickTexts;
  final List<String> secondTickTexts;
  final List<String> categoryTexts;
  final String Function(double value) format;
  final String Function(double value)? secondFormat;
  final ({int count, String min, String max}) described;
  final ({int count, String min, String max})? describedSecond;

  bool onSecond(int series) => series < second.length && second[series];

  /// The numbers each legend row keeps room for under `showValue`, worked out
  /// once per change to the data rather than on every move of the pointer.
  late final List<List<String>> reserve = <List<String>>[
    for (int series = 0; series < values.length; series++)
      chartNumberShapes(values[series], formatFor(series)),
  ];

  String Function(double value) formatFor(int series) {
    final String Function(double value)? second = secondFormat;

    return onSecond(series) && second != null ? second : format;
  }
}

/// The layout, and the chrome painted from it.
class _ChartModel {
  _ChartModel(this.layout, this.chrome);

  final NebaChartLayout layout;
  final List<Object> chrome;

  void dispose() {
    for (final Object op in chrome) {
      if (op is NebaChartLabel) {
        op.painter.dispose();
      }
    }
  }
}

class _Rule {
  const _Rule(this.from, this.to, this.color, {this.solid = true});

  final Offset from;
  final Offset to;
  final Color color;
  final bool solid;
}

class _Wash {
  const _Wash(this.rect, this.color);

  final Rect rect;
  final Color color;
}

class _NebaCartesianChartState<T> extends State<NebaCartesianChart<T>>
    with SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode(debugLabel: 'NebaChart');
  final GlobalKey _plotKey = GlobalKey();
  late final NebaChartEmphasis _emphasis = NebaChartEmphasis(vsync: this);

  Map<String, bool> _chosen = <String, bool>{};
  int? _legendHover;
  int? _column;
  int? _pointerSeries;
  bool _focused = false;
  bool _routing = false;

  _ChartData? _data;
  Object? _dataKey;
  _ChartModel? _model;
  Object? _modelKey;
  T? _traced;
  Object? _tracedKey;
  Widget? _table;
  Object? _tableKey;

  @override
  void didUpdateWidget(NebaCartesianChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.series.length != widget.series.length) {
      _legendHover = null;
      _emphasise();
    }
  }

  @override
  void dispose() {
    _unroute();
    _model?.dispose();
    _focus.dispose();
    _emphasis.dispose();
    super.dispose();
  }

  // ----- Visibility ----------------------------------------------------------

  void _toggle(int index) {
    final List<String> keys = chartSeriesKeys(widget.series);

    if (index >= keys.length) {
      return;
    }

    final String key = keys[index];

    setState(() {
      _chosen = <String, bool>{..._chosen, key: !(_chosen[key] ?? !widget.series[index].hidden)};
    });
  }

  void _hoverLegend(int? index) {
    if (index == _legendHover) {
      return;
    }

    setState(() => _legendHover = index);
    _emphasise();
  }

  // ----- The active category -----------------------------------------------

  void _setActive(int? column, {int? series}) {
    if (column == _column && series == _pointerSeries) {
      return;
    }

    setState(() {
      _column = column;
      _pointerSeries = series;
    });
    _emphasise();

    if (column == null) {
      _unroute();
    } else {
      _route();
    }
  }

  void _clear() => _setActive(null);

  void _emphasise() {
    if (!mounted) {
      return;
    }

    final int count = widget.series.length;
    final int? hovered = _legendHover;

    _emphasis.retarget(
      opacity: <double>[
        for (int index = 0; index < count; index++)
          hovered == null || hovered == index ? 1 : chartDimmedOpacity,
      ],
      active: _column,
      duration: nebaDuration(context, NebaScale.duration),
    );
  }

  /// A press anywhere outside the plot puts a reading down: a finger cannot
  /// leave a plot the way a mouse does, so a tap pins the reading instead.
  void _route() {
    if (!_routing) {
      _routing = true;
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onGlobalPointer);
    }
  }

  void _unroute() {
    if (_routing) {
      _routing = false;
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onGlobalPointer);
    }
  }

  void _onGlobalPointer(PointerEvent event) {
    if (event is! PointerDownEvent) {
      return;
    }

    final RenderObject? box = _plotKey.currentContext?.findRenderObject();

    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return;
    }

    if (!(Offset.zero & box.size).contains(box.globalToLocal(event.position))) {
      _clear();
    }
  }

  NebaChartTooltipMode get _mode {
    final Object? tooltip = widget.tooltip;

    if (tooltip == false) {
      return NebaChartTooltipMode.none;
    }

    return tooltip is NebaChartTooltip
        ? tooltip.mode ?? NebaChartTooltipMode.category
        : NebaChartTooltipMode.category;
  }

  /// The category nearest [local] along the plot: a two-pixel line is not
  /// something a pointer can be asked to land on, so a category's column is
  /// its whole step.
  int? _indexAt(Offset local) {
    final NebaChartLayout? layout = _model?.layout;

    if (layout == null || layout.count == 0 || layout.plot.width <= 0) {
      return null;
    }

    final double along = local.dx - layout.plot.left;
    final double length = layout.plot.width;
    final int count = layout.count;

    if (along < -layout.band.step || along > length + layout.band.step) {
      return null;
    }

    final int raw = layout.inset
        ? (count <= 1 ? 0 : (along / length * (count - 1)).round())
        : (along / layout.band.step).floor();

    return raw.clamp(0, count - 1);
  }

  /// In item mode, the series whose mark at column [index] is nearest [at],
  /// down the plot. A tie goes to the series passed first.
  int? _nearestSeries(int index, double at) {
    final _ChartData? data = _data;
    final NebaChartLayout? layout = _model?.layout;

    if (data == null || layout == null) {
      return null;
    }

    int? found;
    double best = double.infinity;
    double above = 0;
    double below = 0;

    for (int series = 0; series < data.values.length; series++) {
      final List<NebaChartValue> row = data.values[series];
      final double? value = index < row.length ? row[index].value : null;

      if (!data.visible[series] || value == null) {
        continue;
      }

      final bool stacked = widget.stacked || widget.stackedFull;
      final double from = !stacked ? value : (value < 0 ? below : above);
      final double to = !stacked ? value : from + value;

      if (stacked && value < 0) {
        below = to;
      } else if (stacked) {
        above = to;
      }

      final double a = layout.valuePx(from, series);
      final double b = layout.valuePx(to, series);
      final double distance = math.max(0, math.max(math.min(a, b) - at, at - math.max(a, b)));

      if (distance < best) {
        best = distance;
        found = series;
      }
    }

    return found;
  }

  void _read(Offset local) {
    final NebaChartTooltipMode mode = _mode;

    if (mode == NebaChartTooltipMode.none) {
      return;
    }

    final int? next = _indexAt(local);
    final int? series = mode == NebaChartTooltipMode.item && next != null
        ? _nearestSeries(next, local.dy)
        : null;

    _setActive(next, series: series);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final _ChartData? data = _data;

    if (event is! KeyDownEvent && event is! KeyRepeatEvent ||
        data == null ||
        _mode == NebaChartTooltipMode.none) {
      return KeyEventResult.ignored;
    }

    final int count = data.count;
    final LogicalKeyboardKey key = event.logicalKey;
    final int? current = _column;

    if (count == 0) {
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      _setActive(math.min(count - 1, (current ?? -1) + 1));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _setActive(math.max(0, (current ?? count) - 1));
    } else if (key == LogicalKeyboardKey.home) {
      _setActive(0);
    } else if (key == LogicalKeyboardKey.end) {
      _setActive(count - 1);
    } else if (key == LogicalKeyboardKey.escape && current != null) {
      _clear();
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  // ----- Data ----------------------------------------------------------------

  _ChartData _dataFor(NebaTokens tokens) {
    final NebaCartesianChart<T> widget = this.widget;
    final Object key = (
      widget.series,
      widget.categories,
      widget.zeroGaps,
      widget.stacked,
      widget.stackedFull,
      widget.includeZero,
      widget.format,
      widget.xAxis,
      widget.yAxis,
      widget.secondaryAxis,
      widget.references,
      _chosen,
      tokens,
    );
    final _ChartData? cached = _data;

    if (cached != null && key == _dataKey) {
      return cached;
    }

    final List<NebaChartSeries> series = widget.zeroGaps
        ? chartZeroGaps(widget.series)
        : widget.series;
    final List<String> keys = chartSeriesKeys(series);
    final List<bool> visible = <bool>[
      for (int index = 0; index < series.length; index++)
        _chosen[keys[index]] ?? !series[index].hidden,
    ];
    final String Function(num value)? own = widget.format;
    final String Function(double value) format = own == null
        ? nebaFormatCompact
        : (double value) => own(chartNumber(value));
    final List<List<NebaChartValue>> given = chartValuesOf(series);
    final List<List<NebaChartValue>> values = widget.stackedFull
        ? chartFullShares(given, visible, format)
        : given;
    final int count = chartCategoryCount(series);
    final List<Object> labels = <Object>[
      for (int index = 0; index < count; index++) chartCategoryAt(index, widget.categories, values),
    ];
    final NebaChartAxis? secondaryAxis = widget.secondaryAxis;
    // A second axis is what turns the split on, and a stack puts everything
    // back on one scale, because a total across two units is not a number.
    final bool twoAxes = secondaryAxis != null && !widget.stacked && !widget.stackedFull;
    final List<bool> second = <bool>[
      for (final NebaChartSeries one in series)
        twoAxes && one.axis == NebaChartSeriesAxis.secondary,
    ];
    bool firstOf(int index) => visible[index] && !second[index];
    bool secondOf(int index) => visible[index] && second[index];

    // The scale takes the references read against the value axis in, so a
    // target above everything measured is still on the chart.
    final ({double min, double max})? measured = chartExtentOf(<List<NebaChartValue>>[
      for (int index = 0; index < values.length; index++)
        if (firstOf(index)) values[index],
    ], stacked: widget.stacked);
    final List<double> marks = <double>[
      for (final NebaChartReference one in widget.references ?? const <NebaChartReference>[])
        if (one.axis == NebaChartReferenceAxis.value) ...<double>[one.value, ?one.to],
    ];
    final ({double min, double max})? extent = marks.isEmpty
        ? measured
        : (
            min: marks.fold<double>(measured?.min ?? double.infinity, math.min),
            max: marks.fold<double>(measured?.max ?? double.negativeInfinity, math.max),
          );
    final ({double min, double max})? secondExtent = twoAxes
        ? chartExtentOf(<List<NebaChartValue>>[
            for (int index = 0; index < values.length; index++)
              if (secondOf(index)) values[index],
          ], stacked: false)
        : null;
    final NebaChartAxis? yAxis = widget.yAxis;
    final NebaChartScale scale = chartValueScale(
      extent,
      min: yAxis?.min,
      max: yAxis?.max,
      tickCount: yAxis?.tickCount,
      includeZero: widget.includeZero,
    );
    final NebaChartScale? secondScale = secondExtent == null
        ? null
        : secondaryAxis?.tickCount == null
        ? chartAlignedScale(
            secondExtent,
            scale.ticks.length - 1,
            min: secondaryAxis?.min,
            max: secondaryAxis?.max,
            includeZero: widget.includeZero,
          )
        : chartValueScale(
            secondExtent,
            min: secondaryAxis?.min,
            max: secondaryAxis?.max,
            tickCount: secondaryAxis?.tickCount,
            includeZero: widget.includeZero,
          );
    final String Function(Object value, int index)? valueTicks = yAxis?.tickFormat;
    final String Function(Object value, int index)? secondTicks = secondaryAxis?.tickFormat;
    final String Function(Object value, int index)? categoryTicks = widget.xAxis?.tickFormat;
    final String Function(double value)? secondFormat = secondTicks == null
        ? null
        : (double value) => secondTicks(chartNumber(value), 0);

    final _ChartData data = _ChartData(
      values: values,
      given: given,
      visible: visible,
      colors: <Color>[
        for (int index = 0; index < series.length; index++)
          chartSeriesColor(series[index], index, tokens),
      ],
      names: <String>[
        for (int index = 0; index < series.length; index++) series[index].name ?? '${index + 1}',
      ],
      count: count,
      labels: labels,
      second: second,
      extent: extent,
      scale: scale,
      secondScale: secondScale,
      tickTexts: <String>[
        for (int index = 0; index < scale.ticks.length; index++)
          valueTicks?.call(chartNumber(scale.ticks[index]), index) ?? format(scale.ticks[index]),
      ],
      secondTickTexts: <String>[
        for (int index = 0; index < (secondScale?.ticks.length ?? 0); index++)
          secondTicks?.call(chartNumber(secondScale!.ticks[index]), index) ??
              format(secondScale!.ticks[index]),
      ],
      categoryTexts: <String>[
        for (int index = 0; index < labels.length; index++)
          categoryTicks?.call(labels[index], index) ?? chartCategoryText(labels[index]),
      ],
      format: format,
      secondFormat: twoAxes ? secondFormat : null,
      described: chartSummarise(<List<NebaChartValue>>[
        for (int index = 0; index < values.length; index++)
          if (firstOf(index)) values[index],
      ], format),
      describedSecond: twoAxes
          ? chartSummarise(<List<NebaChartValue>>[
              for (int index = 0; index < values.length; index++)
                if (secondOf(index)) values[index],
            ], secondFormat ?? format)
          : null,
    );

    chartWarnPaletteOverflow(series.length, tokens.chart.series.length);
    _data = data;
    _dataKey = key;

    return data;
  }

  // ----- Layout --------------------------------------------------------------

  _ChartModel _modelFor({
    required _ChartData data,
    required double width,
    required double plotHeight,
    required NebaSize size,
    required double fontSize,
    required NebaTokens tokens,
    required TextStyle base,
    required TextDirection direction,
  }) {
    final Object key = (
      data,
      width,
      plotHeight,
      size,
      fontSize,
      tokens,
      base,
      direction,
      widget.inset,
      widget.headroom,
      widget.bandRatio,
    );
    final _ChartModel? cached = _model;

    if (cached != null && key == _modelKey) {
      return cached;
    }

    final NebaChartAxis? valueAxis = widget.yAxis;
    final NebaChartAxis? categoryAxis = widget.xAxis;
    final NebaChartAxis? secondaryAxis = widget.secondaryAxis;
    final NebaChartScale scale = data.scale;
    final NebaChartScale? secondScale = data.secondScale;
    final bool valueHidden = valueAxis?.hidden ?? false;
    final bool categoryHidden = categoryAxis?.hidden ?? false;
    final bool secondHidden = secondaryAxis?.hidden ?? false;
    final int count = data.count;

    double widest(List<String> texts) {
      return texts.fold<double>(
        0,
        (double most, String text) => math.max(most, chartTextWidth(text, fontSize)),
      );
    }

    final double widestTick = widest(data.tickTexts);
    final double widestSecondTick = widest(data.secondTickTexts);
    final double axisLabelBand = fontSize + 6;
    final double secondBand = secondScale != null && !secondHidden
        ? secondaryAxis?.thickness ?? widestSecondTick + 10
        : 0;
    final bool namesLeftAxis = valueAxis?.label != null && !valueHidden;
    final bool namesSecondAxis =
        secondScale != null && secondaryAxis?.label != null && !secondHidden;
    final NebaChartTurn turn = chartTurnedAxis(
      categoryHidden ? 0 : categoryAxis?.tickAngle ?? 0,
      fontSize,
    );
    final bool tilted = turn.tilted;
    final double valueBand = valueHidden ? 0 : widestTick + 10;
    final double slot = (width - valueBand - 16) / math.max(1, count);
    // Cut a long name to its slot rather than dropping labels until the rest
    // fit; below about four characters that stops helping, and the stride
    // takes over.
    final double tiltRoom = math.min(140, plotHeight * 0.4);
    final bool cutsLabels = tilted || slot - 6 >= fontSize * 2.4;
    final double cutTo = tilted ? turn.cut(tiltRoom) : slot - 6;
    final List<String> categoryTexts = cutsLabels
        ? <String>[
            for (final String text in data.categoryTexts) chartTruncate(text, cutTo, fontSize),
          ]
        : data.categoryTexts;
    final double widestCategory = widest(categoryTexts);
    final double labelDepth = turn.depth(widestCategory);
    final double bottomBand = categoryHidden
        ? 0
        : labelDepth + 12 + (categoryAxis?.label != null ? axisLabelBand : 0);
    final double left = valueAxis?.thickness ?? valueBand;
    final double bottom = categoryAxis?.thickness ?? bottomBand;
    // The last label is centred on the last tick, so half of it hangs past
    // the plot; a turned one hangs off one side only.
    final double rightPad =
        (tilted
            ? (turn.angle > 0 ? turn.overhang(widestCategory) + 8 : 8)
            : math.max(8, categoryTexts.isNotEmpty ? turn.overhang(widestCategory) : 8)) +
        secondBand;
    final double topPad =
        chartMarkerRadii[size]! +
        4 +
        widget.headroom +
        (namesLeftAxis || namesSecondAxis ? axisLabelBand + 2 : 0);
    final Rect plot = Rect.fromLTWH(
      left,
      topPad,
      math.max(0, width - left - rightPad),
      math.max(0, plotHeight - topPad - bottom),
    );
    final TextStyle textStyle = base.copyWith(
      fontSize: fontSize,
      color: tokens.mutedFg,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      height: 1.2,
    );
    final NebaChartLayout layout = NebaChartLayout(
      plot: plot,
      values: data.values,
      visible: data.visible,
      colors: data.colors,
      scale: scale,
      secondScale: secondScale,
      second: data.second,
      inset: widget.inset,
      count: count,
      band: NebaChartBand(
        widget.inset ? math.max(1, count - 1) : count,
        plot.width,
        widget.bandRatio,
      ),
      categories: data.labels,
      size: size,
      fontSize: fontSize,
      tokens: tokens,
      textStyle: textStyle,
      textDirection: direction,
      format: data.format,
      secondFormat: data.secondFormat,
    );

    final List<Object> chrome = <Object>[];
    final TextStyle named = textStyle.copyWith(fontWeight: FontWeight.w500);
    TextPainter text(String value, [TextStyle? style]) {
      return chartTextPainter(value, style ?? textStyle, direction);
    }

    // The value axis' gridlines, and its labels beside them. A gridline is
    // drawn at every tick, and the labels are thinned: a line with no number
    // on it is still a line the eye can measure against.
    final bool grid = (valueAxis?.grid ?? true) && !valueHidden;
    final int ticks = scale.ticks.length;
    final int valueStride = chartTickStride(ticks, plot.height, fontSize * 2);
    final double valueStep = ticks > 1
        ? (layout.valuePx(scale.ticks[1]) - layout.valuePx(scale.ticks[0])).abs()
        : plot.height;
    final bool lastValue = chartFitsLast(ticks, valueStride, valueStep, fontSize * 1.6);

    for (int index = 0; index < ticks; index++) {
      final double tick = scale.ticks[index];
      final double along = layout.valuePx(tick);

      if (grid) {
        chrome.add(
          _Rule(
            Offset(plot.left, along),
            Offset(plot.right, along),
            tick.abs() < 1e-9 ? tokens.chartBaseline : tokens.chartGrid,
          ),
        );
      }

      if (!valueHidden && chartShowsTick(index, ticks, valueStride, roomForLast: lastValue)) {
        chrome.add(
          NebaChartLabel(
            text(data.tickTexts[index]),
            Offset(plot.left - 8, along),
            anchor: -1,
            central: true,
          ),
        );
      }
    }

    // The category axis. Its rule sits at the baseline rather than at the
    // bottom of the plot: with negative values those are not the same line.
    if (!categoryHidden) {
      final double zero = layout.zeroPxOf();
      final bool categoryGrid = categoryAxis?.grid ?? false;
      final double room = turn.room(widestCategory);
      final int stride = chartTickStride(categoryTexts.length, plot.width, room);
      final double step = categoryTexts.length > 1
          ? (layout.categoryPx(1) - layout.categoryPx(0)).abs()
          : plot.width;
      final bool lastCategory = chartFitsLast(
        categoryTexts.length,
        stride,
        step,
        tilted ? room : chartTextWidth(categoryTexts.isEmpty ? '' : categoryTexts.last, fontSize),
      );
      final double baseline = plot.bottom + turn.offset;

      chrome.add(_Rule(Offset(plot.left, zero), Offset(plot.right, zero), tokens.chartAxis));

      for (int index = 0; index < categoryTexts.length; index++) {
        final bool labelled = chartShowsTick(
          index,
          categoryTexts.length,
          stride,
          roomForLast: lastCategory,
        );

        if (!labelled && !categoryGrid) {
          continue;
        }

        final double along = plot.left + layout.categoryPx(index);

        if (categoryGrid) {
          chrome.add(_Rule(Offset(along, plot.top), Offset(along, plot.bottom), tokens.chartGrid));
        }

        if (labelled) {
          chrome.add(
            NebaChartLabel(
              text(categoryTexts[index]),
              Offset(along, baseline),
              anchor: turn.anchor,
              central: tilted,
              angle: turn.angle,
            ),
          );
        }
      }
    }

    // The second value axis, on the far edge. It casts no gridlines: its
    // scale is cut into as many intervals as the first, so each of its ticks
    // sits on a rule already there.
    if (secondScale != null && !secondHidden) {
      final int ticks = secondScale.ticks.length;

      for (int index = 0; index < ticks; index++) {
        if (!chartShowsTick(index, ticks, valueStride, roomForLast: lastValue)) {
          continue;
        }

        final double along =
            plot.top + (1 - secondScale.fraction(secondScale.ticks[index])) * plot.height;

        chrome.add(
          NebaChartLabel(
            text(data.secondTickTexts[index]),
            Offset(plot.right + 8, along),
            anchor: 1,
            central: true,
          ),
        );
      }

      if (secondaryAxis?.label case final String name) {
        chrome.add(NebaChartLabel(text(name, named), Offset(plot.right, fontSize + 2), anchor: -1));
      }
    }

    // The axis names: the left axis' above the plot where the plot starts, and
    // the bottom axis' under its labels at the far end.
    if (valueAxis?.label case final String name when !valueHidden) {
      chrome.add(NebaChartLabel(text(name, named), Offset(plot.left, fontSize + 2), anchor: 1));
    }

    if (categoryAxis?.label case final String name when !categoryHidden) {
      chrome.add(
        NebaChartLabel(
          text(name, named),
          Offset(plot.right, plot.bottom + labelDepth + fontSize + 12),
          anchor: -1,
        ),
      );
    }

    // The references, under the marks and over the grid: heavier than a
    // gridline because they carry meaning, dashed and neutral because they
    // are not the reader's data.
    final double first = widget.inset ? 0 : -0.5;
    final double last = widget.inset ? count - 1.0 : count - 0.5;

    for (final NebaChartReference one in widget.references ?? const <NebaChartReference>[]) {
      final bool onValue = one.axis == NebaChartReferenceAxis.value;
      final double? to = one.to;
      final double high = math.max(one.value, to ?? one.value);
      final double low = math.min(one.value, to ?? one.value);

      if (!onValue && (high < first || low > last)) {
        continue;
      }

      bool inside(double number) => onValue || (number >= first && number <= last);
      double clamp(double number) => onValue ? number : number.clamp(first, last).toDouble();
      double at(double number) =>
          onValue ? layout.valuePx(number) : plot.left + layout.categoryPx(number);

      final double from = at(clamp(one.value));
      final double? end = to == null ? null : at(clamp(to));
      final double near = end == null ? from : math.min(from, end);
      final double far = end == null ? from : math.max(from, end);
      final Color ink = chartResolveColor(one.color, tokens) ?? tokens.mutedFg;

      if (end != null) {
        chrome.add(
          _Wash(
            onValue
                ? Rect.fromLTWH(plot.left, near, plot.width, far - near)
                : Rect.fromLTWH(near, plot.top, far - near, plot.height),
            mixOklab(ink, 0.12, transparent),
          ),
        );
      }

      for (final double edge in <double>[one.value, ?to]) {
        if (!inside(edge)) {
          continue;
        }

        final double along = at(edge);

        chrome.add(
          onValue
              ? _Rule(Offset(plot.left, along), Offset(plot.right, along), ink, solid: one.solid)
              : _Rule(Offset(along, plot.top), Offset(along, plot.bottom), ink, solid: one.solid),
        );
      }

      if (one.label case final String name) {
        chrome.add(
          NebaChartLabel(
            text(name, named.copyWith(color: ink)),
            onValue ? Offset(plot.right - 4, near - 5) : Offset(near + 4, plot.top + fontSize),
            anchor: onValue ? -1 : 1,
          ),
        );
      }
    }

    final _ChartModel model = _ChartModel(layout, chrome);
    final _ChartModel? previous = _model;

    // Disposed after the frame that stops painting it, never under a painter.
    if (previous != null) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => previous.dispose());
    }

    _model = model;
    _modelKey = key;

    return model;
  }

  T _tracedFor(NebaChartLayout layout) {
    final Object key = (layout, widget.traceKey);
    final T? cached = _traced;

    if (cached != null && key == _tracedKey) {
      return cached;
    }

    final T traced = widget.trace(layout);

    _traced = traced;
    _tracedKey = key;

    return traced;
  }

  Widget _tableFor(_ChartData data, String? caption) {
    final List<NebaChartReference> named = <NebaChartReference>[
      for (final NebaChartReference one in widget.references ?? const <NebaChartReference>[])
        if (one.label != null) one,
    ];
    final Object key = (data, caption, widget.xAxis?.label, widget.references);
    final Widget? cached = _table;

    if (cached != null && key == _tableKey) {
      return cached;
    }

    String reference(double value, NebaChartReference one) {
      if (one.axis == NebaChartReferenceAxis.value) {
        return data.format(value);
      }

      final int index = value.round();

      return chartCategoryText(
        index >= 0 && index < data.labels.length && index == value ? data.labels[index] : value,
      );
    }

    final Widget table = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NebaChartDataTable(
          caption: caption,
          columns: <String>[widget.xAxis?.label ?? '', ...data.names],
          points: data.given.fold<int>(0, (int sum, List<NebaChartValue> row) => sum + row.length),
          rows: <List<String>>[
            for (int index = 0; index < data.labels.length; index++)
              <String>[
                chartCategoryText(data.labels[index]),
                for (int series = 0; series < data.given.length; series++)
                  if (index < data.given[series].length)
                    data.given[series][index].label ??
                        switch (data.given[series][index].value) {
                          final double value => data.formatFor(series)(value),
                          null => '',
                        }
                  else
                    '',
              ],
          ],
        ),
        // The references, for the reader who gets the table instead of the
        // picture: a target drawn across the plot is context the numbers
        // alone do not carry.
        for (final NebaChartReference one in named)
          NebaVisuallyHidden(
            child: Text(
              '${one.label}: ${reference(one.value, one)}'
              '${one.to == null ? '' : '–${reference(one.to!, one)}'}',
            ),
          ),
      ],
    );

    _table = table;
    _tableKey = key;

    return table;
  }

  // ----- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final Map<String, String> words = nebaMessages(context, 'chart', locale: widget.locale);
    final Map<String, String> emptyWords = nebaMessages(context, 'empty', locale: widget.locale);
    final _ChartData data = _dataFor(tokens);
    final double plotHeight = widget.height ?? chartPlotHeights[size]!;
    final double fontSize = MediaQuery.textScalerOf(context).scale(chartFontSizes[size]!);
    final TextStyle base = DefaultTextStyle.of(context).style;
    final TextDirection direction = Directionality.of(context);
    final NebaChartTooltipMode mode = _mode;
    final Object? tooltip = widget.tooltip;
    final NebaChartTooltip options = tooltip is NebaChartTooltip
        ? tooltip
        : const NebaChartTooltip();
    final bool nothing = data.count == 0 || data.extent == null;
    final int? column = _column;
    final int? active = column != null && column < data.count && !nothing ? column : null;

    final List<NebaChartTooltipItem> readings = active == null
        ? const <NebaChartTooltipItem>[]
        : <NebaChartTooltipItem>[
            for (int series = 0; series < data.values.length; series++)
              if (data.visible[series] && active < data.values[series].length)
                if (data.values[series][active].value case final double value)
                  NebaChartTooltipItem(
                    seriesIndex: series,
                    name: widget.series[series].name,
                    color:
                        chartResolveColor(data.values[series][active].color, tokens) ??
                        data.colors[series],
                    value: value,
                    formatted: data.formatFor(series)(value),
                    label: data.values[series][active].label,
                  ),
          ];
    final int? pointerSeries = _pointerSeries;
    final NebaChartTooltipItem? picked =
        mode == NebaChartTooltipMode.item && readings.length > 1 && pointerSeries != null
        ? readings
              .where((NebaChartTooltipItem item) => item.seriesIndex == pointerSeries)
              .firstOrNull
        : null;
    final List<NebaChartTooltipItem> items = picked == null
        ? readings
        : <NebaChartTooltipItem>[picked];
    final String? heading = active == null ? null : chartCategoryText(data.labels[active]);

    // The legend.
    final Object? legend = widget.legend;
    final NebaChartLegend legendOptions = legend is NebaChartLegend
        ? legend
        : legend == false
        ? const NebaChartLegend(interactive: false)
        : const NebaChartLegend();
    final bool showLegend = legend == true || (legend != false && widget.series.length > 1);
    final Widget? legendBar = showLegend
        ? NebaChartLegendBar(
            names: data.names,
            colors: data.colors,
            visible: data.visible,
            hovered: _legendHover,
            options: legendOptions,
            size: size,
            color: widget.color,
            onToggle: _toggle,
            onHover: _hoverLegend,
            reserve: legendOptions.showValue ? data.reserve : null,
            values: legendOptions.showValue && active != null
                ? <String?>[
                    for (int series = 0; series < data.values.length; series++)
                      if (active < data.values[series].length)
                        switch (data.values[series][active].value) {
                          final double value => data.formatFor(series)(value),
                          null => null,
                        }
                      else
                        null,
                  ]
                : null,
          )
        : null;

    // The sentence the plot is described by: how many values there are and
    // between which two they fall, rather than every one of them.
    final ({int count, String min, String max}) described = data.described;
    final ({int count, String min, String max})? describedSecond = data.describedSecond;
    String sentence(String template, ({int count, String min, String max}) summary) {
      return fillNebaMessage(template, <String, String>{
        'count': nebaFormatNumber(summary.count),
        'min': summary.min,
        'max': summary.max,
      });
    }

    final String summary = <String>[
      sentence(words['summary']!, described),
      if (describedSecond != null && describedSecond.count > 0)
        sentence(words['summarySecondary']!, describedSecond),
    ].join(' ');

    final Widget plot = NebaChartBox(
      key: _plotKey,
      height: plotHeight,
      builder: (BuildContext context, double width) {
        if (nothing) {
          return Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg, fontSize: NebaScale.metaText[size]),
              textAlign: TextAlign.center,
              child: widget.empty ?? Text(emptyWords['title']!),
            ),
          );
        }

        final _ChartModel model = _modelFor(
          data: data,
          width: width,
          plotHeight: plotHeight,
          size: size,
          fontSize: fontSize,
          tokens: tokens,
          base: base,
          direction: direction,
        );
        final NebaChartLayout layout = model.layout;
        final T traced = _tracedFor(layout);
        final bool crosshair =
            active != null && mode == NebaChartTooltipMode.category && options.crosshair;
        final Size area = Size(width, plotHeight);
        final List<Widget> layers = <Widget>[
          RepaintBoundary(
            child: CustomPaint(size: area, painter: _ChromePainter(model)),
          ),
          if (crosshair)
            CustomPaint(
              size: area,
              painter: _CrosshairPainter(
                layout.plot.left + layout.categoryPx(active),
                layout.plot,
                tokens.chartBaseline,
              ),
            ),
          CustomPaint(
            size: area,
            painter: widget.painter(
              NebaChartMarks<T>(
                layout: layout,
                traced: traced,
                activeIndex: active,
                emphasis: _emphasis,
              ),
            ),
          ),
        ];

        if (active != null && items.isNotEmpty && mode != NebaChartTooltipMode.none) {
          final double anchorX = layout.plot.left + layout.categoryPx(active);
          final double anchorY = layout.plot.top;
          final bool flip = layout.categoryPx(active) / math.max(1, layout.plot.width) > 0.6;
          final Widget panel =
              options.builder?.call(
                context,
                NebaChartTooltipContext(index: active, category: data.labels[active], items: items),
              ) ??
              NebaChartTooltipPanel(
                heading: heading ?? '',
                items: items,
                size: size,
                color: widget.color,
              );

          layers.add(
            Positioned(
              left: flip ? null : anchorX + 10,
              right: flip ? width - anchorX + 10 : null,
              top: anchorY,
              child: IgnorePointer(child: panel),
            ),
          );
        }

        return Stack(clipBehavior: Clip.none, children: layers);
      },
    );

    final BorderRadius ringRadius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);
    final Widget readable = Semantics(
      container: true,
      image: true,
      label: widget.label ?? words['label'],
      hint: nothing ? null : summary,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: !nothing,
        skipTraversal: nothing,
        onKeyEvent: _onKey,
        onFocusChange: (bool focused) {
          setState(() => _focused = focused);

          if (!focused) {
            _clear();
          }
        },
        child: NebaFocusRing(
          visible: _focused,
          color: tokens.roles(widget.color).ring,
          borderRadius: ringRadius,
          child: ExcludeSemantics(
            child: MouseRegion(
              onHover: (PointerHoverEvent event) => _read(event.localPosition),
              onExit: (PointerExitEvent event) {
                if (event.kind != PointerDeviceKind.touch) {
                  _clear();
                }
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                // A tap moves nothing, so the press itself is what reads the
                // point, and it stays read until a press lands elsewhere.
                onPointerDown: (PointerDownEvent event) {
                  if (event.kind == PointerDeviceKind.touch) {
                    _read(event.localPosition);
                  }
                },
                child: plot,
              ),
            ),
          ),
        ),
      ),
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
        if (!nothing) _tableFor(data, widget.label),
        if (mode != NebaChartTooltipMode.none)
          NebaVisuallyHidden(
            child: NebaLiveRegion(
              role: SemanticsRole.status,
              child: Text(chartReadout(heading, items)),
            ),
          ),
      ],
    );
  }
}

/// The axes, the grid and the references: everything on the plot that does
/// not move with the pointer.
class _ChromePainter extends CustomPainter {
  const _ChromePainter(this.model);

  final _ChartModel model;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Object op in model.chrome) {
      switch (op) {
        case _Rule(:final Offset from, :final Offset to, :final Color color, :final bool solid):
          chartPaintRule(canvas, from, to, color, solid: solid);
        case _Wash(:final Rect rect, :final Color color):
          canvas.drawRect(rect, Paint()..color = color);
        case NebaChartLabel():
          op.paint(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(_ChromePainter oldDelegate) => !identical(oldDelegate.model, model);
}

/// The line dropped through the plot at the active category.
class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter(this.x, this.plot, this.color);

  final double x;
  final Rect plot;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    chartPaintRule(canvas, Offset(x, plot.top), Offset(x, plot.bottom), color);
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.plot != plot || oldDelegate.color != color;
  }
}

/// A linear gradient from [from] to [to] in [colors], for a fill or a stroke.
Shader chartGradient(Offset from, Offset to, List<Color> colors) {
  return ui.Gradient.linear(from, to, colors);
}
