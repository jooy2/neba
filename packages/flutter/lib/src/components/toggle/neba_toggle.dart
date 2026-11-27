/// `NebaToggle`, a button that stays down.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A button that stays down: bold on the selected words, the grid on the
/// canvas, the filter on the list.
///
/// Off is neutral, with muted ink on an undyed plate, and on is the colour
/// family asserting itself, whichever [variant] was asked for. The depth never
/// changes, only the colour. Controlled with [pressed] and [onPressedChange],
/// or left to keep its own state from [defaultPressed]; inside a
/// `NebaToggleGroup` the group owns the state and [value] names the toggle.
///
/// ```dart
/// NebaToggle(
///   pressed: bold,
///   onPressedChange: (bool on) => setState(() => bold = on),
///   child: const Text('Bold'),
/// )
/// ```
class NebaToggle extends StatefulWidget {
  /// A toggle labelled [child].
  const NebaToggle({
    this.child,
    this.pressed,
    this.defaultPressed = false,
    this.onPressedChange,
    this.value,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.startIcon,
    this.endIcon,
    this.disabled,
    this.fullWidth = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The label. Left out, the toggle goes square around its icon and needs a
  /// [semanticLabel].
  final Widget? child;

  /// Whether it is on, for a controlled toggle. Leave it out and the toggle
  /// keeps its own state.
  final bool? pressed;

  /// Whether an uncontrolled toggle starts on.
  final bool defaultPressed;

  /// Called with the new state when the toggle is pressed.
  final ValueChanged<bool>? onPressedChange;

  /// What names the toggle inside a `NebaToggleGroup`.
  final String? value;

  /// How the toggle looks while it is off: `solid` a filled neutral plate,
  /// `outline` a hairline panel, `text` nothing until it is hovered or on.
  /// Defaults to the group's, then `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height and the type scale. Defaults to the group's, then
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family it turns when on. Defaults to the group's, then
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The inline padding, and nothing else.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation? elevation;

  /// Before the label, drawn at 1.2 times the label's size.
  final Widget? startIcon;

  /// After the label.
  final Widget? endIcon;

  /// Unavailable: neutral grey and out of the focus order. Defaults to the
  /// group's, then `false`.
  final bool? disabled;

  /// Stretches to the width it is given.
  final bool fullWidth;

  /// What a screen reader hears in place of the label.
  final String? semanticLabel;

  /// The toggle's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the toggle takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaToggle> createState() => _NebaToggleState();
}

class _NebaToggleState extends State<NebaToggle> {
  late bool _pressed = widget.defaultPressed;
  FocusNode? _ownNode;
  NebaToggleGroupScope? _group;
  int? _registeredIndex;
  FocusNode? _registeredNode;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaToggle'));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register();
  }

  @override
  void didUpdateWidget(NebaToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register();
  }

  @override
  void dispose() {
    _unregister();
    _ownNode?.dispose();
    super.dispose();
  }

  bool get _disabled {
    return widget.disabled ?? NebaButtonGroupScope.maybeOf(context)?.disabled ?? false;
  }

  /// Hands the group this toggle's focus node, so the arrow keys can reach it.
  void _register() {
    final NebaToggleGroupScope? group = NebaToggleGroupScope.maybeOf(context);
    final int? index = NebaRunIndex.maybeOf(context)?.index;

    if (group == null || index == null) {
      _unregister();
      return;
    }

    if (_group != group || _registeredIndex != index || _registeredNode != _node) {
      _unregister();
    }

    _group = group;
    _registeredIndex = index;
    _registeredNode = _node;
    group.register(index, _node, enabled: !_disabled);
  }

  void _unregister() {
    final int? index = _registeredIndex;
    final FocusNode? node = _registeredNode;

    if (index != null && node != null) {
      _group?.unregister(index, node);
    }

    _group = null;
    _registeredIndex = null;
    _registeredNode = null;
  }

  bool _isPressed(NebaToggleGroupScope? group) {
    final String? value = widget.value;

    if (group != null && value != null) {
      return group.selected.contains(value);
    }

    return widget.pressed ?? _pressed;
  }

  void _toggle(NebaToggleGroupScope? group) {
    final bool next = !_isPressed(group);
    final String? value = widget.value;

    if (group != null && value != null) {
      group.onToggle(value, next);
    } else if (widget.pressed == null) {
      setState(() => _pressed = next);
    }

    widget.onPressedChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaButtonGroupScope? set = NebaButtonGroupScope.maybeOf(context);
    final NebaToggleGroupScope? group = NebaToggleGroupScope.maybeOf(context);
    final int? index = NebaRunIndex.maybeOf(context)?.index;

    final NebaVariant variant =
        widget.variant ?? set?.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? set?.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? set?.color ?? NebaColor.primary;
    final NebaDensity density =
        widget.density ?? set?.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? set?.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);
    final bool disabled = _disabled;
    final bool pressed = _isPressed(group);
    final bool iconOnly = widget.child == null;

    // In a group, one toggle is the set's stop in the focus order and the
    // arrow keys reach the rest.
    _node.skipTraversal = group != null && index != null && index != group.tabStop;

    final double height = NebaScale.controlHeight[size]!;
    final double text = NebaScale.controlText[size]!;
    final BorderRadius radius = NebaJoinScope.of(
      context,
    ).corners(tokens.radius[size]!, Directionality.of(context));

    Widget toggle = NebaInteractive(
      enabled: !disabled,
      onTap: () => _toggle(group),
      focusNode: _node,
      autofocus: widget.autofocus,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder:
          (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
            final _Look look = _Look.of(
              tokens: tokens,
              roles: roles,
              variant: variant,
              elevation: elevation,
              disabled: disabled,
              pressed: pressed,
              interaction: interaction,
            );
            final Widget? child = widget.child;

            final Widget label = NebaInk(
              color: look.ink,
              instant: interaction.pressed,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: text, height: 1, fontWeight: FontWeight.w500),
                softWrap: false,
                child: IconTheme.merge(
                  data: IconThemeData(size: text * 1.2),
                  child: Row(
                    mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[?widget.startIcon, ?child, ?widget.endIcon],
                  ),
                ),
              ),
            );
            final double inner = height - (look.edge == null ? 0 : 2);

            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              child: NebaSheet(
                fill: look.fill,
                edge: look.edge,
                plate: look.plate,
                elevation: look.elevation,
                borderRadius: radius,
                pressed: interaction.pressed,
                blur: look.textured,
                texture: look.textured,
                child: SizedBox(
                  height: inner,
                  width: iconOnly ? inner : null,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: iconOnly ? 0 : NebaScale.paddingX[density]![size]!,
                        ),
                        child: Center(widthFactor: widget.fullWidth ? null : 1, child: label),
                      ),
                      if (!disabled)
                        Positioned.fill(
                          child: NebaGlow(
                            interaction: interaction,
                            pointer: pointer,
                            colors: NebaGlowColors.of(tokens, color, variant),
                            borderRadius: radius,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
    );

    if (widget.fullWidth) {
      toggle = SizedBox(width: double.infinity, child: toggle);
    }

    final String? semanticLabel = widget.semanticLabel;

    return Semantics(
      container: true,
      button: true,
      enabled: !disabled,
      selected: pressed,
      label: semanticLabel,
      child: semanticLabel == null ? toggle : ExcludeSemantics(child: toggle),
    );
  }
}

/// What a toggle looks like in one state: the React package's `offClasses`,
/// `onClasses` and `disabledClasses`, decided in one place.
class _Look {
  const _Look({
    required this.fill,
    required this.edge,
    required this.ink,
    required this.plate,
    required this.elevation,
    required this.textured,
  });

  factory _Look.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required NebaVariant variant,
    required NebaElevation elevation,
    required bool disabled,
    required bool pressed,
    required NebaInteraction interaction,
  }) {
    const Color clear = Color(0x00000000);
    final bool hovered = interaction.hovered;
    final bool down = interaction.pressed;

    if (disabled) {
      return switch (variant) {
        NebaVariant.solid => _Look(
          fill: tokens.disabledBg,
          edge: null,
          ink: tokens.disabledFg,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
        ),
        NebaVariant.outline => _Look(
          fill: clear,
          edge: tokens.disabledBorder,
          ink: tokens.disabledFg,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
        ),
        NebaVariant.text => _Look(
          fill: clear,
          edge: null,
          ink: tokens.disabledFg,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
        ),
      };
    }

    if (pressed) {
      return switch (variant) {
        NebaVariant.solid => _Look(
          fill: down
              ? roles.fillActive
              : hovered
              ? roles.fillHover
              : roles.fill,
          edge: null,
          ink: roles.family.onSolid,
          plate: NebaPlate.solid,
          elevation: elevation,
          textured: true,
        ),
        // The dyed plate stays put under the pointer: what answers it is the
        // edge and the ink, both moving towards more rather than less.
        NebaVariant.outline => _Look(
          fill: roles.panelPress,
          edge: hovered || down ? roles.accent : roles.lineHover,
          ink: hovered ? tokens.fg : roles.onTint,
          plate: NebaPlate.glass,
          elevation: elevation,
          textured: true,
        ),
        NebaVariant.text => _Look(
          fill: hovered || down ? roles.softPress : roles.softHover,
          edge: null,
          ink: roles.onTint,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
        ),
      };
    }

    // Off is neutral: muted ink on the undyed plate, because accent ink on a
    // toggle that is off would say it was on.
    return switch (variant) {
      NebaVariant.solid => _Look(
        fill: hovered || down ? tokens.panelPress : tokens.panelHover,
        edge: null,
        ink: hovered ? tokens.fg : tokens.mutedFg,
        plate: NebaPlate.solid,
        elevation: elevation,
        textured: true,
      ),
      NebaVariant.outline => _Look(
        fill: down
            ? tokens.panelPress
            : hovered
            ? tokens.panelHover
            : tokens.panel,
        edge: tokens.border,
        ink: hovered ? tokens.fg : tokens.mutedFg,
        plate: NebaPlate.glass,
        elevation: elevation,
        textured: true,
      ),
      NebaVariant.text => _Look(
        fill: down
            ? roles.softHover
            : hovered
            ? roles.soft
            : clear,
        edge: null,
        ink: hovered ? tokens.fg : tokens.mutedFg,
        plate: NebaPlate.none,
        elevation: 0,
        textured: false,
      ),
    };
  }

  final Color fill;
  final Color? edge;
  final Color ink;
  final NebaPlate plate;
  final int elevation;
  final bool textured;
}
