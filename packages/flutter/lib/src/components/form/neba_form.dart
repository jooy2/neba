/// `NebaForm` and `NebaFormField`, a form that knows which of its fields is
/// wrong.
library;

import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// When a field of a [NebaForm] decides whether it is valid.
enum NebaFormValidationMode {
  /// On submit, and on every change after the first submit: the only mode
  /// that does not tell somebody their email is wrong while they are still
  /// typing it.
  onSubmit,

  /// When a field loses the focus, and on submit.
  onBlur,

  /// On every change, and on submit.
  onChange,
}

/// What a [NebaFormField] builds its field with.
typedef NebaFormFieldBuilder<T> = Widget Function(NebaFormFieldState<T> field);

/// A form that knows which of its fields is wrong.
///
/// On its own, a column of fields checks nothing and a submit leaves the
/// reader to find the one that is wrong. What a form adds is the part that
/// has to be owned above the fields: [NebaFormState.submit] checks every
/// [NebaFormField] at once, moves the focus to the first that failed, and
/// hands [onSubmit] the values keyed by each field's name only when none did;
/// and [errors] puts a server's answer back on the field it belongs to.
///
/// It is not a form library. There is no schema and no field array here: a
/// project that wants those keeps them and hands the result to [errors].
///
/// The children stand one under the other, stretched to its width, at the
/// gap [size] picks or a [spacing] of its own.
///
/// ```dart
/// final GlobalKey<NebaFormState> form = GlobalKey<NebaFormState>();
///
/// NebaForm(
///   key: form,
///   onSubmit: (Map<String, Object?> values) => save(values),
///   children: <Widget>[
///     NebaFormField<String>(
///       name: 'email',
///       validator: (String? value) => value == null || value.isEmpty ? 'Enter your email.' : null,
///       builder: (NebaFormFieldState<String> field) => NebaTextField(
///         label: const Text('Email'),
///         error: field.error,
///         onChanged: field.didChange,
///       ),
///     ),
///     NebaButton(onPressed: () => form.currentState!.submit(), child: const Text('Sign up')),
///   ],
/// )
/// ```
class NebaForm extends StatefulWidget {
  /// A form around [children].
  const NebaForm({
    this.validationMode = NebaFormValidationMode.onSubmit,
    this.errors,
    this.onSubmit,
    this.size,
    this.spacing,
    this.semanticLabel,
    this.children = const <Widget>[],
    super.key,
  }) : assert(spacing == null || spacing >= 0);

  /// When a field validates: on submit and on every change afterwards, when it
  /// loses the focus, or on every change.
  final NebaFormValidationMode validationMode;

  /// Errors from outside the fields' own validators, a server's or a
  /// schema's, keyed by the name of the field each belongs to. Each is a
  /// `String`, or a `List<String>` drawn one message to a line. They are shown
  /// on that field and cleared as soon as it changes; a new map shows them
  /// again. They do not stop a submit.
  final Map<String, Object>? errors;

  /// Called on a submit when every field is valid, with each field's value
  /// under its name.
  final ValueChanged<Map<String, Object?>>? onSubmit;

  /// The gap between the children when [spacing] is not given. A form is a
  /// stack, and this is which rung of the ladder it stacks on. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The gap between the children on the spacing scale, `5` being 20 logical
  /// pixels. Takes over from the gap [size] picks. Defaults to
  /// `NebaProvider`'s `spacing`.
  final double? spacing;

  /// What a screen reader names the form, React's `aria-label`: worth giving
  /// where a screen holds more than one.
  final String? semanticLabel;

  /// The fields and the button that submits them, one under the other.
  final List<Widget> children;

  /// The state of the form around [context], to [NebaFormState.submit] it
  /// from a button inside it. Fails outside a form.
  static NebaFormState of(BuildContext context) {
    final NebaFormState? form = maybeOf(context);

    assert(form != null, 'NebaForm.of() was called with a context that is not inside a NebaForm.');

    return form!;
  }

  /// The state of the form around [context], or `null` outside one.
  static NebaFormState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<NebaFormState>();
  }

  @override
  State<NebaForm> createState() => NebaFormState();
}

/// What a [NebaForm] keeps, and the way to submit it.
class NebaFormState extends State<NebaForm> {
  final Set<NebaFormFieldState<Object?>> _fields = <NebaFormFieldState<Object?>>{};

  /// The names whose field changed since [NebaForm.errors] was last handed
  /// over, whose error from outside is gone.
  final Set<String> _cleared = <String>{};

  int _submits = 0;
  int _generation = 0;

  @override
  void didUpdateWidget(NebaForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(widget.errors, oldWidget.errors)) {
      _cleared.clear();
      _generation += 1;
    } else if (widget.validationMode != oldWidget.validationMode) {
      _generation += 1;
    }
  }

  /// Checks every field, moves the focus to the first that failed and, when
  /// none did, calls [NebaForm.onSubmit] with the values. Returns whether the
  /// form was valid.
  ///
  /// A field that is disabled, or inside a disabled `NebaFieldset`, is left
  /// out, as a browser leaves a disabled control out of a form.
  bool submit() {
    _submits += 1;

    final List<NebaFormFieldState<Object?>> fields = _ordered();
    NebaFormFieldState<Object?>? first;

    for (final NebaFormFieldState<Object?> field in fields) {
      if (!field.validate()) {
        first ??= field;
      }
    }

    if (first != null) {
      // The first that failed and can take the focus, in the order the
      // fields stand in.
      for (final NebaFormFieldState<Object?> field in fields) {
        if (field.invalid && field._focus()) {
          break;
        }
      }

      return false;
    }

    widget.onSubmit?.call(values);

    return true;
  }

  /// Every field's value under its name, in the order the fields stand in,
  /// leaving out a disabled one.
  Map<String, Object?> get values {
    return <String, Object?>{
      for (final NebaFormFieldState<Object?> field in _ordered())
        if (field._takesPart) field.widget.name: field.value,
    };
  }

  /// The registered fields in the order they stand in the tree, which is the
  /// order a reader meets them in, rather than the order they arrived in.
  List<NebaFormFieldState<Object?>> _ordered() {
    final List<NebaFormFieldState<Object?>> found = <NebaFormFieldState<Object?>>[];

    void visit(Element element) {
      if (element is StatefulElement) {
        final State<StatefulWidget> state = element.state;

        if (state is NebaFormFieldState<Object?> && _fields.contains(state)) {
          found.add(state);
        }
      }

      element.visitChildren(visit);
    }

    context.visitChildElements(visit);

    return found;
  }

  bool get _validatesOnChange {
    return switch (widget.validationMode) {
      NebaFormValidationMode.onChange => true,
      NebaFormValidationMode.onSubmit => _submits > 0,
      NebaFormValidationMode.onBlur => false,
    };
  }

  /// The error from outside for [name], as one message to a line, or `null`.
  String? _errorFor(String name) {
    if (_cleared.contains(name)) {
      return null;
    }

    final Object? error = widget.errors?[name];

    return switch (error) {
      final String message when message.isNotEmpty => message,
      final List<Object?> messages when messages.isNotEmpty => messages.join('\n'),
      _ => null,
    };
  }

  /// A field changed, which takes its error from outside away.
  void _changed(String name) {
    if (_errorFor(name) != null) {
      setState(() {
        _cleared.add(name);
        _generation += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final double? spacing = widget.spacing ?? defaults.spacing;

    return _NebaFormScope(
      form: this,
      generation: _generation,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.form,
        label: widget.semanticLabel,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing == null
              ? NebaScale.sheetSectionGap[size]!
              : spacing * NebaScale.spacingUnit,
          children: nebaPresentChildren(context, widget.children),
        ),
      ),
    );
  }
}

/// The form a [NebaFormField] registers with, and when its errors changed.
class _NebaFormScope extends InheritedWidget {
  const _NebaFormScope({required this.form, required this.generation, required super.child});

  final NebaFormState form;

  final int generation;

  @override
  bool updateShouldNotify(_NebaFormScope oldWidget) {
    return form != oldWidget.form || generation != oldWidget.generation;
  }
}

/// One field of a [NebaForm]: what names it, holds its value and checks it.
///
/// The field itself is whatever [builder] builds, a `NebaTextField`, a
/// `NebaSelect` or a widget of the caller's, handed this field's [NebaFormFieldState]
/// to take its `error` from and to report each change to through
/// [NebaFormFieldState.didChange]. Flutter's own `FormField` takes the same
/// shape; a Neba field has no `name` and no constraint of its own to check.
///
/// ```dart
/// NebaFormField<String>(
///   name: 'email',
///   validator: (String? value) => value == null || value.isEmpty ? 'Enter your email.' : null,
///   builder: (NebaFormFieldState<String> field) => NebaTextField(
///     label: const Text('Email'),
///     error: field.error,
///     onChanged: field.didChange,
///   ),
/// )
/// ```
class NebaFormField<T> extends StatefulWidget {
  /// A field named [name], built by [builder].
  const NebaFormField({
    required this.name,
    required this.builder,
    this.initialValue,
    this.validator,
    this.disabled = false,
    super.key,
  });

  /// What identifies the field: the key of its value in what
  /// [NebaForm.onSubmit] is handed, and of its error in [NebaForm.errors].
  final String name;

  /// Builds the field from this one's state.
  final NebaFormFieldBuilder<T> builder;

  /// The value the field starts with, which the field it builds should start
  /// from too.
  final T? initialValue;

  /// Checks the value: a message saying what is wrong, or `null` when it is
  /// valid. Flutter has no browser to check a `required` or a `type="email"`,
  /// so every rule and its words are this function's.
  final FormFieldValidator<T>? validator;

  /// Leaves the field out of the form: not checked, not in the values, and
  /// showing no error, as a browser leaves a disabled control out. A disabled
  /// `NebaFieldset` around it does the same.
  final bool disabled;

  @override
  State<NebaFormField<T>> createState() => NebaFormFieldState<T>();
}

/// What a [NebaFormField] holds: its value, its error and the way to change
/// the first.
class NebaFormFieldState<T> extends State<NebaFormField<T>> {
  late T? _value = widget.initialValue;
  String? _own;
  NebaFormState? _form;

  /// Around what [NebaFormField.builder] builds, to know when the focus
  /// leaves it and to put the focus in it.
  final FocusNode _node = FocusNode(
    debugLabel: 'NebaFormField',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The field's current value.
  T? get value => _value;

  /// What is wrong with the value, or `null`: the form's error from outside
  /// while there is one, then the validator's.
  String? get errorText {
    if (!_takesPart) {
      return null;
    }

    return _form?._errorFor(widget.name) ?? _own;
  }

  /// [errorText] as a [Text], for the `error` of the field the builder
  /// builds.
  Widget? get error {
    final String? text = errorText;

    return text == null ? null : Text(text);
  }

  /// Whether the field shows an error.
  bool get invalid => errorText != null;

  bool get _takesPart => !widget.disabled && !NebaFieldsetScope.disabledOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final NebaFormState? form = context.dependOnInheritedWidgetOfExactType<_NebaFormScope>()?.form;

    if (form != _form) {
      _form?._fields.remove(this);
      form?._fields.add(this);
      _form = form;
    }
  }

  @override
  void dispose() {
    _form?._fields.remove(this);
    _node.dispose();
    super.dispose();
  }

  /// The field's value changed to [value]: the field it builds reports every
  /// change here, as its `onChanged`.
  void didChange(T? value) {
    setState(() => _value = value);
    _form?._changed(widget.name);

    if (_form?._validatesOnChange ?? false) {
      validate();
    }
  }

  /// Runs the validator and shows what it says. Returns whether the field is
  /// valid; a field left out of the form always is.
  bool validate() {
    if (!_takesPart) {
      return true;
    }

    final String? own = widget.validator?.call(_value);

    if (own != _own) {
      setState(() => _own = own);
    }

    return own == null;
  }

  /// Puts the focus on the first control inside the field that takes it.
  bool _focus() {
    for (final FocusNode node in _node.traversalDescendants) {
      node.requestFocus();

      return true;
    }

    return false;
  }

  void _focusChanged(bool focused) {
    if (!focused && _form?.widget.validationMode == NebaFormValidationMode.onBlur) {
      validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      includeSemantics: false,
      onFocusChange: _focusChanged,
      child: widget.builder(this),
    );
  }
}
