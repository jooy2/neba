/// `NebaButton`, a control that runs an action.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A control that runs an action: submitting a form, saving, deleting.
///
/// `solid` is the primary action, `outline` a secondary one and `text` a
/// low-weight one for a list or a toolbar. A press lands on the frame the
/// pointer goes down, in colour and one step down the shadow, and drains
/// slowly after; nothing in the button ever moves. With no [onPressed] it is
/// disabled, as every Flutter button is.
///
/// ```dart
/// NebaButton(onPressed: save, child: const Text('Save'))
/// ```
class NebaButton extends StatelessWidget {
  /// A button that calls [onPressed].
  const NebaButton({
    required this.onPressed,
    this.child,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.startIcon,
    this.endIcon,
    this.loading = false,
    this.readOnly = false,
    this.disabled,
    this.focusableWhenDisabled = false,
    this.fullWidth = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// What the button does. `null` disables it.
  final VoidCallback? onPressed;

  /// The label, usually a [Text]. Left out, the button goes square around its
  /// icon and needs a [semanticLabel].
  final Widget? child;

  /// The weight of the surface. Defaults to the `NebaButtonGroup`'s, then
  /// `NebaProvider`'s, then [NebaVariant.solid].
  final NebaVariant? variant;

  /// The height and the type scale: 22, 26, 32, 40 or 48 logical pixels.
  /// Defaults to the group's, then `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family. Defaults to the group's, then [NebaColor.primary].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to the group's, then
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`. Hovering adds a level
  /// and pressing takes one away. Defaults to the group's, then `0`.
  final NebaElevation? elevation;

  /// Before the label, drawn at 1.2 times the label's size.
  final Widget? startIcon;

  /// After the label.
  final Widget? endIcon;

  /// Shows a turning ring in place of [startIcon] and stops the button from
  /// activating, while it keeps the focus and otherwise looks the same.
  final bool loading;

  /// Keeps the shape and the colour but goes flat, drains most of the
  /// saturation and stops reacting: the action exists, it just is not
  /// available here. Keeps the focus.
  final bool readOnly;

  /// Drops the colour family for neutral grey and takes the button out of the
  /// focus order. The same as leaving [onPressed] out, for a button that keeps
  /// its handler. Defaults to the group's, then `false`.
  final bool? disabled;

  /// Keeps a disabled button in the focus order, still unable to be pressed:
  /// for the Next that reaches the last page, where losing the focus would drop
  /// a keyboard reader onto the page.
  final bool focusableWhenDisabled;

  /// Stretches to the width it is given.
  final bool fullWidth;

  /// What a screen reader hears in place of the label: the name of a button
  /// with only an icon.
  final String? semanticLabel;

  /// The button's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    // A group sets these once for the set; a button's own argument still
    // wins, as a danger button in a group of secondary ones does.
    final NebaButtonGroupScope? group = NebaButtonGroupScope.maybeOf(context);
    final NebaVariant variant =
        this.variant ?? group?.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaSize size = this.size ?? group?.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? group?.color ?? NebaColor.primary;
    final NebaDensity density =
        this.density ?? group?.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = this.elevation ?? group?.elevation ?? 0;
    final NebaColorRoles roles = tokens.roles(color);

    final bool isDisabled =
        nebaFieldsetDisabled(context, disabled ?? group?.disabled) || onPressed == null;
    // Loading and read-only stop the press without changing how the button is
    // drawn at rest; disabled changes both.
    final bool inert = loading || readOnly;
    final bool active = !isDisabled && !inert;
    final bool iconOnly = child == null;
    final String? semanticLabel = this.semanticLabel;

    final double height = NebaScale.controlHeight[size]!;
    final double text = NebaScale.controlText[size]!;
    // In a group, the corners that face a neighbour are squared off.
    final BorderRadius radius = NebaJoinScope.of(
      context,
    ).corners(tokens.radius[size]!, Directionality.of(context));

    final MouseCursor cursor = isDisabled
        ? SystemMouseCursors.forbidden
        : loading
        ? SystemMouseCursors.progress
        : readOnly
        ? SystemMouseCursors.basic
        : SystemMouseCursors.click;

    Widget button = NebaInteractive(
      enabled: active,
      focusable: !isDisabled || focusableWhenDisabled,
      onTap: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      cursor: cursor,
      builder:
          (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
            final _Look look = _Look.of(
              tokens: tokens,
              roles: roles,
              variant: variant,
              elevation: elevation,
              disabled: isDisabled,
              readOnly: readOnly,
              interaction: interaction,
            );

            final Widget label = NebaInk(
              color: look.ink,
              instant: interaction.pressed,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: text, height: 1, fontWeight: FontWeight.w500),
                softWrap: false,
                // A label never wraps; held narrower than itself, it ends in
                // an ellipsis rather than running out of the button.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: IconTheme.merge(
                  // Icons track the label, as `1.2em` does.
                  data: IconThemeData(size: text * 1.2),
                  child: Row(
                    mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[
                      if (loading) const NebaSpinner() else ?startIcon,
                      if (child case final Widget given?) Flexible(child: given),
                      ?endIcon,
                    ],
                  ),
                ),
              ),
            );

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
                // The height is the whole box's, hairline included, as a CSS
                // `border-box` is: an outline button is as tall as a solid one.
                child: SizedBox(
                  height: height - (look.edge == null ? 0 : 2),
                  width: iconOnly ? height - (look.edge == null ? 0 : 2) : null,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: iconOnly ? 0 : NebaScale.paddingX[density]![size]!,
                        ),
                        child: Center(
                          widthFactor: fullWidth ? null : 1,
                          // A semantic label stands in for what is drawn, and
                          // only for that: the node keeps its tap and focus.
                          child: ExcludeSemantics(excluding: semanticLabel != null, child: label),
                        ),
                      ),
                      if (active)
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

    if (readOnly && !isDisabled) {
      button = ColorFiltered(
        colorFilter: ColorFilter.matrix(saturationMatrix(0.55)),
        child: button,
      );
    }

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      container: true,
      button: true,
      enabled: active,
      label: semanticLabel,
      child: button,
    );
  }
}

/// What a button looks like in one state.
class _Look {
  const _Look({
    required this.fill,
    required this.edge,
    required this.ink,
    required this.plate,
    required this.elevation,
    required this.textured,
  });

  /// The React package's `restClasses`, `hoverClasses`, `readOnlyClasses` and
  /// `disabledClasses`, decided in one place so the states cannot stack.
  factory _Look.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required NebaVariant variant,
    required NebaElevation elevation,
    required bool disabled,
    required bool readOnly,
    required NebaInteraction interaction,
  }) {
    const Color clear = Color(0x00000000);

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

    final bool hovered = interaction.hovered;
    final bool pressed = interaction.pressed;
    // Press is one level down the shadow and hover one up, so a flat button
    // stays flat and only deepens. Read-only goes flat altogether.
    final int lift = readOnly
        ? 0
        : pressed
        ? math.max(elevation - 1, 0)
        : hovered
        ? math.min(elevation + 1, 4)
        : elevation;

    return switch (variant) {
      NebaVariant.solid => _Look(
        fill: pressed
            ? roles.fillActive
            : hovered
            ? roles.fillHover
            : roles.fill,
        edge: null,
        ink: roles.family.onSolid,
        plate: NebaPlate.solid,
        elevation: lift,
        textured: true,
      ),
      NebaVariant.outline => _Look(
        fill: pressed
            ? roles.panelPress
            : hovered
            ? roles.panelHover
            : roles.panel,
        edge: hovered || pressed ? roles.lineHover : roles.line,
        ink: roles.onTint,
        plate: NebaPlate.glass,
        elevation: lift,
        textured: true,
      ),
      NebaVariant.text => _Look(
        fill: pressed
            ? roles.softHover
            : hovered
            ? roles.soft
            : clear,
        edge: null,
        ink: roles.onTint,
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
