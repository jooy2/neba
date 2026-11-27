/// `NebaTextField`, a field that takes text.
library;

import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A field that takes a line of text, or several.
///
/// The label, the description and the error are part of it, and a screen
/// reader hears all three with the field. `error` turns the whole field over
/// to the `danger` family, edge, ring, caret and message together. The sheet
/// is never dyed, whichever [variant] it is: what a field holds is the
/// reader's text, so the colour shows in the edge, the ring and the caret.
///
/// Its height is a floor rather than a fixed row: one line at [size] is
/// exactly as tall as a `NebaButton`, and text set larger grows the field
/// instead of being cut off. Typing, selecting and submitting are an
/// [EditableText]'s, so [controller], [focusNode], [onChanged] and
/// [onSubmitted] are the ones any Flutter text field takes.
///
/// ```dart
/// NebaTextField(label: const Text('Email'), onChanged: (String value) => email = value)
/// ```
class NebaTextField extends StatefulWidget {
  /// A text field.
  const NebaTextField({
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.labelPlacement,
    this.placeholder,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.endIcon,
    this.loading = false,
    this.multiline = false,
    this.rows = 3,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints = const <String>[],
    this.inputFormatters,
    this.maxLength,
    this.shortcuts,
    this.semanticLabel,
    this.autofocus = false,
    super.key,
  }) : assert(
         controller == null || initialValue == null,
         'A controller holds its own value; give it the initial one instead.',
       ),
       assert(rows >= 1),
       assert(!obscureText || !multiline, 'An obscured field is a single line.'),
       assert(maxLength == null || maxLength > 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The text, when the caller holds it. Leave it out and the field keeps its
  /// own, starting from [initialValue].
  final TextEditingController? controller;

  /// The text an uncontrolled field starts with, React's `defaultValue`.
  final String? initialValue;

  /// The field's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// The field's name, usually a [Text]. A tap on it puts the caret in the
  /// field, and a screen reader hears it as the field's name.
  final Widget? label;

  /// Where [label] is drawn: above the field, in a notch cut into its top
  /// edge, or inside it where the placeholder would be until the field takes
  /// the focus or holds a value, and in the notch from then on. A [startIcon]
  /// keeps a `float` label in the notch, since the icon is where it would
  /// rest. Defaults to `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// What the field shows while it is empty. Under a `float` label it shows
  /// only once the label has moved up.
  final String? placeholder;

  /// Helper text under the field, usually a [Text].
  final Widget? description;

  /// An error under the field, usually a [Text]. Giving one turns the field
  /// invalid.
  final Widget? error;

  /// Whether the field is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Before the text, drawn at 1.2 times its size, muted until the field holds
  /// the focus.
  final Widget? startIcon;

  /// After the text.
  final Widget? endIcon;

  /// Shows a turning ring in place of [endIcon]. Typing is still allowed: a
  /// field is usually busy because of what was just typed into it.
  final bool loading;

  /// Takes more than one line, and grows as the text does.
  final bool multiline;

  /// How many lines a [multiline] field shows at least. One row is exactly as
  /// tall as a single-line field.
  final int rows;

  /// The weight of the sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type scale: 22, 26, 32, 40 or 48 logical
  /// pixels, as a button's. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the caret. Defaults to
  /// [NebaColor.primary]; an invalid field is [NebaColor.danger].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`. A field is a well
  /// rather than a surface that floats, so it is rarely raised.
  final NebaElevation? elevation;

  /// Grey, out of the focus order and unable to take text.
  final bool disabled;

  /// Shows its text but takes none. It keeps the focus and its text can still
  /// be selected and copied; it goes flat and drains most of its saturation.
  final bool readOnly;

  /// Stretches to the width it is given. Otherwise the field is about twenty
  /// characters wide, or as wide as it is given when that is less.
  final bool fullWidth;

  /// The text's style, laid over the field's own. Text set larger than the
  /// size's grows the field.
  final TextStyle? style;

  /// Called with the text each time the reader changes it.
  final ValueChanged<String>? onChanged;

  /// Called with the text when the reader submits it from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// The keyboard a touch screen shows. Defaults to text, or multiline text.
  final TextInputType? keyboardType;

  /// What the keyboard's action key says and does.
  final TextInputAction? textInputAction;

  /// Draws every character as a dot, for a password.
  final bool obscureText;

  /// What the platform may fill the field with: `AutofillHints.email` and
  /// the rest. `null` keeps the field out of autofill altogether.
  final Iterable<String>? autofillHints;

  /// Formatters applied to the text as it is typed.
  final List<TextInputFormatter>? inputFormatters;

  /// The most characters the field takes.
  final int? maxLength;

  /// Key combinations to act on while the field holds the focus, with what
  /// each does: `SingleActivator(LogicalKeyboardKey.enter, control: true)`.
  /// A bound key is taken, so it does not also type a new line or submit.
  final Map<ShortcutActivator, VoidCallback>? shortcuts;

  /// What a screen reader names the field, in place of [label]: for a field
  /// with no label of its own, a search box, say.
  final String? semanticLabel;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaTextField> createState() => _NebaTextFieldState();
}

class _NebaTextFieldState extends State<NebaTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ValueNotifier<bool> _typing = ValueNotifier<bool>(false);
  late final _FieldGestures _gestures = _FieldGestures(delegate: this);
  TextEditingController? _ownController;
  FocusNode? _ownNode;
  bool _empty = true;
  int _length = 0;

  TextEditingController get _controller => widget.controller ?? _ownController!;

  FocusNode get _node {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaTextField'));
  }

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !widget.disabled && !(widget.readOnly && widget.obscureText);

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
  void didUpdateWidget(NebaTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_handleText);

      final TextEditingController? previous = oldWidget.controller;

      if (widget.controller == null && previous != null) {
        // Handed back to itself, the field carries on with the text it had.
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
    _length = widget.maxLength == null ? 0 : text.characters.length;
  }

  /// Rebuilds the field only when what it draws from the text changes: whether
  /// there is any, and how much of the most it takes.
  void _handleText() {
    final String text = _controller.text;
    final bool empty = text.isEmpty;
    final int length = widget.maxLength == null ? 0 : text.characters.length;

    if (empty == _empty && length == _length) {
      return;
    }

    // A controller can be written to while the caller builds.
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
    final bool disabled = widget.disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool lit = !disabled && !readOnly;
    final bool invalid = widget.invalid ?? widget.error != null;
    // Invalid repoints the whole family at danger, so the edge, the ring, the
    // caret and the message turn over together.
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final Widget? label = widget.label;
    // A label on the edge takes the edge over from the shell; with no label
    // there is nothing to cut a notch for.
    final bool notched = label != null && placement != NebaLabelPlacement.top;
    final bool rests = notched && placement == NebaLabelPlacement.float && widget.startIcon == null;
    final double restEnd = nebaNotchRestEnd(
      size,
      widget.loading || widget.endIcon != null ? const <double>[1.2] : const <double>[],
    );
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: label,
      description: widget.description,
      error: widget.error,
      placeholder: widget.placeholder,
    );

    final double text = NebaScale.controlText[size]!;
    final TextStyle style = DefaultTextStyle.of(context).style
        .merge(
          TextStyle(
            fontSize: text,
            height: NebaScale.controlLeading[size]! / text,
            leadingDistribution: TextLeadingDistribution.even,
            color: disabled ? tokens.disabledFg : tokens.fg,
          ),
        )
        .merge(widget.style);

    Widget control(bool focused) {
      final int? maxLength = widget.maxLength;
      Widget editable = EditableText(
        key: _editableKey,
        controller: _controller,
        focusNode: _node,
        style: style,
        cursorColor: roles.accent,
        backgroundCursorColor: tokens.mutedFg,
        selectionColor: roles.softPress,
        readOnly: readOnly,
        obscureText: widget.obscureText,
        autocorrect: !widget.obscureText,
        enableSuggestions: !widget.obscureText,
        keyboardType:
            widget.keyboardType ??
            (widget.multiline ? TextInputType.multiline : TextInputType.text),
        textInputAction: widget.textInputAction,
        maxLines: widget.multiline ? null : 1,
        minLines: widget.multiline ? widget.rows : null,
        autofocus: widget.autofocus,
        autofillHints: widget.autofillHints,
        inputFormatters: <TextInputFormatter>[
          ...?widget.inputFormatters,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        // The gestures are the field's, over its whole shell.
        rendererIgnoresPointer: true,
        enableInteractiveSelection: selectionEnabled,
        // No selection handles and no copy-and-paste toolbar: both are drawn
        // by Material or Cupertino, which the package does not import. The
        // pointer and the keyboard still select, and on the web the
        // browser's own menu still copies and pastes.
        selectionControls: null,
      );

      final String? placeholder = widget.placeholder;

      if (placeholder != null && _empty) {
        // Under a float label at rest the placeholder is the label's place,
        // so it shows only once the label has moved up.
        final bool hidden = rests && !focused;

        editable = Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: hidden ? tokens.mutedFg.withValues(alpha: 0) : tokens.mutedFg,
                    ),
                    duration: nebaDuration(context, NebaScale.duration),
                    curve: NebaScale.ease,
                    builder: (BuildContext context, Color? color, Widget? _) {
                      return Text(
                        placeholder,
                        style: style.copyWith(color: color),
                        maxLines: widget.multiline ? null : 1,
                        softWrap: widget.multiline,
                        overflow: widget.multiline ? TextOverflow.clip : TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ),
            editable,
          ],
        );
      }

      if (lit) {
        editable = NebaFieldTypingMark(typing: _typing, child: editable);
      }

      final Map<ShortcutActivator, VoidCallback>? shortcuts = widget.shortcuts;

      if (shortcuts != null && shortcuts.isNotEmpty) {
        editable = CallbackShortcuts(bindings: shortcuts, child: editable);
      }

      return editable;
    }

    Widget content(BuildContext context, bool focused) {
      Widget adornment(Widget child) {
        return NebaFieldAdornment(size: size, focused: focused, accent: roles.accent, child: child);
      }

      final Widget? startIcon = widget.startIcon;
      final Widget? endIcon = widget.endIcon;

      return Row(
        crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        spacing: NebaScale.gap[size]!,
        children: <Widget>[
          if (startIcon != null) adornment(startIcon),
          Expanded(child: control(focused)),
          if (widget.loading)
            adornment(const NebaSpinner())
          else if (endIcon != null)
            adornment(endIcon),
        ],
      );
    }

    final double? firstLine = widget.multiline ? nebaFieldMultilinePad[size] : null;

    Widget shell = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation ?? 0,
      disabled: disabled,
      readOnly: readOnly,
      multiline: widget.multiline,
      typing: lit ? _typing : null,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      notch: notched
          ? NebaFieldNotch(
              label: ExcludeSemantics(excluding: semantics.labelTaken, child: label),
              rests: rests,
              empty: _empty,
              firstLine: firstLine,
              restEnd: restEnd,
            )
          : null,
      builder: content,
    );

    shell = disabled
        ? ExcludeFocus(child: shell)
        // A press anywhere on the shell, padding included, puts the caret in
        // the field, and a press on the shell is not a press outside it.
        : TextFieldTapRegion(
            child: _gestures.buildGestureDetector(
              behavior: HitTestBehavior.translucent,
              child: shell,
            ),
          );

    final int? maxLength = widget.maxLength;

    // One node for the whole column. The text field's own flags and actions
    // come up from the editable and merge into it, so nothing here repeats
    // them: a flag or an action set twice splits the node in two.
    return Semantics(
      container: true,
      label: semantics.label,
      hint: semantics.hint,
      enabled: !disabled,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      maxValueLength: maxLength,
      currentValueLength: maxLength == null ? null : _length,
      onTap: disabled ? null : _requestFocus,
      child: NebaFieldWidth(
        width: nebaFieldWidth(size, density),
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

/// The gestures of an [EditableText] in the widgets layer, without the
/// selection toolbar.
///
/// Two of the stock gestures show the toolbar, and an editable builds the
/// overlay it would draw that toolbar in when a selection lands on it before
/// it has the focus. An overlay needs an `Overlay` above it, which a bare
/// `WidgetsApp` and a widget test do not have. So these gestures put the focus
/// in the field before they move the selection, and never ask for a toolbar.
class _FieldGestures extends TextSelectionGestureDetectorBuilder {
  _FieldGestures({required super.delegate});

  /// Puts the focus in the field now rather than at the end of the event.
  void _focus() {
    final EditableTextState? editable = delegate.editableTextKey.currentState;

    if (editable != null && !editable.widget.focusNode.hasFocus) {
      editable.requestKeyboard();
      FocusManager.instance.applyFocusChangesIfNeeded();
    }
  }

  @override
  void onTapDown(TapDragDownDetails details) {
    switch (defaultTargetPlatform) {
      // On a desktop the caret lands on the press.
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        _focus();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        break;
    }

    super.onTapDown(details);
  }

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    if (delegate.selectionEnabled) {
      switch (defaultTargetPlatform) {
        // On a touch screen the caret lands on the release.
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          _focus();
          renderEditable.selectPosition(cause: SelectionChangedCause.tap);
        case TargetPlatform.iOS:
          _focus();
          switch (details.kind) {
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              renderEditable.selectPosition(cause: SelectionChangedCause.tap);
          }
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          break;
      }
    }

    editableText.requestKeyboard();
  }

  @override
  void onSecondaryTap() {
    // There is no context menu to open, so a secondary press only focuses.
    _focus();
  }

  @override
  void onDoubleTapDown(TapDragDownDetails details) {
    _focus();
    super.onDoubleTapDown(details);
  }

  @override
  void onDragSelectionStart(TapDragStartDetails details) {
    _focus();
    super.onDragSelectionStart(details);
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    _focus();
    super.onSingleLongTapStart(details);
  }
}
