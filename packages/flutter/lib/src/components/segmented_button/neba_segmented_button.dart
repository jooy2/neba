/// `NebaSegmentedButton` and `NebaSegment`, two or more choices in one pill,
/// exactly one of them taken.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The one fully round shape the set uses, for the trough, the tile and every
/// segment alike: a tile riding in a groove cut into the sheet.
const BorderRadius _round = BorderRadius.all(Radius.circular(9999));

/// The trough's padding around the segments, CSS `p-1`.
const double _troughPadding = 4;

/// Two or more choices in one pill, exactly one of them taken.
///
/// A screen reader hears a radio group: the set is one stop in the focus
/// order, the arrow keys move between its segments and choose as they go, and
/// the segment that is taken is checked. The tile behind the chosen segment
/// slides to the next one when the choice changes, by its rectangle and never
/// by a transform.
///
/// Controlled with [value] and [onValueChange], or left to keep its own state
/// from [defaultValue]. [variant], [size], [color] and [density] belong to the
/// set, so a segment has none of its own.
///
/// ```dart
/// NebaSegmentedButton<String>(
///   semanticLabel: 'Range',
///   value: range,
///   onValueChange: (String? next) => setState(() => range = next),
///   children: const <NebaSegment<String>>[
///     NebaSegment<String>(value: 'day', child: Text('Day')),
///     NebaSegment<String>(value: 'week', child: Text('Week')),
///   ],
/// )
/// ```
class NebaSegmentedButton<T> extends StatefulWidget {
  /// A set of [children], one of which is taken.
  const NebaSegmentedButton({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.disabled = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The segments, each named by its `value`.
  final List<NebaSegment<T>> children;

  /// The chosen segment's value, for a controlled set. Leave it `null` and
  /// the set keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which segment starts chosen, for an uncontrolled set.
  final T? defaultValue;

  /// Called with the value of the segment that was chosen.
  final ValueChanged<T?>? onValueChange;

  /// The weight of the trough the segments sit in: `solid` a frosted trough
  /// with a filled tile riding in it, `outline` the same trough with a
  /// hairline and a lit tile, `text` no trough, with a surface on the chosen
  /// segment alone. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The segments' height and type scale, the ladder `NebaButton` uses.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the trough and the tile. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The segments' inline padding, and nothing else.
  final NebaDensity? density;

  /// The trough's drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// Disables every segment at once and drops the colour family for neutral
  /// grey.
  final bool disabled;

  /// Shows which segment is chosen but does not let it change: the arrow keys
  /// still move between the segments, and the set's saturation is drained.
  final bool readOnly;

  /// Stretches the set to the width it is given and shares it evenly between
  /// the segments, unless a label needs more than its share.
  final bool fullWidth;

  /// What a screen reader calls the set.
  final String? semanticLabel;

  @override
  State<NebaSegmentedButton<T>> createState() => _NebaSegmentedButtonState<T>();
}

class _NebaSegmentedButtonState<T> extends State<NebaSegmentedButton<T>> {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late T? _value = widget.defaultValue;

  /// One focus node per segment, by index, made as a segment first needs one
  /// and kept until the set goes.
  final List<FocusNode> _nodes = <FocusNode>[];

  /// The segment holding the focus, which is the set's stop in the focus
  /// order while the focus is inside it.
  int? _active;
  bool _focusCheckScheduled = false;

  T? get _current => widget.value ?? _value;

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.removeListener(_handleFocus);
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _nodeAt(int index) {
    while (_nodes.length <= index) {
      _nodes.add(FocusNode(debugLabel: 'NebaSegment')..addListener(_handleFocus));
    }

    return _nodes[index];
  }

  /// The index of the segment carrying [value], or `null` when none does.
  int? _indexOf(T? value) {
    if (value == null) {
      return null;
    }

    for (int i = 0; i < widget.children.length; i++) {
      if (widget.children[i].value == value) {
        return i;
      }
    }

    return null;
  }

  bool _off(int index) => _disabled || widget.children[index].disabled;

  void _chooseAt(int index) {
    if (_disabled || widget.readOnly || index >= widget.children.length || _off(index)) {
      return;
    }

    final T value = widget.children[index].value;

    if (value == _current) {
      return;
    }

    if (widget.value == null) {
      setState(() => _value = value);
    }

    widget.onValueChange?.call(value);
  }

  /// Moves the set's stop to the segment that took the focus, and back to the
  /// chosen one once the focus has left. A focus change can land during a
  /// build, so the stop moves after the frame.
  void _handleFocus() {
    if (_focusCheckScheduled) {
      return;
    }

    _focusCheckScheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((Duration _) {
        _focusCheckScheduled = false;

        if (!mounted) {
          return;
        }

        final int? focused = _focused;

        if (focused != _active) {
          setState(() => _active = focused);
        }
      })
      ..ensureVisualUpdate();
  }

  int? get _focused {
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].hasPrimaryFocus) {
        return i;
      }
    }

    return null;
  }

  /// The set's one stop in the focus order: the segment holding the focus,
  /// then the chosen one, then the first that is not disabled.
  int? _tabStop(int? chosen) {
    final int count = widget.children.length;
    final int? active = _active;

    if (active != null && active < count && !_off(active)) {
      return active;
    }

    if (chosen != null && !_off(chosen)) {
      return chosen;
    }

    for (int i = 0; i < count; i++) {
      if (!_off(i)) {
        return i;
      }
    }

    return null;
  }

  /// The arrow keys, as a radio group takes them: the next or the previous
  /// segment that is not disabled, wrapping at the ends, chosen as the focus
  /// lands on it unless the set is read-only.
  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final int? current = _focused;
    final int count = widget.children.length;

    if (current == null || current >= count) {
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

    int index = current;

    for (int tries = 1; tries < count; tries++) {
      index = (index + direction + count) % count;

      if (!_off(index)) {
        _nodeAt(index).requestFocus();
        _chooseAt(index);
        break;
      }
    }

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final bool disabled = _disabled;
    final bool solid = variant == NebaVariant.solid;

    final int? chosen = _indexOf(_current);
    final int? tabStop = _tabStop(chosen);
    final List<NebaSegment<T>> segments = widget.children;

    // A disabled segment under the tile greys the tile too, or its grey label
    // would sit on the family's fill.
    final bool tileOff = chosen != null && _off(chosen);
    final Widget tile = NebaSheet(
      fill: tileOff
          ? tokens.disabledBg
          : solid
          ? roles.fill
          : roles.panelPress,
      plate: tileOff
          ? NebaPlate.none
          : solid
          ? NebaPlate.solid
          : NebaPlate.glass,
      elevation: tileOff ? 0 : 1,
      borderRadius: _round,
    );

    final Widget row = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: NebaTileRun(
        current: chosen,
        fill: widget.fullWidth,
        tile: tile,
        children: <Widget>[
          for (int i = 0; i < segments.length; i++)
            _SegmentSlot(
              // The segment's own key, one level up, so a reordered set keeps
              // each segment's state with it; wrapped, so a GlobalKey is not
              // used twice.
              key: segments[i].key == null ? null : ValueKey<Key>(segments[i].key!),
              index: i,
              chosen: i == chosen,
              off: _off(i),
              readOnly: widget.readOnly,
              variant: variant,
              size: size,
              color: color,
              density: density,
              focusNode: _nodeAt(i)..skipTraversal = i != tabStop,
              choose: _chooseAt,
              child: segments[i],
            ),
        ],
      ),
    );

    // The trough is drawn behind the row rather than around it, so the row
    // keeps its place in the tree whatever the variant, and nothing clips the
    // tile's shadow where there is no trough to hold it.
    final Widget? trough = switch (variant) {
      NebaVariant.text => null,
      NebaVariant.solid => NebaSheet(
        fill: disabled ? edgeless : roles.panel,
        plate: disabled ? NebaPlate.none : NebaPlate.glass,
        elevation: disabled ? 0 : elevation,
        borderRadius: _round,
        blur: !disabled,
        texture: !disabled,
      ),
      NebaVariant.outline => NebaSheet(
        fill: disabled ? edgeless : roles.panel,
        edge: disabled ? tokens.disabledBorder : roles.line,
        plate: disabled ? NebaPlate.none : NebaPlate.glass,
        elevation: disabled ? 0 : elevation,
        borderRadius: _round,
        blur: !disabled,
        texture: !disabled,
      ),
    };
    final double inset = switch (variant) {
      NebaVariant.text => 0,
      NebaVariant.solid => _troughPadding,
      // The hairline takes a pixel of the box, as a CSS border does.
      NebaVariant.outline => _troughPadding + 1,
    };

    Widget set = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(child: trough ?? const SizedBox.shrink()),
        Padding(padding: EdgeInsets.all(inset), child: row),
      ],
    );

    if (widget.readOnly) {
      set = ColorFiltered(colorFilter: ColorFilter.matrix(saturationMatrix(0.55)), child: set);
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.radioGroup,
      label: widget.semanticLabel,
      child: set,
    );
  }
}

/// One choice in a [NebaSegmentedButton].
///
/// It has no `size`, `color` or `variant` of its own: all three belong to the
/// set, which is the only place they can be set once and mean the same thing
/// for every segment.
class NebaSegment<T> extends StatelessWidget {
  /// A segment named [value], labelled [child].
  const NebaSegment({
    required this.value,
    this.child,
    this.startIcon,
    this.endIcon,
    this.disabled = false,
    this.semanticLabel,
    super.key,
  });

  /// What names the segment, and what `onValueChange` reports when it is
  /// chosen.
  final T value;

  /// The label.
  final Widget? child;

  /// Before the label, drawn at 1.2 times the label's size.
  final Widget? startIcon;

  /// After the label: a count, a status dot.
  final Widget? endIcon;

  /// Unavailable, but still part of the set: neutral grey, out of the focus
  /// order and passed over by the arrow keys.
  final bool disabled;

  /// What a screen reader hears in place of the label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final _SegmentSlot? slot = context.dependOnInheritedWidgetOfExactType<_SegmentSlot>();

    assert(() {
      if (slot == null) {
        throw FlutterError(
          'A NebaSegment was built outside a NebaSegmentedButton.\n'
          'A segment draws itself from the set it is in, so it has to be one of '
          "a NebaSegmentedButton's children.",
        );
      }
      return true;
    }());

    final _SegmentSlot set = slot!;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(set.color);
    final bool off = set.off;
    // A read-only set still says which segment is taken, and nothing under the
    // pointer says a press would change it.
    final bool still = set.readOnly && !off;
    final bool live = !off && !still;
    final bool chosen = set.chosen;
    final NebaSize size = set.size;
    final double text = NebaScale.controlText[size]!;
    final String? semanticLabel = this.semanticLabel;

    final Widget body = NebaInteractive(
      enabled: live,
      // Read-only keeps its place in the focus order, so the arrow keys can
      // still walk the set.
      focusable: !off,
      onTap: () => set.choose(set.index),
      focusNode: set.focusNode,
      cursor: off
          ? SystemMouseCursors.forbidden
          : still
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder:
          (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
            // The chosen ink wins over the hovered one, and a disabled segment
            // over both.
            final Color ink = off
                ? tokens.disabledFg
                : chosen
                ? (set.variant == NebaVariant.solid ? roles.onSolid : roles.onTint)
                : interaction.hovered
                ? tokens.fg
                : tokens.mutedFg;

            final Widget label = NebaInk(
              color: ink,
              instant: interaction.pressed,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: text, height: 1, fontWeight: FontWeight.w500),
                softWrap: false,
                child: IconTheme.merge(
                  data: IconThemeData(size: text * 1.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[?startIcon, ?child, ?endIcon],
                  ),
                ),
              ),
            );

            // Inside the segment rather than off it: a ring standing off a
            // segment in a trough would be drawn over its neighbours.
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: _round,
              offset: -focusRingWidth,
              child: SizedBox(
                height: NebaScale.controlHeight[size],
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: NebaScale.paddingX[set.density]![size]!,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: ExcludeSemantics(excluding: semanticLabel != null, child: label),
                      ),
                    ),
                    if (live)
                      Positioned.fill(
                        child: NebaGlow(
                          interaction: interaction,
                          pointer: pointer,
                          colors: NebaGlowColors.of(tokens, set.color, set.variant),
                          borderRadius: _round,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
    );

    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: chosen,
      enabled: !off,
      label: semanticLabel,
      child: body,
    );
  }
}

/// What the set tells one segment: where it is, whether it is the chosen one,
/// and the set's own axes.
class _SegmentSlot extends InheritedWidget {
  const _SegmentSlot({
    required this.index,
    required this.chosen,
    required this.off,
    required this.readOnly,
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.focusNode,
    required this.choose,
    required super.child,
    super.key,
  });

  final int index;
  final bool chosen;
  final bool off;
  final bool readOnly;
  final NebaVariant variant;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final FocusNode focusNode;
  final void Function(int index) choose;

  @override
  bool updateShouldNotify(_SegmentSlot oldWidget) {
    return index != oldWidget.index ||
        chosen != oldWidget.chosen ||
        off != oldWidget.off ||
        readOnly != oldWidget.readOnly ||
        variant != oldWidget.variant ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        focusNode != oldWidget.focusNode ||
        choose != oldWidget.choose;
  }
}
