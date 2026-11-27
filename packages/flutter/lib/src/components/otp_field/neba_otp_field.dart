/// `NebaOtpField`, a row of one-character cells for a short code.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What may be typed into a [NebaOtpField].
enum NebaOtpCharset {
  /// The digits. The default, since that is what a texted code is, and it
  /// puts a number pad in front of a phone.
  numeric,

  /// The Latin letters.
  alpha,

  /// The Latin letters and the digits.
  alphanumeric,

  /// Whatever the keyboard produces but a space, for a key with punctuation
  /// in it.
  any,
}

/// The fewest cells a code has: one is a text field.
const int _fewest = 2;

/// The most cells a code has: past twelve the row stops fitting a phone.
const int _most = 12;

/// A cell's box, taller than it is wide at every step, on a ladder of its
/// own: a cell is one character standing on its own, not a control in a row
/// of them.
const Map<NebaSize, Size> _cellSize = <NebaSize, Size>{
  NebaSize.xs: Size(24, 28),
  NebaSize.sm: Size(28, 32),
  NebaSize.md: Size(32, 40),
  NebaSize.lg: Size(40, 48),
  NebaSize.xl: Size(48, 56),
};

/// A cell's corners, about 22% of its width, so a cell is never a pill.
const Map<NebaSize, double> _cellRadius = <NebaSize, double>{
  NebaSize.xs: 5,
  NebaSize.sm: 6,
  NebaSize.md: 7,
  NebaSize.lg: 9,
  NebaSize.xl: 11,
};

/// The character's size, two steps up the control ladder: a code is read
/// off one screen and typed on another.
const Map<NebaSize, double> _cellText = <NebaSize, double>{
  NebaSize.xs: 13,
  NebaSize.sm: 15,
  NebaSize.md: 17,
  NebaSize.lg: 20,
  NebaSize.xl: 24,
};

/// Between the cells, and the only thing density changes.
const Map<NebaDensity, Map<NebaSize, double>> _cellGap = <NebaDensity, Map<NebaSize, double>>{
  NebaDensity.standard: <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 4,
    NebaSize.md: 6,
    NebaSize.lg: 8,
    NebaSize.xl: 10,
  },
  NebaDensity.compact: <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 4,
    NebaSize.xl: 6,
  },
};

/// How long the caret stays on, and off.
const Duration _blink = Duration(milliseconds: 500);

/// What drew a change to the code, which decides whether it completes it.
enum _Cause { typed, pasted, keyboard }

/// A row of one-character cells for a short code: a PIN, a texted
/// verification code, an invite key.
///
/// The cells act as one field. Typing moves on a cell, Backspace steps back,
/// the arrow keys walk the row, Home and End go to its ends, and a paste fills
/// the cells from the one it lands in. A press lands on the cell under it, or
/// on the first empty one past the code, so a half-typed code cannot be
/// edited into a gap. Behind the cells is one [EditableText], which a phone
/// fills from a texted code through [AutofillHints.oneTimeCode], and which a
/// screen reader hears as one field with its label and the code.
///
/// ```dart
/// NebaOtpField(label: const Text('Verification code'), groupSize: 3, onComplete: verify)
/// ```
class NebaOtpField extends StatefulWidget {
  /// A code field.
  const NebaOtpField({
    this.length = 6,
    this.charset = NebaOtpCharset.numeric,
    this.mask = false,
    this.groupSize,
    this.separator,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.onComplete,
    this.onValueInvalid,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// How many characters the code has, held to 2 to 12.
  final int length;

  /// What may be typed. Anything else is dropped rather than shown, and
  /// [onValueInvalid] reports the text it came in.
  final NebaOtpCharset charset;

  /// Draws every character as a dot, as a password field does.
  final bool mask;

  /// Splits the row every [groupSize] cells with the [separator]: `3` on a
  /// six-character code gives two blocks of three.
  final int? groupSize;

  /// What is drawn between two groups, an en dash when left out.
  final Widget? separator;

  /// The code, for a controlled field, with [onValueChange]. Leave it `null`
  /// and the field keeps its own, starting from [defaultValue].
  final String? value;

  /// The code an uncontrolled field starts with.
  final String? defaultValue;

  /// Called with the code each time it changes.
  final ValueChanged<String>? onValueChange;

  /// Called once every cell is filled, which is the moment to check the code.
  final ValueChanged<String>? onComplete;

  /// Called with typed or pasted text that held characters [charset] keeps
  /// out, or more than the cells hold.
  final ValueChanged<String>? onValueInvalid;

  /// The field's name, usually a [Text], above the cells. A tap on it puts the
  /// caret in the first cell, and a screen reader hears it as the field's name.
  final Widget? label;

  /// Helper text under the cells, usually a [Text].
  final Widget? description;

  /// An error under the cells, usually a [Text]. Giving one turns the field
  /// invalid.
  final Widget? error;

  /// Whether the field is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// The weight of each cell's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// A cell's box and the character in it, on a ladder of the field's own.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edges, the ring and the caret. Defaults to
  /// [NebaColor.primary]; an invalid field is [NebaColor.danger].
  final NebaColor? color;

  /// The space between the cells, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Each cell's drop shadow, from `0`, which is none, to `3`.
  final NebaElevation? elevation;

  /// Grey, out of the focus order and unable to change.
  final bool disabled;

  /// Shows the code and can be walked and copied, but takes nothing typed.
  final bool readOnly;

  /// What a screen reader names the field, in place of [label].
  final String? semanticLabel;

  /// The field's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the field takes the focus when it is first built, with the
  /// caret in the first cell.
  final bool autofocus;

  @override
  State<NebaOtpField> createState() => _NebaOtpFieldState();
}

class _NebaOtpFieldState extends State<NebaOtpField> {
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ValueNotifier<bool> _caretOn = ValueNotifier<bool>(true);
  late final _OtpEdits _edits = _OtpEdits(_edit);
  late final TextEditingController _controller;
  FocusNode? _ownNode;

  /// An uncontrolled field's code.
  String _value = '';

  /// The cell the next character lands in.
  int _active = 0;
  bool _focused = false;
  int? _hovered;

  /// Set while the focus arrives from a press, a label or [autofocus] that
  /// already chose the cell.
  bool _placed = false;

  /// Set while the focus is landing, when the editable may move its
  /// selection on its own: on a desktop it selects everything.
  bool _arriving = false;

  /// A controlled field's change, waiting for its parent to take it: the
  /// code, the cell after it, and whether it completes the code.
  ({String value, int active, bool complete})? _pending;
  Timer? _blinker;

  int get _cells => widget.length.clamp(_fewest, _most);

  String get _current => _normalize(widget.value ?? _value).$1;

  FocusNode get _node {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaOtpField'));
  }

  /// The last cell the caret may stand in: the first empty one, or the last.
  int _end(String code) => math.min(_charsOf(code).length, _cells - 1);

  @override
  void initState() {
    super.initState();
    _value = _normalize(widget.defaultValue ?? '').$1;

    if (widget.autofocus) {
      _placed = true;
    } else {
      _active = _end(_current);
    }

    _controller = TextEditingController.fromValue(_shown());
    _controller.addListener(_handleController);
    _node.addListener(_handleFocus);
    _focused = _node.hasFocus;
  }

  @override
  void didUpdateWidget(NebaOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownNode)?.removeListener(_handleFocus);
      _node.addListener(_handleFocus);
      _focused = _node.hasFocus;
    }

    final ({String value, int active, bool complete})? pending = _pending;

    if (pending != null && widget.value != null) {
      _pending = null;

      if (_current == pending.value) {
        _active = pending.active;

        if (pending.complete) {
          // After the frame, since the parent is building now.
          SchedulerBinding.instance.addPostFrameCallback((Duration _) {
            if (mounted) {
              widget.onComplete?.call(pending.value);
            }
          });
        }
      }
    }

    _active = math.min(_active, _end(_current));
    _show();
  }

  @override
  void dispose() {
    _blinker?.cancel();
    _node.removeListener(_handleFocus);
    _controller.removeListener(_handleController);
    _controller.dispose();
    _ownNode?.dispose();
    _caretOn.dispose();
    super.dispose();
  }

  /// [raw] with its spaces taken out, its characters held to [charset] and
  /// cut to the cells, and whether anything was dropped on the way.
  (String, bool) _normalize(String raw) {
    final String stripped = raw.replaceAll(RegExp(r'\s'), '');
    final RegExp? outside = switch (widget.charset) {
      NebaOtpCharset.numeric => RegExp('[^0-9]'),
      NebaOtpCharset.alpha => RegExp('[^a-zA-Z]'),
      NebaOtpCharset.alphanumeric => RegExp('[^a-zA-Z0-9]'),
      NebaOtpCharset.any => null,
    };
    final String kept = outside == null ? stripped : stripped.replaceAll(outside, '');
    final List<String> chars = _charsOf(kept);

    return (chars.take(_cells).join(), kept.length < stripped.length || chars.length > _cells);
  }

  /// The selection that stands for [active] in [code]: its character, or the
  /// caret where an empty cell starts.
  TextSelection _selectionFor(String code, int active) {
    final List<String> chars = _charsOf(code);
    final int start = chars.take(active).join().length;

    if (active < chars.length) {
      return TextSelection(baseOffset: start, extentOffset: start + chars[active].length);
    }

    return TextSelection.collapsed(offset: start);
  }

  /// The code, and while the field holds the focus the active cell's
  /// selection. A field without the focus has none, as an input has none.
  TextEditingValue _shown() {
    final String code = _current;

    return TextEditingValue(
      text: code,
      selection: _focused
          ? _selectionFor(code, _active)
          : const TextSelection.collapsed(offset: -1),
    );
  }

  /// Puts the code and the cell in the editable, which the platform's
  /// keyboard then answers to.
  void _show() {
    final TextEditingValue shown = _shown();

    if (_controller.value.text != shown.text || _controller.value.selection != shown.selection) {
      _controller.value = shown;
    }
  }

  /// [change] now, or after the frame when it would land in the middle of
  /// one: a selection can move while the tree is being built.
  void _later(VoidCallback change) {
    if (!mounted) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(change);
        }
      });
    } else {
      setState(change);
    }
  }

  void _restartBlink() {
    _blinker?.cancel();
    _blinker = null;
    _caretOn.value = true;

    if (_focused) {
      _blinker = Timer.periodic(_blink, (Timer _) => _caretOn.value = !_caretOn.value);
    }
  }

  void _handleFocus() {
    final bool focused = _node.hasFocus;

    if (!mounted || focused == _focused) {
      return;
    }

    _focused = focused;

    if (focused && !_placed) {
      // A focus that came in from the keyboard lands on the first empty
      // cell, where the code goes on.
      _active = _end(_current);
    }

    _placed = false;
    _later(() {});

    if (focused) {
      _arriving = true;
      // The editable answers the same focus change after this, and may move
      // its selection; the cell is put back once it has.
      scheduleMicrotask(() {
        _arriving = false;

        if (mounted) {
          _show();
        }
      });
    }

    _show();
    _restartBlink();
  }

  /// The selection moved on its own: by the platform, or by a character typed
  /// over the same one, which moves on a cell.
  void _handleController() {
    final TextEditingValue shown = _controller.value;
    final String code = _current;

    if (shown.text != code || !shown.selection.isValid) {
      return;
    }

    final TextSelection wanted = _selectionFor(code, _active);

    if (shown.selection == wanted) {
      return;
    }

    if (_arriving) {
      _show();
      return;
    }

    final int before = _charsOf(code.substring(0, shown.selection.start)).length;

    _active = math.min(before, _end(code));
    _later(() {});
    _show();
    _restartBlink();
  }

  /// What the editable shows after the platform edited it into [next].
  TextEditingValue _edit(TextEditingValue next) {
    if (widget.disabled || widget.readOnly) {
      return _shown();
    }

    // A character still being composed is left to the keyboard until it is
    // committed, and only then read.
    if (next.composing.isValid && !next.composing.isCollapsed) {
      return next;
    }

    final String code = _current;
    final String text = next.text;

    if (text == code) {
      return _shown();
    }

    final TextSelection was = _selectionFor(code, _active);
    final String before = code.substring(0, was.start);
    final String after = code.substring(was.end);

    if (text.length >= before.length + after.length &&
        text.startsWith(before) &&
        text.endsWith(after)) {
      final String inserted = text.substring(was.start, text.length - after.length);

      if (inserted.isEmpty) {
        // The character in the cell was deleted: a phone's backspace.
        _backspace();
      } else {
        _type(inserted);
      }
    } else if (was.isCollapsed &&
        before.isNotEmpty &&
        text == _charsOf(before).sublist(0, _charsOf(before).length - 1).join() + after) {
      // The character before an empty cell was deleted.
      _backspace();
    } else {
      // The whole code was replaced, as autofill does.
      final (String filled, bool rejected) = _normalize(text);

      if (rejected) {
        widget.onValueInvalid?.call(text);
      }

      _change(filled, active: math.max(0, _charsOf(filled).length - 1), cause: _Cause.typed);
    }

    return _shown();
  }

  /// [raw] typed or pasted into the active cell, filling the cells from it.
  void _type(String raw) {
    final (String typed, bool rejected) = _normalize(raw);

    if (rejected) {
      widget.onValueInvalid?.call(raw);
    }

    // Every character was rejected, so the cell keeps the one it had.
    if (typed.isEmpty) {
      return;
    }

    final List<String> chars = _charsOf(_current);
    final List<String> added = _charsOf(typed);
    final String next = _normalize(
      chars.take(_active).join() + typed + chars.skip(_active + added.length).join(),
    ).$1;

    _change(
      next,
      active: math.min(_active + added.length, _cells - 1),
      cause: added.length > 1 ? _Cause.pasted : _Cause.typed,
    );
  }

  /// Takes the character in the active cell, or the one before it when the
  /// cell is empty, and steps back a cell.
  void _backspace() {
    final List<String> chars = _charsOf(_current);
    final int target = math.max(0, _active - 1);
    final int index = _active < chars.length ? _active : target;

    if (index < chars.length) {
      chars.removeAt(index);
    }

    _change(chars.join(), active: target, cause: _Cause.keyboard);
  }

  /// Sets the code and the cell, and reports a change.
  void _change(String next, {required int active, required _Cause cause}) {
    final String code = _current;
    final int count = _charsOf(next).length;
    final bool complete =
        cause != _Cause.keyboard &&
        count == _cells &&
        (_charsOf(code).length != _cells || cause == _Cause.pasted);

    if (next == code) {
      if (complete) {
        widget.onComplete?.call(next);
      }

      return;
    }

    widget.onValueChange?.call(next);

    if (widget.value != null) {
      // Controlled: the parent's code is shown until it takes this one.
      _pending = (value: next, active: active, complete: complete);
      return;
    }

    setState(() {
      _value = next;
      _active = math.min(active, _end(next));
    });
    _restartBlink();

    if (complete) {
      widget.onComplete?.call(next);
    }
  }

  void _moveTo(int index) {
    setState(() => _active = math.max(0, math.min(index, _end(_current))));
    _show();
    _restartBlink();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    final bool far =
        (keyboard.isControlPressed || keyboard.isMetaPressed) && !keyboard.isAltPressed;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    final LogicalKeyboardKey back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final LogicalKeyboardKey ahead = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final int end = _end(_current);

    if (key == back) {
      _moveTo(far ? 0 : _active - 1);
    } else if (key == ahead) {
      _moveTo(far ? end : _active + 1);
    } else if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.arrowUp) {
      _moveTo(0);
    } else if (key == LogicalKeyboardKey.end || key == LogicalKeyboardKey.arrowDown) {
      _moveTo(end);
    } else if (widget.readOnly) {
      return KeyEventResult.ignored;
    } else if (key == LogicalKeyboardKey.backspace && far) {
      _change('', active: 0, cause: _Cause.keyboard);
      _show();
    } else if (key == LogicalKeyboardKey.delete) {
      final List<String> chars = _charsOf(_current);

      if (_active < chars.length) {
        chars.removeAt(_active);
      }

      _change(chars.join(), active: _active, cause: _Cause.keyboard);
      _show();
    } else if (key == LogicalKeyboardKey.backspace) {
      _backspace();
      _show();
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  /// A press on cell [index]: the caret goes there, or to the first empty
  /// cell when the press is past the code.
  void _press(int index) {
    if (widget.disabled) {
      return;
    }

    final int active = math.min(index, _end(_current));

    if (!_node.hasFocus) {
      _placed = true;
    }

    setState(() => _active = active);
    _editableKey.currentState?.requestKeyboard();
    _show();
    _restartBlink();
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool disabled = widget.disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );
    final String code = _current;
    final List<String> chars = _charsOf(code);
    final int cells = _cells;
    final int every = (widget.groupSize ?? 0) > 0 ? widget.groupSize! : 0;
    final Size box = _cellSize[size]!;
    final double fontSize = _cellText[size]!;
    final BorderRadius radius = BorderRadius.circular(_cellRadius[size]!);
    final bool focused = _focused && !disabled;
    final int active = math.min(_active, _end(code));
    // The cells take their colour from the ink around them, which eases with
    // the sheet; the editable, which draws nothing, takes the whole style.
    final TextStyle character = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500);
    final TextStyle text = DefaultTextStyle.of(context).style.merge(character);

    Widget cell(int index) {
      final bool here = focused && index == active;
      final NebaFieldLook look = NebaFieldLook.of(
        tokens: tokens,
        roles: roles,
        variant: variant,
        elevation: widget.elevation ?? 0,
        disabled: disabled,
        readOnly: readOnly,
        hovered: _hovered == index && !disabled,
        focused: here,
      );
      final String? char = index < chars.length ? (widget.mask ? '•' : chars[index]) : null;
      final Widget inside;

      if (char != null) {
        // The character in the cell the caret is in is selected, so the next
        // one typed takes its place.
        inside = DecoratedBox(
          decoration: BoxDecoration(
            color: here ? roles.softPress : roles.softPress.withValues(alpha: 0),
          ),
          child: Text(char, style: character, textAlign: TextAlign.center),
        );
      } else if (here && !readOnly) {
        inside = ValueListenableBuilder<bool>(
          valueListenable: _caretOn,
          builder: (BuildContext context, bool on, Widget? _) {
            return Container(
              width: 2,
              height: fontSize * 1.2,
              decoration: BoxDecoration(
                color: on ? roles.accent : roles.accent.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          },
        );
      } else {
        inside = const SizedBox.shrink();
      }

      Widget sheet = SizedBox.fromSize(
        size: box,
        child: NebaSheet(
          fill: look.fill,
          edge: look.edge,
          plate: look.plate,
          elevation: look.elevation,
          borderRadius: radius,
          blur: look.textured,
          texture: look.textured,
          fillDuration: here ? NebaScale.duration : null,
          child: NebaInk(
            color: look.ink,
            child: Center(child: inside),
          ),
        ),
      );

      // Flush with the edge, as every field's ring is, and on any focus: the
      // ring is what says which cell the next key lands in.
      sheet = NebaFocusRing(
        visible: here,
        color: roles.ring,
        borderRadius: radius,
        offset: 0,
        keyboardOnly: false,
        child: sheet,
      );

      return MouseRegion(
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
        onEnter: disabled ? null : (PointerEnterEvent event) => setState(() => _hovered = index),
        onExit: disabled
            ? null
            : (PointerExitEvent event) {
                if (_hovered == index) {
                  setState(() => _hovered = null);
                }
              },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // A mouse puts the caret in the cell on the press, a finger on the
          // release, as a browser's input does.
          onTapDown: disabled
              ? null
              : (TapDownDetails details) {
                  if (details.kind != PointerDeviceKind.touch) {
                    _press(index);
                  }
                },
          onTapUp: disabled
              ? null
              : (TapUpDetails details) {
                  if (details.kind == PointerDeviceKind.touch) {
                    _press(index);
                  }
                },
          child: sheet,
        ),
      );
    }

    final Widget separator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: fontSize, color: tokens.mutedFg),
        child: widget.separator ?? const Text('–'),
      ),
    );

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: _cellGap[density]![size]!,
      children: <Widget>[
        for (int index = 0; index < cells; index += 1) ...<Widget>[
          if (every > 0 && index > 0 && index % every == 0) separator,
          cell(index),
        ],
      ],
    );

    if (readOnly) {
      row = ColorFiltered(colorFilter: ColorFilter.matrix(saturationMatrix(0.55)), child: row);
    }

    Widget field = Stack(
      children: <Widget>[
        // The editable the keyboard, autofill and a screen reader reach,
        // drawing nothing: the cells draw the code.
        Positioned.fill(
          child: NebaFieldEditable(
            editableKey: _editableKey,
            controller: _controller,
            focusNode: _node,
            style: text,
            roles: roles,
            drawn: false,
            readOnly: readOnly,
            obscureText: widget.mask,
            suggestions: false,
            keyboardType: widget.charset == NebaOtpCharset.numeric
                ? TextInputType.number
                : TextInputType.text,
            textInputAction: TextInputAction.done,
            autofocus: widget.autofocus,
            autofillHints: const <String>[AutofillHints.oneTimeCode],
            inputFormatters: <TextInputFormatter>[_edits],
            onKeyEvent: _handleKey,
          ),
        ),
        // The cells are the field's look; the field's one node is what a
        // screen reader hears.
        ExcludeSemantics(child: row),
      ],
    );

    if (disabled) {
      field = ExcludeFocus(child: field);
    }

    return Semantics(
      container: true,
      label: semantics.label,
      hint: semantics.hint,
      enabled: !disabled,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      maxValueLength: cells,
      currentValueLength: chars.length,
      onTap: disabled ? null : () => _press(_end(code)),
      child: IntrinsicWidth(
        child: NebaFieldColumn(
          size: size,
          semantics: semantics,
          errorColor: roles.accent,
          disabled: disabled,
          label: widget.label,
          description: widget.description,
          error: widget.error,
          onLabelTap: () => _press(0),
          field: Align(alignment: AlignmentDirectional.centerStart, child: field),
        ),
      ),
    );
  }
}

/// Hands every edit the platform makes to the field, which answers with the
/// code it comes to and the cell after it.
class _OtpEdits extends TextInputFormatter {
  _OtpEdits(this.edit);

  final TextEditingValue Function(TextEditingValue next) edit;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return edit(newValue);
  }
}

/// [text]'s characters, one code point each.
List<String> _charsOf(String text) => text.runes.map(String.fromCharCode).toList();
