/// `NebaNumberField`, a field that only holds a number.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/hit.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/wheel.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Where a [NebaNumberField]'s two steppers sit.
///
/// There is no stacked pair of half-height chevrons: at `xs` each arrow
/// would be under three pixels tall.
enum NebaNumberFieldSteppers {
  /// Both at the trailing edge. The default.
  end,

  /// Minus at the start, plus at the end, with the number between them, for
  /// a quantity that is nudged rather than typed.
  split,

  /// No buttons. The arrow keys, the range and the writing all stay.
  none,
}

/// The largest whole number a double holds exactly, which bounds a field
/// with no `min` or `max`, as JavaScript's `Number.MAX_SAFE_INTEGER` does.
const double _safeInteger = 9007199254740991;

/// How long a stepper is held before it starts to repeat.
const Duration _holdDelay = Duration(milliseconds: 400);

/// How often a held stepper steps.
const Duration _holdInterval = Duration(milliseconds: 60);

/// A stepper's side, in ems of the field's text.
const double _stepperEms = 1.7;

/// Between the two steppers at the end.
const double _stepperGap = 2;

/// The shell's padding on a side a stepper sits on.
const double _stepperInset = 4;

/// A field that only holds a number.
///
/// Its shell is a `NebaTextField`'s, to the pixel, so a quantity box lines up
/// with the boxes around it. On top of it is a real numeric control: Up and
/// Down and the steppers move by [step], [largeStep] with Shift held and
/// [smallStep] with Alt; Home and End go to [min] and [max] when the field has
/// them; the wheel steps a field that holds the focus while the pointer is on
/// the number; and the value is held to [min] and [max] throughout.
///
/// [format] writes the number, as currency or a percentage, while the value
/// stays a plain number; [parse] reads what was typed back, and a [format]
/// that writes a decimal comma or scales the number needs one. What is typed
/// is reported as it parses, and settles on blur, where the text is written
/// out again the way [format] writes it.
///
/// A screen reader hears one field, with its label, its text, and increase
/// and decrease actions that do what the steppers do.
///
/// ```dart
/// NebaNumberField(label: const Text('Seats'), defaultValue: 3, min: 1, max: 20)
/// ```
class NebaNumberField extends StatefulWidget {
  /// A number field.
  const NebaNumberField({
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.onValueCommitted,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep = 10,
    this.smallStep = 0.1,
    this.snapOnStep = false,
    this.wheel = true,
    this.format,
    this.parse,
    this.steppers = NebaNumberFieldSteppers.end,
    this.label,
    this.labelPlacement,
    this.placeholder,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.endIcon,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.style,
    this.shortcuts,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(step > 0),
       assert(largeStep > 0),
       assert(smallStep > 0),
       assert(min == null || max == null || min <= max, 'The range runs from min up to max.'),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The number, for a controlled field, with [onValueChange]. Leave it
  /// `null` and the field keeps its own, starting from [defaultValue]; a
  /// controlled field whose value turns `null` is cleared.
  final double? value;

  /// The number an uncontrolled field starts with.
  final double? defaultValue;

  /// Called on every change: typing, stepping, the wheel. `null` is an empty
  /// field.
  final ValueChanged<double?>? onValueChange;

  /// Called when the value settles: on blur after typing, on the release of a
  /// stepper, and with [onValueChange] for a key or the wheel.
  final ValueChanged<double?>? onValueCommitted;

  /// The bottom of the range. Stepping stops here, and what is typed is held
  /// to it.
  final double? min;

  /// The top of the range.
  final double? max;

  /// How far one step goes.
  final double step;

  /// The step taken while Shift is held.
  final double largeStep;

  /// The step taken while Alt is held.
  final double smallStep;

  /// Whether stepping lands on multiples of the step, counted from [min].
  final bool snapOnStep;

  /// Whether the wheel steps the value while the field holds the focus and
  /// the pointer is over the number. Both have to be true, so a screen still
  /// scrolls over a field nobody has put the caret in.
  final bool wheel;

  /// How the number is written: given the value, it returns the text, so a
  /// currency, a unit or a percentage is written in the app's own formatter
  /// and language. Without it the number is written plainly, with a point
  /// and at most three decimals.
  final String Function(double value)? format;

  /// How typed text is read back into a number, or `null` for text that is
  /// not one. Without it the digits, one point and a leading sign are read,
  /// and grouping commas, currency signs and units are passed over; a
  /// [format] that writes a decimal comma or a percentage needs its own.
  final double? Function(String text)? parse;

  /// Where the steppers sit, or `none` for a field without them.
  final NebaNumberFieldSteppers steppers;

  /// The field's name, usually a [Text]. A tap on it puts the caret in the
  /// field, and a screen reader hears it as the field's name.
  final Widget? label;

  /// Where [label] is drawn: above the field, in a notch cut into its top
  /// edge, or inside it until the field takes the focus or holds a number. A
  /// [startIcon] or `split` steppers keep a `float` label in the notch, since
  /// they are where it would rest. Defaults to `NebaProvider`'s, then
  /// [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// What the field shows while it is empty.
  final String? placeholder;

  /// Helper text under the field, usually a [Text].
  final Widget? description;

  /// An error under the field, usually a [Text]. Giving one turns the field
  /// invalid.
  final Widget? error;

  /// Whether the field is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Before the number: a currency mark, a unit, an icon.
  final Widget? startIcon;

  /// After the number, before the steppers.
  final Widget? endIcon;

  /// The weight of the sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type scale, a button's; the steppers are sized
  /// against the text. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring, the caret and the steppers'
  /// hover. Defaults to [NebaColor.primary]; an invalid field is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation? elevation;

  /// Grey, out of the focus order and unable to change.
  final bool disabled;

  /// Shows the number but takes none. The steppers go rather than turning
  /// grey, and the number can still be selected and copied.
  final bool readOnly;

  /// Stretches to the width it is given. Otherwise the field is about twenty
  /// characters wide and its steppers, or as wide as it is given when that is
  /// less.
  final bool fullWidth;

  /// The number's style, laid over the field's own.
  final TextStyle? style;

  /// Key combinations to act on while the field holds the focus, with what
  /// each does. A bound key is taken, except the keys that step, which still
  /// step after the binding has run.
  final Map<ShortcutActivator, VoidCallback>? shortcuts;

  /// What a screen reader names the field, in place of [label].
  final String? semanticLabel;

  /// The field's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaNumberField> createState() => _NebaNumberFieldState();
}

class _NebaNumberFieldState extends State<NebaNumberField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ValueNotifier<bool> _typing = ValueNotifier<bool>(false);
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);
  late final _NumberCharacters _characters = _NumberCharacters(_allows);
  late final TextEditingController _controller;
  FocusNode? _ownNode;

  /// An uncontrolled field's number, and the last one a controlled field
  /// reported.
  late double? _value = widget.defaultValue;

  /// Whether the text is what the reader typed, which the value does not
  /// write over until it settles: Base UI's `allowInputSync`, turned round.
  bool _editing = false;

  /// Whether the value has changed since it was last committed.
  bool _pending = false;

  /// What the last change came to, once held to the range.
  double? _last;

  /// The text the field was last built with.
  String _text = '';
  bool _focused = false;

  /// The step a stepper press takes for its whole hold, and whether it is a
  /// small one: read once, on the press, as the pointer event carries them.
  double _pressAmount = 1;
  bool _pressSmall = false;

  double? get _current => widget.value ?? _value;

  FocusNode get _node {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaNumberField'));
  }

  double get _lowest => widget.min ?? -_safeInteger;

  double get _highest => widget.max ?? _safeInteger;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !_disabled;

  @override
  void initState() {
    super.initState();
    _text = _textOf(_current);
    _controller = TextEditingController(text: _text);
    _controller.addListener(_handleText);
    _node.addListener(_handleFocus);
    _focused = _node.hasFocus;
  }

  @override
  void didUpdateWidget(NebaNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownNode)?.removeListener(_handleFocus);
      _node.addListener(_handleFocus);
      _focused = _node.hasFocus;
    }

    // A controlled field handed back empty is cleared rather than left with
    // the number it had.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }

    if (!_editing) {
      _write(_textOf(_current));
    }
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocus);
    _controller.removeListener(_handleText);
    _controller.dispose();
    _ownNode?.dispose();
    _typing.dispose();
    super.dispose();
  }

  String _textOf(double? value) {
    if (value == null) {
      return '';
    }

    return (widget.format ?? _plainText)(value);
  }

  double? _parse(String text) => (widget.parse ?? _plainParse)(text);

  /// Puts [text] in the field with the caret after it, as a browser leaves
  /// an input whose value a script wrote.
  void _write(String text) {
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  /// Rebuilds the field when its text changes, which a screen reader reads
  /// as the field's value and a resting label reads as whether it is empty.
  void _handleText() {
    if (_controller.text == _text) {
      return;
    }

    // A controller can be written to while the field builds.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(() => _text = _controller.text);
        }
      });
    } else {
      setState(() => _text = _controller.text);
    }
  }

  void _handleFocus() {
    final bool focused = _node.hasFocus;

    if (!mounted || focused == _focused) {
      return;
    }

    _focused = focused;

    if (!focused) {
      _settle();
    }
  }

  /// Whether every character of [text] is one a number may be written with:
  /// the digits, a point, a comma, a sign and a space, and whatever else
  /// [NebaNumberField.format] writes.
  bool _allows(String text) {
    final bool signed = _lowest < 0;
    final Set<String> extra = <String>{
      for (final String sample in <String>[
        _textOf(1234.5),
        if (signed) _textOf(-1234.5),
        _textOf(_current),
      ])
        ...sample.split(''),
    };

    for (final String char in text.split('')) {
      final bool numeric = '0123456789.,+   '.contains(char);
      final bool sign = signed && (char == '-' || char == '−');

      if (!numeric && !sign && !extra.contains(char)) {
        return false;
      }
    }

    return true;
  }

  /// [value] held to the range, landed on a step when [step] is the step
  /// that moved it and the field snaps, and cleaned of the noise binary
  /// arithmetic leaves after a step: Base UI's `toValidatedNumber`.
  double? _validate(double? value, {double? step, bool small = false}) {
    if (value == null) {
      return null;
    }

    double next = value;
    final double? min = widget.min;

    if (step != null && widget.snapOnStep && step != 0) {
      final double base = small || min == null ? (min ?? 0) : min;

      next = _snap(next, base, step, nearest: small);
    }

    next = _clamp(next);

    if (step == null) {
      return next;
    }

    return _clamp(_clean(next));
  }

  double _clamp(double value) => math.min(_highest, math.max(_lowest, value));

  /// Sets the value, and reports it if it changed. [input] marks a value
  /// that came from what was typed, which is reported while the reader is
  /// typing even when it comes to the same number.
  bool _setValue(double? next, {double? step, bool small = false, bool input = false}) {
    final double? validated = _validate(next, step: step, small: small);
    final double? current = _current;
    final bool changed = validated != current || (input && (next != current || _editing));

    if (changed) {
      widget.onValueChange?.call(validated);
      setState(() => _value = validated);
      _pending = true;
    }

    _last = validated;

    if (!_editing) {
      _write(_textOf(_current));
    }

    return changed;
  }

  /// Moves the value [direction] steps of [amount], from [from] or the value.
  /// An empty field steps to zero, held to the range.
  bool _increment(int direction, {required double amount, double? from, bool small = false}) {
    final double? previous = from ?? _current;

    if (previous == null) {
      return _setValue(0);
    }

    return _setValue(previous + amount * direction, step: amount * direction, small: small);
  }

  void _commit(double? value) {
    _pending = false;
    widget.onValueCommitted?.call(value);
  }

  /// Takes what was typed as the value before a step builds on it.
  void _takeTyped() {
    if (!_editing) {
      _last = _current;
      return;
    }

    _editing = false;

    final double? parsed = _parse(_controller.text);

    if (parsed != null) {
      _setValue(parsed);
    }
  }

  /// The step a key, the wheel or a press takes with the modifiers held now.
  double get _heldAmount {
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;

    if (keyboard.isAltPressed) {
      return widget.smallStep;
    }

    return keyboard.isShiftPressed ? widget.largeStep : widget.step;
  }

  void _handleChanged(String text) {
    _editing = true;

    if (text.trim().isEmpty) {
      _setValue(null, input: true);
      return;
    }

    final double? parsed = _parse(text);

    if (parsed != null) {
      _setValue(parsed, input: true);
    }
  }

  /// The value settles as the focus leaves: what was typed is read, held to
  /// the range, committed and written out again the way the field writes it.
  void _settle() {
    final bool typed = _editing;
    final bool pending = _pending;

    _editing = false;

    if (widget.readOnly || _disabled) {
      return;
    }

    final String text = _controller.text;
    final double? before = _current;

    if (text.trim().isEmpty) {
      _setValue(null, input: true);

      if (typed || pending || before != null) {
        _commit(null);
      }

      return;
    }

    final double? parsed = _parse(text);

    // Text that is not a number stays as it was typed.
    if (parsed == null) {
      return;
    }

    final double? settled = typed ? parsed : before;
    final bool update = settled != before;
    double? committed = settled;

    if (update) {
      _setValue(settled, input: true);
      committed = _last;
    }

    if (typed || update || pending) {
      _commit(committed);
    }

    _write(_textOf(committed));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _disabled || widget.readOnly) {
      return KeyEventResult.ignored;
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;

    if (keyboard.isControlPressed || keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final bool stepKey = key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowDown;
    final double? boundary = keyboard.isAltPressed
        ? null
        : key == LogicalKeyboardKey.home
        ? widget.min
        : key == LogicalKeyboardKey.end
        ? widget.max
        : null;

    if (!stepKey && boundary == null) {
      return KeyEventResult.ignored;
    }

    // The caller's binding for the key still runs, and the field still
    // steps after it.
    final Map<ShortcutActivator, VoidCallback>? shortcuts = widget.shortcuts;

    if (shortcuts != null) {
      for (final MapEntry<ShortcutActivator, VoidCallback> entry in shortcuts.entries) {
        if (entry.key.accepts(event, keyboard)) {
          entry.value();
        }
      }
    }

    final double? from = _editing ? _parse(_controller.text) : null;
    final bool changed;

    if (!_editing) {
      _last = _current;
    }

    _editing = false;

    if (stepKey) {
      changed = _increment(
        key == LogicalKeyboardKey.arrowUp ? 1 : -1,
        amount: _heldAmount,
        from: from,
        small: keyboard.isAltPressed,
      );
    } else {
      changed = _setValue(boundary);
    }

    if (changed) {
      _commit(_last);
    }

    return KeyEventResult.handled;
  }

  void _handleWheel(PointerSignalEvent event) {
    if (!widget.wheel || _disabled || widget.readOnly || !_node.hasFocus) {
      return;
    }

    nebaFieldWheel(event, (int direction) {
      if (!mounted) {
        return;
      }

      _editing = false;

      if (_increment(
        direction,
        amount: _heldAmount,
        small: HardwareKeyboard.instance.isAltPressed,
      )) {
        _commit(_last);
      }
    });
  }

  /// A stepper is pressed: what was typed is taken first, and a mouse puts
  /// the caret in the field, as a press beside it would.
  void _handleStepperPress(PointerDeviceKind kind) {
    _takeTyped();
    _last = null;
    _pressAmount = _heldAmount;
    _pressSmall = HardwareKeyboard.instance.isAltPressed;

    switch (kind) {
      case PointerDeviceKind.touch:
      case PointerDeviceKind.stylus:
      case PointerDeviceKind.invertedStylus:
        break;
      case PointerDeviceKind.mouse:
      case PointerDeviceKind.trackpad:
      case PointerDeviceKind.unknown:
        if (!_node.hasFocus) {
          _node.requestFocus();
          // Put the caret after the number once the focus has landed, which
          // on a desktop selects everything.
          SchedulerBinding.instance.addPostFrameCallback((Duration _) {
            if (mounted && _node.hasFocus) {
              _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
            }
          });
        }
    }
  }

  bool _stepperTick(int direction) {
    return _increment(direction, amount: _pressAmount, small: _pressSmall);
  }

  void _handleStepperRelease() {
    _commit(_last ?? _current);
  }

  /// A screen reader's increase or decrease, which is a stepper's click.
  void _semanticStep(int direction) {
    _takeTyped();

    final double? before = _current;

    _increment(direction, amount: widget.step);

    if (_last != before) {
      _commit(_last);
    }
  }

  /// What a screen reader is told a step [direction] would write.
  String? _peek(int direction) {
    if (_controller.text.isEmpty) {
      return null;
    }

    final double? from = (_editing ? _parse(_controller.text) : null) ?? _current;
    final double? next = from == null
        ? _validate(0)
        : _validate(from + widget.step * direction, step: widget.step * direction);

    return _textOf(next);
  }

  void _requestFocus() {
    _editableKey.currentState?.requestKeyboard();
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
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool lit = !disabled && !readOnly;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final NebaNumberFieldSteppers steppers = readOnly
        ? NebaNumberFieldSteppers.none
        : widget.steppers;
    final double? current = _current;
    final bool canIncrease = lit && !(current != null && current >= _highest);
    final bool canDecrease = lit && !(current != null && current <= _lowest);
    final Widget? label = widget.label;
    final bool empty = _controller.text.isEmpty;
    final bool notched = label != null && placement != NebaLabelPlacement.top;
    final bool rests =
        notched &&
        placement == NebaLabelPlacement.float &&
        widget.startIcon == null &&
        steppers != NebaNumberFieldSteppers.split;
    final double restEnd = nebaNotchRestEnd(size, <double>[
      if (widget.endIcon != null) 1.2,
      // Two steppers and the eighth of a rem between them.
      if (steppers == NebaNumberFieldSteppers.end) 3.55,
    ]);
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: label,
      description: widget.description,
      error: widget.error,
      placeholder: widget.placeholder,
    );
    final TextStyle style = nebaFieldTextStyle(
      context,
      tokens: tokens,
      size: size,
      disabled: disabled,
      style: widget.style,
    ).copyWith(fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]);
    final double paddingX = NebaScale.paddingX[density]![size]!;
    final double text = NebaScale.controlText[size]!;
    final double stepperSide = _stepperEms * text;
    final double gap = NebaScale.gap[size]!;

    Widget stepper(int direction) {
      final bool enabled = direction > 0 ? canIncrease : canDecrease;

      return NebaHitTarget(
        child: _NumberStepper(
          glyph: direction > 0 ? NebaGlyphs.plus : NebaGlyphs.minus,
          side: stepperSide,
          roles: roles,
          enabled: enabled,
          onPress: _handleStepperPress,
          onTick: () => _stepperTick(direction),
          onRelease: _handleStepperRelease,
        ),
      );
    }

    Widget content(BuildContext context, bool focused) {
      Widget adornment(Widget child) {
        return NebaFieldAdornment(size: size, focused: focused, accent: roles.accent, child: child);
      }

      final Widget? startIcon = widget.startIcon;
      final Widget? endIcon = widget.endIcon;
      final Widget control = Listener(
        onPointerSignal: _handleWheel,
        child: NebaFieldEditable(
          editableKey: _editableKey,
          controller: _controller,
          focusNode: _node,
          style: style,
          roles: roles,
          empty: empty,
          readOnly: readOnly,
          suggestions: false,
          textAlign: steppers == NebaNumberFieldSteppers.split ? TextAlign.center : TextAlign.start,
          keyboardType: TextInputType.numberWithOptions(signed: _lowest < 0, decimal: true),
          autofocus: widget.autofocus,
          autofillHints: null,
          inputFormatters: <TextInputFormatter>[_characters],
          onChanged: _handleChanged,
          selectionEnabled: selectionEnabled,
          placeholder: widget.placeholder,
          placeholderHidden: rests && !focused,
          typing: lit ? _typing : null,
          onKeyEvent: _handleKey,
          shortcuts: widget.shortcuts,
        ),
      );

      return NebaHitArea(
        child: Row(
          spacing: gap,
          children: <Widget>[
            if (steppers == NebaNumberFieldSteppers.split) stepper(-1),
            if (startIcon != null) adornment(startIcon),
            Expanded(child: control),
            if (endIcon != null) adornment(endIcon),
            if (steppers == NebaNumberFieldSteppers.end)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: _stepperGap,
                children: <Widget>[stepper(-1), stepper(1)],
              ),
            if (steppers == NebaNumberFieldSteppers.split) stepper(1),
          ],
        ),
      );
    }

    final double paddingStart = steppers == NebaNumberFieldSteppers.split
        ? _stepperInset
        : paddingX;
    final double paddingEnd = steppers == NebaNumberFieldSteppers.none ? paddingX : _stepperInset;
    // About twenty characters, as a text field, with the steppers beside
    // them rather than taken out of them.
    final double width =
        11 * text +
        paddingStart +
        paddingEnd +
        switch (steppers) {
          NebaNumberFieldSteppers.end => gap + 2 * stepperSide + _stepperGap,
          NebaNumberFieldSteppers.split => 2 * (gap + stepperSide),
          NebaNumberFieldSteppers.none => 0,
        };

    Widget shell = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation ?? 0,
      disabled: disabled,
      readOnly: readOnly,
      typing: lit ? _typing : null,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      paddingStart: paddingStart,
      paddingEnd: paddingEnd,
      notch: notched
          ? NebaFieldNotch(
              label: ExcludeSemantics(excluding: semantics.labelTaken, child: label),
              rests: rests,
              empty: empty,
              restEnd: restEnd,
            )
          : null,
      builder: content,
    );

    shell = _gestures.wrap(shell, disabled: disabled);

    // One node for the whole column, the editable's own flags and actions
    // merged into it. The steppers are not nodes of their own: what they do
    // is the node's increase and decrease.
    return Semantics(
      container: true,
      label: semantics.label,
      hint: semantics.hint,
      enabled: !disabled,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: disabled ? null : _requestFocus,
      onIncrease: canIncrease ? () => _semanticStep(1) : null,
      onDecrease: canDecrease ? () => _semanticStep(-1) : null,
      increasedValue: canIncrease ? _peek(1) : null,
      decreasedValue: canDecrease ? _peek(-1) : null,
      child: NebaFieldWidth(
        width: width,
        fullWidth: widget.fullWidth,
        sizer: notched
            ? NebaNotchSizer(
                label: label,
                size: size,
                density: density,
                variant: variant,
                rests: rests,
                restEnd: restEnd,
              )
            : null,
        child: NebaFieldColumn(
          size: size,
          semantics: semantics,
          errorColor: roles.accent,
          disabled: disabled,
          label: notched ? null : label,
          description: widget.description,
          error: widget.error,
          onLabelTap: _requestFocus,
          field: shell,
        ),
      ),
    );
  }
}

/// Keeps out of a number field every edit that would put a character in it
/// that no number is written with.
class _NumberCharacters extends TextInputFormatter {
  _NumberCharacters(this.allows);

  final bool Function(String text) allows;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == oldValue.text || allows(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

/// One of a number field's two buttons: pressed, it steps once at once, and
/// held, it steps again every 60 milliseconds after 400. Moving off it while
/// it is held stops it, and coming back starts it again.
///
/// It is drawn square against the field's text, muted until the pointer is
/// over it, and grey once the value has reached the end of the range it
/// steps towards. It is not a stop in the focus order and not a node of its
/// own for a screen reader: the arrow keys and the field's increase and
/// decrease do what it does.
class _NumberStepper extends StatefulWidget {
  const _NumberStepper({
    required this.glyph,
    required this.side,
    required this.roles,
    required this.enabled,
    required this.onPress,
    required this.onTick,
    required this.onRelease,
  });

  final List<NebaGlyphPart> glyph;
  final double side;
  final NebaColorRoles roles;
  final bool enabled;
  final ValueChanged<PointerDeviceKind> onPress;

  /// One step, returning whether it moved the value.
  final bool Function() onTick;
  final VoidCallback onRelease;

  @override
  State<_NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<_NumberStepper> {
  Timer? _delay;
  Timer? _repeat;
  PointerDeviceKind _kind = PointerDeviceKind.mouse;
  Offset _origin = Offset.zero;
  bool _hovered = false;
  bool _held = false;
  bool _inside = false;

  @override
  void didUpdateWidget(_NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The value reached the end of the range under a held press.
    if (!widget.enabled) {
      _stop();
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _run() {
    _stop();

    if (!widget.onTick()) {
      return;
    }

    _delay = Timer(_holdDelay, () {
      _repeat = Timer.periodic(_holdInterval, (Timer _) {
        if (!mounted || !widget.onTick()) {
          _stop();
        }
      });
    });
  }

  void _stop() {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
  }

  bool _handleStart(Offset position) {
    if (!widget.enabled) {
      return false;
    }

    _origin = position;
    widget.onPress(_kind);
    setState(() {
      _held = true;
      _inside = true;
    });
    _run();

    return true;
  }

  void _handleMove(Offset travelled) {
    final Size? size = context.size;
    final bool inside = size != null && (Offset.zero & size).contains(_origin + travelled);

    if (inside == _inside) {
      return;
    }

    setState(() => _inside = inside);

    if (inside && widget.enabled) {
      _run();
    } else {
      _stop();
    }
  }

  void _handleEnd() {
    _stop();
    setState(() {
      _held = false;
      _inside = false;
    });
    widget.onRelease();
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = widget.roles;
    final bool enabled = widget.enabled;
    final bool pressed = enabled && _held && _inside;
    final bool lit = enabled && (_hovered || pressed);
    final Color fill = !enabled
        ? roles.soft.withValues(alpha: 0)
        : pressed
        ? roles.softPress
        : lit
        ? roles.soft
        : roles.soft.withValues(alpha: 0);
    final Color ink = !enabled
        ? tokens.disabledFg
        : lit
        ? roles.onTint
        : tokens.mutedFg;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
      onExit: (PointerExitEvent event) => setState(() => _hovered = false),
      child: NebaDragRegion(
        enabled: enabled,
        onStart: _handleStart,
        onMove: _handleMove,
        onEnd: _handleEnd,
        builder: (BuildContext context, bool dragging) {
          return Listener(
            // Asked before the region's own press, which is above it.
            onPointerDown: (PointerDownEvent event) => _kind = event.kind,
            child: AnimatedContainer(
              width: widget.side,
              height: widget.side,
              duration: nebaDuration(context, NebaScale.duration, instant: pressed),
              curve: NebaScale.ease,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(tokens.radius[NebaSize.xs]!),
              ),
              alignment: Alignment.center,
              child: NebaInk(
                color: ink,
                instant: pressed,
                child: NebaGlyph(widget.glyph, size: widget.side * 0.9 / _stepperEms),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A number written plainly: a whole one without a point, any other with at
/// most three decimals and no trailing zeros, as `Intl.NumberFormat` writes
/// one it was told nothing about, without the grouping, which depends on a
/// language the package cannot read.
String _plainText(double value) {
  if (!value.isFinite) {
    return value.toString();
  }

  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }

  String text = value.toStringAsFixed(3);

  text = text.replaceFirst(RegExp(r'0+$'), '');

  return text.endsWith('.') ? text.substring(0, text.length - 1) : text;
}

/// What a number written plainly, or with grouping commas, a currency sign or
/// a unit around it, says: the digits, one point and a leading sign, read
/// with everything else passed over. `null` when they are not a number.
double? _plainParse(String text) {
  final String digits = text.replaceAll('−', '-').replaceAll(RegExp(r'[^0-9.+\-]'), '');

  if (digits.isEmpty) {
    return null;
  }

  return double.tryParse(digits);
}

/// [value] landed on a multiple of [step] counted from [base]: to the
/// nearest one, or the next one in the direction [step] points.
double _snap(double value, double base, double step, {required bool nearest}) {
  final double size = step.abs();
  final double direction = step.sign;
  final double steps = value - base + size * 1e-10 * direction;

  if (nearest) {
    return base + (steps / step).roundToDouble() * step;
  }

  final double snapped = direction > 0
      ? (steps / size).floorToDouble()
      : (steps / size).ceilToDouble();

  return base + snapped * size;
}

/// [value] without the noise binary arithmetic leaves after a step, so
/// `0.1 + 0.2` is `0.3`: read back to fifteen significant digits, and only
/// when that moves it by less than the noise could be.
double _clean(double value) {
  if (!value.isFinite) {
    return value;
  }

  final double rounded = double.parse(value.toStringAsPrecision(15));
  final double tolerance = math.min(2.220446049250313e-16 * math.max(1, value.abs()), 1e-10);

  return (rounded - value).abs() <= tolerance ? rounded : value;
}
