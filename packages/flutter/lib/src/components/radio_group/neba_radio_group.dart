/// `NebaRadioGroup` and `NebaRadio`, a set of options where exactly one is
/// chosen.
library;

import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The parts of a group's label, description and error, at a fixed step
/// apart, CSS `gap-1.5`.
const double _groupGap = 6;

/// A set of options where exactly one is chosen, generic over the type of an
/// option's `value`.
///
/// The set is one stop in the focus order: Tab reaches the chosen option, or
/// the first one when none is chosen, and the arrow keys move between the
/// options and choose as they go, wrapping at the ends and passing over a
/// disabled one. A screen reader hears a radio group named by [label].
///
/// Controlled with [value] and [onValueChange], or left to keep its own state
/// from [defaultValue]. [size], [color] and [readOnly] belong to the set, and
/// a `NebaRadio` has no size or colour of its own; [disabled] and an invalid
/// state reach every option.
///
/// ```dart
/// NebaRadioGroup<String>(
///   label: const Text('Plan'),
///   value: plan,
///   onValueChange: (String? next) => setState(() => plan = next),
///   children: const <Widget>[
///     NebaRadio<String>(value: 'starter', label: Text('Starter')),
///     NebaRadio<String>(value: 'team', label: Text('Team')),
///   ],
/// )
/// ```
class NebaRadioGroup<T> extends StatefulWidget {
  /// A set of [children].
  const NebaRadioGroup({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
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

  /// The options, each a `NebaRadio` with a `value`, laid out in a column or a
  /// row. An option may also sit further down, inside a widget of the
  /// caller's.
  final List<Widget> children;

  /// The chosen option's value, for a controlled group. Leave it `null` and
  /// the group keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which option starts chosen, for an uncontrolled group.
  final T? defaultValue;

  /// Called with the value of the option that was chosen.
  final ValueChanged<T?>? onValueChange;

  /// The question the options answer, usually a [Text]. It names the group
  /// for a screen reader.
  final Widget? label;

  /// Helper text between the label and the options.
  final Widget? description;

  /// The error under the options. Given, it also turns the group invalid.
  final Widget? error;

  /// Whether the group is invalid, for when something else owns the validity.
  /// Defaults to whether there is an [error].
  final bool? invalid;

  /// The size of every option, and the type of the label, the description
  /// and the error. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of every option. Defaults to [NebaColor.primary]; an
  /// invalid group is [NebaColor.danger].
  final NebaColor? color;

  /// Which way the options run: a column, or a row that wraps.
  final NebaOrientation orientation;

  /// The gap between the options on the spacing scale, `3` being 12 logical
  /// pixels, one length on both axes. Left out, a column follows [size] and a
  /// row keeps 20 pixels along it. `NebaProvider`'s spacing does not reach
  /// it, since that is the gap between separate fields.
  final double? spacing;

  /// Disables every option and takes the set out of the focus order.
  final bool disabled;

  /// Shows which option is chosen without letting it change, unless an
  /// option says otherwise. The arrow keys still move between the options.
  final bool readOnly;

  /// What a screen reader calls a group with no label.
  final String? semanticLabel;

  @override
  State<NebaRadioGroup<T>> createState() => _NebaRadioGroupState<T>();
}

/// What the group knows of one option: its value and whether it can take the
/// focus.
class _Option<T> {
  _Option(this.value, {required this.enabled, required this.readOnly});

  T value;
  bool enabled;
  bool readOnly;
}

class _NebaRadioGroupState<T> extends State<NebaRadioGroup<T>> {
  late T? _value = widget.defaultValue;

  /// Every option, by its focus node. Read when a key is pressed and when the
  /// focus order is worked out, so it changes without a rebuild.
  final Map<FocusNode, _Option<T>> _options = <FocusNode, _Option<T>>{};

  late final _OneStopPolicy<T> _policy = _OneStopPolicy<T>(this);

  T? get _current => widget.value ?? _value;

  void _choose(T value) {
    if (widget.disabled || value == _current) {
      return;
    }

    if (widget.value == null) {
      setState(() => _value = value);
    }

    widget.onValueChange?.call(value);
  }

  void _register(FocusNode node, T value, {required bool enabled, required bool readOnly}) {
    final _Option<T>? option = _options[node];

    if (option == null) {
      _options[node] = _Option<T>(value, enabled: enabled, readOnly: readOnly);
    } else {
      option
        ..value = value
        ..enabled = enabled
        ..readOnly = readOnly;
    }
  }

  void _unregister(FocusNode node) {
    _options.remove(node);
  }

  /// The options that can take the focus, in reading order.
  List<FocusNode> get _ordered {
    return ReadingOrderTraversalPolicy.sort(<FocusNode>[
      for (final MapEntry<FocusNode, _Option<T>> entry in _options.entries)
        if (entry.value.enabled && entry.key.context != null) entry.key,
    ]).toList();
  }

  /// The set's one stop in the focus order among [candidates]: the option
  /// holding the focus, then the chosen one, then the first in reading order.
  FocusNode? _stopAmong(Iterable<FocusNode> candidates) {
    final List<FocusNode> options = <FocusNode>[
      for (final FocusNode node in candidates)
        if (_options[node]?.enabled ?? false) node,
    ];

    for (final FocusNode node in options) {
      if (node.hasFocus) {
        return node;
      }
    }

    final T? current = _current;

    for (final FocusNode node in options) {
      if (current != null && _options[node]!.value == current) {
        return node;
      }
    }

    return options.isEmpty ? null : ReadingOrderTraversalPolicy.sort(options).first;
  }

  /// The arrow keys, as a radio group takes them: the next or the previous
  /// option that can take the focus, wrapping at the ends, chosen as the
  /// focus lands on it unless it is read-only.
  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final int? direction = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowDown => 1,
      LogicalKeyboardKey.arrowUp => -1,
      _ => null,
    };

    if (direction == null) {
      return KeyEventResult.ignored;
    }

    final List<FocusNode> ordered = _ordered;
    final int at = ordered.indexWhere((FocusNode node) => node.hasPrimaryFocus);

    if (at < 0) {
      return KeyEventResult.ignored;
    }

    final FocusNode next = ordered[(at + direction) % ordered.length];
    final _Option<T> option = _options[next]!;

    next.requestFocus();

    if (!option.readOnly) {
      _choose(option.value);
    }

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final bool invalid = widget.invalid ?? widget.error != null;
    // Invalid repoints every option at danger with the message.
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );

    return _RadioGroupScope<T>(
      value: _current,
      size: size,
      roles: roles,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      choose: _choose,
      register: _register,
      unregister: _unregister,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.radioGroup,
        label: semantics.label,
        hint: semantics.hint,
        validationResult: invalid
            ? ui.SemanticsValidationResult.invalid
            : ui.SemanticsValidationResult.none,
        child: IntrinsicWidth(
          child: NebaFieldColumn(
            size: size,
            semantics: semantics,
            errorColor: roles.accent,
            disabled: widget.disabled,
            label: widget.label,
            description: widget.description,
            error: widget.error,
            descriptionFirst: true,
            spacing: _groupGap,
            field: FocusTraversalGroup(
              policy: _policy,
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                includeSemantics: false,
                onKeyEvent: _handleKey,
                child: NebaChoiceOptions(
                  size: size,
                  orientation: widget.orientation,
                  spacing: widget.spacing,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The focus order inside a radio group: reading order, with every option
/// left out but the one the set stops at.
class _OneStopPolicy<T> extends ReadingOrderTraversalPolicy {
  _OneStopPolicy(this.group);

  final _NebaRadioGroupState<T> group;

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    final FocusNode? stop = group._stopAmong(descendants);
    final Iterable<FocusNode> kept = descendants.where((FocusNode node) {
      return !group._options.containsKey(node) || node == stop || node == currentNode;
    });

    return super.sortDescendants(kept, currentNode);
  }
}

/// One option in a [NebaRadioGroup].
///
/// It has no size and no colour of its own: both belong to the group, which
/// is the one place they can be set once and mean the same thing for every
/// option. Its ring fills with the group's colour family when it is chosen,
/// and a dot grows into it from nothing. A press on the label chooses it.
class NebaRadio<T> extends StatefulWidget {
  /// An option named [value], labelled [label].
  const NebaRadio({
    required this.value,
    this.label,
    this.description,
    this.disabled = false,
    this.readOnly,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// What names the option, and what `onValueChange` reports when it is
  /// chosen.
  final T value;

  /// The text beside the ring, usually a [Text]. A screen reader hears it as
  /// the option's name.
  final Widget? label;

  /// Helper text under the label. However many lines it takes, the ring stays
  /// on the label's first line.
  final Widget? description;

  /// Unavailable, but still part of the set: neutral grey, out of the focus
  /// order and passed over by the arrow keys. A disabled group disables it
  /// whatever this says.
  final bool disabled;

  /// Shows whether it is chosen without letting a press change it. Defaults
  /// to the group's.
  final bool? readOnly;

  /// What a screen reader calls an option with no label.
  final String? semanticLabel;

  /// The ring's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the option takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaRadio<T>> createState() => _NebaRadioState<T>();
}

class _NebaRadioState<T> extends State<NebaRadio<T>> {
  FocusNode? _ownNode;
  _RadioGroupScope<T>? _group;
  FocusNode? _registered;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaRadio'));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(NebaRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register();
  }

  @override
  void dispose() {
    _unregister();
    _ownNode?.dispose();
    super.dispose();
  }

  /// Hands the group this option's focus node, so the arrow keys and the
  /// focus order can reach it.
  void _register() {
    final _RadioGroupScope<T>? group = _RadioGroupScope.maybeOf<T>(context);

    if (group != _group || _node != _registered) {
      _unregister();
    }

    if (group == null) {
      return;
    }

    final bool disabled = widget.disabled || group.disabled;

    _group = group;
    _registered = _node;
    group.register(
      _node,
      widget.value,
      enabled: !disabled,
      readOnly: widget.readOnly ?? group.readOnly,
    );
  }

  void _unregister() {
    final FocusNode? node = _registered;

    if (node != null) {
      _group?.unregister(node);
    }

    _group = null;
    _registered = null;
  }

  void _choose() {
    final _RadioGroupScope<T>? group = context.getInheritedWidgetOfExactType<_RadioGroupScope<T>>();

    if (group == null || widget.disabled || group.disabled || (widget.readOnly ?? group.readOnly)) {
      return;
    }

    group.choose(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final _RadioGroupScope<T>? scope = _RadioGroupScope.maybeOf<T>(context);

    assert(() {
      if (scope == null) {
        throw FlutterError(
          'A NebaRadio<$T> was built outside a NebaRadioGroup<$T>.\n'
          'An option draws itself from the set it is in, so it has to be inside a '
          'NebaRadioGroup with the same value type.',
        );
      }
      return true;
    }());

    final _RadioGroupScope<T> group = scope!;
    final NebaSize size = group.size;
    final bool disabled = widget.disabled || group.disabled;
    final bool readOnly = !disabled && (widget.readOnly ?? group.readOnly);
    final bool chosen = group.value == widget.value;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
    );

    final Widget ring = NebaTick(
      size: size,
      // Round, and the one control in the library that may be: roundness is
      // what says "one of these" rather than "any of these".
      borderRadius: const BorderRadius.all(Radius.circular(9999)),
      roles: group.roles,
      marked: chosen,
      disabled: disabled,
      readOnly: readOnly,
      onToggle: _choose,
      focusNode: _node,
      autofocus: widget.autofocus,
      mark: NebaTickDot(size: size, shown: chosen),
    );

    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: chosen,
      enabled: !disabled,
      readOnly: readOnly,
      label: semantics.label,
      hint: semantics.hint,
      child: NebaChoiceField(
        size: size,
        control: ring,
        controlHeight: NebaScale.tickSize[size]!,
        semantics: semantics,
        errorColor: group.roles.accent,
        label: widget.label,
        description: widget.description,
        disabled: disabled,
        onLabelTap: _choose,
      ),
    );
  }
}

/// What a radio group tells its options: which value is chosen, the set's
/// size, family and state, and how to choose and to be reached by the keys.
class _RadioGroupScope<T> extends InheritedWidget {
  const _RadioGroupScope({
    required this.value,
    required this.size,
    required this.roles,
    required this.disabled,
    required this.readOnly,
    required this.choose,
    required this.register,
    required this.unregister,
    required super.child,
  });

  final T? value;
  final NebaSize size;
  final NebaColorRoles roles;
  final bool disabled;
  final bool readOnly;
  final void Function(T value) choose;
  final void Function(FocusNode node, T value, {required bool enabled, required bool readOnly})
  register;
  final void Function(FocusNode node) unregister;

  static _RadioGroupScope<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(_RadioGroupScope<T> oldWidget) {
    return value != oldWidget.value ||
        size != oldWidget.size ||
        roles != oldWidget.roles ||
        disabled != oldWidget.disabled ||
        readOnly != oldWidget.readOnly ||
        choose != oldWidget.choose;
  }
}
