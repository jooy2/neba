/// What a checkbox takes from the checkbox group around it: the React
/// package's `src/internal/checkbox-group.ts`, and the value Base UI's group
/// keeps, in Dart.
///
/// Here rather than in either folder so that a checkbox reads it without the
/// two widgets importing each other, as a button reads its group's scope.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/types.dart';

/// The state a checkbox group hands its checkboxes.
///
/// Unlike a button group's scope every value here is settled: the group has
/// already resolved each of them. A checkbox's own argument still wins over
/// [size], [color] and [readOnly]; [invalid] and [disabled] win over the
/// checkbox instead, because a question answered wrongly is wrong in every
/// option and a disabled set cannot hold an option that answers.
class NebaCheckboxGroupScope extends InheritedWidget {
  /// The group's state for [child].
  const NebaCheckboxGroupScope({
    required this.size,
    required this.color,
    required this.invalid,
    required this.disabled,
    required this.readOnly,
    required this.value,
    required this.allValues,
    required this.onToggle,
    required this.onParentToggle,
    required this.register,
    required this.unregister,
    required super.child,
    super.key,
  });

  /// The size of every checkbox that does not set its own.
  final NebaSize size;

  /// The colour family of every checkbox that does not set its own.
  final NebaColor color;

  /// Whether the set is invalid, which turns every checkbox in it to
  /// `danger`.
  final bool invalid;

  /// Whether the set is disabled, which disables every checkbox in it.
  final bool disabled;

  /// Whether every checkbox that does not say otherwise is read-only.
  final bool readOnly;

  /// The values of the ticked checkboxes.
  final List<String> value;

  /// The value of every option, when the set has a parent checkbox that
  /// answers for all of them.
  final List<String>? allValues;

  /// Ticks or clears the checkbox with [value].
  final void Function(String value, bool checked) onToggle;

  /// What a press on the parent checkbox does.
  final VoidCallback onParentToggle;

  /// Tells the set whether the option with [value] is disabled, which the
  /// parent checkbox leaves as it is.
  final void Function(String value, {required bool disabled}) register;

  /// Forgets the option with [value].
  final void Function(String value) unregister;

  /// Whether the parent checkbox is ticked: every option is.
  bool get parentChecked {
    final List<String>? all = allValues;

    return all != null && value.length == all.length;
  }

  /// Whether the parent checkbox is half-ticked: some options are and some
  /// are not.
  bool get parentIndeterminate {
    final List<String>? all = allValues;

    return all != null && value.isNotEmpty && value.length != all.length;
  }

  /// The group around [context], or `null` when there is none.
  static NebaCheckboxGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaCheckboxGroupScope>();
  }

  @override
  bool updateShouldNotify(NebaCheckboxGroupScope oldWidget) {
    return size != oldWidget.size ||
        color != oldWidget.color ||
        invalid != oldWidget.invalid ||
        disabled != oldWidget.disabled ||
        readOnly != oldWidget.readOnly ||
        !listEquals(value, oldWidget.value) ||
        !listEquals(allValues, oldWidget.allValues) ||
        onToggle != oldWidget.onToggle ||
        onParentToggle != oldWidget.onParentToggle;
  }
}
