/// `NebaDateRangePicker`, a span between two days.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/calendar/neba_calendar.dart';
import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/picker.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Two ends of a span, either of which may be missing: the value of a
/// `NebaDateRangePicker`.
///
/// The same type as `NebaCalendar.range`'s value, so a span chosen on an
/// inline calendar and one chosen behind a field can be held in one variable.
/// One value rather than two, because a span is chosen in one gesture,
/// cleared in one and checked as a whole, and the two names are what stop
/// the end being written into the start.
typedef NebaDateRange = NebaCalendarRange;

/// A named span offered as a shortcut beside the calendars: "Last 7 days",
/// "This month".
@immutable
class NebaDateRangePreset {
  /// A shortcut to [value], a span that does not depend on when it is
  /// pressed.
  const NebaDateRangePreset({required this.label, required NebaDateRange value})
    : _value = value,
      _compute = null;

  /// A shortcut to the span [value] works out when the shortcut is pressed,
  /// which is what a span counted from today needs: one worked out when the
  /// screen was built is wrong for anyone who leaves it open overnight.
  const NebaDateRangePreset.computed({required this.label, required NebaDateRange Function() value})
    : _value = null,
      _compute = value;

  /// What the shortcut says, usually a [Text].
  final Widget label;

  final NebaDateRange? _value;
  final NebaDateRange Function()? _compute;

  /// The span the shortcut stands for now.
  NebaDateRange resolve() => _compute?.call() ?? _value!;
}

/// A span between two days, chosen on two calendars side by side.
///
/// Two months because a span that crosses the end of a month is the usual
/// case. The two panels are one calendar in halves: the first has no stepper
/// forward and the second none back, and either header moves the pair. The
/// first press marks where the span starts and draws the band from it to the
/// day under the pointer, and the second lands the end; nothing is reported
/// until it does, so closing the popup after one press keeps the span that
/// was there. A second press before the first starts the span there instead.
///
/// The trigger is a `NebaTextField`'s shell wearing a calendar glyph, with
/// the two ends on either side of an arrow, each as wide as the longest date
/// it could say or its placeholder.
///
/// ```dart
/// NebaDateRangePicker(
///   label: const Text('Stay'),
///   startPlaceholder: const Text('Check in'),
///   endPlaceholder: const Text('Check out'),
///   clearable: true,
/// )
/// ```
class NebaDateRangePicker extends StatefulWidget {
  /// A picker of a span of days.
  const NebaDateRangePicker({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.defaultMonth,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.locale,
    this.weekStartsOn,
    this.format,
    this.monthCount = 2,
    this.startPlaceholder,
    this.endPlaceholder,
    this.presets,
    this.clearable = false,
    this.closeOnSelect = true,
    this.labels,
    this.label,
    this.labelPlacement,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.showStartIcon = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.fullWidth = false,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(monthCount == 1 || monthCount == 2),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The chosen span, for a controlled picker. Left `null`, the picker keeps
  /// its own state, starting from [defaultValue]; a value that goes from a
  /// span to `null` empties it.
  final NebaDateRange? value;

  /// The span a picker that keeps its own state starts on.
  final NebaDateRange? defaultValue;

  /// Called with the span once both ends are chosen, and with an empty one,
  /// both ends `null`, once it is cleared. Never with half a span.
  final ValueChanged<NebaDateRange>? onValueChange;

  /// Whether the popup is open. With [onOpenChange] the caller owns the
  /// state; without it the picker keeps its own.
  final bool? open;

  /// Whether a picker that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the popup opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The month the first panel opens on while nothing is chosen. Defaults to
  /// this one.
  final DateTime? defaultMonth;

  /// The earliest day that may be chosen, in both panels.
  final DateTime? minDate;

  /// The latest day that may be chosen.
  final DateTime? maxDate;

  /// Blocks days inside the bounds that still cannot be chosen. Asked again
  /// when the picker is built again, and not as the band follows the
  /// pointer.
  final bool Function(DateTime date)? shouldDisableDate;

  /// The language the dates are written and named in and the picker's own
  /// words are in, and the region the week starts by. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The first column's weekday, as [DateTime.weekday] counts it. Defaults
  /// to the one [locale] starts its week on.
  final NebaWeekday? weekStartsOn;

  /// How each end of the trigger writes its date. Defaults to [locale]'s
  /// `NebaDateNames` medium date.
  final String Function(DateTime date)? format;

  /// How many months are on screen at once, `1` or `2`. With two, the days
  /// of the months next door are left out, so one date is never in both
  /// panels.
  final int monthCount;

  /// Shown, muted, in the first half of the trigger while the start is not
  /// chosen, usually a [Text].
  final Widget? startPlaceholder;

  /// The same, for the end.
  final Widget? endPlaceholder;

  /// Shortcuts listed beside the calendars.
  final List<NebaDateRangePreset>? presets;

  /// Shows a × in the trigger and a Clear button in the footer that empty
  /// both ends.
  final bool clearable;

  /// Whether the popup closes once both ends are chosen, or a preset is.
  final bool closeOnSelect;

  /// The words a screen reader hears and the footer says, in place of the
  /// [locale]'s.
  final NebaPickerLabels? labels;

  /// The picker's name, usually a [Text]. A screen reader hears it, then the
  /// span the trigger says.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it in place of both placeholders while neither end is
  /// chosen, the trigger does not hold the focus and the popup is closed.
  /// The glyph at the start keeps a `float` label in the notch;
  /// [showStartIcon] `false` gives it somewhere to rest. Defaults to
  /// `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the trigger, usually a [Text].
  final Widget? description;

  /// An error under the trigger, usually a [Text]. Giving one turns the
  /// picker invalid.
  final Widget? error;

  /// Whether the picker is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// The glyph before the value, in place of the calendar.
  final Widget? startIcon;

  /// Whether a glyph is drawn before the value at all: React's
  /// `startIcon={false}`.
  final bool showStartIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type, a field's, and the calendars' cells: 32
  /// logical pixels at [NebaSize.md]. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring, the ends and the band.
  /// Defaults to [NebaColor.primary]; an invalid picker is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0` to `3`. The popup has its own,
  /// fixed at `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise each end of the trigger
  /// is as wide as the longest date it could say or its placeholder.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows its value, keeps the focus and does not open.
  final bool readOnly;

  /// What a screen reader names the trigger, in place of [label].
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaDateRangePicker> createState() => _NebaDateRangePickerState();
}

class _NebaDateRangePickerState extends State<NebaDateRangePicker> {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late NebaDateRange _value = widget.defaultValue ?? const NebaDateRange();
  late bool _open = widget.defaultOpen;
  late DateTime _month = _monthToOpen;

  // The first of the two presses, while the second has not landed. Held here
  // rather than in the value, so a caller is never handed half a span.
  DateTime? _anchor;

  NebaDateRange get _current => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  DateTime get _monthToOpen {
    return NebaDate.startOfMonth(_current.start ?? widget.defaultMonth ?? NebaDate.today());
  }

  @override
  void didUpdateWidget(NebaDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A caller that held a span and now holds none has emptied the picker.
    if (oldWidget.value != null && widget.value == null) {
      _value = const NebaDateRange();
    }

    if (widget.open == true && oldWidget.open != true) {
      _month = _monthToOpen;
    }

    // Closed from outside: a span half chosen does not outlive the popup.
    if (oldWidget.open == true && widget.open == false) {
      _anchor = null;
    }
  }

  void _setOpen(bool open) {
    if (open && (widget.readOnly || _disabled)) {
      return;
    }

    if (open == _isOpen) {
      return;
    }

    setState(() {
      if (widget.open == null) {
        _open = open;
      }

      if (open) {
        _month = _monthToOpen;
      } else {
        _anchor = null;
      }
    });

    widget.onOpenChange?.call(open);
  }

  void _commit(NebaDateRange next) {
    setState(() => _value = next);
    widget.onValueChange?.call(next);
  }

  void _select(DateTime date) {
    final DateTime day = NebaDate.startOfDay(date);
    final DateTime? anchor = _anchor;

    // The first press of a new span, or a second one before the first: it
    // marks where the span starts and reports nothing, so closing the popup
    // here keeps the span that was there.
    if (anchor == null || NebaDate.compareDay(day, anchor) < 0) {
      setState(() => _anchor = day);

      return;
    }

    setState(() => _anchor = null);
    _commit(NebaDateRange(start: anchor, end: day));

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  void _applyPreset(NebaDateRangePreset preset) {
    final NebaDateRange range = preset.resolve();
    final DateTime? start = range.start;

    setState(() {
      _anchor = null;

      if (start != null) {
        _month = NebaDate.startOfMonth(start);
      }
    });
    _commit(range);

    if (widget.closeOnSelect) {
      _setOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaLabelPlacement placement =
        widget.labelPlacement ?? defaults.labelPlacement ?? NebaLabelPlacement.top;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColor family = invalid ? NebaColor.danger : color;
    final NebaColorRoles roles = tokens.roles(family);
    final Locale? locale = nebaDateLocale(context, locale: widget.locale);
    final NebaDateNames names = NebaDateNames.resolve(locale);
    final Map<String, String> words = nebaPickerWords(
      context,
      locale: widget.locale,
      labels: widget.labels,
    );
    final String Function(DateTime date) format =
        widget.format ?? (DateTime date) => names.write(names.mediumDate, date);
    final NebaDateRange value = _current;
    final DateTime? start = value.start;
    final DateTime? end = value.end;
    final DateTime? anchor = _anchor;
    final bool twoUp = widget.monthCount == 2;
    final List<NebaDateRangePreset> presets = widget.presets ?? const <NebaDateRangePreset>[];
    final double text = NebaScale.controlText[size]!;
    final List<String> samples = nebaDisplaySamples(format);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    // Each day is asked once per build of the picker, and not again as the
    // band follows the pointer, which rebuilds the panels alone: asking every
    // cell of both months on every cell the pointer entered was sixty-two
    // calls a move.
    final bool Function(DateTime date)? check = widget.shouldDisableDate;
    final Map<DateTime, bool> asked = <DateTime, bool>{};
    final bool Function(DateTime date)? shouldDisableDate = check == null
        ? null
        : (DateTime date) => asked.putIfAbsent(date, () => check(date));

    // Which end the next press fills: the trigger says so with its two
    // halves, but the popup is over it, so the footer says it where it is read.
    final String? hint = anchor != null
        ? words['end']
        : start == null
        ? words['start']
        : null;

    Widget panel({
      required Key key,
      required DateTime month,
      required ValueChanged<DateTime> onMonthChange,
      required DateTime? bandStart,
      required DateTime? bandEnd,
      required ValueChanged<DateTime?> onPreviewChange,
      bool showPreviousButton = true,
      bool showNextButton = true,
      bool autofocus = false,
    }) {
      return NebaCalendarGrid(
        key: key,
        size: size,
        color: family,
        roles: roles,
        names: names,
        words: words,
        weekStartsOn: widget.weekStartsOn ?? nebaWeekStart(locale),
        month: month,
        onMonthChange: onMonthChange,
        selected: <DateTime>[?start, ?end, ?anchor],
        rangeStart: bandStart,
        rangeEnd: bandEnd,
        onPreviewChange: onPreviewChange,
        onSelect: _select,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        shouldDisableDate: shouldDisableDate,
        // With two panels a trailing day of the first would be a leading day
        // of the second: one date twice in one popup.
        showOutsideDays: false,
        showPreviousButton: showPreviousButton,
        showNextButton: showNextButton,
        autofocus: autofocus,
      );
    }

    final Widget popup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              if (presets.isNotEmpty)
                _Presets(
                  size: size,
                  color: family,
                  roles: roles,
                  presets: presets,
                  onPressed: _applyPreset,
                ),
              _RangeCalendars(
                anchor: anchor,
                start: start,
                end: end,
                month: _month,
                onMonthChange: (DateTime next) => setState(() => _month = next),
                twoUp: twoUp,
                gap: NebaScale.gap[size]!,
                panel: panel,
              ),
            ],
          ),
        ),
        if (widget.clearable || hint != null)
          NebaPickerFooter(
            size: size,
            roles: roles,
            children: <Widget>[
              if (hint != null)
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
                  ),
                ),
              if (widget.clearable)
                NebaButton(
                  onPressed: () {
                    setState(() => _anchor = null);
                    _commit(const NebaDateRange());
                    _setOpen(false);
                  },
                  variant: NebaVariant.text,
                  size: size,
                  color: family,
                  density: NebaDensity.compact,
                  child: Text(words['clear']!),
                ),
            ],
          ),
      ],
    );

    // One end of the trigger: its date or its placeholder, as wide as the
    // longest of either. Each end holds its own width, so the arrow between
    // them stays put whatever is chosen.
    Widget half(DateTime? date, Widget? placeholder) {
      return NebaFieldWidth(
        width: 0,
        sizer: NebaWidthSizer(
          samples: <Widget>[for (final String sample in samples) Text(sample), ?placeholder],
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: date == null
              ? placeholder ?? const SizedBox.shrink()
              : Text(format(date), style: TextStyle(color: tokens.fg)),
        ),
      );
    }

    final double arrow = text * 1.2;
    // The arrow points along the line of reading, back to front under a
    // right-to-left direction.
    final Widget arrowGlyph = RotatedBox(
      quarterTurns: rtl ? 2 : 0,
      child: NebaGlyph(NebaGlyphs.arrowRight, size: arrow),
    );

    final Widget display = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        Flexible(child: half(start, widget.startPlaceholder)),
        arrowGlyph,
        Flexible(child: half(end, widget.endPlaceholder)),
      ],
    );

    // What the trigger's width is measured from: both ends at their widest
    // and the arrow between them.
    final Widget sizer = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        NebaWidthSizer(
          samples: <Widget>[
            for (final String sample in samples) Text(sample),
            ?widget.startPlaceholder,
          ],
        ),
        SizedBox(width: arrow),
        NebaWidthSizer(
          samples: <Widget>[
            for (final String sample in samples) Text(sample),
            ?widget.endPlaceholder,
          ],
        ),
      ],
    );

    return NebaPickerField(
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: widget.elevation ?? 0,
      value: start == null && end == null
          ? null
          : '${start == null ? '' : format(start)} – ${end == null ? '' : format(end)}',
      samples: const <String>[],
      display: display,
      sizer: sizer,
      label: widget.label,
      labelPlacement: placement,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      startIcon: widget.showStartIcon ? widget.startIcon ?? NebaGlyph(NebaGlyphs.calendar) : null,
      clearable: widget.clearable,
      clearLabel: words['clear']!,
      onClear: () => _commit(const NebaDateRange()),
      open: _isOpen && !_disabled && !widget.readOnly,
      onOpenChange: _setOpen,
      popup: popup,
      fullWidth: widget.fullWidth,
      disabled: _disabled,
      readOnly: widget.readOnly,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
    );
  }
}

/// What builds one panel of the range picker.
typedef _Panel =
    Widget Function({
      required Key key,
      required DateTime month,
      required ValueChanged<DateTime> onMonthChange,
      required DateTime? bandStart,
      required DateTime? bandEnd,
      required ValueChanged<DateTime?> onPreviewChange,
      bool showPreviousButton,
      bool showNextButton,
      bool autofocus,
    });

/// The panels, and the day under the pointer while a span is half chosen.
///
/// The band follows the pointer from cell to cell, which is a build for
/// every cell it enters, so the day it is drawn to is held here, and only
/// the panels are built again: the trigger, the field and the popup around
/// them depend on none of it.
class _RangeCalendars extends StatefulWidget {
  const _RangeCalendars({
    required this.anchor,
    required this.start,
    required this.end,
    required this.month,
    required this.onMonthChange,
    required this.twoUp,
    required this.gap,
    required this.panel,
  });

  final DateTime? anchor;
  final DateTime? start;
  final DateTime? end;
  final DateTime month;
  final ValueChanged<DateTime> onMonthChange;
  final bool twoUp;

  /// The gap between the two panels, the one beside the presets too.
  final double gap;

  final _Panel panel;

  @override
  State<_RangeCalendars> createState() => _RangeCalendarsState();
}

class _RangeCalendarsState extends State<_RangeCalendars> {
  // The day under the pointer, with the press it was measured from, so a
  // new first press starts the band at that press rather than at wherever
  // the pointer last was.
  (DateTime, DateTime)? _hovered;

  void _preview(DateTime? date) {
    final DateTime? anchor = widget.anchor;

    if (anchor == null) {
      return;
    }

    setState(() => _hovered = date == null ? null : (anchor, date));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? anchor = widget.anchor;
    final (DateTime, DateTime)? hovered = _hovered;
    final DateTime? preview = anchor != null && hovered != null && hovered.$1 == anchor
        ? hovered.$2
        : anchor;
    // The finished span, or the first press and the day under the pointer.
    final DateTime? bandStart = anchor ?? widget.start;
    final DateTime? bandEnd = anchor != null ? preview : widget.end;
    final DateTime month = widget.month;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: widget.gap,
      children: <Widget>[
        widget.panel(
          key: const ValueKey<String>('first'),
          month: month,
          onMonthChange: widget.onMonthChange,
          bandStart: bandStart,
          bandEnd: bandEnd,
          onPreviewChange: _preview,
          showNextButton: !widget.twoUp,
          autofocus: true,
        ),
        if (widget.twoUp)
          widget.panel(
            key: const ValueKey<String>('second'),
            month: NebaDate.addMonths(month, 1),
            // The second panel is a month on, so moving it moves the pair:
            // both headers drive one month.
            onMonthChange: (DateTime next) => widget.onMonthChange(NebaDate.addMonths(next, -1)),
            bandStart: bandStart,
            bandEnd: bandEnd,
            onPreviewChange: _preview,
            showPreviousButton: false,
          ),
      ],
    );
  }
}

/// The shortcuts, in a column beside the calendars that scrolls past eight
/// cells of a `md` calendar and is ruled off from them.
class _Presets extends StatelessWidget {
  const _Presets({
    required this.size,
    required this.color,
    required this.roles,
    required this.presets,
    required this.onPressed,
  });

  final NebaSize size;
  final NebaColor color;
  final NebaColorRoles roles;
  final List<NebaDateRangePreset> presets;
  final ValueChanged<NebaDateRangePreset> onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        // `max-h-[calc(var(--n-cell,2rem)*8)]`, which reads its fallback,
        // since the cell is set on the calendar and not here: 256 at every
        // size.
        constraints: const BoxConstraints(maxHeight: 256),
        child: SizedBox(
          height: double.infinity,
          child: Container(
            padding: const EdgeInsetsDirectional.only(end: 6),
            decoration: BoxDecoration(
              border: BorderDirectional(end: BorderSide(color: roles.line)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final NebaDateRangePreset preset in presets)
                    NebaButton(
                      onPressed: () => onPressed(preset),
                      variant: NebaVariant.text,
                      size: size,
                      color: color,
                      density: NebaDensity.compact,
                      child: preset.label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
