/// `NebaCalendar`, a month inline with the days it is holding lit up.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How many days a [NebaCalendar] holds at once.
enum NebaCalendarMode {
  /// One day, or none: [NebaCalendar].
  single,

  /// Any number of days: [NebaCalendar.multiple].
  multiple,

  /// A span from one day to another: [NebaCalendar.range].
  range,
}

/// Both ends of a span of days. Either may be missing while the span is
/// being chosen.
@immutable
class NebaCalendarRange {
  /// A span from [start] to [end].
  const NebaCalendarRange({this.start, this.end});

  /// The first day.
  final DateTime? start;

  /// The last day.
  final DateTime? end;

  @override
  bool operator ==(Object other) {
    return other is NebaCalendarRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'NebaCalendarRange($start, $end)';
}

/// A month, inline, with the days it is holding lit up: the same grid the
/// pickers open, without a popup around it, for a page where the dates are
/// always in view.
///
/// The month name and the year in the header each open a grid of their own,
/// twelve months and then twelve years at a time, so a distant date is a few
/// presses away. The cells are a control's height, so [renderDay] is room for
/// a dot, a count or a bar under the number, not for a day of entries.
///
/// [NebaCalendar] holds one day, [NebaCalendar.multiple] a list of them, and
/// [NebaCalendar.range] a span, filled from its near end and then its far
/// one. Each is controlled with its `value` and `onValueChange`, or keeps its
/// own state from its `defaultValue`.
///
/// ```dart
/// NebaCalendar(value: day, onValueChange: (DateTime? next) => setState(() => day = next))
/// ```
class NebaCalendar extends StatefulWidget {
  /// A calendar holding one day.
  const NebaCalendar({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.size,
    this.color,
    this.elevation,
    this.bordered = true,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.granularity = NebaDateGranularity.day,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.locale,
    this.weekStartsOn,
    this.showOutsideDays = true,
    this.renderDay,
    this.labels,
    super.key,
  }) : mode = NebaCalendarMode.single,
       values = null,
       defaultValues = null,
       onValuesChange = null,
       range = null,
       defaultRange = null,
       onRangeChange = null,
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// A calendar holding any number of days. A press on a day it holds takes
  /// it back out.
  ///
  /// [value], [defaultValue] and [onValueChange] speak in lists here, which
  /// is why this is a constructor of its own.
  const NebaCalendar.multiple({
    List<DateTime>? value,
    List<DateTime>? defaultValue,
    ValueChanged<List<DateTime>>? onValueChange,
    this.size,
    this.color,
    this.elevation,
    this.bordered = true,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.granularity = NebaDateGranularity.day,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.locale,
    this.weekStartsOn,
    this.showOutsideDays = true,
    this.renderDay,
    this.labels,
    super.key,
  }) : mode = NebaCalendarMode.multiple,
       values = value,
       defaultValues = defaultValue,
       onValuesChange = onValueChange,
       value = null,
       defaultValue = null,
       onValueChange = null,
       range = null,
       defaultRange = null,
       onRangeChange = null,
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// A calendar holding a span. The first press sets the start and the
  /// second the end; a press before the start begins again rather than
  /// turning the span round, and a press once a span is finished starts
  /// another.
  ///
  /// [value], [defaultValue] and [onValueChange] speak in
  /// [NebaCalendarRange]s here.
  const NebaCalendar.range({
    NebaCalendarRange? value,
    NebaCalendarRange? defaultValue,
    ValueChanged<NebaCalendarRange>? onValueChange,
    this.size,
    this.color,
    this.elevation,
    this.bordered = true,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.granularity = NebaDateGranularity.day,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.locale,
    this.weekStartsOn,
    this.showOutsideDays = true,
    this.renderDay,
    this.labels,
    super.key,
  }) : mode = NebaCalendarMode.range,
       range = value,
       defaultRange = defaultValue,
       onRangeChange = onValueChange,
       value = null,
       defaultValue = null,
       onValueChange = null,
       values = null,
       defaultValues = null,
       onValuesChange = null,
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// How many days the calendar holds, which its constructor decides.
  final NebaCalendarMode mode;

  /// The day a single calendar holds, for a controlled one. Left `null`, the
  /// calendar keeps its own state, starting from [defaultValue]; a value that
  /// goes from a day to `null` empties it.
  final DateTime? value;

  /// The day a single calendar that keeps its own state starts with.
  final DateTime? defaultValue;

  /// Called with the day a single calendar now holds.
  final ValueChanged<DateTime?>? onValueChange;

  /// The days a multiple calendar holds, which [NebaCalendar.multiple] takes
  /// as `value`.
  final List<DateTime>? values;

  /// The days a multiple calendar starts with, which
  /// [NebaCalendar.multiple] takes as `defaultValue`.
  final List<DateTime>? defaultValues;

  /// Called with the days a multiple calendar now holds, which
  /// [NebaCalendar.multiple] takes as `onValueChange`.
  final ValueChanged<List<DateTime>>? onValuesChange;

  /// The span a range calendar holds, which [NebaCalendar.range] takes as
  /// `value`.
  final NebaCalendarRange? range;

  /// The span a range calendar starts with, which [NebaCalendar.range] takes
  /// as `defaultValue`.
  final NebaCalendarRange? defaultRange;

  /// Called with the span a range calendar now holds, which
  /// [NebaCalendar.range] takes as `onValueChange`.
  final ValueChanged<NebaCalendarRange>? onRangeChange;

  /// The cells' height and the type: 32 logical pixels a cell at
  /// [NebaSize.md], the height of a button of that size. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the chosen days, the band, today's ink and the
  /// header's buttons. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The drop shadow, from `0`, which is none, to `3`. A calendar in a page
  /// is not floating, so it defaults to `0`.
  final NebaElevation? elevation;

  /// Whether the sheet a picker's popup draws is drawn around the grid, with
  /// the same edge and padding. Off for a bare grid inside something that
  /// already has an edge.
  final bool bordered;

  /// The month on screen, for a caller that controls it with
  /// [onMonthChange].
  final DateTime? month;

  /// The month it opens on. Defaults to the month of the value, then this
  /// one.
  final DateTime? defaultMonth;

  /// Called with the 1st of the month that is now on screen.
  final ValueChanged<DateTime>? onMonthChange;

  /// What a press chooses: a day, a whole month or a whole year. At
  /// [NebaDateGranularity.month] or [NebaDateGranularity.year] the calendar
  /// opens on that grid, a press there is the answer, and the value is the
  /// first day of what was chosen.
  final NebaDateGranularity granularity;

  /// The earliest day that may be chosen, read at [granularity].
  final DateTime? minDate;

  /// The latest day that may be chosen, read at [granularity].
  final DateTime? maxDate;

  /// Blocks cells inside the bounds, handed the value each would produce.
  final bool Function(DateTime date)? shouldDisableDate;

  /// The language the month and weekday names and the calendar's own words
  /// are in, and the region the week starts by. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The first column's weekday, as [DateTime.weekday] counts it. Defaults
  /// to the one [locale] starts its week on.
  final NebaWeekday? weekStartsOn;

  /// Whether the leading and trailing days of the months next door are
  /// drawn.
  final bool showOutsideDays;

  /// What a day cell draws over its number, in a [Stack] the cell's size: a
  /// [Positioned] dot lands where it is put. What it draws is read with the
  /// cell's name unless it is wrapped in [ExcludeSemantics].
  final Widget? Function(DateTime date)? renderDay;

  /// The words a screen reader hears from the steppers and the header, in
  /// place of the [locale]'s.
  final NebaPickerLabels? labels;

  @override
  State<NebaCalendar> createState() => _NebaCalendarState();
}

class _NebaCalendarState extends State<NebaCalendar> {
  late DateTime? _value = widget.defaultValue;
  late List<DateTime> _values = widget.defaultValues ?? const <DateTime>[];
  late NebaCalendarRange _range = widget.defaultRange ?? const NebaCalendarRange();
  late DateTime _month = NebaDate.startOfMonth(
    _held.firstOrNull ?? widget.defaultMonth ?? NebaDate.today(),
  );

  DateTime? get _single => widget.value ?? _value;

  List<DateTime> get _multiple => widget.values ?? _values;

  NebaCalendarRange get _span => widget.range ?? _range;

  /// The days the value lights up.
  List<DateTime> get _held {
    return switch (widget.mode) {
      NebaCalendarMode.single => <DateTime>[?_single],
      NebaCalendarMode.multiple => _multiple,
      NebaCalendarMode.range => <DateTime>[?_span.start, ?_span.end],
    };
  }

  @override
  void didUpdateWidget(NebaCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A caller that held a day and now holds none has emptied the calendar.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }
  }

  void _setMonth(DateTime next) {
    if (widget.month == null) {
      setState(() => _month = next);
    }

    widget.onMonthChange?.call(next);
  }

  void _select(DateTime date) {
    final DateTime unit = NebaDate.startOfUnit(date, widget.granularity);

    switch (widget.mode) {
      case NebaCalendarMode.single:
        setState(() => _value = unit);
        widget.onValueChange?.call(unit);
      case NebaCalendarMode.multiple:
        final List<DateTime> held = _multiple;
        final List<DateTime> without = <DateTime>[
          for (final DateTime entry in held)
            if (!NebaDate.isSameDay(entry, unit)) entry,
        ];
        // A press on a day already held takes it back out, the one way the
        // pointer can undo a multiple calendar.
        final List<DateTime> next = without.length == held.length
            ? <DateTime>[...held, unit]
            : without;

        setState(() => _values = next);
        widget.onValuesChange?.call(next);
      case NebaCalendarMode.range:
        final NebaCalendarRange span = _span;
        final DateTime? start = span.start;
        // A span in progress has a start and no end; anything else, a
        // finished span or an empty one, starts a new one. Before the start
        // is a new start rather than a span turned round, which is what
        // makes a reader think they pressed the wrong day.
        final NebaCalendarRange next =
            start == null || span.end != null || NebaDate.compareDay(unit, start) < 0
            ? NebaCalendarRange(start: unit)
            : NebaCalendarRange(start: start, end: unit);

        setState(() => _range = next);
        widget.onRangeChange?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaElevation elevation = widget.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final Locale? locale = nebaDateLocale(context, locale: widget.locale);
    final NebaCalendarRange span = widget.mode == NebaCalendarMode.range
        ? _span
        : const NebaCalendarRange();

    final Widget grid = NebaCalendarGrid(
      size: size,
      color: color,
      roles: roles,
      names: NebaDateNames.resolve(locale),
      words: nebaPickerWords(context, locale: widget.locale, labels: widget.labels),
      weekStartsOn: widget.weekStartsOn ?? nebaWeekStart(locale),
      month: widget.month ?? _month,
      onMonthChange: _setMonth,
      selected: _held,
      rangeStart: span.start,
      rangeEnd: span.end,
      onSelect: _select,
      granularity: widget.granularity,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      shouldDisableDate: widget.shouldDisableDate,
      showOutsideDays: widget.showOutsideDays,
      renderDay: widget.renderDay,
    );

    if (widget.bordered) {
      return NebaCalendarSheet(size: size, roles: roles, elevation: elevation, child: grid);
    }

    if (elevation == 0) {
      return grid;
    }

    // A bare grid keeps the shadow it was asked for.
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: tokens.elevation(elevation)),
      child: grid,
    );
  }
}
