/// `NebaPromptInput`, everything a prompt goes out through.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which key sends a [NebaPromptInput], as `NebaShortcut` spells it.
enum NebaPromptSubmitKey {
  /// `Enter` sends and `Shift+Enter` breaks the line.
  enter,

  /// `Mod+Enter` sends and `Enter` breaks the line, for a field people write
  /// paragraphs in: Command on Apple platforms, Control everywhere else.
  modEnter,
}

/// The arrow that sends. Up rather than across, because the thread is above.
final List<NebaGlyphPart> _sendGlyph = <NebaGlyphPart>[
  const NebaGlyphPart.stroke(
    'M8 13V3.5m0 0L3.75 7.75M8 3.5l4.25 4.25',
    width: 1.75,
    cap: StrokeCap.round,
    join: StrokeJoin.round,
  ),
];

/// And the square that stops, solid, at the optical weight of the arrow.
final List<NebaGlyphPart> _stopGlyph = <NebaGlyphPart>[
  const NebaGlyphPart.fill(
    'M5.5 4h5A1.5 1.5 0 0 1 12 5.5v5a1.5 1.5 0 0 1-1.5 1.5h-5A1.5 1.5 0 0 1 4 10.5v-5A1.5 1.5 0 0 1 5.5 4Z',
  ),
];

/// Everything a prompt goes out through: the text, the controls under it,
/// and one button that sends and then stops.
///
/// A `NebaTextField` with `multiline` gets the shell. What it does not get is
/// what this adds: a field that grows with what is typed from [minRows] to
/// [maxRows] and then scrolls, a send button that becomes a stop button
/// without moving while [submitting], and Enter meaning send while
/// Shift+Enter breaks the line, or the other way round with
/// [NebaPromptSubmitKey.modEnter].
///
/// Neither key sends while an input method is composing: a Korean or
/// Japanese reader pressing Enter to accept a candidate is finishing a word.
/// Sending does not clear the field; what happens to what was typed is the
/// app's, since a message that failed to send should still be there.
///
/// ```dart
/// NebaPromptInput(
///   label: const Text('Message'),
///   placeholder: 'Ask anything',
///   onSubmit: (String text) => send(text),
/// )
/// ```
class NebaPromptInput extends StatefulWidget {
  /// A prompt field.
  const NebaPromptInput({
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmit,
    this.submitting = false,
    this.onStop,
    this.submitKey = NebaPromptSubmitKey.enter,
    this.label,
    this.placeholder,
    this.minRows = 1,
    this.maxRows = 8,
    this.start = const <Widget>[],
    this.end = const <Widget>[],
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled = false,
    this.readOnly = false,
    this.shortcuts,
    this.locale,
    this.labels,
    this.focusNode,
    this.autofocus = false,
    this.child,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'A controller holds its own value; give it the initial one instead.',
       ),
       assert(minRows > 0 && maxRows >= minRows),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// What is in the field, for a caller that drives it.
  final TextEditingController? controller;

  /// What a field that keeps its own text starts with.
  final String? initialValue;

  /// Called with the whole text on every change.
  final ValueChanged<String>? onChanged;

  /// Called with the text when the field is sent, by the key, by the button
  /// or by a touch keyboard's send key. A field that holds only whitespace
  /// never sends.
  final ValueChanged<String>? onSubmit;

  /// Whether an answer is being written. The send button becomes a stop
  /// button and stays pressable, in the place the reader last pressed to
  /// start it.
  final bool submitting;

  /// Called when the stop button is pressed.
  final VoidCallback? onStop;

  /// Which key sends.
  final NebaPromptSubmitKey submitKey;

  /// The field's name, usually a [Text], read by a screen reader and drawn
  /// for nobody.
  final Widget? label;

  /// What shows while the field is empty.
  final String? placeholder;

  /// How many rows the field is at its shortest.
  final int minRows;

  /// And at its tallest, after which it scrolls. A prompt field that grows
  /// without a ceiling pushes the conversation it belongs to off the screen.
  final int maxRows;

  /// Controls at the start of the row under the text: attach, a model
  /// `NebaSelect`.
  final List<Widget> start;

  /// Controls at its end, before the send button: a token count, a mode
  /// toggle.
  final List<Widget> end;

  /// The shell's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The type, the corners, one step rounder than a field's because the box
  /// is tall, and the send button. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the edge, the ring, the caret and the send button.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The shell's inline padding. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// Greyed out, out of the focus order, and never sends.
  final bool disabled;

  /// Shows its text but takes none, and never sends.
  final bool readOnly;

  /// Key combinations to act on, with what each does, asked before the field
  /// reads a key itself: a mention list open over the field can take Enter.
  final Map<ShortcutActivator, VoidCallback>? shortcuts;

  /// The language the two button labels are said in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those words, written out over the [locale]'s, by the React package's
  /// keys: `send` and `stop`.
  final Map<String, String>? labels;

  /// The field's focus node.
  final FocusNode? focusNode;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  /// A strip above the text: the attachments added, a reply-to line.
  final Widget? child;

  /// The step the corners are drawn at, for each size: one rounder than a
  /// field's.
  static const Map<NebaSize, NebaSize> cornerSizes = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.sm,
    NebaSize.sm: NebaSize.md,
    NebaSize.md: NebaSize.lg,
    NebaSize.lg: NebaSize.xl,
    NebaSize.xl: NebaSize.xl,
  };

  /// Between the strip above, the text and the row under it.
  static const Map<NebaSize, double> stackGaps = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 10,
    NebaSize.xl: 12,
  };

  @override
  State<NebaPromptInput> createState() => _NebaPromptInputState();
}

class _NebaPromptInputState extends State<NebaPromptInput>
    implements TextSelectionGestureDetectorBuilderDelegate {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ValueNotifier<bool> _typing = ValueNotifier<bool>(false);
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);
  TextEditingController? _ownController;
  FocusNode? _ownNode;
  bool _empty = true;
  bool _blank = true;

  TextEditingController get _controller => widget.controller ?? _ownController!;

  FocusNode get _node {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaPromptInput'));
  }

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !_disabled;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _ownController = TextEditingController(text: widget.initialValue);
    }

    _controller.addListener(_handleText);
    _read();
  }

  @override
  void didUpdateWidget(NebaPromptInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_handleText);

      final TextEditingController? previous = oldWidget.controller;

      if (widget.controller == null && previous != null) {
        _ownController = TextEditingController.fromValue(previous.value);
      } else if (widget.controller != null) {
        _ownController?.dispose();
        _ownController = null;
      }

      _controller.addListener(_handleText);
    }

    _read();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleText);
    _ownController?.dispose();
    _ownNode?.dispose();
    _typing.dispose();
    super.dispose();
  }

  void _read() {
    final String text = _controller.text;

    _empty = text.isEmpty;
    _blank = text.trim().isEmpty;
  }

  /// Rebuilds only when what the field draws from its text changes: whether
  /// there is any, and whether there is anything to send.
  void _handleText() {
    final String text = _controller.text;

    if (text.isEmpty == _empty && text.trim().isEmpty == _blank) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(_read);
        }
      });
    } else {
      setState(_read);
    }
  }

  bool get _locked => _disabled || widget.readOnly;

  void _send() {
    final String text = _controller.text;

    if (text.trim().isEmpty || _locked || widget.submitting) {
      return;
    }

    widget.onSubmit?.call(text);
  }

  /// Whether a key event is the platform's modifier: Command on Apple
  /// platforms and Control everywhere else.
  bool get _mod {
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return keyboard.isMetaPressed && !keyboard.isControlPressed;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return keyboard.isControlPressed && !keyboard.isMetaPressed;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // The caller's first, so a list open over the field can take Enter.
    final Map<ShortcutActivator, VoidCallback>? shortcuts = widget.shortcuts;

    if (shortcuts != null) {
      for (final MapEntry<ShortcutActivator, VoidCallback> entry in shortcuts.entries) {
        if (entry.key.accepts(event, HardwareKeyboard.instance)) {
          entry.value();

          return KeyEventResult.handled;
        }
      }
    }

    final LogicalKeyboardKey key = event.logicalKey;

    if (key != LogicalKeyboardKey.enter && key != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }

    // An input method is mid-word, and Enter is finishing it.
    final TextRange composing = _controller.value.composing;

    if (composing.isValid && !composing.isCollapsed) {
      return KeyEventResult.ignored;
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    final bool shift = keyboard.isShiftPressed;
    final bool alt = keyboard.isAltPressed;
    final bool bare = !shift && !alt && !keyboard.isControlPressed && !keyboard.isMetaPressed;
    final bool mod = _mod && !shift && !alt;

    switch (widget.submitKey) {
      case NebaPromptSubmitKey.enter:
        if (bare) {
          _send();

          return KeyEventResult.handled;
        }

        if (shift && !alt && !keyboard.isControlPressed && !keyboard.isMetaPressed) {
          // The line break the platform would otherwise read as a send.
          _insertBreak();

          return KeyEventResult.handled;
        }
      case NebaPromptSubmitKey.modEnter:
        if (mod) {
          _send();

          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }

  void _insertBreak() {
    if (_locked) {
      return;
    }

    final TextEditingValue value = _controller.value;
    final TextSelection selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final String text = value.text.replaceRange(selection.start, selection.end, '\n');

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selection.start + 1),
    );
    widget.onChanged?.call(text);
  }

  void _requestFocus() {
    if (!_disabled) {
      _editableKey.currentState?.requestKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(color);
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool lit = !disabled && !readOnly;
    final Map<String, String> messages = nebaMessages(
      context,
      'prompt',
      locale: widget.locale ?? defaults.locale,
    );
    String word(String key) => widget.labels?[key] ?? messages[key]!;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      label: widget.label,
      placeholder: widget.placeholder,
    );
    final TextStyle style = nebaFieldTextStyle(
      context,
      tokens: tokens,
      size: size,
      disabled: disabled,
    );
    final bool submitting = widget.submitting;
    final bool canSend = !_blank && !_locked;
    final Widget? child = widget.child;

    final Widget editable = _gestures.wrap(
      NebaFieldEditable(
        editableKey: _editableKey,
        controller: _controller,
        focusNode: _node,
        style: style,
        roles: roles,
        empty: _empty,
        readOnly: readOnly,
        multiline: true,
        rows: widget.minRows,
        maxRows: widget.maxRows,
        // A phone labels its Enter key from this, and a touch keyboard's send
        // key sends without taking the focus away.
        textInputAction: widget.submitKey == NebaPromptSubmitKey.enter
            ? TextInputAction.send
            : TextInputAction.newline,
        onSubmitted: (String _) => _send(),
        onEditingComplete: () {},
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        selectionEnabled: selectionEnabled,
        placeholder: widget.placeholder,
        typing: lit ? _typing : null,
        onKeyEvent: _handleKey,
      ),
      disabled: disabled,
    );

    final Widget button = NebaIconButton(
      size: size,
      color: color,
      // One button, never two: what a reader reaches for to stop an answer is
      // where they last pressed to start it.
      icon: NebaGlyph(submitting ? _stopGlyph : _sendGlyph),
      label: submitting ? word('stop') : word('send'),
      onPressed: submitting ? () => widget.onStop?.call() : (canSend ? _send : null),
    );

    final Widget toolbar = DefaultTextStyle.merge(
      style: TextStyle(fontSize: NebaScale.metaText[size]),
      child: Row(
        spacing: 8,
        children: <Widget>[
          if (widget.start.isNotEmpty)
            Flexible(
              child: Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: widget.start),
            ),
          const Spacer(),
          if (widget.end.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: widget.end),
          button,
        ],
      ),
    );

    Widget shell = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation ?? 0,
      disabled: disabled,
      readOnly: readOnly,
      multiline: true,
      typing: lit ? _typing : null,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      cornerSize: NebaPromptInput.cornerSizes[size],
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: NebaScale.paddingX[density]![size]!,
        vertical: 8,
      ),
      builder: (BuildContext context, bool focused) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: NebaPromptInput.stackGaps[size]!,
          children: <Widget>[?child, editable, toolbar],
        );
      },
    );

    // A press on the shell's own padding puts the caret in the field, as a
    // press anywhere inside a native input does. The text and the controls
    // take their own.
    shell = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: disabled ? null : _requestFocus,
      child: shell,
    );

    return Semantics(
      container: true,
      label: semantics.label,
      hint: semantics.hint,
      enabled: !disabled,
      child: shell,
    );
  }
}
