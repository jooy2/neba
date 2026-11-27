/// `NebaToggleGroup`, a set of toggles that share one state.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/toggle/neba_toggle.dart';
import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A set of toggles that share one state.
///
/// The corners that face a neighbour are squared off, as in a
/// `NebaButtonGroup`, and the set owns the value: each `NebaToggle` names
/// itself with its `value`, [multiple] decides whether more than one can be on,
/// and [variant], [size], [color], [density], [elevation] and [disabled] are
/// set once for the set. The whole set is one stop in the focus order, and the
/// arrow keys move between its toggles.
///
/// ```dart
/// NebaToggleGroup(
///   value: alignment,
///   onValueChange: (List<String> next) => setState(() => alignment = next),
///   children: const <Widget>[
///     NebaToggle(value: 'left', child: Text('Left')),
///     NebaToggle(value: 'centre', child: Text('Centre')),
///   ],
/// )
/// ```
class NebaToggleGroup extends StatefulWidget {
  /// A set of [children].
  const NebaToggleGroup({
    required this.children,
    this.value,
    this.defaultValue = const <String>[],
    this.onValueChange,
    this.multiple = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.orientation = NebaOrientation.horizontal,
    this.disabled,
    this.loopFocus = true,
    this.fullWidth = false,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The toggles, each with a `value`.
  final List<Widget> children;

  /// Which toggles are on, by their `value`, for a controlled set. A list in
  /// the single case too, so it does not change type with [multiple].
  final List<String>? value;

  /// Which toggles start on, for an uncontrolled set.
  final List<String> defaultValue;

  /// Called with the values that are on after a toggle is pressed.
  final ValueChanged<List<String>>? onValueChange;

  /// Whether more than one toggle can be on. Off, turning one on turns the
  /// last one off.
  final bool multiple;

  /// The variant of every toggle that does not set its own. Defaults to
  /// `NebaProvider`'s, then to each toggle's own, [NebaVariant.outline].
  final NebaVariant? variant;

  /// The size of every toggle that does not set its own.
  final NebaSize? size;

  /// The colour family of every toggle that does not set its own.
  final NebaColor? color;

  /// The density of every toggle that does not set its own.
  final NebaDensity? density;

  /// The elevation of every toggle that does not set its own.
  final NebaElevation? elevation;

  /// Which way the toggles run, and which arrow keys move between them.
  final NebaOrientation orientation;

  /// Disables every toggle that does not say otherwise.
  final bool? disabled;

  /// Whether the arrow keys wrap around at the ends.
  final bool loopFocus;

  /// Stretches the set to the width it is given and shares it evenly.
  final bool fullWidth;

  /// What a screen reader calls the set.
  final String? semanticLabel;

  @override
  State<NebaToggleGroup> createState() => _NebaToggleGroupState();
}

class _NebaToggleGroupState extends State<NebaToggleGroup> {
  late List<String> _value = List<String>.of(widget.defaultValue);

  /// The focus node of each toggle, by its index, and whether it can take the
  /// focus.
  final Map<int, (FocusNode, bool)> _nodes = <int, (FocusNode, bool)>{};

  /// The toggle the focus was last in, which is the set's stop in the focus
  /// order once there is one.
  int? _active;

  List<String> get _current => widget.value ?? _value;

  void _toggle(String value, bool pressed) {
    final List<String> current = _current;
    final List<String> next = widget.multiple
        ? (pressed
              ? <String>[...current.where((String v) => v != value), value]
              : current.where((String v) => v != value).toList())
        : (pressed ? <String>[value] : <String>[]);

    if (widget.value == null) {
      setState(() => _value = next);
    }

    widget.onValueChange?.call(next);
  }

  void _register(int index, FocusNode node, {required bool enabled}) {
    final (FocusNode, bool)? previous = _nodes[index];

    if (previous?.$1 != node) {
      previous?.$1.removeListener(_handleFocus);
      node.addListener(_handleFocus);
    }

    _nodes[index] = (node, enabled);
  }

  void _unregister(int index, FocusNode node) {
    if (_nodes[index]?.$1 == node) {
      node.removeListener(_handleFocus);
      _nodes.remove(index);
    }
  }

  /// Makes the toggle that took the focus the set's stop in the focus order.
  void _handleFocus() {
    for (final MapEntry<int, (FocusNode, bool)> entry in _nodes.entries) {
      if (entry.value.$1.hasPrimaryFocus && _active != entry.key) {
        // A focus change can land during a build, so the stop moves after it.
        final int index = entry.key;
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          if (mounted) {
            setState(() => _active = index);
          }
        });
        return;
      }
    }
  }

  @override
  void dispose() {
    for (final (FocusNode node, bool _) in _nodes.values) {
      node.removeListener(_handleFocus);
    }
    super.dispose();
  }

  /// The set's one stop in the focus order: the toggle the focus was last in,
  /// then the first one that is on, then the first.
  int get _tabStop {
    final int? active = _active;

    if (active != null && active < widget.children.length) {
      return active;
    }

    for (int i = 0; i < widget.children.length; i++) {
      final Widget child = widget.children[i];

      if (child is NebaToggle && child.value != null && _current.contains(child.value)) {
        return i;
      }
    }

    return 0;
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final bool horizontal = widget.orientation == NebaOrientation.horizontal;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    final int count = widget.children.length;
    int? current;

    for (final MapEntry<int, (FocusNode, bool)> entry in _nodes.entries) {
      if (entry.value.$1.hasPrimaryFocus) {
        current = entry.key;
      }
    }

    if (current == null || count == 0) {
      return KeyEventResult.ignored;
    }

    int? target;

    if (key == LogicalKeyboardKey.home) {
      // The first that can take the focus, and from the far end the last.
      target = _step(1, from: -1, count: count, loop: false);
    } else if (key == LogicalKeyboardKey.end) {
      target = _step(-1, from: count, count: count, loop: false);
    } else {
      final int? direction = switch (key) {
        LogicalKeyboardKey.arrowRight when horizontal => rtl ? -1 : 1,
        LogicalKeyboardKey.arrowLeft when horizontal => rtl ? 1 : -1,
        LogicalKeyboardKey.arrowDown when !horizontal => 1,
        LogicalKeyboardKey.arrowUp when !horizontal => -1,
        _ => null,
      };

      if (direction == null) {
        return KeyEventResult.ignored;
      }

      target = _step(direction, from: current, count: count, loop: widget.loopFocus);
    }

    if (target != null) {
      _nodes[target]!.$1.requestFocus();
      setState(() => _active = target);
    }

    return KeyEventResult.handled;
  }

  /// The next toggle from [from] in [direction] that can take the focus, or
  /// `null` at an end that does not wrap.
  int? _step(int direction, {required int from, required int count, required bool loop}) {
    int index = from;

    for (int tries = 0; tries < count; tries++) {
      index += direction;

      if (index < 0 || index >= count) {
        if (!loop) {
          return null;
        }

        index = (index + count) % count;
      }

      final (FocusNode, bool)? node = _nodes[index];

      if (node != null && node.$2) {
        return index;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant? variant = widget.variant ?? defaults.variant;

    Widget group = NebaButtonGroupScope(
      variant: variant,
      size: widget.size ?? defaults.size,
      color: widget.color,
      density: widget.density ?? defaults.density,
      elevation: widget.elevation,
      disabled: widget.disabled,
      child: NebaToggleGroupScope(
        selected: Set<String>.of(_current),
        onToggle: _toggle,
        tabStop: _tabStop,
        register: _register,
        unregister: _unregister,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleKey,
          child: NebaJoinedRun(
            axis: widget.orientation == NebaOrientation.horizontal
                ? Axis.horizontal
                : Axis.vertical,
            // A toggle's own default is outline, so a set left unset shares its
            // hairlines.
            overlap: (variant ?? NebaVariant.outline) == NebaVariant.outline ? 1 : 0,
            fill: widget.fullWidth,
            children: widget.children,
          ),
        ),
      ),
    );

    if (widget.fullWidth && widget.orientation == NebaOrientation.horizontal) {
      group = SizedBox(width: double.infinity, child: group);
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: group,
    );
  }
}
