/// `NebaCheckboxGroup`, a set of checkboxes that answer one question.
library;

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/checkbox_group.dart';
import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The parts of a group's label, description and error, at a fixed step
/// apart, CSS `gap-1.5`.
const double _groupGap = 6;

/// Where a parent checkbox is in its cycle, once a press on it has left the
/// options somewhere other than all ticked or all clear.
enum _ParentStatus { mixed, on, off }

/// A set of checkboxes that answer one question, any number of them at once.
///
/// The group owns one value for the set, a list of the ticked checkboxes'
/// `value`s, controlled with [value] and [onValueChange] or kept from
/// [defaultValue]. It names the question with [label], describes it with
/// [description] and shows [error] under the set. [size], [color] and
/// [readOnly] reach every `NebaCheckbox` inside that does not set its own, and
/// [disabled] and an invalid state reach all of them.
///
/// With [allValues] naming every option, the `NebaCheckbox` with `parent` ticks
/// them all at once and draws a dash while only some are ticked. Pressed from
/// that state it ticks every option, then clears them, then brings back the
/// mix the reader had made; a disabled option keeps its state throughout.
///
/// ```dart
/// NebaCheckboxGroup(
///   label: const Text('Email me about'),
///   defaultValue: const <String>['deploys'],
///   children: const <Widget>[
///     NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
///     NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
///   ],
/// )
/// ```
class NebaCheckboxGroup extends StatefulWidget {
  /// A set of [children].
  const NebaCheckboxGroup({
    required this.children,
    this.value,
    this.defaultValue = const <String>[],
    this.onValueChange,
    this.allValues,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.size,
    this.color,
    this.orientation = NebaOrientation.vertical,
    this.spacing,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    super.key,
  });

  /// The checkboxes, each with a `value`, laid out in a column or a row. A
  /// checkbox may also sit further down, inside a widget of the caller's.
  final List<Widget> children;

  /// The values of the ticked checkboxes, for a controlled group. Leave it
  /// `null` and the group keeps its own state, starting from [defaultValue].
  final List<String>? value;

  /// The values ticked at first, for an uncontrolled group.
  final List<String> defaultValue;

  /// Called with the new list when a checkbox is ticked or cleared. A newly
  /// ticked value goes on the end.
  final ValueChanged<List<String>>? onValueChange;

  /// The value of every checkbox in the group, which makes the `NebaCheckbox`
  /// with `parent` the one that ticks them all.
  final List<String>? allValues;

  /// The question the checkboxes answer, usually a [Text]. It names the group
  /// for a screen reader.
  final Widget? label;

  /// Helper text between the label and the checkboxes.
  final Widget? description;

  /// The error under the checkboxes. Given, it also turns the group invalid.
  final Widget? error;

  /// Whether the group is invalid, for when something else owns the validity.
  /// Defaults to whether there is an [error].
  final bool? invalid;

  /// The size of every checkbox that does not set its own, and the type of
  /// the label, the description and the error. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of every checkbox that does not set its own. Defaults
  /// to [NebaColor.primary].
  final NebaColor? color;

  /// Which way the checkboxes run: a column, or a row that wraps.
  final NebaOrientation orientation;

  /// The gap between the checkboxes on the spacing scale, `3` being 12
  /// logical pixels, one length on both axes. Left out, a column follows
  /// [size] and a row keeps 20 pixels along it. `NebaProvider`'s spacing does
  /// not reach it, since that is the gap between separate fields.
  final double? spacing;

  /// Disables every checkbox in the group.
  final bool disabled;

  /// Shows every checkbox's state without letting it change, unless a
  /// checkbox says otherwise.
  final bool readOnly;

  /// What a screen reader calls a group with no label.
  final String? semanticLabel;

  @override
  State<NebaCheckboxGroup> createState() => _NebaCheckboxGroupState();
}

class _NebaCheckboxGroupState extends State<NebaCheckboxGroup> {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _setDisabled => nebaFieldsetDisabled(context, widget.disabled);

  late List<String> _value = List<String>.of(widget.defaultValue);

  /// The options the reader last left, by ticking them one at a time, which
  /// a parent checkbox comes back to after ticking and clearing them all.
  late List<String> _remembered = List<String>.of(widget.value ?? widget.defaultValue);
  _ParentStatus _status = _ParentStatus.mixed;

  /// Whether each option is disabled, by its value. Read only when the parent
  /// is pressed, so it changes without a rebuild.
  final Map<String, bool> _disabled = <String, bool>{};

  List<String> get _current => widget.value ?? _value;

  void _commit(List<String> next) {
    if (widget.value == null) {
      setState(() => _value = next);
    }

    widget.onValueChange?.call(next);
  }

  void _toggle(String value, bool checked) {
    final List<String> current = _current;
    final List<String> next = <String>[
      ...current.where((String v) => v != value),
      if (checked) value,
    ];

    _remembered = next;
    _status = _ParentStatus.mixed;
    _commit(next);
  }

  /// A press on the parent checkbox.
  ///
  /// From all ticked or all clear it flips between the two. From a mix it
  /// ticks everything, then clears everything, then brings the mix back. An
  /// option that is disabled stays as it was: "all" is every option that is
  /// not disabled and every disabled one that was ticked, and "none" the
  /// disabled ones that were ticked.
  void _toggleParent() {
    final List<String> everything = widget.allValues ?? const <String>[];
    final List<String> remembered = _remembered;
    bool off(String value) => _disabled[value] ?? false;

    final List<String> all = <String>[
      for (final String value in everything)
        if (!off(value) || remembered.contains(value)) value,
    ];
    final List<String> none = <String>[
      for (final String value in everything)
        if (off(value) && remembered.contains(value)) value,
    ];

    if (remembered.length == all.length || remembered.isEmpty) {
      _commit(_current.length == all.length ? none : all);
      return;
    }

    switch (_status) {
      case _ParentStatus.mixed:
        _status = _ParentStatus.on;
        _commit(all);
      case _ParentStatus.on:
        _status = _ParentStatus.off;
        _commit(none);
      case _ParentStatus.off:
        _status = _ParentStatus.mixed;
        _commit(List<String>.of(remembered));
    }
  }

  void _register(String value, {required bool disabled}) {
    _disabled[value] = disabled;
  }

  void _unregister(String value) {
    _disabled.remove(value);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColorRoles roles = tokens.roles(invalid ? NebaColor.danger : color);
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );

    return NebaCheckboxGroupScope(
      size: size,
      color: color,
      invalid: invalid,
      disabled: _setDisabled,
      readOnly: widget.readOnly,
      value: _current,
      allValues: widget.allValues,
      onToggle: _toggle,
      onParentToggle: _toggleParent,
      register: _register,
      unregister: _unregister,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semantics.label,
        hint: semantics.hint,
        validationResult: invalid
            ? ui.SemanticsValidationResult.invalid
            : ui.SemanticsValidationResult.none,
        // As wide as the widest of its parts, or the width it is given when
        // that is set, as a block flex column is.
        child: IntrinsicWidth(
          child: NebaFieldColumn(
            size: size,
            semantics: semantics,
            errorColor: roles.accent,
            disabled: _setDisabled,
            label: widget.label,
            description: widget.description,
            error: widget.error,
            descriptionFirst: true,
            spacing: _groupGap,
            field: NebaChoiceOptions(
              size: size,
              orientation: widget.orientation,
              spacing: widget.spacing,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
