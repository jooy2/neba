/// `NebaDateTimePicker`, a day and a time in one popup.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/picker.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A day and a time, chosen in one popup: a calendar and a clock side by
/// side, at the same height, so the popup is one rectangle.
///
/// The trigger is a `NebaTextField`'s shell wearing a calendar glyph, and it
/// writes the moment as one string. Choosing a day keeps the time and
/// choosing a time keeps the day, so the two can be given in either order,
/// and the popup stays open until Done is pressed, since a moment is two
/// answers.
///
/// [minDate] and [maxDate] are read to the second: a minimum of 09:30 on the
/// 27th leaves the 27th open in the calendar and greys out the morning in the
/// clock, and a moment chosen outside them, the 27th while the clock still
/// says midnight, is moved to the nearest bound. That is what a rule such as
/// "not before now" needs.
///
/// ```dart
/// NebaDateTimePicker(
///   label: const Text('Publish at'),
///   placeholder: const Text('Pick a moment'),
///   minuteStep: 15,
///   clearable: true,
/// )
/// ```
class NebaDateTimePicker extends StatefulWidget {
  /// A picker of a moment.
  const NebaDateTimePicker({
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
    this.shouldDisableTime,
    this.locale,
    this.weekStartsOn,
    this.format,
    this.hour12,
    this.showSeconds = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.placeholder,
    this.clearable = false,
    this.showNowButton = true,
    this.closeOnSelect = false,
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
  }) : assert(hourStep > 0 && minuteStep > 0 && secondStep > 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The chosen moment, for a controlled picker. Left `null`, the picker
  /// keeps its own state, starting from [defaultValue]; a value that goes
  /// from a moment to `null` empties it.
  final DateTime? value;

  /// The moment a picker that keeps its own state starts on.
  final DateTime? defaultValue;

  /// Called with the moment now chosen, and `null` once the picker is
  /// emptied.
  final ValueChanged<DateTime?>? onValueChange;

  /// Whether the popup is open. With [onOpenChange] the caller owns the
  /// state; without it the picker keeps its own.
  final bool? open;

  /// Whether a picker that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the popup opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The month the calendar opens on while nothing is chosen. Defaults to
  /// this one.
  final DateTime? defaultMonth;

  /// The earliest moment that may be chosen, read to the second: its day
  /// stays open in the calendar, and the clock blocks the times before it.
  final DateTime? minDate;

  /// The latest moment that may be chosen, read the same way.
  final DateTime? maxDate;

  /// Blocks days inside the bounds that still cannot be chosen.
  final bool Function(DateTime date)? shouldDisableDate;

  /// Blocks single rows of the clock, handed the instant each row would
  /// produce and the column it is in.
  final bool Function(DateTime value, NebaTimeUnit unit)? shouldDisableTime;

  /// The language the moment is written and named in and the picker's own
  /// words are in, and the region the week starts by. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The first column's weekday, as [DateTime.weekday] counts it. Defaults
  /// to the one [locale] starts its week on.
  final NebaWeekday? weekStartsOn;

  /// How the trigger writes the chosen moment. Defaults to [locale]'s
  /// `NebaDateNames` date and time.
  final String Function(DateTime value)? format;

  /// A 12-hour dial with a column of AM and PM. Defaults to what [locale]'s
  /// `NebaDateNames` says, which is 12 hours in English.
  final bool? hour12;

  /// Adds the column of seconds.
  final bool showSeconds;

  /// How far apart the hours are.
  final int hourStep;

  /// How far apart the minutes are.
  final int minuteStep;

  /// How far apart the seconds are.
  final int secondStep;

  /// Shown, muted, in the trigger while nothing is chosen, usually a [Text].
  final Widget? placeholder;

  /// Shows a × in the trigger and a Clear button in the footer that empty
  /// it.
  final bool clearable;

  /// Offers the footer's shortcut to this moment.
  final bool showNowButton;

  /// Whether choosing a day closes the popup. Off by default, unlike a date
  /// picker's: a moment is a day and a time, and closing on the first would
  /// leave the second unanswered.
  final bool closeOnSelect;

  /// The words a screen reader hears and the footer says, in place of the
  /// [locale]'s.
  final NebaPickerLabels? labels;

  /// The picker's name, usually a [Text]. A screen reader hears it, then the
  /// moment the trigger says.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it while nothing is chosen, the trigger does not hold
  /// the focus and the popup is closed. The glyph at the start keeps a
  /// `float` label in the notch; [showStartIcon] `false` gives it somewhere
  /// to rest. Defaults to `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the trigger, usually a [Text].
  final Widget? description;

  /// An error under the trigger, usually a [Text]. Giving one turns the
  /// picker invalid.
  final Widget? error;

  /// Whether the picker is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// The glyph before the value, in place of the calendar. The calendar
  /// alone rather than a calendar and a clock: the date is the part a
  /// reader scans for.
  final Widget? startIcon;

  /// Whether a glyph is drawn before the value at all: React's
  /// `startIcon={false}`.
  final bool showStartIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type, a field's, and the calendar's cells and
  /// the clock's rows: 32 logical pixels at [NebaSize.md]. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the chosen day and time.
  /// Defaults to [NebaColor.primary]; an invalid picker is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding and the gap between the clock's columns.
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0` to `3`. The popup has its own,
  /// fixed at `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the picker is as wide as
  /// the longest moment it could say, its placeholder or a resting label.
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
  State<NebaDateTimePicker> createState() => _NebaDateTimePickerState();
}

class _NebaDateTimePickerState extends State<NebaDateTimePicker> {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late DateTime? _value = widget.defaultValue;
  late bool _open = widget.defaultOpen;
  late DateTime _month = _monthToOpen;

  DateTime? get _current => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  DateTime get _monthToOpen {
    return NebaDate.startOfMonth(_current ?? widget.defaultMonth ?? NebaDate.today());
  }

  @override
  void didUpdateWidget(NebaDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A caller that held a moment and now holds none has emptied the picker.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }

    // Opened from outside: the calendar starts on the chosen month too.
    if (widget.open == true && oldWidget.open != true) {
      _month = _monthToOpen;
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

      // Opening puts the calendar back on the chosen month.
      if (open) {
        _month = _monthToOpen;
      }
    });

    widget.onOpenChange?.call(open);
  }

  // Every way of choosing a moment ends here, a day, a row of the clock or
  // Now, so the bounds are held here: the day the minimum falls on gave
  // midnight, and an hour pressed could give a minute before the bound.
  void _commit(DateTime? next) {
    final DateTime? bounded = next == null
        ? null
        : NebaDate.clamp(next, widget.minDate, widget.maxDate);

    setState(() => _value = bounded);
    widget.onValueChange?.call(bounded);
  }

  // A row of the clock is blocked when the whole of its span on the day it
  // writes onto is outside the bounds, compared on the wall clock.
  bool _isTimeBlocked(DateTime candidate, NebaTimeUnit unit) {
    final (DateTime from, DateTime to) = NebaDate.timeUnitRange(unit, candidate);
    final DateTime? min = widget.minDate;
    final DateTime? max = widget.maxDate;

    if (min != null && to.isBefore(min)) {
      return true;
    }

    if (max != null && from.isAfter(max)) {
      return true;
    }

    return widget.shouldDisableTime?.call(candidate, unit) ?? false;
  }

  void _selectDay(DateTime date) {
    final DateTime? current = _current;
    // The day changes and the clock does not, so the two can be chosen in
    // either order.
    final DateTime next = current == null
        ? NebaDate.startOfDay(date)
        : NebaDate.mergeDateAndTime(date, current);

    _commit(next);
    setState(() => _month = NebaDate.startOfMonth(next));

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
    final String Function(DateTime value) format =
        widget.format ?? (DateTime value) => names.write(names.dateTime, value);
    final DateTime? value = _current;
    final DateTime now = DateTime.now();
    final DateTime nowValue = NebaDate.withTime(now, seconds: widget.showSeconds ? null : 0);
    final bool nowBlocked =
        NebaDate.isDayOutside(nowValue, widget.minDate, widget.maxDate) ||
        (widget.shouldDisableDate?.call(nowValue) ?? false) ||
        _isTimeBlocked(nowValue, NebaTimeUnit.second);

    final Widget popup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: <Widget>[
        // The calendar, a hairline and the clock, the line as tall as the
        // taller of the two.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.topStart,
                child: NebaCalendarGrid(
                  size: size,
                  color: family,
                  roles: roles,
                  names: names,
                  words: words,
                  weekStartsOn: widget.weekStartsOn ?? nebaWeekStart(locale),
                  month: _month,
                  onMonthChange: (DateTime next) => setState(() => _month = next),
                  selected: <DateTime>[?value],
                  onSelect: _selectDay,
                  minDate: widget.minDate,
                  maxDate: widget.maxDate,
                  shouldDisableDate: widget.shouldDisableDate,
                  autofocus: true,
                ),
              ),
              SizedBox(width: 1, child: ColoredBox(color: roles.line)),
              Align(
                alignment: AlignmentDirectional.topStart,
                child: NebaTimeGrid(
                  size: size,
                  density: density,
                  roles: roles,
                  names: names,
                  words: words,
                  value: value,
                  // With no moment yet the clock writes onto today, and a day
                  // chosen afterwards keeps whatever time was set.
                  referenceDate: value ?? NebaDate.today(),
                  onChange: _commit,
                  hour12: widget.hour12 ?? names.hour12,
                  showSeconds: widget.showSeconds,
                  hourStep: widget.hourStep,
                  minuteStep: widget.minuteStep,
                  secondStep: widget.secondStep,
                  shouldDisableTime: _isTimeBlocked,
                ),
              ),
            ],
          ),
        ),
        NebaPickerFooter(
          size: size,
          roles: roles,
          children: <Widget>[
            if (widget.clearable)
              NebaButton(
                onPressed: () {
                  _commit(null);
                  _setOpen(false);
                },
                variant: NebaVariant.text,
                size: size,
                color: family,
                density: NebaDensity.compact,
                child: Text(words['clear']!),
              ),
            if (widget.showNowButton)
              NebaButton(
                onPressed: nowBlocked
                    ? null
                    : () {
                        _commit(nowValue);
                        setState(() => _month = NebaDate.startOfMonth(nowValue));
                      },
                variant: NebaVariant.text,
                size: size,
                color: family,
                density: NebaDensity.compact,
                child: Text(words['now']!),
              ),
            NebaButton(
              onPressed: () => _setOpen(false),
              variant: NebaVariant.solid,
              size: size,
              color: family,
              density: NebaDensity.compact,
              child: Text(words['done']!),
            ),
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
      value: value == null ? null : format(value),
      samples: nebaDisplaySamples(format),
      placeholder: widget.placeholder,
      label: widget.label,
      labelPlacement: placement,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      startIcon: widget.showStartIcon ? widget.startIcon ?? NebaGlyph(NebaGlyphs.calendar) : null,
      clearable: widget.clearable,
      clearLabel: words['clear']!,
      onClear: () => _commit(null),
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
