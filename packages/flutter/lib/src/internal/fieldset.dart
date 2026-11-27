/// Whether a `NebaFieldset` around a control is disabled: the React
/// package's `src/internal/fieldset.ts`, in Dart.
///
/// A `<fieldset disabled>` stops every control inside it answering, which the
/// browser does on its own; a widget tree has no such thing, so every control
/// that a fieldset reaches reads this scope and ORs it into its own
/// `disabled`, and is then drawn disabled and takes no input, as it would be
/// with its own argument set.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// Whether the controls below are inside a disabled fieldset.
class NebaFieldsetScope extends InheritedWidget {
  /// Disables every control in [child] that reads it, when [disabled].
  const NebaFieldsetScope({required this.disabled, required super.child, super.key});

  /// Whether the fieldset is disabled, its own argument or one around it.
  final bool disabled;

  /// Whether a fieldset around [context] is disabled, `false` outside one.
  static bool disabledOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaFieldsetScope>()?.disabled ?? false;
  }

  @override
  bool updateShouldNotify(NebaFieldsetScope oldWidget) => disabled != oldWidget.disabled;
}

/// A control's own [disabled], or the fieldset's around it.
///
/// React's `useFieldsetDisabled`: the fieldset wins over a control's own
/// `false`, as a browser disables every control inside a disabled
/// `<fieldset>` whatever it says itself.
bool nebaFieldsetDisabled(BuildContext context, bool? disabled) {
  return NebaFieldsetScope.disabledOf(context) || disabled == true;
}
