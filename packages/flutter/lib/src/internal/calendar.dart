/// The calendar grid, written once for `NebaCalendar` and the pickers: the
/// React package's `internal/calendar.tsx`.
///
/// One month with a way to reach every other one: the days of a month, the
/// twelve months of a year and twelve years at a time, on the same footprint,
/// so switching between them never resizes the popup under the pointer that
/// opened it. A DateTimePicker is this beside a clock and a DateRangePicker
/// is two of these, so it lives here rather than in any one of them.
///
/// The cells are deliberately not buttons. A cell has states a button has no
/// words for, inside a range, at the end of one, today, belonging to the month
/// next door, and four of them have to be told apart at a glance in a grid of
/// forty-two.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A picker popup's padding and a bordered calendar's, one track tighter
/// than a control's: the React package's `popupPaddingClasses`.
const Map<NebaSize, double> nebaPickerPadding = <NebaSize, double>{
  NebaSize.xs: 6,
  NebaSize.sm: 8,
  NebaSize.md: 10,
  NebaSize.lg: 12,
  NebaSize.xl: 14,
};

/// A cell's corner, one step down the radius ladder from the sheet it sits
/// on.
const Map<NebaSize, NebaSize> _cellRadiusStep = <NebaSize, NebaSize>{
  NebaSize.xs: NebaSize.xs,
  NebaSize.sm: NebaSize.xs,
  NebaSize.md: NebaSize.sm,
  NebaSize.lg: NebaSize.md,
  NebaSize.xl: NebaSize.lg,
};

/// The width of one day cell: a control's height, so a `md` day is a `md`
/// button and the grid stands on a form's own ladder.
double nebaCalendarCell(NebaSize size) => NebaScale.controlHeight[size]!;

/// The sheet a picker's popup and a bordered calendar are drawn on: the
/// undyed panel with the family's hairline and the glass plate, at the
/// size's corners and padding, so a calendar on a page and one in a popup
/// are the same object.
class NebaCalendarSheet extends StatelessWidget {
  /// A sheet with [child] on it.
  const NebaCalendarSheet({
    required this.size,
    required this.roles,
    required this.elevation,
    required this.child,
    super.key,
  });

  /// The corners and the padding.
  final NebaSize size;

  /// The family of the hairline.
  final NebaColorRoles roles;

  /// The drop shadow.
  final NebaElevation elevation;

  /// What is on it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaSheet(
      fill: tokens.panelPress,
      edge: roles.line,
      plate: NebaPlate.glass,
      elevation: elevation,
      borderRadius: BorderRadius.circular(tokens.radius[size]!),
      child: Padding(padding: EdgeInsets.all(nebaPickerPadding[size]!), child: child),
    );
  }
}

/// Where a cell sits in a run of banded days, so the band knows where to
/// round off.
enum _RangeEdge { start, end, both, middle }

/// The calendar: a header with its steppers and the way into the coarser
/// views, over the grid of the view on screen.
///
/// [month] is controlled, so two panels can be kept a month apart; [selected]
/// are the days drawn filled, and [rangeStart] and [rangeEnd] the ends of
/// the band drawn between them. [granularity] is the view the reader may stop
/// on: a pick there is handed to [onSelect], and a pick above it is only a
/// way of reaching it.
///
/// The arrow keys move a day or a week, Page Up and Page Down a month (with
/// Shift a year), Home and End to the week's ends, and running off the month
/// steps the calendar rather than stopping. One cell is a tab stop, so Tab
/// leaves the grid instead of walking forty-two cells.
class NebaCalendarGrid extends StatefulWidget {
  /// A calendar on [month].
  const NebaCalendarGrid({
    required this.size,
    required this.color,
    required this.roles,
    required this.names,
    required this.words,
    required this.weekStartsOn,
    required this.month,
    required this.onMonthChange,
    required this.selected,
    required this.onSelect,
    this.rangeStart,
    this.rangeEnd,
    this.granularity = NebaDateGranularity.day,
    this.onPreviewChange,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.showOutsideDays = true,
    this.renderDay,
    this.autofocus = false,
    this.showPreviousButton = true,
    this.showNextButton = true,
    super.key,
  });

  /// The cells, the type and the header's buttons.
  final NebaSize size;

  /// The family the header's buttons are in.
  final NebaColor color;

  /// The family's roles, which the cells are filled and washed in.
  final NebaColorRoles roles;

  /// How the months and the weekdays are named.
  final NebaDateNames names;

  /// The `picker` messages: the steppers' names and what the header's
  /// buttons do.
  final Map<String, String> words;

  /// The first column's weekday.
  final NebaWeekday weekStartsOn;

  /// The month on screen, the 1st of it.
  final DateTime month;

  /// Asks for another month on screen.
  final ValueChanged<DateTime> onMonthChange;

  /// The days drawn filled.
  final List<DateTime> selected;

  /// Called with a day, the 1st of a month or the 1st of January, as
  /// [granularity] says, when one is chosen.
  final ValueChanged<DateTime> onSelect;

  /// One end of the band.
  final DateTime? rangeStart;

  /// The other end of the band.
  final DateTime? rangeEnd;

  /// The view the reader may stop on, and what [onSelect] hands back.
  final NebaDateGranularity granularity;

  /// Called with the day under the pointer, and `null` when it leaves the
  /// grid: for a range that is half chosen.
  final ValueChanged<DateTime?>? onPreviewChange;

  /// The earliest day that may be chosen.
  final DateTime? minDate;

  /// The latest day that may be chosen.
  final DateTime? maxDate;

  /// Blocks a cell inside the bounds, handed the value it would produce.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Whether the leading and trailing days of the months next door are
  /// drawn.
  final bool showOutsideDays;

  /// What a day cell draws over its number.
  final Widget? Function(DateTime date)? renderDay;

  /// Whether the grid takes the focus once it is built: the popup has just
  /// opened.
  final bool autofocus;

  /// Whether the stepper back is drawn, or a hole its size.
  final bool showPreviousButton;

  /// Whether the stepper on is drawn, or a hole its size.
  final bool showNextButton;

  @override
  State<NebaCalendarGrid> createState() => _NebaCalendarGridState();
}

class _NebaCalendarGridState extends State<NebaCalendarGrid> {
  // One node a position, so a cell keeps its node as the month changes under
  // it, and each grid its own, so a view change never moves a node.
  final List<FocusNode> _dayNodes = List<FocusNode>.generate(
    42,
    (int index) => FocusNode(debugLabel: 'NebaCalendar day $index'),
  );
  final List<FocusNode> _monthNodes = List<FocusNode>.generate(
    12,
    (int index) => FocusNode(debugLabel: 'NebaCalendar month $index'),
  );
  final List<FocusNode> _yearNodes = List<FocusNode>.generate(
    12,
    (int index) => FocusNode(debugLabel: 'NebaCalendar year $index'),
  );

  late NebaCalendarView _view = _viewOf(widget.granularity);
  late DateTime _focusedDate = _initialFocus();
  // Set only by what moves the focus, an arrow key or a view change, so the
  // grid never takes the focus from somewhere else on the page.
  late bool _pendingFocus = widget.autofocus;

  static NebaCalendarView _viewOf(NebaDateGranularity granularity) {
    return switch (granularity) {
      NebaDateGranularity.day => NebaCalendarView.day,
      NebaDateGranularity.month => NebaCalendarView.month,
      NebaDateGranularity.year => NebaCalendarView.year,
    };
  }

  // A view finer than the granularity is not one this calendar has.
  NebaCalendarView get _shownView {
    final NebaCalendarView floor = _viewOf(widget.granularity);

    return _view.index < floor.index ? floor : _view;
  }

  // The chosen day, or today when today is on screen, or the 1st: never
  // nowhere, or the keyboard could not reach the grid at all.
  DateTime _initialFocus() {
    for (final DateTime date in widget.selected) {
      if (NebaDate.isSameMonth(date, widget.month)) {
        return NebaDate.startOfDay(date);
      }
    }

    final DateTime today = NebaDate.today();

    return NebaDate.isSameMonth(today, widget.month) ? today : NebaDate.startOfMonth(widget.month);
  }

  @override
  void initState() {
    super.initState();
    _focusLater();
  }

  @override
  void didUpdateWidget(NebaCalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The tab stop follows the month, so stepping and then pressing an arrow
    // lands inside the grid the reader is looking at.
    if (!NebaDate.isSameMonth(_focusedDate, widget.month)) {
      _focusedDate = NebaDate.startOfMonth(widget.month);
    }

    _focusLater();
  }

  @override
  void dispose() {
    for (final FocusNode node in <FocusNode>[..._dayNodes, ..._monthNodes, ..._yearNodes]) {
      node.dispose();
    }

    super.dispose();
  }

  // After the frame that draws the stop: the cell it names may only now be
  // there.
  void _focusLater() {
    if (!_pendingFocus) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted || !_pendingFocus) {
        return;
      }

      _pendingFocus = false;
      _stopNode?.requestFocus();
    });
  }

  FocusNode? get _stopNode {
    return switch (_shownView) {
      NebaCalendarView.day => _dayNodes[_dayStop],
      NebaCalendarView.month => _monthNodes[widget.month.month - 1],
      NebaCalendarView.year =>
        _yearNodes[widget.month.year - NebaDate.yearPageStart(widget.month.year)],
    };
  }

  // Where the tab stop sits among the forty-two days.
  int get _dayStop {
    return _dayPosition(
      NebaDate.isSameMonth(_focusedDate, widget.month)
          ? _focusedDate
          : NebaDate.startOfMonth(widget.month),
    );
  }

  // Where a day of the month on screen sits among the forty-two.
  int _dayPosition(DateTime date) {
    final DateTime first = NebaDate.startOfMonth(widget.month);

    return NebaDate.column(first, widget.weekStartsOn) + date.day - 1;
  }

  // The day whose cell holds the focus, which is where a key moves from: a
  // screen reader can put the focus on a cell that is not the tab stop.
  DateTime get _keyedDay {
    final int at = _dayNodes.indexWhere((FocusNode node) => node.hasPrimaryFocus);

    if (at < 0) {
      return _focusedDate;
    }

    return NebaDate.weeks(widget.month, widget.weekStartsOn)[at ~/ 7][at % 7];
  }

  bool _isDayDisabled(DateTime date) {
    return NebaDate.isDayOutside(date, widget.minDate, widget.maxDate) ||
        (widget.shouldDisableDate?.call(date) ?? false);
  }

  void _step(int direction) {
    final DateTime month = widget.month;

    widget.onMonthChange(switch (_shownView) {
      NebaCalendarView.day => NebaDate.addMonths(month, direction),
      NebaCalendarView.month => NebaDate.addYears(month, direction),
      NebaCalendarView.year => NebaDate.addYears(month, direction * nebaYearPageSize),
    });
  }

  void _changeView(NebaCalendarView view) {
    setState(() {
      _pendingFocus = true;
      _view = view;
    });
    _focusLater();
  }

  // Moves the tab stop and the focus with it, at once inside the month on
  // screen, so a key pressed straight after starts from the new cell, and
  // after the frame that draws the next month when it pulls the month along.
  void _moveFocus(DateTime next) {
    final bool here = NebaDate.isSameMonth(next, widget.month);

    setState(() {
      _pendingFocus = !here;
      _focusedDate = next;
    });

    if (here) {
      _dayNodes[_dayPosition(next)].requestFocus();
    } else {
      widget.onMonthChange(NebaDate.startOfMonth(next));
      _focusLater();
    }
  }

  // In the month and the year views the header's month is the cursor, and
  // the cell it names is the stop.
  void _moveCursor(DateTime next, {required bool years}) {
    final int pageStart = NebaDate.yearPageStart(widget.month.year);
    final bool here = years
        ? NebaDate.yearPageStart(next.year) == pageStart
        : next.year == widget.month.year;

    _pendingFocus = !here;
    widget.onMonthChange(next);

    if (here) {
      (years ? _yearNodes[next.year - pageStart] : _monthNodes[next.month - 1]).requestFocus();
    } else {
      _focusLater();
    }
  }

  bool _rtl(BuildContext context) => Directionality.of(context) == TextDirection.rtl;

  KeyEventResult _onDayKey(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final DateTime date = _keyedDay;
    final int ahead = _rtl(context) ? -1 : 1;
    final int offset = NebaDate.column(date, widget.weekStartsOn);
    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final DateTime? next = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => NebaDate.addDays(date, -ahead),
      LogicalKeyboardKey.arrowRight => NebaDate.addDays(date, ahead),
      LogicalKeyboardKey.arrowUp => NebaDate.addDays(date, -7),
      LogicalKeyboardKey.arrowDown => NebaDate.addDays(date, 7),
      LogicalKeyboardKey.home => NebaDate.addDays(date, -offset),
      LogicalKeyboardKey.end => NebaDate.addDays(date, 6 - offset),
      LogicalKeyboardKey.pageUp => NebaDate.addMonths(date, shift ? -12 : -1),
      LogicalKeyboardKey.pageDown => NebaDate.addMonths(date, shift ? 12 : 1),
      _ => null,
    };

    if (next == null) {
      return KeyEventResult.ignored;
    }

    _moveFocus(next);

    return KeyEventResult.handled;
  }

  KeyEventResult _onUnitKey(BuildContext context, KeyEvent event, {required bool years}) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final int ahead = _rtl(context) ? -1 : 1;
    final int across = years ? 4 : 3;
    final int page = years ? nebaYearPageSize : 12;
    final int? step = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => -ahead,
      LogicalKeyboardKey.arrowRight => ahead,
      LogicalKeyboardKey.arrowUp => -across,
      LogicalKeyboardKey.arrowDown => across,
      LogicalKeyboardKey.pageUp => -page,
      LogicalKeyboardKey.pageDown => page,
      _ => null,
    };

    if (step == null) {
      return KeyEventResult.ignored;
    }

    // From the cell that holds the focus, which is the header's month unless
    // a screen reader put it somewhere else.
    final List<FocusNode> nodes = years ? _yearNodes : _monthNodes;
    final int at = nodes.indexWhere((FocusNode node) => node.hasPrimaryFocus);
    final DateTime month = at < 0
        ? NebaDate.startOfMonth(widget.month)
        : years
        ? DateTime(NebaDate.yearPageStart(widget.month.year) + at, widget.month.month)
        : DateTime(widget.month.year, at + 1);

    _moveCursor(
      years ? NebaDate.addYears(month, step) : NebaDate.addMonths(month, step),
      years: years,
    );

    return KeyEventResult.handled;
  }

  void _pickMonth(int index) {
    final DateTime picked = DateTime(widget.month.year, index + 1);

    widget.onMonthChange(picked);

    // The floor is where a pick becomes an answer; above it a pick only
    // reaches the grid below, and the stop moves with it in the same frame.
    if (widget.granularity == NebaDateGranularity.month) {
      widget.onSelect(picked);
    } else {
      if (!NebaDate.isSameMonth(_focusedDate, picked)) {
        _focusedDate = picked;
      }

      _changeView(NebaCalendarView.day);
    }
  }

  void _pickYear(int year) {
    if (widget.granularity == NebaDateGranularity.year) {
      final DateTime picked = DateTime(year);

      widget.onMonthChange(picked);
      widget.onSelect(picked);

      return;
    }

    widget.onMonthChange(DateTime(year, widget.month.month));
    _changeView(NebaCalendarView.month);
  }

  @override
  Widget build(BuildContext context) {
    final NebaSize size = widget.size;
    final double cell = nebaCalendarCell(size);
    final NebaCalendarView view = _shownView;
    final DateTime month = widget.month;
    final NebaDateNames names = widget.names;
    final int pageStart = NebaDate.yearPageStart(month.year);
    final String caption = switch (view) {
      NebaCalendarView.day => names.write(names.monthYear, month),
      NebaCalendarView.month => '${month.year}',
      NebaCalendarView.year => '$pageStart–${pageStart + nebaYearPageSize - 1}',
    };

    final Widget grid = switch (view) {
      NebaCalendarView.day => _dayGrid(context, caption),
      NebaCalendarView.month => _monthGrid(context, caption),
      NebaCalendarView.year => _yearGrid(context, caption),
    };

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: NebaScale.gap[size]!,
      children: <Widget>[
        _header(context, view: view, caption: caption, pageStart: pageStart),
        // Seven rows of cells whichever view is drawn into them, and the
        // grid at the start when the header is wider than it, as the
        // stylesheet lays it out.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(width: cell * 7, height: cell * 7, child: grid),
        ),
      ],
    );

    if (widget.onPreviewChange != null) {
      body = MouseRegion(
        opaque: false,
        onExit: (PointerExitEvent _) => widget.onPreviewChange?.call(null),
        child: body,
      );
    }

    return IntrinsicWidth(child: body);
  }

  Widget _header(
    BuildContext context, {
    required NebaCalendarView view,
    required String caption,
    required int pageStart,
  }) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size;
    final NebaColor color = widget.color;
    final Map<String, String> words = widget.words;
    final DateTime month = widget.month;
    final NebaDateNames names = widget.names;
    final bool rtl = _rtl(context);
    final double height = NebaScale.controlHeight[size]!;
    final double text = NebaScale.controlText[size]!;
    final (String previous, String next) = switch (view) {
      NebaCalendarView.day => (words['previousMonth']!, words['nextMonth']!),
      NebaCalendarView.month => (words['previousYear']!, words['nextYear']!),
      NebaCalendarView.year => (words['previousYears']!, words['nextYears']!),
    };

    Widget stepper(int direction, {required bool shown}) {
      if (!shown) {
        // A hole the size of the button, so two panels side by side keep
        // their headings on one centre line.
        return SizedBox(width: nebaCalendarCell(size), height: height);
      }

      final bool back = direction < 0;

      return NebaButton(
        onPressed: () => _step(direction),
        variant: NebaVariant.text,
        size: size,
        color: color,
        density: NebaDensity.compact,
        semanticLabel: back ? previous : next,
        startIcon: RotatedBox(
          quarterTurns: back == rtl ? 3 : 1,
          child: NebaGlyph(NebaGlyphs.chevron),
        ),
      );
    }

    // Named by what it shows, which is what a reader who can see it calls it,
    // and described by what pressing it does.
    Widget disclosure({
      required String label,
      required NebaCalendarView opens,
      required String hint,
      bool figures = false,
    }) {
      final bool open = view == opens;

      return MergeSemantics(
        child: Semantics(
          expanded: open,
          hint: hint,
          child: NebaButton(
            onPressed: () => _changeView(open ? NebaCalendarView.day : opens),
            variant: NebaVariant.text,
            size: size,
            color: color,
            density: NebaDensity.compact,
            endIcon: NebaDisclosureChevron(open: open, color: tokens.mutedFg),
            child: Text(
              label,
              style: figures
                  ? const TextStyle(fontFeatures: <FontFeature>[FontFeature.tabularFigures()])
                  : null,
            ),
          ),
        ),
      );
    }

    final Widget monthButton = disclosure(
      label: names.months[month.month - 1],
      opens: NebaCalendarView.month,
      hint: words['chooseMonth']!,
    );
    final Widget yearButton = disclosure(
      label: '${month.year}',
      opens: NebaCalendarView.year,
      hint: words['chooseYear']!,
      figures: true,
    );

    final Widget middle = switch (view) {
      // A range rather than a control: there is nothing above a page of
      // years to open. It keeps the row's height, so a view change never
      // moves it.
      NebaCalendarView.year => SizedBox(
        height: height,
        child: Center(
          widthFactor: 1,
          child: ExcludeSemantics(
            child: Text(
              '$pageStart–${pageStart + nebaYearPageSize - 1}',
              style: TextStyle(
                fontSize: text,
                fontWeight: FontWeight.w500,
                color: tokens.fg,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
      NebaCalendarView.month => yearButton,
      NebaCalendarView.day => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: NebaScale.gap[size]!,
        children: names.monthBeforeYear
            ? <Widget>[monthButton, yearButton]
            : <Widget>[yearButton, monthButton],
      ),
    };

    return Stack(
      children: <Widget>[
        Row(
          spacing: 4,
          children: <Widget>[
            stepper(-1, shown: widget.showPreviousButton),
            Expanded(
              // Wider than the room it is given, the middle is cut at the
              // steppers rather than pushing them off the row.
              child: UnconstrainedBox(clipBehavior: Clip.hardEdge, child: middle),
            ),
            stepper(1, shown: widget.showNextButton),
          ],
        ),
        // What the grid is showing, said again whenever it changes: a stepper
        // or an arrow key off the edge moves every cell at once, and the
        // focused cell's own name does not say its month has changed.
        PositionedDirectional(
          start: 0,
          top: 0,
          child: NebaVisuallyHidden(
            child: NebaLiveRegion(
              role: SemanticsRole.status,
              child: Semantics(label: caption, child: const SizedBox.square(dimension: 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _table({required String caption, required Widget child}) {
    return Semantics(
      container: true,
      role: SemanticsRole.table,
      label: caption,
      explicitChildNodes: true,
      child: child,
    );
  }

  Widget _dayGrid(BuildContext context, String caption) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size;
    final double cell = nebaCalendarCell(size);
    final NebaDateNames names = widget.names;
    final DateTime month = widget.month;
    final DateTime today = NebaDate.today();
    final List<List<DateTime>> weeks = NebaDate.weeks(month, widget.weekStartsOn);
    final List<DateTime> chosen = widget.selected;
    final DateTime? start = widget.rangeStart;
    final DateTime? end = widget.rangeEnd;
    // The band's two ends, smallest first, whichever way round they came.
    final (DateTime, DateTime)? band = start == null || end == null
        ? null
        : NebaDate.compareDay(start, end) <= 0
        ? (start, end)
        : (end, start);
    final int stop = _dayStop;
    final ValueChanged<DateTime?>? preview = widget.onPreviewChange;

    final Widget heads = Semantics(
      container: true,
      role: SemanticsRole.row,
      explicitChildNodes: true,
      child: Row(
        children: <Widget>[
          for (int column = 0; column < 7; column++)
            () {
              final int weekday = (widget.weekStartsOn - 1 + column) % 7;

              return Semantics(
                container: true,
                role: SemanticsRole.columnHeader,
                label: names.weekdays[weekday],
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: cell,
                    height: cell,
                    child: Center(
                      child: Text(
                        names.shortWeekdays[weekday],
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: NebaScale.metaText[size],
                          fontWeight: FontWeight.w500,
                          color: tokens.mutedFg,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }(),
        ],
      ),
    );

    final List<Widget> rows = <Widget>[heads];

    for (int week = 0; week < 6; week++) {
      final List<Widget> cells = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final int position = week * 7 + day;
        final DateTime date = weeks[week][day];
        final bool outside = !NebaDate.isSameMonth(date, month);
        final FocusNode node = _dayNodes[position];

        // A hole the size of a cell rather than a missing one: the grid
        // keeps its seven columns and six rows whatever month it is on.
        if (outside && !widget.showOutsideDays) {
          node.skipTraversal = true;
          cells.add(SizedBox(width: cell, height: cell));
          continue;
        }

        final bool isChosen = chosen.any((DateTime entry) => NebaDate.isSameDay(entry, date));
        final bool within =
            band != null &&
            NebaDate.compareDay(date, band.$1) >= 0 &&
            NebaDate.compareDay(date, band.$2) <= 0;
        final bool atStart = within && NebaDate.isSameDay(date, band.$1);
        final bool atEnd = within && NebaDate.isSameDay(date, band.$2);
        final bool current = NebaDate.isSameDay(date, today);

        node.skipTraversal = position != stop;

        Widget dayCell = _CalendarCell(
          size: size,
          roles: widget.roles,
          focusNode: node,
          label: names.write(names.fullDate, date),
          hint: current ? widget.words['today'] : null,
          selected: isChosen,
          inRange: within && !isChosen,
          edge: !within
              ? null
              : atStart && atEnd
              ? _RangeEdge.both
              : atStart
              ? _RangeEdge.start
              : atEnd
              ? _RangeEdge.end
              : _RangeEdge.middle,
          current: current,
          muted: outside,
          disabled: _isDayDisabled(date),
          extra: widget.renderDay?.call(date),
          onPressed: () {
            _focusedDate = date;
            widget.onSelect(date);
          },
          child: Text('${date.day}'),
        );

        if (preview != null) {
          dayCell = MouseRegion(
            opaque: false,
            onEnter: (PointerEnterEvent _) => preview(date),
            child: dayCell,
          );
        }

        cells.add(SizedBox(width: cell, height: cell, child: dayCell));
      }

      rows.add(
        Semantics(
          container: true,
          role: SemanticsRole.row,
          explicitChildNodes: true,
          child: Row(children: cells),
        ),
      );
    }

    return _table(
      caption: caption,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (FocusNode _, KeyEvent event) => _onDayKey(context, event),
        child: Column(children: rows),
      ),
    );
  }

  Widget _monthGrid(BuildContext context, String caption) {
    final NebaDateNames names = widget.names;
    final int year = widget.month.year;
    final DateTime now = DateTime.now();

    return _unitGrid(
      context,
      caption: caption,
      columns: 3,
      rows: 4,
      nodes: _monthNodes,
      years: false,
      cellOf: (int index) {
        final DateTime first = DateTime(year, index + 1);

        return (
          text: names.shortMonths[index],
          label: names.write(names.monthYear, first),
          hint: now.year == year && now.month == index + 1 ? widget.words['thisMonth'] : null,
          selected: widget.selected.any(
            (DateTime entry) => entry.year == year && entry.month == index + 1,
          ),
          current: now.year == year && now.month == index + 1,
          // A month is out of bounds only when every day in it is: the month
          // a minimum falls in is still reachable, it just starts late.
          disabled:
              NebaDate.isUnitOutside(
                first,
                NebaDateGranularity.month,
                widget.minDate,
                widget.maxDate,
              ) ||
              // The caller's own check is asked only when a month is what is
              // being chosen: at day granularity a check that blocks weekends
              // would grey out every month whose 1st is a Saturday.
              (widget.granularity == NebaDateGranularity.month &&
                  (widget.shouldDisableDate?.call(first) ?? false)),
          stop: index == widget.month.month - 1,
          onPressed: () => _pickMonth(index),
        );
      },
    );
  }

  Widget _yearGrid(BuildContext context, String caption) {
    final int pageStart = NebaDate.yearPageStart(widget.month.year);
    final int now = DateTime.now().year;

    return _unitGrid(
      context,
      caption: caption,
      columns: 4,
      rows: 3,
      nodes: _yearNodes,
      years: true,
      cellOf: (int index) {
        final int year = pageStart + index;
        final DateTime first = DateTime(year);

        return (
          text: '$year',
          label: '$year',
          hint: year == now ? widget.words['thisYear'] : null,
          selected: widget.selected.any((DateTime entry) => entry.year == year),
          current: year == now,
          disabled:
              NebaDate.isUnitOutside(
                first,
                NebaDateGranularity.year,
                widget.minDate,
                widget.maxDate,
              ) ||
              (widget.granularity == NebaDateGranularity.year &&
                  (widget.shouldDisableDate?.call(first) ?? false)),
          stop: year == widget.month.year,
          onPressed: () => _pickYear(year),
        );
      },
    );
  }

  // Twelve months three across or twelve years four across, the rows spread
  // over the height the day view takes rather than stretched to fill it, so
  // a cell stays a cell.
  Widget _unitGrid(
    BuildContext context, {
    required String caption,
    required int columns,
    required int rows,
    required List<FocusNode> nodes,
    required bool years,
    required ({
      String text,
      String label,
      String? hint,
      bool selected,
      bool current,
      bool disabled,
      bool stop,
      VoidCallback onPressed,
    })
    Function(int index)
    cellOf,
  }) {
    final double cell = nebaCalendarCell(widget.size);
    final List<Widget> lines = <Widget>[];

    for (int row = 0; row < rows; row++) {
      final List<Widget> cells = <Widget>[];

      for (int column = 0; column < columns; column++) {
        final int index = row * columns + column;
        final ({
          String text,
          String label,
          String? hint,
          bool selected,
          bool current,
          bool disabled,
          bool stop,
          VoidCallback onPressed,
        })
        unit = cellOf(index);
        final FocusNode node = nodes[index];

        node.skipTraversal = !unit.stop;
        cells.add(
          Expanded(
            child: SizedBox(
              height: cell,
              child: _CalendarCell(
                size: widget.size,
                roles: widget.roles,
                focusNode: node,
                label: unit.label,
                hint: unit.hint,
                selected: unit.selected,
                current: unit.current,
                disabled: unit.disabled,
                onPressed: unit.onPressed,
                child: Text(
                  unit.text,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }

      lines.add(
        Semantics(
          container: true,
          role: SemanticsRole.row,
          explicitChildNodes: true,
          child: Row(spacing: 4, children: cells),
        ),
      );
    }

    return _table(
      caption: caption,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (FocusNode _, KeyEvent event) => _onUnitKey(context, event, years: years),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: lines),
      ),
    );
  }
}

/// One pressable square of a grid.
///
/// The state is one chain decided in order of importance, as the stylesheet
/// writes it: unavailable first, since a blocked day wearing the range's tint
/// would be advertising a range it cannot join; then chosen, then inside the
/// range, then today, then the days of the month next door.
class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.size,
    required this.roles,
    required this.focusNode,
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.child,
    this.hint,
    this.inRange = false,
    this.edge,
    this.current = false,
    this.muted = false,
    this.disabled = false,
    this.extra,
  });

  final NebaSize size;
  final NebaColorRoles roles;
  final FocusNode focusNode;

  /// What a screen reader hears: always the whole date, never the number.
  final String label;

  /// Read after it: that this is today, this month or this year.
  final String? hint;

  final bool selected;
  final bool inRange;
  final _RangeEdge? edge;
  final bool current;
  final bool muted;
  final bool disabled;
  final Widget? extra;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.controlText[size]!;
    final Radius corner = Radius.circular(tokens.radius[_cellRadiusStep[size]]!);
    // Square through the middle of a run and rounded where it stops, so a
    // week of banded days reads as one shape rather than seven.
    final BorderRadius radius = switch (edge) {
      _RangeEdge.start => BorderRadiusDirectional.horizontal(
        start: corner,
      ).resolve(Directionality.of(context)),
      _RangeEdge.end => BorderRadiusDirectional.horizontal(
        end: corner,
      ).resolve(Directionality.of(context)),
      _RangeEdge.middle => BorderRadius.zero,
      _RangeEdge.both || null => BorderRadius.all(corner),
    };
    final Widget? extra = this.extra;

    return Semantics(
      container: true,
      role: SemanticsRole.cell,
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        enabled: !disabled,
        label: label,
        hint: hint,
        // Not out of the focus order when unavailable: a blocked day that left
        // it would be a hole in the arrow keys' path across the month.
        child: NebaInteractive(
          onTap: onPressed,
          enabled: !disabled,
          focusable: true,
          focusNode: focusNode,
          cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            final bool hovered = interaction.hovered;
            final bool pressed = interaction.pressed;
            final Color clear = roles.soft.withValues(alpha: 0);
            final Color wash = pressed
                ? roles.softPress
                : hovered
                ? roles.soft
                : clear;
            final (Color fill, Color ink) = disabled
                ? (clear, tokens.disabledFg)
                : selected
                ? (
                    pressed
                        ? roles.fillActive
                        : hovered
                        ? roles.fillHover
                        : roles.fill,
                    roles.family.onSolid,
                  )
                : inRange
                ? (
                    pressed
                        ? roles.softPress
                        : hovered
                        ? roles.softHover
                        : roles.soft,
                    tokens.fg,
                  )
                : current
                ? (wash, roles.onTint)
                : muted
                ? (wash, tokens.mutedFg)
                : (wash, tokens.fg);
            final bool bold = !disabled && (selected || current);

            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              // Inside the cell: in a grid with no gaps, a ring outside it is
              // a ring drawn on the neighbours.
              offset: -focusRingWidth,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: fill),
                duration: nebaDuration(context, NebaScale.durationFill, instant: pressed),
                curve: NebaScale.ease,
                builder: (BuildContext context, Color? color, Widget? content) {
                  return DecoratedBox(
                    decoration: BoxDecoration(color: color, borderRadius: radius),
                    child: content,
                  );
                },
                child: NebaInk(
                  color: ink,
                  instant: pressed,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: text,
                      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ExcludeSemantics(child: child),
                        // Today's mark: a dot rather than a ring, since the
                        // ring is the focus's. It takes the ink, so it turns
                        // white the moment the cell fills.
                        if (current)
                          Positioned(
                            bottom: text * 0.18,
                            child: ExcludeSemantics(child: _Dot(extent: text * 0.22)),
                          ),
                        ?extra,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A dot in the text's colour.
class _Dot extends StatelessWidget {
  const _Dot({required this.extent});

  final double extent;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DefaultTextStyle.of(context).style.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
