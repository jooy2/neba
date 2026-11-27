/// `NebaHeatmapChart`, `NebaHeatmapShape` and `NebaHeatmapScale`, a magnitude
/// per cell, coloured rather than measured.
library;

import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
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

/// What a [NebaHeatmapChart] is drawn as.
enum NebaHeatmapShape {
  /// A cell per row and column: two categorical axes and one magnitude, such
  /// as hours against weekdays or a cohort against a week.
  grid,

  /// A tile per datum, sized by its share and packed to fill the box: parts
  /// of a whole that are grouped, and more of them than a pie can hold.
  treemap,
}

/// How a [NebaHeatmapChart] colours a magnitude.
enum NebaHeatmapScale {
  /// One hue, pale to deep: right whenever more is simply more.
  sequential,

  /// Two hues either side of a neutral, for a value whose middle means
  /// something: over and under target, gained and lost.
  diverging,
}

/// The corner of a cell: a tile is a block, not a chip.
const double _cellRadius = 3;

/// How far a cell the reader is not reading is drawn back.
const double _restOpacity = 0.94;

/// A magnitude per cell, coloured rather than measured.
///
/// Two shapes of one idea. A [NebaHeatmapShape.grid] is for two categorical
/// axes where the question is where: which hour of which day, which cohort in
/// which week. A [NebaHeatmapShape.treemap] is for parts of a whole with more
/// parts than a `NebaPieChart` can hold, and it is the same widget because a
/// row of a heatmap and a group of a treemap are both a named series of named
/// magnitudes.
///
/// Colour encodes size here and not identity, so it comes off a one-hue ramp
/// rather than the categorical palette: a heatmap in eight hues says its
/// cells are eight unrelated things.
///
/// ```dart
/// const NebaHeatmapChart(
///   label: 'Sessions by hour and weekday',
///   categories: <Object>['00', '06', '12', '18'],
///   series: <NebaChartSeries>[
///     NebaChartSeries(name: 'Mon', data: <num>[4, 24, 38, 33]),
///     NebaChartSeries(name: 'Tue', data: <num>[3, 27, 40, 36]),
///   ],
/// )
/// ```
class NebaHeatmapChart extends StatefulWidget {
  /// A heatmap of [series].
  const NebaHeatmapChart({
    required this.series,
    this.categories,
    this.shape = NebaHeatmapShape.grid,
    this.scale = NebaHeatmapScale.sequential,
    this.midpoint = 0,
    this.min,
    this.max,
    this.valueLabels = NebaChartValueLabels.none,
    this.legend,
    this.xAxis,
    this.yAxis,
    this.height,
    this.format,
    this.locale,
    this.label,
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

  /// The rows. Each series is a row of the grid or a group of the treemap,
  /// and each datum a cell or a tile: `y` is the magnitude, `x` names the
  /// column, and a `null` is a gap, left as the surface rather than drawn as
  /// the bottom of the scale.
  final List<NebaChartSeries> series;

  /// The column names: a [String], a [num] or a [DateTime]. Points may carry
  /// their own `x` instead.
  final List<Object>? categories;

  /// A grid of cells or a treemap of tiles.
  final NebaHeatmapShape shape;

  /// How the magnitude is coloured.
  final NebaHeatmapScale scale;

  /// Where a diverging scale turns over.
  final double midpoint;

  /// Where the scale starts. Taken from the data when left out, so two charts
  /// are not comparable until they are given the same bounds.
  final double? min;

  /// Where the scale ends. Taken from the data when left out.
  final double? max;

  /// [NebaChartValueLabels.all] writes each cell's value on it, where the
  /// cell has room for the text with some either side; a label that does not
  /// fit is dropped rather than clipped. The other two do not apply here.
  final NebaChartValueLabels valueLabels;

  /// `true`, `false` or a [NebaChartLegend] whose `side` and `align` place
  /// the scale bar. On unless it is `false`.
  final Object? legend;

  /// The column axis along the bottom of a grid. Both axes here are category
  /// axes, so its `min`, `max`, `tickCount` and `grid` are not read; `label`,
  /// `tickFormat`, `tickAngle`, `hidden` and `thickness` are. A treemap reads
  /// neither axis.
  final NebaChartAxis? xAxis;

  /// The row axis down the side of a grid: the same as [xAxis] less
  /// `tickAngle`, since a row already has a line of its own.
  final NebaChartAxis? yAxis;

  /// How tall the drawing is, the names inside it. The size ladder when left
  /// out: 120, 160, 220, 280 and 360 logical pixels.
  final double? height;

  /// How a number is written everywhere it appears: the cells, the scale
  /// bar, the tooltip and the table.
  final String Function(num value)? format;

  /// The language of the chart's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartTooltip], whose `builder` draws the panel.
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type and the height. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet and the focus ring.
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
  State<NebaHeatmapChart> createState() => _NebaHeatmapChartState();
}

/// One cell or tile, placed: its slot, the rectangle drawn in it once the
/// gap is taken off, its fill, and the lines written on it.
class _Cell {
  _Cell({
    required this.row,
    required this.index,
    required this.value,
    required this.slot,
    required this.drawn,
    required this.fill,
    required this.lines,
  });

  final int row;
  final int index;
  final NebaChartValue value;
  final Rect slot;

  /// `null` for a slot too small to draw anything in.
  final RRect? drawn;
  final Color fill;
  final List<NebaChartLabel> lines;
}

/// Everything the chart drew at one width: the cells in the order the keys
/// walk them, the names around them, and the plot they fill.
class _Layout {
  _Layout({required this.cells, required this.names, required this.plot});

  final List<_Cell> cells;
  final List<NebaChartLabel> names;
  final Rect plot;

  void dispose() {
    for (final _Cell cell in cells) {
      for (final NebaChartLabel line in cell.lines) {
        line.painter.dispose();
      }
    }

    for (final NebaChartLabel name in names) {
      name.painter.dispose();
    }
  }
}

class _NebaHeatmapChartState extends State<NebaHeatmapChart> with SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode(debugLabel: 'NebaHeatmapChart');
  final GlobalKey _plotKey = GlobalKey();
  late final NebaChartEmphasis _emphasis = NebaChartEmphasis(vsync: this);
  late final NebaChartPressOutside _outside = NebaChartPressOutside(
    plot: _plotKey,
    onPress: _clear,
  );

  ({int row, int index})? _active;
  bool _focused = false;

  _Layout? _layout;
  Object? _layoutKey;
  Widget? _table;
  Object? _tableKey;

  @override
  void dispose() {
    _outside.dispose();
    _layout?.dispose();
    _focus.dispose();
    _emphasis.dispose();
    super.dispose();
  }

  bool get _tooltipOff => chartTooltipMode(widget.tooltip) == NebaChartTooltipMode.none;

  List<_Cell> get _cells => _layout?.cells ?? const <_Cell>[];

  int _positionOf(({int row, int index})? at) {
    if (at == null) {
      return -1;
    }

    return _cells.indexWhere((_Cell cell) => cell.row == at.row && cell.index == at.index);
  }

  void _setActive(({int row, int index})? at) {
    if (at == _active) {
      return;
    }

    setState(() => _active = at);
    _emphasise();
    _outside.watch(at != null);
  }

  void _clear() => _setActive(null);

  /// The cell being read comes forward and the rest stay drawn back.
  void _emphasise() {
    if (!mounted) {
      return;
    }

    final int at = _positionOf(_active);

    _emphasis.retarget(
      opacity: const <double>[],
      active: at < 0 ? null : at,
      duration: nebaDuration(context, NebaScale.duration),
    );
  }

  /// Reads the cell under [local]. Between two cells, where the surface shows
  /// through, the reading stays where it was.
  void _point(Offset local) {
    if (_tooltipOff) {
      return;
    }

    for (final _Cell cell in _cells) {
      if (cell.drawn?.outerRect.contains(local) ?? false) {
        _setActive((row: cell.row, index: cell.index));

        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final List<_Cell> cells = _cells;

    if (event is! KeyDownEvent && event is! KeyRepeatEvent || _tooltipOff || cells.isEmpty) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final int at = _positionOf(_active);
    final bool down = key == LogicalKeyboardKey.arrowDown;
    final bool up = key == LogicalKeyboardKey.arrowUp;
    final bool forward = key == LogicalKeyboardKey.arrowRight || down;

    // On a grid the vertical arrows keep the column and change the row,
    // skipping a row whose cell in that column is a gap. A treemap has no
    // columns to keep, so every arrow walks its tiles largest first.
    if (widget.shape == NebaHeatmapShape.grid && at != -1 && (down || up)) {
      final _Cell here = cells[at];
      _Cell? next;

      for (final _Cell cell in cells) {
        if (cell.index != here.index || (down ? cell.row <= here.row : cell.row >= here.row)) {
          continue;
        }

        if (next == null || (down ? cell.row < next.row : cell.row > next.row)) {
          next = cell;
        }
      }

      if (next != null) {
        _setActive((row: next.row, index: next.index));
      }
    } else if (forward || key == LogicalKeyboardKey.arrowLeft || up) {
      final _Cell next = forward
          ? cells[math.min(cells.length - 1, at + 1)]
          : cells[math.max(0, (at == -1 ? cells.length : at) - 1)];

      _setActive((row: next.row, index: next.index));
    } else if (key == LogicalKeyboardKey.escape) {
      if (_active == null) {
        return KeyEventResult.ignored;
      }

      _clear();
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  /// The hidden table: a row per series and a column per name. A grid's
  /// columns are its categories in place; a treemap's are every name any
  /// group uses, in the order they first appear, each value under its own.
  Widget _tableFor({
    required List<List<NebaChartValue>> values,
    required List<Object> labels,
    required List<String> names,
    required String Function(double value) format,
  }) {
    final NebaHeatmapChart widget = this.widget;
    final Object key = (
      widget.series,
      widget.categories,
      widget.shape,
      widget.label,
      widget.format,
    );
    final Widget? cached = _table;

    if (cached != null && key == _tableKey) {
      return cached;
    }

    final List<String> heads = <String>[];
    final List<List<NebaChartValue?>> rows = <List<NebaChartValue?>>[];

    if (widget.shape == NebaHeatmapShape.grid) {
      heads.addAll(<String>[for (final Object label in labels) chartCategoryText(label)]);

      for (final List<NebaChartValue> one in values) {
        rows.add(<NebaChartValue?>[
          for (int index = 0; index < labels.length; index++)
            if (index < one.length) one[index] else null,
        ]);
      }
    } else {
      final Map<String, int> columnOf = <String, int>{};

      for (final List<NebaChartValue> one in values) {
        final List<NebaChartValue?> out = <NebaChartValue?>[];

        for (int index = 0; index < one.length; index++) {
          final String head = _nameOf(one[index], index, labels);
          final int column = columnOf.putIfAbsent(head, () {
            heads.add(head);

            return heads.length - 1;
          });

          while (out.length <= column) {
            out.add(null);
          }

          out[column] = one[index];
        }

        rows.add(out);
      }
    }

    final Widget table = NebaChartDataTable(
      caption: widget.label,
      columns: <String>['', ...heads],
      points: values.fold<int>(0, (int sum, List<NebaChartValue> one) => sum + one.length),
      rows: <List<String>>[
        for (int at = 0; at < rows.length; at++)
          <String>[
            names[at],
            for (int index = 0; index < heads.length; index++)
              switch (index < rows[at].length ? rows[at][index] : null) {
                NebaChartValue(label: final String label) => label,
                NebaChartValue(value: final double value) => format(value),
                _ => '',
              },
          ],
      ],
    );

    _table = table;
    _tableKey = key;

    return table;
  }

  /// What a tile or a cell calls itself: its own column name, not its
  /// group's.
  String _nameOf(NebaChartValue value, int index, List<Object> labels) {
    final List<Object>? categories = widget.categories;

    return chartCategoryText(
      value.x ??
          (categories != null && index < categories.length ? categories[index] : null) ??
          (index < labels.length ? labels[index] : index),
    );
  }

  _Layout _layoutFor({
    required double width,
    required double plotHeight,
    required List<List<NebaChartValue>> values,
    required List<Object> labels,
    required List<String> names,
    required int columns,
    required double low,
    required double high,
    required String Function(double value) format,
    required double fontSize,
    required NebaTokens tokens,
    required TextStyle base,
    required TextDirection direction,
  }) {
    final NebaHeatmapChart widget = this.widget;
    final Object key = (
      width,
      plotHeight,
      widget.series,
      widget.categories,
      widget.shape,
      widget.scale,
      widget.midpoint,
      low,
      high,
      widget.valueLabels,
      widget.xAxis,
      widget.yAxis,
      widget.format,
      fontSize,
      tokens,
      base,
      direction,
    );
    final _Layout? cached = _layout;

    if (cached != null && key == _layoutKey) {
      return cached;
    }

    final bool treemap = widget.shape == NebaHeatmapShape.treemap;
    final bool diverging = widget.scale == NebaHeatmapScale.diverging;
    final NebaChartAxis? xAxis = widget.xAxis;
    final NebaChartAxis? yAxis = widget.yAxis;
    final TextStyle textStyle = base.copyWith(
      fontSize: fontSize,
      color: tokens.mutedFg,
      height: 1.2,
    );
    TextPainter text(String value, [TextStyle? style]) {
      return chartTextPainter(value, style ?? textStyle, direction);
    }

    // The band the row names take, measured from the names and capped at a
    // quarter of the width: a grid that hands a third of itself to a column
    // of words has stopped being a grid, and a name cut here is whole in the
    // tooltip and the table. A treemap names its tiles on their own faces.
    final bool rowsShown = !treemap && !(yAxis?.hidden ?? false);
    final double room = math.min(150, width * 0.25);
    final List<String> rowTexts = rowsShown
        ? <String>[
            for (int index = 0; index < names.length; index++)
              chartTruncate(
                yAxis?.tickFormat?.call(names[index], index) ?? names[index],
                room,
                fontSize,
              ),
          ]
        : const <String>[];
    final double rowBand = rowsShown
        ? rowTexts.fold<double>(
                0,
                (double most, String one) => math.max(most, chartTextWidth(one, fontSize)),
              ) +
              10
        : 0;

    // The column names, turned by `tickAngle` as a cartesian chart's are, and
    // thinned on one stride measured from the widest, so a short name beside
    // a long one is not given a stride of its own.
    final NebaChartTurn turn = chartTurnedAxis(treemap ? 0 : xAxis?.tickAngle ?? 0, fontSize);
    final double columnRoom = math.min(140, plotHeight * 0.4);
    final List<String> columnTexts = <String>[
      for (int index = 0; index < labels.length; index++)
        if (turn.tilted)
          chartTruncate(
            xAxis?.tickFormat?.call(labels[index], index) ?? chartCategoryText(labels[index]),
            turn.cut(columnRoom),
            fontSize,
          )
        else
          xAxis?.tickFormat?.call(labels[index], index) ?? chartCategoryText(labels[index]),
    ];
    final double widestColumn = columnTexts.fold<double>(
      0,
      (double most, String one) => math.max(most, chartTextWidth(one, fontSize)),
    );
    final double nameBand = fontSize + 6;
    final bool columnsShown = !treemap && !(xAxis?.hidden ?? false);
    final double columnBand = columnsShown
        ? turn.depth(widestColumn) + 8 + (xAxis?.label != null ? nameBand : 0)
        : 0;
    // A row axis' name goes along the top rather than turned on its side.
    final bool namesRows = yAxis?.label != null && rowsShown;
    final double top = namesRows ? nameBand + 2 : 0;
    final double left = yAxis?.thickness ?? rowBand;
    final Rect plot = Rect.fromLTWH(
      left,
      top,
      math.max(0, width - left),
      math.max(0, plotHeight - (xAxis?.thickness ?? columnBand) - top),
    );

    // Where each cell goes: a grid divides the box evenly and a treemap packs
    // it, and past that the two are one drawing.
    final List<({int row, int index, NebaChartValue value, Rect slot})> slots =
        <({int row, int index, NebaChartValue value, Rect slot})>[];

    if (plot.width > 0 && plot.height > 0) {
      if (treemap) {
        final List<({int row, int index, NebaChartValue value})> flat =
            <({int row, int index, NebaChartValue value})>[
              for (int row = 0; row < values.length; row++)
                for (int index = 0; index < values[row].length; index++)
                  if (values[row][index].value != null)
                    (row: row, index: index, value: values[row][index]),
            ];

        // A tile's area is its share, so a negative has no area to be: it
        // stays in the table and off the picture.
        for (final ({int index, Rect rect}) tile in chartSquarify(
          <double>[for (final one in flat) math.max(0, one.value.value!)],
          plot.width,
          plot.height,
        )) {
          final ({int row, int index, NebaChartValue value}) one = flat[tile.index];

          slots.add((
            row: one.row,
            index: one.index,
            value: one.value,
            slot: tile.rect.shift(plot.topLeft),
          ));
        }
      } else {
        final double rowHeight = plot.height / math.max(1, values.length);
        final double cellWidth = plot.width / math.max(1, columns);

        for (int row = 0; row < values.length; row++) {
          for (int index = 0; index < values[row].length; index++) {
            if (values[row][index].value == null) {
              continue;
            }

            slots.add((
              row: row,
              index: index,
              value: values[row][index],
              slot: Rect.fromLTWH(
                plot.left + index * cellWidth,
                plot.top + row * rowHeight,
                cellWidth,
                rowHeight,
              ),
            ));
          }
        }
      }
    }

    final bool labelled = widget.valueLabels == NebaChartValueLabels.all;
    final List<_Cell> cells = <_Cell>[];

    for (final ({int row, int index, NebaChartValue value, Rect slot}) one in slots) {
      // The two pixels between cells are the surface showing through and
      // never a stroke, as between two bars.
      final double w = math.max(0, one.slot.width - chartMarkGap);
      final double h = math.max(0, one.slot.height - chartMarkGap);
      final double magnitude = one.value.value ?? 0;
      final int step = chartRampStep(
        magnitude,
        low,
        high,
        diverging: diverging,
        midpoint: widget.midpoint,
      );
      final Color? own = chartResolveColor(one.value.color, tokens);
      final Color fill =
          own ?? (diverging ? tokens.chart.diverging : tokens.chart.sequential)[step];
      // Inside a filled mark is the one place a label does not wear a text
      // token: which of the two it wears is decided per step.
      final Color ink = own != null
          ? tokens.surface
          : tokens.ink((diverging ? tokens.chart.divergingInk : tokens.chart.sequentialInk)[step]);
      // A tile says what it is and a cell says how much: a grid's two
      // coordinates are already written along its edges, and nothing is
      // written anywhere else on a treemap.
      final String value = labelled ? format(magnitude) : '';
      final List<String> wanted = treemap
          ? <String>[_nameOf(one.value, one.index, labels), if (labelled) value]
          : <String>[if (labelled) value];
      final List<String> written = <String>[
        for (final String line in wanted)
          if (w > 0 && h > 0 && _fits(line, w, h / wanted.length, fontSize))
            chartTruncate(line, one.slot.width - 8, fontSize),
      ];
      final Offset middle = one.slot.center;

      cells.add(
        _Cell(
          row: one.row,
          index: one.index,
          value: one.value,
          slot: one.slot,
          drawn: w <= 0 || h <= 0
              ? null
              : RRect.fromRectAndRadius(
                  Rect.fromLTWH(
                    one.slot.left + chartMarkGap / 2,
                    one.slot.top + chartMarkGap / 2,
                    w,
                    h,
                  ),
                  Radius.circular(math.min(_cellRadius, math.min(w / 2, h / 2))),
                ),
          fill: fill,
          lines: <NebaChartLabel>[
            for (int line = 0; line < written.length; line++)
              NebaChartLabel(
                text(
                  written[line],
                  textStyle.copyWith(
                    color: line == 0 ? ink : ink.withValues(alpha: ink.a * 0.85),
                    fontWeight: line == 0 ? FontWeight.w500 : FontWeight.w400,
                    fontFeatures: line == 0 && treemap
                        ? null
                        : const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
                middle + Offset(0, (line - (written.length - 1) / 2) * (fontSize + 2)),
                central: true,
              ),
          ],
        ),
      );
    }

    // The grid's two axes, each in a band of its own: written over the cells
    // they would be unreadable, and the cells have no contrast to spare.
    final List<NebaChartLabel> chrome = <NebaChartLabel>[];
    final TextStyle named = textStyle.copyWith(fontWeight: FontWeight.w500);

    for (int index = 0; index < rowTexts.length; index++) {
      chrome.add(
        NebaChartLabel(
          text(rowTexts[index]),
          Offset(
            plot.left - 8,
            plot.top + (index + 0.5) * plot.height / math.max(1, values.length),
          ),
          anchor: -1,
          central: true,
        ),
      );
    }

    if (columnsShown) {
      final double slot = plot.width / math.max(1, columns);
      final int stride = math.max(1, (turn.room(widestColumn) / math.max(1, slot)).ceil());
      final double baseline = plot.bottom + turn.offset - 6;

      for (int index = 0; index < columnTexts.length; index += stride) {
        chrome.add(
          NebaChartLabel(
            text(columnTexts[index]),
            Offset(plot.left + (index + 0.5) * slot, baseline),
            anchor: turn.anchor,
            central: turn.tilted,
            angle: turn.angle,
          ),
        );
      }

      if (xAxis?.label case final String name) {
        chrome.add(
          NebaChartLabel(
            text(name, named),
            Offset(plot.right, plot.bottom + turn.depth(widestColumn) + fontSize + 8),
            anchor: -1,
          ),
        );
      }
    }

    if (namesRows) {
      chrome.add(
        NebaChartLabel(text(yAxis!.label!, named), Offset(plot.left, fontSize + 2), anchor: 1),
      );
    }

    final _Layout layout = _Layout(cells: cells, names: chrome, plot: plot);
    final _Layout? previous = _layout;

    // Disposed after the frame that stops painting it, never under a painter.
    if (previous != null) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => previous.dispose());
    }

    _layout = layout;
    _layoutKey = key;

    return layout;
  }

  @override
  Widget build(BuildContext context) {
    final NebaHeatmapChart widget = this.widget;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.text;
    final Map<String, String> words = nebaMessages(context, 'chart', locale: widget.locale);
    final String Function(num value)? own = widget.format;
    final String Function(double value) format = own == null
        ? nebaFormatCompact
        : (double value) => own(chartNumber(value));
    final List<List<NebaChartValue>> values = chartValuesOf(widget.series);
    final int columns = chartCategoryCount(widget.series);
    final List<Object> labels = <Object>[
      for (int index = 0; index < columns; index++)
        chartCategoryAt(index, widget.categories, values),
    ];
    final List<String> names = <String>[
      for (int index = 0; index < widget.series.length; index++)
        widget.series[index].name ?? '${index + 1}',
    ];

    // One ladder for the whole chart and not one per row: a cell's colour has
    // to mean the same number wherever it is.
    final ({double min, double max})? extent = chartExtentOf(values, stacked: false);
    final double low = widget.min ?? extent?.min ?? 0;
    final double high = widget.max ?? extent?.max ?? 1;
    final bool diverging = widget.scale == NebaHeatmapScale.diverging;
    final bool nothing = extent == null || columns == 0 || widget.series.isEmpty;
    final double plotHeight = widget.height ?? chartPlotHeights[size]!;
    final double fontSize = MediaQuery.textScalerOf(context).scale(chartFontSizes[size]!);
    final TextStyle base = DefaultTextStyle.of(context).style;
    final TextDirection direction = Directionality.of(context);
    final NebaChartTooltip options = chartTooltipOptions(widget.tooltip);

    // What is being read, off the cells the last layout drew.
    _Cell? hovered;

    if (_active case final ({int row, int index}) at when !nothing) {
      for (final _Cell cell in _cells) {
        if (cell.row == at.row && cell.index == at.index) {
          hovered = cell;
          break;
        }
      }
    }

    final String? heading = hovered == null
        ? null
        : '${names[hovered.row]} · ${_nameOf(hovered.value, hovered.index, labels)}';
    // One row with no name: the heading already says which cell it is.
    final List<NebaChartTooltipItem> items = hovered == null
        ? const <NebaChartTooltipItem>[]
        : <NebaChartTooltipItem>[
            NebaChartTooltipItem(
              seriesIndex: hovered.row,
              color: hovered.fill,
              value: hovered.value.value ?? 0,
              formatted: format(hovered.value.value ?? 0),
              label: hovered.value.label,
            ),
          ];

    final Object? legend = widget.legend;
    final NebaChartLegend legendOptions = legend is NebaChartLegend
        ? legend
        : const NebaChartLegend();
    final double reach = math.max((high - widget.midpoint).abs(), (widget.midpoint - low).abs());
    final Widget? scaleBar = legend != false && !nothing
        ? _ScaleLegend(
            steps: diverging ? tokens.chart.diverging : tokens.chart.sequential,
            from: format(diverging ? widget.midpoint - reach : low),
            to: format(diverging ? widget.midpoint + reach : high),
            middle: diverging ? format(widget.midpoint) : null,
            align: legendOptions.align,
            vertical: legendOptions.side == NebaSide.left || legendOptions.side == NebaSide.right,
            size: size,
          )
        : null;

    final Widget plot = NebaChartBox(
      key: _plotKey,
      height: plotHeight,
      builder: (BuildContext context, double width) {
        if (nothing) {
          return NebaChartEmpty(empty: widget.empty, size: size, locale: widget.locale);
        }

        final _Layout layout = _layoutFor(
          width: width,
          plotHeight: plotHeight,
          values: values,
          labels: labels,
          names: names,
          columns: columns,
          low: low,
          high: high,
          format: format,
          fontSize: fontSize,
          tokens: tokens,
          base: base,
          direction: direction,
        );
        final _Cell? reading = hovered == null || _tooltipOff
            ? null
            : layout.cells
                  .where((_Cell cell) => cell.row == hovered!.row && cell.index == hovered.index)
                  .firstOrNull;
        final Widget Function(BuildContext context, NebaChartTooltipContext reading)? builder =
            options.builder;
        final List<Widget> layers = <Widget>[
          CustomPaint(
            size: Size(width, plotHeight),
            painter: _HeatmapPainter(layout: layout, emphasis: _emphasis),
          ),
          if (reading != null)
            if (builder != null)
              Positioned(
                left: reading.slot.center.dx,
                top: reading.slot.top,
                child: IgnorePointer(
                  child: builder(
                    context,
                    NebaChartTooltipContext(
                      index: reading.index,
                      category:
                          reading.value.x ??
                          (reading.index < labels.length ? labels[reading.index] : reading.index),
                      items: items,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: reading.slot.center.dx > width * 0.6 ? null : reading.slot.center.dx + 10,
                right: reading.slot.center.dx > width * 0.6
                    ? width - reading.slot.center.dx + 10
                    : null,
                top: reading.slot.top,
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
      hint: nothing ? null : chartSummary(words, chartSummarise(values, format)),
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
      legend: scaleBar,
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
        if (!nothing) _tableFor(values: values, labels: labels, names: names, format: format),
        if (!_tooltipOff) NebaChartStatus(heading: heading, items: items),
      ],
    );
  }
}

/// Whether a label fits a cell with room either side. Measured before it is
/// placed and dropped when it does not: a missing label sends the reader to
/// the tooltip, and a clipped one sends them nowhere.
bool _fits(String text, double width, double height, double fontSize) {
  return height >= fontSize * 1.8 &&
      width >= math.min(chartTextWidth(text, fontSize), fontSize * 2.5) + 8;
}

/// The cells, each drawn back until the reader reads it, and the names
/// around them.
class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({required this.layout, required this.emphasis}) : super(repaint: emphasis);

  final _Layout layout;
  final NebaChartEmphasis emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    for (int at = 0; at < layout.cells.length; at++) {
      final _Cell cell = layout.cells[at];
      final RRect? drawn = cell.drawn;

      if (drawn == null) {
        continue;
      }

      final double lift = _restOpacity + (1 - _restOpacity) * emphasis.growthOf(at);

      canvas.drawRRect(drawn, Paint()..color = cell.fill.withValues(alpha: cell.fill.a * lift));

      for (final NebaChartLabel line in cell.lines) {
        line.paint(canvas);
      }
    }

    for (final NebaChartLabel name in layout.names) {
      name.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) {
    return !identical(oldDelegate.layout, layout) || !identical(oldDelegate.emphasis, emphasis);
  }
}

/// The legend a magnitude needs: a bar of the ramp's five steps with the two
/// numbers at its ends, and its middle under it on a diverging scale.
///
/// Five joined blocks rather than a gradient, because five is what the cells
/// are coloured with: a smooth bar would promise a continuum the chart cannot
/// deliver. Nothing on it is pressed, since there is no series to filter.
class _ScaleLegend extends StatelessWidget {
  const _ScaleLegend({
    required this.steps,
    required this.from,
    required this.to,
    required this.middle,
    required this.align,
    required this.vertical,
    required this.size,
  });

  final List<Color> steps;
  final String from;
  final String to;
  final String? middle;
  final NebaAlign align;
  final bool vertical;
  final NebaSize size;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final TextStyle figures = TextStyle(
      fontSize: NebaScale.metaText[size],
      color: tokens.mutedFg,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final String? middle = this.middle;
    final Widget bar = ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          width: vertical ? 80 : 96,
          height: 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final Color step in steps) Expanded(child: ColoredBox(color: step)),
            ],
          ),
        ),
      ),
    );
    // A table rather than a row, so the middle sits in the bar's own column:
    // written beside the bar it would read as a third end.
    final Widget scale = Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            Text(from, style: figures),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: bar),
            Text(to, style: figures),
          ],
        ),
        if (middle != null)
          TableRow(
            children: <Widget>[
              const SizedBox.shrink(),
              Center(child: Text(middle, style: figures)),
              const SizedBox.shrink(),
            ],
          ),
      ],
    );

    if (vertical) {
      return scale;
    }

    return Align(
      alignment: switch (align) {
        NebaAlign.start => AlignmentDirectional.centerStart,
        NebaAlign.center => AlignmentDirectional.center,
        NebaAlign.end => AlignmentDirectional.centerEnd,
      },
      child: scale,
    );
  }
}
