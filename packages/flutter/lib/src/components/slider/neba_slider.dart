/// `NebaSlider`, a value chosen by dragging along a range, and the marks
/// named along it.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How thick the groove is, CSS `h-1` to `h-2.5`.
const Map<NebaSize, double> _trackThickness = <NebaSize, double>{
  NebaSize.xs: 4,
  NebaSize.sm: 6,
  NebaSize.md: 6,
  NebaSize.lg: 8,
  NebaSize.xl: 10,
};

/// The thumb's diameter, CSS `size-3` to `size-6`: far bigger than the groove,
/// because it is the part a finger has to catch.
const Map<NebaSize, double> _thumbDiameter = <NebaSize, double>{
  NebaSize.xs: 12,
  NebaSize.sm: 14,
  NebaSize.md: 16,
  NebaSize.lg: 20,
  NebaSize.xl: 24,
};

/// How tall the strip a press lands on is, CSS `h-4` to `h-7`: taller than the
/// groove drawn in it, so the whole strip is a target and not just the rail.
const Map<NebaSize, double> _stripExtent = <NebaSize, double>{
  NebaSize.xs: 16,
  NebaSize.sm: 18,
  NebaSize.md: 20,
  NebaSize.lg: 24,
  NebaSize.xl: 28,
};

/// The length a slider takes where it is given none: the CSS `h-40` a
/// vertical one starts from.
const double _length = 160;

/// Past this many steps, `NebaSliderMarks.steps` draws nothing: a tick at
/// every one of ten thousand steps is not what anybody meant.
const int _maxStepMarks = 100;

/// A tick's length, CSS `1.5`, and the gap between a vertical tick and its
/// label.
const double _tick = 6;

/// The halo a thumb wears under the pointer and while the slider is dragged,
/// CSS `0 0 0 4px` and `0 0 0 6px`.
const double _hoverHalo = 4;
const double _dragHalo = 6;

/// One labelled point on a [NebaSlider]'s track.
@immutable
class NebaSliderMark {
  /// A mark at [value], with [label] written beside it.
  const NebaSliderMark({required this.value, this.label});

  /// Where it sits, in the slider's own units.
  final double value;

  /// What is written under it, usually a [Text]. A mark with no label is a
  /// tick on its own.
  final Widget? label;
}

/// The points named along a [NebaSlider]'s track: a list of them, or a tick
/// at every step.
@immutable
class NebaSliderMarks {
  /// The [marks], each at its own value.
  const NebaSliderMarks(List<NebaSliderMark> this.marks);

  const NebaSliderMarks._steps() : marks = null;

  /// A tick at every `step`, which is worth pairing with a step chosen for
  /// it: the default step of 1 over the default range is a hundred and one of
  /// them, and past a hundred steps none are drawn.
  static const NebaSliderMarks steps = NebaSliderMarks._steps();

  /// The marks, or `null` for [steps].
  final List<NebaSliderMark>? marks;
}

/// A value chosen by dragging along a range, for where the relative magnitude
/// matters more than the exact number.
///
/// One thumb holds one value. [NebaSlider.range] takes a list and draws a
/// thumb for each entry, so two values are a range with the groove filled
/// between them. A press on the strip moves the nearest thumb to it, a drag
/// moves it on, and a thumb pressed and dragged past another pushes it along.
/// The arrow keys move a focused thumb by [step], by [largeStep] with Shift
/// held or with Page Up and Page Down, and Home and End take it to the end of
/// the room it has.
///
/// The thumb is the one thing that moves, along its groove, and nothing
/// grows: it wears a halo under the pointer and while the slider is dragged,
/// and a focus ring when the keyboard reaches it.
///
/// A horizontal slider takes the width it is given and a vertical one the
/// height, 160 pixels where there is no limit.
///
/// ```dart
/// NebaSlider(
///   label: const Text('Volume'),
///   value: volume,
///   onValueChange: (double next) => setState(() => volume = next),
///   showValue: true,
/// )
/// ```
class NebaSlider extends StatefulWidget {
  /// A slider with one thumb, controlled by [value] or starting from
  /// [defaultValue].
  const NebaSlider({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.onValueCommitted,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.largeStep = 10,
    this.orientation = NebaOrientation.horizontal,
    this.label,
    this.description,
    this.showValue = false,
    this.format,
    this.marks,
    this.size,
    this.color,
    this.disabled = false,
    this.semanticLabel,
    this.thumbSemanticLabel,
    this.thumbSemanticValue,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : values = null,
       defaultValues = null,
       onValuesChange = null,
       onValuesCommitted = null,
       _range = false,
       assert(step > 0),
       assert(largeStep > 0);

  /// A slider with a thumb for each entry of [values], or of [defaultValues],
  /// which is `[min, max]` when neither is given.
  const NebaSlider.range({
    this.values,
    this.defaultValues,
    this.onValuesChange,
    this.onValuesCommitted,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.largeStep = 10,
    this.orientation = NebaOrientation.horizontal,
    this.label,
    this.description,
    this.showValue = false,
    this.format,
    this.marks,
    this.size,
    this.color,
    this.disabled = false,
    this.semanticLabel,
    this.thumbSemanticLabel,
    this.thumbSemanticValue,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : value = null,
       defaultValue = null,
       onValueChange = null,
       onValueCommitted = null,
       _range = true,
       assert(step > 0),
       assert(largeStep > 0);

  /// The value, for a controlled slider with [onValueChange]. Leave it out
  /// and the slider keeps its own, starting from [defaultValue]. A value past
  /// either end of the range is held to it.
  final double? value;

  /// Where an uncontrolled slider starts: [min] when left out.
  final double? defaultValue;

  /// Called with the new value throughout a drag, and for every key.
  final ValueChanged<double>? onValueChange;

  /// Called once, when the value settles: on the release of a drag that moved
  /// it, and with [onValueChange] for a key. Put the network request here.
  final ValueChanged<double>? onValueCommitted;

  /// The values of a [NebaSlider.range], lowest first, for a controlled
  /// slider with [onValuesChange]. They are sorted and held to the range.
  final List<double>? values;

  /// Where an uncontrolled [NebaSlider.range] starts.
  final List<double>? defaultValues;

  /// [onValueChange] for a [NebaSlider.range].
  final ValueChanged<List<double>>? onValuesChange;

  /// [onValueCommitted] for a [NebaSlider.range].
  final ValueChanged<List<double>>? onValuesCommitted;

  /// The lowest value.
  final double min;

  /// The highest value.
  final double max;

  /// The interval a thumb settles on, counted from [min], and what an arrow
  /// key moves it by.
  final double step;

  /// What Shift with an arrow key, Page Up and Page Down move a thumb by.
  final double largeStep;

  /// Which way the slider runs. A vertical one runs from [min] at the bottom.
  final NebaOrientation orientation;

  /// The label above the track, usually a [Text]. A press on it puts the focus
  /// on the thumb of a single slider, and a screen reader hears it as each
  /// thumb's name.
  final Widget? label;

  /// Helper text under the track, which a screen reader hears after each
  /// thumb's name.
  final Widget? description;

  /// Whether the value is written at the end of the label's row, every value
  /// of a range joined by a dash.
  final bool showValue;

  /// Writes a value as text, for the row [showValue] draws and for what a
  /// screen reader hears: a unit, a currency, or the app's own formatter and
  /// language. Without it the number is grouped by threes, with at most three
  /// digits after the point.
  final String Function(double value)? format;

  /// Points named along the track: [NebaSliderMarks.steps] for a tick at
  /// every step, or a list of [NebaSliderMark]s. They are read by the eye and
  /// not by a screen reader, which already hears the value from the thumb.
  final NebaSliderMarks? marks;

  /// The groove's thickness, the thumb's diameter and the type scale.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the groove fills with. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// Drops the colour family for the disabled tokens and takes the thumbs out
  /// of the focus order.
  final bool disabled;

  /// What a screen reader calls each thumb in place of [label].
  final String? semanticLabel;

  /// Names each thumb by its index, in place of [label] and [semanticLabel]:
  /// the two thumbs of a range are otherwise heard under the same name. The
  /// [label] is then read as text of its own.
  final String Function(int index)? thumbSemanticLabel;

  /// What a thumb's value is read out as, handed the value as [format] writes
  /// it, the number and the thumb's index: "20 dollars" rather than "20".
  /// Without it a thumb is heard as its written value, and each of a range's
  /// two thumbs adds which end of the range it is.
  final String Function(String formatted, double value, int index)? thumbSemanticValue;

  /// The first thumb's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the first thumb takes the focus when it is first built.
  final bool autofocus;

  final bool _range;

  @override
  State<NebaSlider> createState() => _NebaSliderState();
}

class _NebaSliderState extends State<NebaSlider> {
  final GlobalKey _strip = GlobalKey(debugLabel: 'NebaSlider strip');
  final List<FocusNode> _nodes = <FocusNode>[];

  late List<double> _own = _initial();

  /// The thumb a press holds, while one does.
  int? _held;

  /// How far along the strip the press landed from the held thumb's centre,
  /// so a thumb picked up off its middle does not jump under the pointer.
  double _grab = 0;
  Offset _origin = Offset.zero;

  /// The values the press has set, which its release commits.
  List<double>? _moved;

  /// The thumb last pressed, stepped or focused, drawn over the others.
  int _front = 0;

  List<double> _initial() {
    if (widget._range) {
      return widget.defaultValues ?? <double>[widget.min, widget.max];
    }

    return <double>[widget.defaultValue ?? widget.min];
  }

  bool get _controlled => widget._range ? widget.values != null : widget.value != null;

  /// The values drawn: the caller's or the slider's own, held to the range
  /// and lowest first.
  List<double> get _current {
    final double? single = widget.value;
    final List<double> raw = widget._range
        ? widget.values ?? _own
        : single != null
        ? <double>[single]
        : _own;

    return <double>[for (final double value in raw) _clamp(value)]..sort();
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }

    super.dispose();
  }

  FocusNode _node(int index) {
    final FocusNode? given = widget.focusNode;

    if (index == 0 && given != null) {
      return given;
    }

    while (_nodes.length <= index) {
      _nodes.add(FocusNode(debugLabel: 'NebaSlider thumb ${_nodes.length}'));
    }

    return _nodes[index];
  }

  double _clamp(double value) => math.min(math.max(value, widget.min), widget.max);

  double _fraction(double value) {
    final double span = widget.max - widget.min;

    return span > 0 ? (value - widget.min) / span : 0;
  }

  String _write(double value) => widget.format?.call(value) ?? nebaFormatNumber(value);

  /// What a screen reader hears of thumb [index] at [value].
  String _spoken(int index, double value, int count) {
    final String written = _write(value);
    final String Function(String formatted, double value, int index)? spoken =
        widget.thumbSemanticValue;

    if (spoken != null) {
      return spoken(written, value, index);
    }

    // Base UI's own words for the two ends of a range, which the React
    // package reads in English too.
    if (count == 2) {
      return '$written ${index == 0 ? 'start' : 'end'} range';
    }

    return written;
  }

  /// [value] on the nearest step counted from `min`, with the noise of a
  /// decimal step taken off.
  double _onStep(double value) {
    final double min = widget.min;
    final double step = widget.step;
    final double nearest = ((value - min) / step).round() * step + min;

    return _fixed(nearest, math.max(_decimals(step), _decimals(min)));
  }

  /// [value] moved [direction] times [amount] from its nearest step, as a key
  /// moves a thumb.
  double _stepped(double value, double amount, int direction) {
    final double from = _onStep(value);
    final int digits = math.max(
      math.max(_decimals(from), _decimals(amount)),
      _decimals(widget.min),
    );

    return _clamp(_fixed(from + amount * direction, digits));
  }

  bool _change(List<double> next) {
    if (listEquals(next, _current)) {
      return false;
    }

    if (widget._range) {
      widget.onValuesChange?.call(List<double>.unmodifiable(next));
    } else {
      widget.onValueChange?.call(next.first);
    }

    if (!_controlled) {
      setState(() => _own = next);
    }

    return true;
  }

  void _commit(List<double> values) {
    if (widget._range) {
      widget.onValuesCommitted?.call(List<double>.unmodifiable(values));
    } else {
      widget.onValueCommitted?.call(values.first);
    }
  }

  /// Thumb [index] set to [value], held between its neighbours, as a key or
  /// a screen reader sets it.
  bool _setThumb(int index, double value) {
    final List<double> values = _current;
    final double low = index > 0 ? values[index - 1] : double.negativeInfinity;
    final double high = index < values.length - 1 ? values[index + 1] : double.infinity;
    final List<double> next = <double>[...values];

    next[index] = math.min(math.max(_clamp(value), low), high);

    if (_change(next)) {
      _commit(next);
      return true;
    }

    return false;
  }

  void _bringForward(int index) {
    if (_front != index) {
      setState(() => _front = index);
    }
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;

    if (keyboard.isControlPressed || keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final List<double> values = _current;

    if (index >= values.length) {
      return KeyEventResult.ignored;
    }

    // The arrow along the line moves towards the end it points at, so it
    // turns round under a right-to-left direction; up is always more.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double thumb = values[index];
    double amount = keyboard.isShiftPressed ? widget.largeStep : widget.step;
    int direction = 0;
    double? next;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        direction = 1;
      case LogicalKeyboardKey.arrowDown:
        direction = -1;
      case LogicalKeyboardKey.arrowRight:
        direction = rtl ? -1 : 1;
      case LogicalKeyboardKey.arrowLeft:
        direction = rtl ? 1 : -1;
      case LogicalKeyboardKey.pageUp:
        amount = widget.largeStep;
        direction = 1;
      case LogicalKeyboardKey.pageDown:
        amount = widget.largeStep;
        direction = -1;
      case LogicalKeyboardKey.home:
        next = index > 0 ? values[index - 1] : widget.min;
      case LogicalKeyboardKey.end:
        next = index < values.length - 1 ? values[index + 1] : widget.max;
      default:
        return KeyEventResult.ignored;
    }

    _setThumb(index, next ?? _stepped(thumb, amount, direction));
    _bringForward(index);

    return KeyEventResult.handled;
  }

  /// How far along the strip [position] is from the start of travel: the
  /// inline start of a horizontal slider, the bottom of a vertical one.
  double _along(Offset position, Size size) {
    if (widget.orientation == NebaOrientation.vertical) {
      return size.height - position.dy;
    }

    return Directionality.of(context) == TextDirection.rtl ? size.width - position.dx : position.dx;
  }

  Size? get _stripSize {
    final RenderObject? box = _strip.currentContext?.findRenderObject();

    return box is RenderBox && box.hasSize ? box.size : null;
  }

  bool _handleStart(Offset position) {
    final Size? size = _stripSize;
    final bool vertical = widget.orientation == NebaOrientation.vertical;

    if (widget.disabled || size == null) {
      return false;
    }

    final double extent = vertical ? size.height : size.width;

    if (extent <= 0) {
      return false;
    }

    final List<double> values = _current;
    final NebaSize scale = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final double radius = _thumbDiameter[scale]! / 2;
    final double along = _along(position, size);
    final double across = vertical ? position.dx - size.width / 2 : position.dy - size.height / 2;
    final int front = math.min(_front, values.length - 1);
    int? pressed;

    // A thumb under the press, the one drawn on top first.
    for (final int index in <int>[front, for (int i = values.length - 1; i >= 0; i--) i]) {
      final double centre = _fraction(values[index]) * extent;

      if (Offset(along - centre, across).distance <= radius) {
        pressed = index;
        break;
      }
    }

    _origin = position;
    _moved = null;

    if (pressed != null) {
      int held = pressed;

      // Thumbs stacked at the top of the range can only move down, and the
      // lowest of them is the one that may.
      if (values[held] == widget.max) {
        while (held > 0 && values[held - 1] == widget.max) {
          held -= 1;
        }
      }

      _grab = along - _fraction(values[pressed]) * extent;
      _held = held;
    } else {
      // A press on the strip takes the nearest thumb there, the later one of
      // two equally near.
      int nearest = 0;
      double best = double.infinity;

      for (int i = 0; i < values.length; i++) {
        final double distance = (along - _fraction(values[i]) * extent).abs();

        if (distance <= best) {
          best = distance;
          nearest = i;
        }
      }

      _grab = 0;
      _held = nearest;
      _moveTo(along, extent);
    }

    setState(() => _front = _held!);

    return true;
  }

  void _handleMove(Offset travelled) {
    final Size? size = _stripSize;

    if (size == null) {
      return;
    }

    final bool vertical = widget.orientation == NebaOrientation.vertical;

    _moveTo(_along(_origin + travelled, size), vertical ? size.height : size.width);
  }

  void _handleEnd() {
    final List<double>? moved = _moved;

    setState(() {
      _held = null;
      _moved = null;
    });

    if (moved != null && !widget.disabled) {
      _commit(moved);
    }
  }

  /// The held thumb taken to the point [along] the strip, on a step, pushing
  /// any thumb it meets along with it.
  void _moveTo(double along, double extent) {
    final List<double> values = _current;
    final int? held = _held;

    // A slider turned off mid-drag stops following the pointer, as Base UI
    // stops listening.
    if (held == null || held >= values.length || extent <= 0 || widget.disabled) {
      return;
    }

    final double share = ((along - _grab) / extent).clamp(0.0, 1.0);
    final double value = _clamp(_onStep((widget.max - widget.min) * share + widget.min));
    final List<double> next = <double>[...values];

    next[held] = value;

    for (int i = held + 1; i < next.length; i++) {
      next[i] = _fixed(math.max(next[i], next[i - 1]), 12);
    }

    for (int i = held - 1; i >= 0; i--) {
      next[i] = _fixed(math.min(next[i], next[i + 1]), 12);
    }

    if (_change(next)) {
      _moved = next;
    }
  }

  List<NebaSliderMark> _markList() {
    final NebaSliderMarks? marks = widget.marks;

    if (marks == null) {
      return const <NebaSliderMark>[];
    }

    final List<NebaSliderMark>? given = marks.marks;

    if (given != null) {
      return given;
    }

    final double span = widget.max - widget.min;
    final double step = widget.step;

    if (!(step > 0) || !(span > 0) || span / step > _maxStepMarks) {
      return const <NebaSliderMark>[];
    }

    // Floored rather than counted up, so a range that is not a whole number
    // of steps still lands its last tick on a real value; the epsilon keeps
    // 0.6 / 0.1, which is 5.999999999999999, from losing the top one. Each is
    // `min + index * step` rather than a running sum, which drifts.
    final int count = (span / step + 1e-9).floor();

    return <NebaSliderMark>[
      for (int i = 0; i <= count; i++) NebaSliderMark(value: widget.min + i * step),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final bool vertical = widget.orientation == NebaOrientation.vertical;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool disabled = widget.disabled;
    final List<double> values = _current;
    final int count = values.length;
    final String Function(int index)? named = widget.thumbSemanticLabel;
    // Named per thumb, the label is left to be read as text of its own.
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: named == null ? widget.label : null,
      description: widget.description,
    );
    final double diameter = _thumbDiameter[size]!;
    final Color fill = disabled ? tokens.disabledFg : roles.fill;

    final Widget groove = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: fill),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? filling, Widget? _) {
        return NebaGroove(
          thickness: _trackThickness[size]!,
          track: disabled ? tokens.disabledBg : roles.soft,
          fill: filling ?? fill,
          rest: roles.soft,
          fraction: count == 0 ? 0 : _fraction(values.last),
          start: count > 1 ? _fraction(values.first) : 0,
          vertical: vertical,
        );
      },
    );

    Widget thumb(int index, bool dragging) {
      final double value = values[index];
      final double low = index > 0 ? values[index - 1] : widget.min;
      final double high = index < count - 1 ? values[index + 1] : widget.max;
      final bool canIncrease = !disabled && value < high;
      final bool canDecrease = !disabled && value > low;

      return _AlongSlot(
        key: ValueKey<int>(index),
        fraction: _fraction(value),
        child: FocusTraversalOrder(
          order: NumericFocusOrder(index.toDouble()),
          child: _SliderThumb(
            index: index,
            diameter: diameter,
            roles: roles,
            disabled: disabled,
            dragging: dragging,
            held: dragging && _held == index,
            focusNode: _node(index),
            autofocus: index == 0 && widget.autofocus,
            label: named?.call(index) ?? semantics.label,
            hint: semantics.hint,
            value: _spoken(index, value, count),
            increasedValue: canIncrease
                ? _spoken(index, math.min(_stepped(value, widget.step, 1), high), count)
                : null,
            decreasedValue: canDecrease
                ? _spoken(index, math.max(_stepped(value, widget.step, -1), low), count)
                : null,
            onIncrease: canIncrease
                ? () => _setThumb(index, _stepped(value, widget.step, 1))
                : null,
            onDecrease: canDecrease
                ? () => _setThumb(index, _stepped(value, widget.step, -1))
                : null,
            onKey: (KeyEvent event) => _handleKey(index, event),
            onFocus: () => _bringForward(index),
          ),
        ),
      );
    }

    final Widget strip = FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: NebaDragRegion(
        enabled: !disabled,
        cursor: _held == null ? MouseCursor.defer : SystemMouseCursors.grabbing,
        // A press leaves the focus where it was, as every drag in the package
        // does: a field being typed in beside the slider keeps it.
        onStart: _handleStart,
        onMove: _handleMove,
        onEnd: _handleEnd,
        builder: (BuildContext context, bool dragging) {
          return _Along(
            key: _strip,
            vertical: vertical,
            rtl: rtl,
            cross: _stripExtent[size],
            // The groove is the first child, so the thumb in front is one on.
            front: count == 0 ? null : math.min(_front, count - 1) + 1,
            children: <Widget>[
              _AlongSlot(fraction: null, child: groove),
              for (int i = 0; i < count; i++) thumb(i, dragging),
            ],
          );
        },
      ),
    );

    final List<NebaSliderMark> marks = _markList();
    final Widget? markRow = marks.isEmpty
        ? null
        : _MarkRow(
            marks: marks,
            size: size,
            vertical: vertical,
            rtl: rtl,
            fraction: _fraction,
            min: widget.min,
            max: widget.max,
          );

    final Widget field;

    if (vertical) {
      // Loose, so a slider given a height takes it and one given none is the
      // 160 pixels the limit says.
      field = Flexible(
        child: LimitedBox(
          maxHeight: _length,
          child: SizedBox(
            height: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[strip, ?markRow],
              ),
            ),
          ),
        ),
      );
    } else {
      field = markRow == null
          ? strip
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: <Widget>[strip, markRow],
            );
    }

    final Widget? label = widget.label;
    final Widget? header = label == null && !widget.showValue
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: <Widget>[
              if (label != null) Expanded(child: label) else const Spacer(),
              if (widget.showValue)
                // Silent: every thumb already says its value.
                ExcludeSemantics(
                  child: Text(
                    <String>[for (final double value in values) _write(value)].join(' – '),
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: tokens.mutedFg,
                      fontWeight: FontWeight.w400,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          );

    Widget slider = NebaFieldColumn(
      size: size,
      semantics: semantics,
      errorColor: roles.accent,
      disabled: disabled,
      label: header,
      description: widget.description,
      // A label focuses the thumb when there is only one to focus.
      onLabelTap: count == 1 ? () => _node(0).requestFocus() : null,
      spacing: vertical ? 8 : 6,
      field: field,
    );

    slider = vertical
        ? IntrinsicWidth(child: slider)
        : LimitedBox(
            maxWidth: _length,
            child: SizedBox(width: double.infinity, child: slider),
          );

    if (disabled) {
      slider = MouseRegion(cursor: SystemMouseCursors.forbidden, child: slider);
    }

    return slider;
  }
}

/// A thumb: a disc of the page's surface on the groove, heard as a slider of
/// its own.
class _SliderThumb extends StatefulWidget {
  const _SliderThumb({
    required this.index,
    required this.diameter,
    required this.roles,
    required this.disabled,
    required this.dragging,
    required this.held,
    required this.focusNode,
    required this.autofocus,
    required this.label,
    required this.hint,
    required this.value,
    required this.increasedValue,
    required this.decreasedValue,
    required this.onIncrease,
    required this.onDecrease,
    required this.onKey,
    required this.onFocus,
  });

  final int index;
  final double diameter;
  final NebaColorRoles roles;
  final bool disabled;

  /// Whether the slider is being dragged, which rings every thumb on it.
  final bool dragging;

  /// Whether this is the thumb the drag holds.
  final bool held;
  final FocusNode focusNode;
  final bool autofocus;
  final String? label;
  final String? hint;
  final String value;
  final String? increasedValue;
  final String? decreasedValue;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final KeyEventResult Function(KeyEvent event) onKey;
  final VoidCallback onFocus;

  @override
  State<_SliderThumb> createState() => _SliderThumbState();
}

class _SliderThumbState extends State<_SliderThumb> {
  bool _hovered = false;
  bool _focused = false;

  @override
  void didUpdateWidget(_SliderThumb oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.disabled) {
      _hovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = widget.roles;
    final bool disabled = widget.disabled;
    final bool dragging = widget.dragging && !disabled;
    final bool hovered = _hovered && !disabled;
    final double diameter = widget.diameter;
    final BorderRadius round = BorderRadius.circular(diameter / 2);
    // The halo is a ring of the family's wash around the disc, as CSS draws
    // `0 0 0 4px`: the thumb itself never grows. A drag is a press, so its
    // halo lands at once and drains back over the house duration.
    final Color halo = dragging
        ? roles.softHover
        : hovered
        ? roles.soft
        : roles.soft.withValues(alpha: 0);
    // The stylesheet swaps the whole shadow list on hover and on a drag, and
    // the top light is in the list at rest only.
    final NebaPlate plate = disabled || dragging || hovered ? NebaPlate.none : NebaPlate.glass;
    final int elevation = disabled
        ? 0
        : hovered && !dragging
        ? 2
        : 1;

    return Semantics(
      container: true,
      slider: true,
      enabled: !disabled,
      sortKey: OrdinalSortKey(widget.index.toDouble()),
      label: widget.label,
      hint: widget.hint,
      value: widget.value,
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      onIncrease: widget.onIncrease,
      onDecrease: widget.onDecrease,
      child: Focus(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: !disabled,
        skipTraversal: disabled,
        onKeyEvent: (FocusNode node, KeyEvent event) => widget.onKey(event),
        onFocusChange: (bool focused) {
          setState(() => _focused = focused);

          if (focused) {
            widget.onFocus();
          }
        },
        child: MouseRegion(
          cursor: disabled
              ? SystemMouseCursors.forbidden
              : widget.held
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.grab,
          onEnter: disabled ? null : (PointerEnterEvent event) => setState(() => _hovered = true),
          onExit: disabled ? null : (PointerExitEvent event) => setState(() => _hovered = false),
          child: NebaFocusRing(
            visible: _focused && !disabled,
            color: roles.ring,
            borderRadius: round,
            child: AnimatedContainer(
              duration: nebaDuration(context, NebaScale.duration, instant: dragging),
              curve: NebaScale.ease,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: halo, spreadRadius: dragging ? _dragHalo : _hoverHalo),
                ],
              ),
              // A size of its own rather than the container's, which would
              // ease a new one in: the thumb never grows.
              child: SizedBox.square(
                dimension: diameter,
                // The surface is opaque, so there is nothing behind it for a
                // blur to show.
                child: NebaSheet(
                  fill: tokens.surface,
                  edge: disabled ? tokens.disabledBorder : roles.lineHover,
                  plate: plate,
                  elevation: elevation,
                  borderRadius: round,
                  pressed: dragging,
                  blur: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The row of marks beside the track: ticks and their labels, each at its
/// share of the range, and kept from a screen reader.
class _MarkRow extends StatelessWidget {
  const _MarkRow({
    required this.marks,
    required this.size,
    required this.vertical,
    required this.rtl,
    required this.fraction,
    required this.min,
    required this.max,
  });

  final List<NebaSliderMark> marks;
  final NebaSize size;
  final bool vertical;
  final bool rtl;
  final double Function(double value) fraction;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Widget tick = SizedBox(
      width: vertical ? _tick : 1,
      height: vertical ? 1 : _tick,
      child: ColoredBox(color: tokens.border),
    );

    Widget mark(NebaSliderMark mark) {
      final Widget? label = mark.label;
      // Centred, a label at either end would hang half its width past the
      // track, so a mark at an end lines its label up inward from the tick.
      final _Anchor anchor = mark.value <= min
          ? _Anchor.leading
          : mark.value >= max
          ? _Anchor.trailing
          : _Anchor.centre;
      final Widget drawn;

      if (vertical) {
        drawn = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _tick,
          // A vertical track runs from the bottom, so the two ends swap.
          crossAxisAlignment: switch (anchor) {
            _Anchor.leading => CrossAxisAlignment.end,
            _Anchor.trailing => CrossAxisAlignment.start,
            _Anchor.centre => CrossAxisAlignment.center,
          },
          children: <Widget>[tick, ?label],
        );
      } else {
        drawn = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: switch (anchor) {
            _Anchor.leading => CrossAxisAlignment.start,
            _Anchor.trailing => CrossAxisAlignment.end,
            _Anchor.centre => CrossAxisAlignment.center,
          },
          children: <Widget>[tick, ?label],
        );
      }

      return _AlongSlot(fraction: fraction(mark.value), anchor: anchor, child: drawn);
    }

    return ExcludeSemantics(
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
        softWrap: false,
        maxLines: 1,
        child: _Along(
          vertical: vertical,
          rtl: rtl,
          centred: false,
          // The tick and the gap beside it, as CSS reserves `ps-3` for them
          // whether or not any mark has a label.
          minCross: vertical ? 2 * _tick : 0,
          children: <Widget>[for (final NebaSliderMark entry in marks) mark(entry)],
        ),
      ),
    );
  }
}

/// Which edge of a child sits on its point along an [_Along].
enum _Anchor {
  /// The edge towards the start of travel: the child reaches on towards the
  /// end.
  leading,

  /// Its middle.
  centre,

  /// The edge towards the end of travel: the child reaches back towards the
  /// start.
  trailing,
}

class _AlongData extends ContainerBoxParentData<RenderBox> {
  double? fraction;
  _Anchor anchor = _Anchor.centre;
}

/// A child of an [_Along], at [fraction] of the way along it, or across the
/// whole of it when [fraction] is `null`.
class _AlongSlot extends ParentDataWidget<_AlongData> {
  const _AlongSlot({
    required this.fraction,
    required super.child,
    this.anchor = _Anchor.centre,
    super.key,
  });

  final double? fraction;
  final _Anchor anchor;

  @override
  void applyParentData(RenderObject renderObject) {
    final _AlongData data = renderObject.parentData! as _AlongData;

    if (data.fraction != fraction || data.anchor != anchor) {
      data
        ..fraction = fraction
        ..anchor = anchor;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _Along;
}

/// Children placed at a share of a line's length, measured from the start of
/// travel: the inline start of a horizontal line, the bottom of a vertical
/// one. The thumbs on a strip and the marks under it are laid out by it, so a
/// mark and the thumb that stops on it are measured from the same edge, and a
/// right-to-left direction flips the line without any arithmetic changing.
///
/// It takes the length it is given, 160 pixels where there is no limit, and
/// is [cross] thick, or as thick as its thickest child.
class _Along extends MultiChildRenderObjectWidget {
  const _Along({
    required this.vertical,
    required this.rtl,
    required super.children,
    this.cross,
    this.minCross = 0,
    this.centred = true,
    this.front,
    super.key,
  });

  final bool vertical;
  final bool rtl;

  /// The thickness, or `null` for the thickest child's.
  final double? cross;

  /// The least thickness.
  final double minCross;

  /// Whether a placed child is centred across the line, or set at its start:
  /// the top of a horizontal line, the inline start of a vertical one.
  final bool centred;

  /// The child drawn over the others and hit first.
  final int? front;

  @override
  _RenderAlong createRenderObject(BuildContext context) {
    return _RenderAlong(
      vertical: vertical,
      rtl: rtl,
      cross: cross,
      minCross: minCross,
      centred: centred,
      front: front,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderAlong renderObject) {
    renderObject
      ..vertical = vertical
      ..rtl = rtl
      ..cross = cross
      ..minCross = minCross
      ..centred = centred
      ..front = front;
  }
}

class _RenderAlong extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _AlongData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _AlongData> {
  _RenderAlong({
    required bool vertical,
    required bool rtl,
    required double? cross,
    required double minCross,
    required bool centred,
    required int? front,
  }) : _vertical = vertical,
       _rtl = rtl,
       _cross = cross,
       _minCross = minCross,
       _centred = centred,
       _front = front;

  bool _vertical;
  set vertical(bool value) {
    if (_vertical != value) {
      _vertical = value;
      markNeedsLayout();
    }
  }

  bool _rtl;
  set rtl(bool value) {
    if (_rtl != value) {
      _rtl = value;
      markNeedsLayout();
    }
  }

  double? _cross;
  set cross(double? value) {
    if (_cross != value) {
      _cross = value;
      markNeedsLayout();
    }
  }

  double _minCross;
  set minCross(double value) {
    if (_minCross != value) {
      _minCross = value;
      markNeedsLayout();
    }
  }

  bool _centred;
  set centred(bool value) {
    if (_centred != value) {
      _centred = value;
      markNeedsLayout();
    }
  }

  int? _front;
  set front(int? value) {
    if (_front != value) {
      _front = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AlongData) {
      child.parentData = _AlongData();
    }
  }

  double _mainOf(Size size) => _vertical ? size.height : size.width;

  double _crossOf(Size size) => _vertical ? size.width : size.height;

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final double main = _vertical
        ? (constraints.hasBoundedHeight
              ? constraints.maxHeight
              : constraints.constrainHeight(_length))
        : (constraints.hasBoundedWidth
              ? constraints.maxWidth
              : constraints.constrainWidth(_length));
    final double? cross = _cross;
    final BoxConstraints loose = _vertical
        ? BoxConstraints(maxWidth: cross ?? constraints.maxWidth)
        : BoxConstraints(maxHeight: cross ?? constraints.maxHeight);
    double thickness = math.max(cross ?? 0, _minCross);

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final _AlongData data = child.parentData! as _AlongData;
      final BoxConstraints given = data.fraction == null
          ? (_vertical ? loose.tighten(height: main) : loose.tighten(width: main))
          : loose;
      final Size measured;

      if (dry) {
        measured = child.getDryLayout(given);
      } else {
        child.layout(given, parentUsesSize: true);
        measured = child.size;
      }

      if (cross == null) {
        thickness = math.max(thickness, _crossOf(measured));
      }
    }

    final Size size = constraints.constrain(
      _vertical ? Size(thickness, main) : Size(main, thickness),
    );

    if (dry) {
      return size;
    }

    final double length = _mainOf(size);
    final double across = _crossOf(size);

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final _AlongData data = child.parentData! as _AlongData;
      final double fraction = data.fraction ?? 0;
      final double extent = _mainOf(child.size);
      final double along = fraction * length;
      // From the start of travel to the child's own nearer edge.
      final double lead = data.fraction == null
          ? 0
          : switch (data.anchor) {
              _Anchor.leading => along,
              _Anchor.centre => along - extent / 2,
              _Anchor.trailing => along - extent,
            };
      final double thick = _crossOf(child.size);
      final double side = data.fraction == null || _centred
          ? (across - thick) / 2
          : _vertical && _rtl
          ? across - thick
          : 0;

      data.offset = _vertical
          ? Offset(side, length - lead - extent)
          : Offset(_rtl ? length - lead - extent : lead, side);
    }

    return size;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return _layout(constraints, dry: true);
  }

  @override
  void performLayout() {
    size = _layout(constraints, dry: false);
  }

  double _thickness({required bool most}) {
    final double? cross = _cross;

    if (cross != null) {
      return math.max(cross, _minCross);
    }

    double thickness = _minCross;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      final double measured = _vertical
          ? (most
                ? child.getMaxIntrinsicWidth(double.infinity)
                : child.getMinIntrinsicWidth(double.infinity))
          : (most
                ? child.getMaxIntrinsicHeight(double.infinity)
                : child.getMinIntrinsicHeight(double.infinity));

      thickness = math.max(thickness, measured);
    }

    return thickness;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _vertical ? _thickness(most: false) : 0;

  @override
  double computeMaxIntrinsicWidth(double height) => _vertical ? _thickness(most: true) : _length;

  @override
  double computeMinIntrinsicHeight(double width) => _vertical ? 0 : _thickness(most: false);

  @override
  double computeMaxIntrinsicHeight(double width) => _vertical ? _length : _thickness(most: true);

  RenderBox? _frontChild() {
    final int? front = _front;

    if (front == null) {
      return null;
    }

    int index = 0;

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      if (index == front) {
        return child;
      }

      index += 1;
    }

    return null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? front = _frontChild();

    for (RenderBox? child = firstChild; child != null; child = childAfter(child)) {
      if (child != front) {
        context.paintChild(child, (child.parentData! as _AlongData).offset + offset);
      }
    }

    if (front != null) {
      context.paintChild(front, (front.parentData! as _AlongData).offset + offset);
    }
  }

  bool _hit(BoxHitTestResult result, RenderBox child, Offset position) {
    final _AlongData data = child.parentData! as _AlongData;

    return result.addWithPaintOffset(
      offset: data.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child.hitTest(result, position: transformed);
      },
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? front = _frontChild();

    if (front != null && _hit(result, front, position)) {
      return true;
    }

    for (RenderBox? child = lastChild; child != null; child = childBefore(child)) {
      if (child != front && _hit(result, child, position)) {
        return true;
      }
    }

    return false;
  }
}

/// How many digits after the point [value] is written with, as Base UI
/// counts them to take the noise off a decimal step.
int _decimals(double value) {
  if (!value.isFinite || value == value.truncateToDouble()) {
    return 0;
  }

  if (value.abs() < 1) {
    final List<String> parts = value.toStringAsExponential().split('e-');
    final List<String> mantissa = parts.first.split('.');

    return (mantissa.length > 1 ? mantissa[1].length : 0) + int.parse(parts.last);
  }

  final String written = value.toString();
  final int point = written.indexOf('.');

  return point < 0 || written.contains('e') ? 0 : written.length - point - 1;
}

/// [value] rounded to [digits] after the point.
double _fixed(double value, int digits) {
  if (!value.isFinite) {
    return value;
  }

  return double.parse(value.toStringAsFixed(math.min(digits, 20)));
}
