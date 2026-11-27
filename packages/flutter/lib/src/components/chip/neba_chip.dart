/// `NebaChip`, a compact token: a tag, a filter, a status.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A compact token holding one short value: a tag, a filter, a status, an
/// entity plucked out of a list.
///
/// A chip sits one step down the control ladder: a `md` chip is a `sm`
/// control, 26 logical pixels tall, so a token inside a row of content never
/// reads as a control the row lines up against. With [onPressed] the label
/// becomes a button of its own, and with [onDelete] a × button follows it;
/// the two are siblings, each with its own focus stop, never one inside the
/// other.
///
/// ```dart
/// NebaChip(onDelete: remove, child: const Text('typescript'))
/// ```
class NebaChip extends StatefulWidget {
  /// A chip with [child] as its label.
  const NebaChip({
    this.child,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.startIcon,
    this.endIcon,
    this.count,
    this.onPressed,
    this.onDelete,
    this.locale,
    this.deleteLabel,
    this.selected,
    this.disabled = false,
    this.transition,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The label, usually a [Text]. One line, cut short with an ellipsis when
  /// the chip is given less room than it needs.
  final Widget? child;

  /// The weight of the surface. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height and the type scale, one step below the control of the same
  /// size. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`. A chip sits on
  /// something else, so this is rarely raised. A `text` chip has no sheet to
  /// lift and ignores it.
  final NebaElevation? elevation;

  /// Before the label: an icon, a status dot, an avatar. Drawn at 1.2 times
  /// the label's size through the [IconTheme] the chip hands down.
  final Widget? startIcon;

  /// After the label, before any [count].
  final Widget? endIcon;

  /// A number set into the end of the chip, usually a [Text], on a plate of
  /// its own, so "Errors 12" reads as one token with a count rather than as
  /// two words.
  final Widget? count;

  /// Makes the label a button that calls this. A chip with none is a plain
  /// token.
  final VoidCallback? onPressed;

  /// Adds the × button after the label, which calls this. It is a button of
  /// its own beside the label, never inside it.
  final VoidCallback? onDelete;

  /// The language the × button is named in. Defaults to `NebaProvider`'s,
  /// then the app's.
  final Locale? locale;

  /// What a screen reader hears for the × button. Defaults to the
  /// [locale]'s "Remove {label}" when the label is a [Text], and to its
  /// "Remove" otherwise.
  final String? deleteLabel;

  /// Marks the chip as chosen, a filter that is on, by deepening the surface
  /// a step rather than changing the colour family. Passing it, `false`
  /// included, is what makes a pressable chip announce whether it is
  /// selected; with [onPressed] alone it is a plain button.
  final bool? selected;

  /// Drops the colour family for neutral grey. A disabled chip's label is not
  /// a button, and its × cannot be pressed.
  final bool disabled;

  /// How the chip arrives when it is first built: `const
  /// NebaTransition.zoom()`, or any of the others.
  final NebaTransition? transition;

  /// The focus node of the pressable label, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the pressable label takes the focus when it is first built.
  final bool autofocus;

  /// The control step a chip of each size is drawn at: one down the ladder,
  /// with `xs` kept from falling off the bottom of it.
  static const Map<NebaSize, NebaSize> step = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.sm,
    NebaSize.lg: NebaSize.md,
    NebaSize.xl: NebaSize.lg,
  };

  @override
  State<NebaChip> createState() => _NebaChipState();
}

class _NebaChipState extends State<NebaChip> {
  // The shell answers the pointer as a whole, the way CSS `:hover` and
  // `:active` on the React package's `<span>` do: a press on the × deepens a
  // pressable chip as well.
  bool _hovered = false;
  bool _pressed = false;

  bool get _interactive => widget.onPressed != null && !widget.disabled;

  @override
  void didUpdateWidget(NebaChip oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_interactive) {
      _hovered = false;
      _pressed = false;
    }
  }

  void _setHovered(bool hovered) {
    if (_hovered != hovered) {
      setState(() => _hovered = hovered);
    }
  }

  void _setPressed(bool pressed) {
    if (_pressed != pressed) {
      setState(() => _pressed = pressed);
    }
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
    final bool disabled = widget.disabled;
    final bool interactive = _interactive;
    final bool deletable = widget.onDelete != null;

    final NebaSize step = NebaChip.step[size]!;
    final double height = NebaScale.controlHeight[step]!;
    final double text = NebaScale.controlText[step]!;
    final double gap = NebaScale.gap[step]!;
    final double padX = NebaScale.paddingX[density]![step]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[step]!);

    final bool hovered = interactive && _hovered;
    final bool pressed = interactive && _pressed;
    final _Look look = _Look.of(
      tokens: tokens,
      roles: roles,
      variant: variant,
      elevation: elevation,
      disabled: disabled,
      selected: !disabled && (widget.selected ?? false),
      hovered: hovered,
      pressed: pressed,
    );

    final Widget label = _Label(
      gap: gap,
      startIcon: widget.startIcon,
      endIcon: widget.endIcon,
      count: widget.count,
      countPlate: variant == NebaVariant.solid ? tokens.glowOnFill : roles.fill,
      countInk: roles.family.onSolid,
      child: widget.child,
    );

    Widget body;

    if (interactive) {
      // The label is a button of its own, its padding inside it, so the whole
      // chip up to the × is what a press lands on. Its ring traces the
      // chip's corners rather than a squarer box inside them.
      body = Semantics(
        container: true,
        button: true,
        enabled: true,
        selected: widget.selected,
        child: NebaInteractive(
          onTap: widget.onPressed,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padX),
                child: label,
              ),
            );
          },
        ),
      );
    } else {
      body = Padding(
        padding: EdgeInsetsDirectional.only(start: padX, end: deletable ? 0 : padX),
        child: label,
      );
    }

    final Widget content = NebaInk(
      color: look.ink,
      instant: pressed,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: text, fontWeight: FontWeight.w500),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: IconTheme.merge(
          // Icons track the label, as `1.2em` does.
          data: IconThemeData(size: text * 1.2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(child: body),
              if (deletable)
                _DeleteButton(
                  onPressed: disabled ? null : widget.onDelete,
                  label: _deleteLabel(context),
                  ring: roles.ring,
                  extent: text * 1.15,
                  glyph: text * 1.2,
                ),
            ],
          ),
        ),
      ),
    );

    final double inner = height - (look.edge == null ? 0 : 2);
    Widget chip = NebaSheet(
      fill: look.fill,
      edge: look.edge,
      plate: look.plate,
      elevation: look.elevation,
      borderRadius: radius,
      pressed: pressed,
      blur: look.textured,
      texture: look.textured,
      child: SizedBox(height: inner, child: content),
    );

    if (interactive) {
      chip = MouseRegion(
        onEnter: (PointerEnterEvent e) => _setHovered(true),
        onExit: (PointerExitEvent e) => _setHovered(false),
        child: Listener(
          onPointerDown: (PointerDownEvent e) => _setPressed(true),
          onPointerUp: (PointerUpEvent e) => _setPressed(false),
          onPointerCancel: (PointerCancelEvent e) => _setPressed(false),
          child: chip,
        ),
      );
    } else if (disabled) {
      chip = MouseRegion(cursor: SystemMouseCursors.forbidden, child: chip);
    }

    // The ring of a pile the chip is in, around its corners.
    chip = NebaRing(borderRadius: radius, child: chip);

    final NebaTransition? transition = widget.transition;

    if (transition != null) {
      chip = NebaEntrance(transition: transition, child: chip);
    }

    return Semantics(container: true, enabled: disabled ? false : null, child: chip);
  }

  String _deleteLabel(BuildContext context) {
    final String? written = widget.deleteLabel;

    if (written != null) {
      return written;
    }

    final Map<String, String> messages = nebaMessages(context, 'action', locale: widget.locale);
    final Widget? child = widget.child;
    final String? name = child is Text ? child.data?.trim() : null;

    if (name != null && name.isNotEmpty) {
      return fillNebaMessage(messages['removeLabel']!, <String, String>{'label': name});
    }

    return messages['remove']!;
  }
}

/// What is inside the chip up to the ×: the icons, the words and the count,
/// centred on one line.
class _Label extends StatelessWidget {
  const _Label({
    required this.gap,
    required this.countPlate,
    required this.countInk,
    this.startIcon,
    this.endIcon,
    this.count,
    this.child,
  });

  final double gap;
  final Widget? startIcon;
  final Widget? endIcon;
  final Widget? count;
  final Color countPlate;
  final Color countInk;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget? child = this.child;
    final Widget? count = this.count;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: gap,
      children: <Widget>[
        ?startIcon,
        if (child != null) Flexible(child: child),
        ?endIcon,
        if (count != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2),
            child: _CountPlate(color: countPlate, ink: countInk, child: count),
          ),
      ],
    );
  }
}

/// The count's own plate. On a filled chip it is a hole punched in the fill;
/// on a tinted or bare one a fill of its own, so the number reads the same
/// wherever the chip sits.
class _CountPlate extends StatelessWidget {
  const _CountPlate({required this.color, required this.ink, required this.child});

  final Color color;
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double text = DefaultTextStyle.of(context).style.fontSize ?? 13;

    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: ink,
            fontSize: text * 0.85,
            fontWeight: FontWeight.w600,
            height: 1,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The × after the label: drawn at the size of the words beside it, and
/// pressed over the chip's whole height and the room on either side of it.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.onPressed,
    required this.label,
    required this.ring,
    required this.extent,
    required this.glyph,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color ring;
  final double extent;
  final double glyph;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      child: NebaInteractive(
        onTap: onPressed,
        enabled: enabled,
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return Padding(
            // The chip's own end padding is the far side of this target.
            padding: const EdgeInsetsDirectional.only(start: 2, end: 4),
            child: Center(
              child: NebaFocusRing(
                visible: interaction.focusVisible,
                color: ring,
                borderRadius: BorderRadius.circular(extent),
                offset: 1,
                child: AnimatedOpacity(
                  opacity: interaction.hovered || interaction.focusVisible ? 1 : 0.7,
                  duration: nebaDuration(context, NebaScale.duration),
                  curve: NebaScale.ease,
                  child: SizedBox.square(
                    dimension: extent,
                    child: OverflowBox(
                      maxWidth: glyph,
                      maxHeight: glyph,
                      child: NebaGlyph(NebaGlyphs.close, size: glyph),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// What a chip looks like in one state: the React package's `restClasses`,
/// `selectedClasses`, `hoverClasses` and `disabledClasses`, decided in one
/// place so the states cannot stack.
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
    required bool selected,
    required bool hovered,
    required bool pressed,
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

    // A press, then the pointer, then the chosen state: the order a CSS
    // `:active` and `:hover` win over a class in.
    return switch (variant) {
      NebaVariant.solid => _Look(
        fill: pressed
            ? roles.fillActive
            : hovered
            ? roles.fillHover
            : selected
            ? roles.fillActive
            : roles.fill,
        edge: null,
        ink: roles.family.onSolid,
        plate: NebaPlate.solid,
        elevation: elevation,
        textured: true,
      ),
      NebaVariant.outline => _Look(
        fill: pressed
            ? roles.panelPress
            : hovered
            ? roles.panelHover
            : selected
            ? roles.panelPress
            : roles.panel,
        edge: hovered || selected ? roles.lineHover : roles.line,
        ink: roles.onTint,
        plate: NebaPlate.glass,
        elevation: elevation,
        textured: true,
      ),
      NebaVariant.text => _Look(
        fill: pressed
            ? roles.softPress
            : hovered
            ? roles.softHover
            : selected
            ? roles.softPress
            : roles.soft,
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
