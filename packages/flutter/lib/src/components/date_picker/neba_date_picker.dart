/// `NebaDatePicker`, one day chosen from a calendar popup.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/date.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/picker.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One day chosen from a calendar popup.
///
/// The trigger is a `NebaTextField`'s shell wearing a calendar glyph, so a
/// date field and the fields around it share their height, corners and edge.
/// A press, Enter or Space opens the calendar on the chosen month with the
/// chosen day focused; Escape, a press outside and the choice itself close
/// it. The month name and the year in the calendar's header each open a grid
/// of their own, so a distant date stays a few presses away.
///
/// [granularity] turns the picker into one that asks for a whole month or a
/// whole year: the calendar opens on that grid and stops there, and the
/// value is the first day of what was chosen. The trigger is as wide as the
/// longest date it could say, so choosing the 1st after the 28th never moves
/// it. There is no typing into it: a date read out of free text depends on
/// the language in a way that cannot be done honestly without a date
/// library, so the calendar is where the answer comes from.
///
/// ```dart
/// NebaDatePicker(
///   label: const Text('Ships on'),
///   placeholder: const Text('Pick a day'),
///   clearable: true,
/// )
/// ```
class NebaDatePicker extends StatefulWidget {
  /// A picker of one day.
  const NebaDatePicker({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.granularity = NebaDateGranularity.day,
    this.defaultMonth,
    this.minDate,
    this.maxDate,
    this.shouldDisableDate,
    this.locale,
    this.weekStartsOn,
    this.format,
    this.placeholder,
    this.clearable = false,
    this.showTodayButton = true,
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
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The chosen day, for a controlled picker. Left `null`, the picker keeps
  /// its own state, starting from [defaultValue]; a value that goes from a
  /// day to `null` empties it.
  final DateTime? value;

  /// The day a picker that keeps its own state starts on.
  final DateTime? defaultValue;

  /// Called with the day now chosen, and `null` once the picker is emptied.
  /// A day chosen keeps the time of day the value already had.
  final ValueChanged<DateTime?>? onValueChange;

  /// Whether the calendar is open. With [onOpenChange] the caller owns the
  /// state; without it the picker keeps its own.
  final bool? open;

  /// Whether a picker that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the calendar opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// What the picker asks for: a day, a whole month or a whole year. At
  /// [NebaDateGranularity.month] and [NebaDateGranularity.year] the calendar
  /// opens on that grid and stops there, and the value is the 1st of the
  /// month or of January. The trigger's default [format], the footer's
  /// shortcut and the unit the bounds are read at all follow it.
  final NebaDateGranularity granularity;

  /// The month the calendar opens on while nothing is chosen. Defaults to
  /// this one.
  final DateTime? defaultMonth;

  /// The earliest date that may be chosen, compared at [granularity]: a
  /// minimum of 15 March leaves the 14th out at a day and March in at a
  /// month, since part of March is allowed.
  final DateTime? minDate;

  /// The latest date that may be chosen, read the same way.
  final DateTime? maxDate;

  /// Blocks cells inside the bounds that still cannot be chosen, weekends,
  /// holidays, a room already booked, handed the value each cell would
  /// produce: at a month, the 1st.
  final bool Function(DateTime date)? shouldDisableDate;

  /// The language the dates are written and named in and the picker's own
  /// words are in, and the region the week starts by. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The first column's weekday, as [DateTime.weekday] counts it. Defaults
  /// to the one [locale] starts its week on.
  final NebaWeekday? weekStartsOn;

  /// How the trigger writes the chosen date. Defaults to what [granularity]
  /// asks for, in [locale]'s [NebaDateNames]: a medium date, a month of a
  /// year, or a year.
  final String Function(DateTime date)? format;

  /// Shown, muted, in the trigger while nothing is chosen, usually a [Text].
  final Widget? placeholder;

  /// Shows a × in the trigger and a Clear button in the footer that empty
  /// it.
  final bool clearable;

  /// Offers the footer's shortcut to the current unit: today, this month or
  /// this year, whichever [granularity] asks for.
  final bool showTodayButton;

  /// Whether choosing closes the calendar.
  final bool closeOnSelect;

  /// The words a screen reader hears and the footer says, in place of the
  /// [locale]'s.
  final NebaPickerLabels? labels;

  /// The picker's name, usually a [Text]. A screen reader hears it, then the
  /// date the trigger says.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it while nothing is chosen, the trigger does not hold
  /// the focus and the calendar is closed. The glyph at the start keeps a
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

  /// The glyph before the value, in place of the calendar.
  final Widget? startIcon;

  /// Whether a glyph is drawn before the value at all: React's
  /// `startIcon={false}`.
  final bool showStartIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type, a field's, and the calendar's cells: 32
  /// logical pixels at [NebaSize.md]. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the chosen day. Defaults to
  /// [NebaColor.primary]; an invalid picker is [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0` to `3`. The popup has its own,
  /// fixed at `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the picker is as wide as
  /// the longest date it could say, its placeholder or a resting label.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows its value, keeps the focus and does not open: what it holds is
  /// something to read.
  final bool readOnly;

  /// What a screen reader names the trigger, in place of [label].
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaDatePicker> createState() => _NebaDatePickerState();
}

class _NebaDatePickerState extends State<NebaDatePicker> {
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
  void didUpdateWidget(NebaDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A caller that held a day and now holds none has emptied the picker.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }

    // Opened from outside: the calendar starts on the chosen month too.
    if (widget.open == true && oldWidget.open != true) {
      _month = _monthToOpen;
    }
  }

  void _setOpen(bool open) {
    // A read-only picker does not open: what it holds is something to read,
    // and a calendar of inert cells would be a menu of nothing.
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

      // Opening puts the calendar back on the chosen month, or one left on
      // 2019 while browsing reads as the picker having lost its value.
      if (open) {
        _month = _monthToOpen;
      }
    });

    widget.onOpenChange?.call(open);
  }

  void _commit(DateTime? next) {
    setState(() => _value = next);
    widget.onValueChange?.call(next);
  }

  void _select(DateTime date) {
    // The unit is the answer: a month picker reports the 1st whichever cell
    // was pressed, and the footer lands on the value the grid would have.
    final DateTime unit = NebaDate.startOfUnit(date, widget.granularity);
    final DateTime? current = _current;
    // The day changes and the time of day, if the value had one, does not.
    final DateTime next = current == null ? unit : NebaDate.mergeDateAndTime(unit, current);

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
    final Locale? locale = nebaDateLocale(context, locale: widget.locale);
    final NebaDateNames names = NebaDateNames.resolve(locale);
    final Map<String, String> words = nebaPickerWords(
      context,
      locale: widget.locale,
      labels: widget.labels,
    );
    final NebaDateGranularity granularity = widget.granularity;
    final String Function(DateTime date) format =
        widget.format ??
        switch (granularity) {
          NebaDateGranularity.day => (DateTime date) => names.write(names.mediumDate, date),
          NebaDateGranularity.month => (DateTime date) => names.write(names.monthYear, date),
          NebaDateGranularity.year => (DateTime date) => '${date.year}',
        };
    final DateTime? value = _current;
    final DateTime now = NebaDate.today();
    // Read at the grid's unit and against the value it would commit, so a
    // "This month" is not greyed out because the 1st is a Saturday.
    final bool shortcutBlocked =
        NebaDate.isUnitOutside(now, granularity, widget.minDate, widget.maxDate) ||
        (widget.shouldDisableDate?.call(NebaDate.startOfUnit(now, granularity)) ?? false);
    final String shortcutLabel = switch (granularity) {
      NebaDateGranularity.year => words['thisYear']!,
      NebaDateGranularity.month => words['thisMonth']!,
      NebaDateGranularity.day => words['today']!,
    };
    final bool hasFooter = widget.showTodayButton || widget.clearable;

    final Widget popup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: hasFooter ? 6 : 0,
      children: <Widget>[
        NebaCalendarGrid(
          size: size,
          color: family,
          roles: tokens.roles(family),
          names: names,
          words: words,
          weekStartsOn: widget.weekStartsOn ?? nebaWeekStart(locale),
          month: _month,
          onMonthChange: (DateTime next) => setState(() => _month = next),
          selected: <DateTime>[?value],
          onSelect: _select,
          granularity: granularity,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          shouldDisableDate: widget.shouldDisableDate,
          autofocus: true,
        ),
        if (hasFooter)
          NebaPickerFooter(
            size: size,
            roles: tokens.roles(family),
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
              if (widget.showTodayButton)
                NebaButton(
                  onPressed: shortcutBlocked ? null : () => _select(now),
                  variant: NebaVariant.text,
                  size: size,
                  color: family,
                  density: NebaDensity.compact,
                  child: Text(shortcutLabel),
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
