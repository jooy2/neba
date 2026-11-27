/// `NebaCheckbox`, a single yes or no.
library;

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/checkbox_group.dart';
import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A single yes or no, or one answer among several in a `NebaCheckboxGroup`.
///
/// Unticked it is a frosted square with a hairline in the colour family;
/// ticked it fills with the family, and the tick inside is drawn along its own
/// length rather than switched on. [indeterminate] draws a dash for a parent
/// whose children disagree. The label sits beside the square, the description
/// under the label, and the error under both; a press on the label ticks the
/// box.
///
/// Controlled with [checked] and [onCheckedChange], or left to keep its own
/// state from [defaultChecked]. Inside a `NebaCheckboxGroup` the group owns the
/// state and [value] names the checkbox, and [parent] makes it the one that
/// ticks every option at once.
///
/// ```dart
/// NebaCheckbox(
///   label: const Text('Remember me'),
///   checked: remember,
///   onCheckedChange: (bool next) => setState(() => remember = next),
/// )
/// ```
class NebaCheckbox extends StatefulWidget {
  /// A checkbox labelled [label].
  const NebaCheckbox({
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.checked,
    this.defaultChecked = false,
    this.onCheckedChange,
    this.indeterminate = false,
    this.value,
    this.parent = false,
    this.size,
    this.color,
    this.disabled = false,
    this.readOnly,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The text beside the square, usually a [Text]. A press on it ticks the
  /// box, and a screen reader hears it as the checkbox's name.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// The error under the checkbox. Given, it also turns the checkbox invalid.
  final Widget? error;

  /// Whether the checkbox is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Whether it is ticked, for a controlled checkbox. Leave it out and the
  /// checkbox keeps its own state. Inside a `NebaCheckboxGroup` a checkbox
  /// with a [value] is ticked by the group instead.
  final bool? checked;

  /// Whether an uncontrolled checkbox starts ticked.
  final bool defaultChecked;

  /// Called with the new state when the checkbox is ticked or cleared.
  final ValueChanged<bool>? onCheckedChange;

  /// Draws a dash rather than a tick: neither ticked nor clear, for a parent
  /// whose children disagree. It changes only what is drawn, and a press
  /// still reports the opposite of [checked].
  final bool indeterminate;

  /// What names this checkbox inside a `NebaCheckboxGroup`: ticked, it is in
  /// the group's value.
  final String? value;

  /// Makes this the checkbox that ticks every option at once, inside a
  /// `NebaCheckboxGroup` given `allValues`. It draws a dash while only some
  /// options are ticked.
  final bool parent;

  /// The size of the square and the type scale. Defaults to the group's, then
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family it fills with. Defaults to the group's, then
  /// [NebaColor.primary]; an invalid checkbox is [NebaColor.danger].
  final NebaColor? color;

  /// Drops the colour family for neutral grey and takes the checkbox out of
  /// the focus order. A disabled group disables it whatever this says.
  final bool disabled;

  /// Shows the state without letting it change, with the saturation drained.
  /// Defaults to the group's, then `false`.
  final bool? readOnly;

  /// What a screen reader calls a checkbox with no label.
  final String? semanticLabel;

  /// The square's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the checkbox takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaCheckbox> createState() => _NebaCheckboxState();
}

class _NebaCheckboxState extends State<NebaCheckbox> {
  late bool _checked = widget.defaultChecked;
  NebaCheckboxGroupScope? _group;
  String? _registered;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(NebaCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register();
  }

  @override
  void dispose() {
    _unregister();
    super.dispose();
  }

  /// Tells the group whether this option is disabled, which its parent
  /// checkbox reads: a disabled option keeps its state when the parent is
  /// pressed.
  void _register() {
    final NebaCheckboxGroupScope? group = NebaCheckboxGroupScope.maybeOf(context);
    final String? value = widget.parent ? null : widget.value;

    if (group != _group || value != _registered) {
      _unregister();
    }

    if (group == null || value == null) {
      return;
    }

    _group = group;
    _registered = value;
    group.register(value, disabled: widget.disabled || group.disabled);
  }

  void _unregister() {
    final String? value = _registered;

    if (value != null) {
      _group?.unregister(value);
    }

    _group = null;
    _registered = null;
  }

  /// Whether this is the parent of a group with every option named.
  bool _isParent(NebaCheckboxGroupScope? group) {
    return widget.parent && group?.allValues != null;
  }

  /// Whether this is an option whose state the group keeps.
  bool _isOption(NebaCheckboxGroupScope? group) {
    return group != null && !widget.parent && widget.value != null;
  }

  bool _isChecked(NebaCheckboxGroupScope? group) {
    if (_isParent(group)) {
      return group!.parentChecked;
    }

    if (_isOption(group)) {
      return group!.value.contains(widget.value);
    }

    return widget.checked ?? _checked;
  }

  void _toggle() {
    final NebaCheckboxGroupScope? group = context
        .getInheritedWidgetOfExactType<NebaCheckboxGroupScope>();
    final bool disabled = widget.disabled || (group?.disabled ?? false);
    final bool readOnly = widget.readOnly ?? group?.readOnly ?? false;

    if (disabled || readOnly) {
      return;
    }

    final bool next = !_isChecked(group);

    widget.onCheckedChange?.call(next);

    if (_isParent(group)) {
      group!.onParentToggle();
    } else if (_isOption(group)) {
      group!.onToggle(widget.value!, next);
    } else if (widget.checked == null) {
      setState(() => _checked = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaCheckboxGroupScope? group = NebaCheckboxGroupScope.maybeOf(context);
    final NebaSize size = widget.size ?? group?.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? group?.color ?? NebaColor.primary;
    final bool disabled = widget.disabled || (group?.disabled ?? false);
    final bool readOnly = !disabled && (widget.readOnly ?? group?.readOnly ?? false);
    final bool invalid = widget.invalid ?? widget.error != null;
    // Invalid repoints the whole family at danger, so the fill, the ring and
    // the message turn over together; an invalid group turns every option
    // over with it, whatever colour the option asked for.
    final NebaColorRoles roles = tokens.roles(
      invalid || (group?.invalid ?? false) ? NebaColor.danger : color,
    );
    final bool checked = _isChecked(group);
    // The parent's dash follows the group, since nobody passes it the flag.
    final bool indeterminate =
        widget.indeterminate || (_isParent(group) && group!.parentIndeterminate);
    final bool marked = checked || indeterminate;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );

    final Widget tick = NebaTick(
      size: size,
      borderRadius: BorderRadius.circular(NebaScale.tickRadius[size]!),
      roles: roles,
      marked: marked,
      disabled: disabled,
      readOnly: readOnly,
      // A dash holds its fill under the pointer; only a tick deepens.
      hoverMarked: !indeterminate,
      onToggle: _toggle,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mark: NebaTickMark(
        shape: indeterminate
            ? NebaTickMarkShape.dash
            : checked
            ? NebaTickMarkShape.check
            : null,
      ),
    );

    return Semantics(
      container: true,
      checked: checked && !indeterminate,
      mixed: indeterminate,
      enabled: !disabled,
      readOnly: readOnly,
      label: semantics.label,
      hint: semantics.hint,
      validationResult: invalid
          ? ui.SemanticsValidationResult.invalid
          : ui.SemanticsValidationResult.none,
      child: NebaChoiceField(
        size: size,
        control: tick,
        controlHeight: NebaScale.tickSize[size]!,
        semantics: semantics,
        errorColor: roles.accent,
        label: widget.label,
        description: widget.description,
        error: widget.error,
        disabled: disabled,
        onLabelTap: _toggle,
      ),
    );
  }
}
