/// `NebaTimePicker`, a time of day chosen from columns.
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

/// A time of day, chosen from columns of hours, minutes and, when asked,
/// seconds, each a list that scrolls.
///
/// The trigger is a `NebaTextField`'s shell wearing a clock glyph, as wide as
/// the longest time it could say. A press, Enter or Space opens the clock with
/// the hours focused; each column is one tab stop and the arrow keys walk it.
/// Unlike a date picker it stays open while the columns are read, since a
/// time is two answers, and a Done button in the footer closes it.
///
/// The bounds are read at the span a row stands for: with a [minTime] of
/// 09:30 the hour `9` stays open, because it holds allowed minutes, and the
/// minute column greys out `00` to `29`. A time that lands outside them when
/// a row is pressed, the hour `9` on 10:15, is moved to the nearest bound.
///
/// The value is a [DateTime], so it carries a day as well: [referenceDate] is
/// the day a time is written onto while there is no value yet.
///
/// ```dart
/// NebaTimePicker(
///   label: const Text('Starts at'),
///   placeholder: const Text('Pick a time'),
///   minuteStep: 15,
///   clearable: true,
/// )
/// ```
class NebaTimePicker extends StatefulWidget {
  /// A picker of a time of day.
  const NebaTimePicker({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.referenceDate,
    this.minTime,
    this.maxTime,
    this.shouldDisableTime,
    this.hour12,
    this.showSeconds = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.locale,
    this.format,
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

  /// The chosen time, for a controlled picker. Left `null`, the picker keeps
  /// its own state, starting from [defaultValue]; a value that goes from a
  /// time to `null` empties it.
  final DateTime? value;

  /// The time a picker that keeps its own state starts on.
  final DateTime? defaultValue;

  /// Called with the time now chosen, and `null` once the picker is emptied.
  final ValueChanged<DateTime?>? onValueChange;

  /// Whether the clock is open. With [onOpenChange] the caller owns the
  /// state; without it the picker keeps its own.
  final bool? open;

  /// Whether a picker that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the clock opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The day a chosen time is written onto while there is no value yet.
  /// Defaults to the start of today, so an hour pressed on an empty picker
  /// lands on the hour, and it is held for as long as the picker is built,
  /// so a clock left open across midnight does not move to the next day.
  final DateTime? referenceDate;

  /// The earliest time of day that may be chosen. Only its clock is read.
  final DateTime? minTime;

  /// The latest time of day that may be chosen.
  final DateTime? maxTime;

  /// Blocks single rows, handed the instant each row would produce and the
  /// column it is in, so a rule can be as coarse as "no afternoons" or as
  /// fine as one minute.
  final bool Function(DateTime value, NebaTimeUnit unit)? shouldDisableTime;

  /// A 12-hour dial with a column of AM and PM. Defaults to what [locale]'s
  /// `NebaDateNames` says, which is 12 hours in English.
  final bool? hour12;

  /// Adds the column of seconds, and the seconds to the trigger.
  final bool showSeconds;

  /// How far apart the hours are.
  final int hourStep;

  /// How far apart the minutes are.
  final int minuteStep;

  /// How far apart the seconds are.
  final int secondStep;

  /// The language the time is written in and the picker's own words are in.
  /// Defaults to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// How the trigger writes the chosen time. Defaults to [locale]'s
  /// `NebaDateNames` time, with the seconds when [showSeconds] is on.
  final String Function(DateTime value)? format;

  /// Shown, muted, in the trigger while nothing is chosen, usually a [Text].
  final Widget? placeholder;

  /// Shows a × in the trigger and a Clear button in the footer that empty
  /// it.
  final bool clearable;

  /// Offers the footer's shortcut to the time now.
  final bool showNowButton;

  /// Whether touching any column closes the clock. Off by default, unlike a
  /// date picker's: a time is two answers, and closing after the first
  /// would make 9:30 a matter of opening it twice. Off, the footer carries a
  /// Done button.
  final bool closeOnSelect;

  /// The words a screen reader hears and the footer says, in place of the
  /// [locale]'s.
  final NebaPickerLabels? labels;

  /// The picker's name, usually a [Text]. A screen reader hears it, then the
  /// time the trigger says.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it while nothing is chosen, the trigger does not hold
  /// the focus and the clock is closed. The glyph at the start keeps a
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

  /// The glyph before the value, in place of the clock.
  final Widget? startIcon;

  /// Whether a glyph is drawn before the value at all: React's
  /// `startIcon={false}`.
  final bool showStartIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type, a field's, and the height of a row of
  /// the clock: 32 logical pixels at [NebaSize.md]. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the chosen rows. Defaults
  /// to [NebaColor.primary]; an invalid picker is [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding and the gap between the columns. Defaults
  /// to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0` to `3`. The popup has its own,
  /// fixed at `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the picker is as wide as
  /// the longest time it could say, its placeholder or a resting label.
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
  State<NebaTimePicker> createState() => _NebaTimePickerState();
}

class _NebaTimePickerState extends State<NebaTimePicker> {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late DateTime? _value = widget.defaultValue;
  late bool _open = widget.defaultOpen;

  // Held for as long as the picker is built, so a clock left open across
  // midnight does not quietly move what it writes onto the next day; the
  // start of the day, so an hour pressed lands on the hour.
  late final DateTime _fallbackDay = widget.referenceDate ?? NebaDate.today();

  DateTime? get _current => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  DateTime get _day => widget.referenceDate ?? _fallbackDay;

  @override
  void didUpdateWidget(NebaTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A caller that held a time and now holds none has emptied the picker.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }
  }

  void _setOpen(bool open) {
    if (open && (widget.readOnly || _disabled)) {
      return;
    }

    if (open == _isOpen) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
  }

  // The bounds are times of day, put on the day of the value they hold: a
  // row whose span only reaches into them stays pressable, and pressing it
  // gave a time outside them, the hour 9 on 10:15 under a 09:30 minimum.
  DateTime? _onDayOf(DateTime date, DateTime? time) {
    return time == null ? null : NebaDate.mergeDateAndTime(date, time);
  }

  void _commit(DateTime? next) {
    final DateTime? bounded = next == null
        ? null
        : NebaDate.clamp(next, _onDayOf(next, widget.minTime), _onDayOf(next, widget.maxTime));

    setState(() => _value = bounded);
    widget.onValueChange?.call(bounded);
  }

  // A row is blocked when the whole of its span is outside the bounds, or
  // when the caller says so.
  bool _isBlocked(DateTime candidate, NebaTimeUnit unit) {
    final (int from, int to) = NebaDate.timeUnitSpan(unit, candidate);
    final DateTime? min = widget.minTime;
    final DateTime? max = widget.maxTime;

    if (min != null && to < NebaDate.secondsOfDay(min)) {
      return true;
    }

    if (max != null && from > NebaDate.secondsOfDay(max)) {
      return true;
    }

    return widget.shouldDisableTime?.call(candidate, unit) ?? false;
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
    final bool showSeconds = widget.showSeconds;
    final String Function(DateTime value) format =
        widget.format ??
        (DateTime value) => names.write(showSeconds ? names.timeWithSeconds : names.time, value);
    final DateTime? value = _current;
    final DateTime now = DateTime.now();
    final DateTime nowValue = NebaDate.withTime(
      _day,
      hours: now.hour,
      minutes: now.minute,
      seconds: showSeconds ? now.second : 0,
    );
    final bool closeOnSelect = widget.closeOnSelect;
    final bool hasFooter = widget.showNowButton || widget.clearable || !closeOnSelect;

    final Widget popup = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: hasFooter ? 6 : 0,
      children: <Widget>[
        NebaTimeGrid(
          size: size,
          density: density,
          roles: roles,
          names: names,
          words: words,
          value: value,
          referenceDate: _day,
          onChange: (DateTime next) {
            _commit(next);

            if (closeOnSelect) {
              _setOpen(false);
            }
          },
          hour12: widget.hour12 ?? names.hour12,
          showSeconds: showSeconds,
          hourStep: widget.hourStep,
          minuteStep: widget.minuteStep,
          secondStep: widget.secondStep,
          shouldDisableTime: _isBlocked,
          autofocus: true,
        ),
        if (hasFooter)
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
                  onPressed: _isBlocked(nowValue, NebaTimeUnit.second)
                      ? null
                      : () {
                          _commit(nowValue);
                          _setOpen(false);
                        },
                  variant: NebaVariant.text,
                  size: size,
                  color: family,
                  density: NebaDensity.compact,
                  child: Text(words['now']!),
                ),
              // The clock stays open while its columns are read, so there
              // has to be something to press that means "that one".
              if (!closeOnSelect)
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
      startIcon: widget.showStartIcon ? widget.startIcon ?? NebaGlyph(NebaGlyphs.clock) : null,
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
