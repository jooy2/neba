/// `NebaPill`, a floating lozenge holding a little live information.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/pinned.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A floating lozenge that holds a small amount of live information: a
/// recording timer, a build still running, the track playing now.
///
/// The row has three parts: [startIcon] on the leading edge, [endIcon] on the
/// trailing one, and the middle, [title] over [description] with [child]
/// under them, centred between the two with generous room on either side.
/// One line keeps the shape a true stadium, its corners half the height of a
/// control of the same [size]; a second line grows it into a rounded
/// rectangle with the same corner.
///
/// As far as colour goes a pill is a control rather than a container: its
/// surface takes [color]'s family, as a button's does. It floats, so its
/// [elevation] is `2` by default. [onPressed] makes the row up to [endIcon] a
/// button, and [details] grows a second area beneath the row while
/// [expanded], by its height and never by a transform.
///
/// ```dart
/// const NebaPill(startIcon: DotIcon(), color: NebaColor.danger, title: Text('Recording'))
/// ```
class NebaPill extends StatelessWidget {
  /// A pill holding [title], [description] and [child].
  const NebaPill({
    this.title,
    this.description,
    this.child,
    this.startIcon,
    this.endIcon,
    this.details,
    this.expanded = false,
    this.onPressed,
    this.position = NebaPosition.static,
    this.side = NebaSide.top,
    this.safeArea = true,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(side == NebaSide.top || side == NebaSide.bottom),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The headline in the middle, what the pill is about now. One line, cut
  /// short with an ellipsis when the pill is given less room than it needs.
  final Widget? title;

  /// The second line, under the title: the same ink, one step smaller and
  /// one weight lighter. One line, like the title.
  final Widget? description;

  /// Anything the middle needs that [title] and [description] cannot say, a
  /// marquee or a pair of small readouts, under them in the same centred
  /// column.
  final Widget? child;

  /// The leading slot: a glyph, an avatar, a status dot, a photograph. It is
  /// a square the size of a standalone icon, clipped to a circle. A glyph is
  /// drawn in it at 1.2 times the type through the `IconTheme` the pill hands
  /// down; an `Image` fills it and is cropped rather than letterboxed.
  final Widget? startIcon;

  /// The trailing slot, outside the pressable row, so it can hold a readout
  /// or a control of its own.
  final Widget? endIcon;

  /// The second half, revealed while [expanded]. The pill grows downward into
  /// it rather than becoming another shape.
  final Widget? details;

  /// Whether [details] is showing.
  final bool expanded;

  /// Makes the row up to [endIcon] a button that calls this. With [details],
  /// a screen reader hears it as expanded or collapsed.
  final VoidCallback? onPressed;

  /// How the pill sits against its [side]. [NebaPosition.sticky] keeps it
  /// 12 pixels and the safe area clear of the edge, for a scroll view to
  /// hold it there; [NebaPosition.fixed] does the same in the nearest
  /// `Overlay`, centred across it, and takes no room where it was written.
  final NebaPosition position;

  /// The edge a pinned pill is held against: [NebaSide.top] or
  /// [NebaSide.bottom].
  final NebaSide side;

  /// Whether a pinned pill adds the screen's inset on its [side] to its
  /// distance from the edge: the padding `MediaQuery` reports where the pill
  /// is built.
  final bool safeArea;

  /// The weight of the surface, which takes [color]'s family: `solid` fills
  /// it, `outline` tints it and draws the hairline, `text` lays the wash.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.solid].
  final NebaVariant? variant;

  /// The row's height and corners, its type and its icon. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family. Defaults to [NebaColor.secondary].
  final NebaColor? color;

  /// The padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `2`: a pill hovers over
  /// the page, and one lying flat on what it floats over reads as a mistake.
  /// A `text` pill has no plate to lift and ignores it.
  final NebaElevation? elevation;

  /// The focus node of the pressable row, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the pressable row takes the focus when it is first built.
  final bool autofocus;

  /// The room either side of the middle at each size, per density: about
  /// twice a control's, so the eye lands on the middle first.
  static const Map<NebaDensity, Map<NebaSize, double>> centerPadding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 12,
          NebaSize.sm: 16,
          NebaSize.md: 20,
          NebaSize.lg: 24,
          NebaSize.xl: 32,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 16,
        },
      };

  /// How far a pinned pill hangs in from its edge, CSS `0.75rem`.
  static const double edgeDistance = 12;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? NebaColor.secondary;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = this.elevation ?? 2;
    final NebaColorRoles roles = tokens.roles(color);

    final double height = NebaScale.controlHeight[size]!;
    final double text = NebaScale.controlText[size]!;
    final double gap = NebaScale.gap[size]!;
    final double padX = NebaScale.paddingX[density]![size]!;
    // Half the row's height, so one line is a true stadium, pinned to the row
    // rather than to the whole pill: a pill that grows a second line keeps
    // the corner it had.
    final BorderRadius radius = BorderRadius.circular(height / 2);
    final bool interactive = onPressed != null;
    final Widget? endIcon = this.endIcon;
    final Widget? details = this.details;
    final Color ink = variant == NebaVariant.solid ? roles.family.onSolid : roles.onTint;

    final Widget? middle = _middle(size, density);
    final Widget? media = _media(size, text);
    final List<Widget> parts = <Widget>[?media, if (middle != null) Expanded(child: middle)];

    final Widget row;

    if (interactive) {
      row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: <Widget>[
          Expanded(
            child: _PillButton(
              onPressed: onPressed!,
              expanded: details == null ? null : expanded,
              variant: variant,
              color: color,
              radius: radius,
              padding: padX,
              focusNode: focusNode,
              autofocus: autofocus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: gap,
                children: parts,
              ),
            ),
          ),
          if (endIcon != null) Center(widthFactor: 1, child: endIcon),
        ],
      );
    } else {
      row = Row(spacing: gap, children: <Widget>[...parts, ?endIcon]);
    }

    // With a pressable middle the padding at the start belongs to the button,
    // so a press lands on the whole row rather than just the words.
    final EdgeInsetsDirectional rowPadding = EdgeInsetsDirectional.fromSTEB(
      interactive ? 0 : padX,
      4,
      endIcon != null ? 4 : (interactive ? 0 : padX),
      4,
    );
    // Less the hairline an outline pill draws inside its edge.
    final double floor = height - (variant == NebaVariant.outline ? 2 : 0);

    final Widget body = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: floor),
            child: Padding(
              padding: rowPadding,
              child: IntrinsicHeight(child: row),
            ),
          ),
          if (details != null)
            NebaDisclosurePanel(
              open: expanded,
              keepWidth: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(padX, 0, padX, 8),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: NebaScale.sheetBodyText[size],
                    height: NebaScale.sheetBodyLeading[size]! / NebaScale.sheetBodyText[size]!,
                  ),
                  softWrap: true,
                  child: details,
                ),
              ),
            ),
        ],
      ),
    );

    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(
        color: ink,
        fontSize: text,
        height: NebaScale.controlLeading[size]! / text,
        fontWeight: FontWeight.w500,
      ),
      softWrap: false,
      child: IconTheme.merge(
        data: IconThemeData(color: ink, size: text * 1.2),
        child: body,
      ),
    );

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: roles.fill,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.outline => NebaSheet(
        fill: roles.panel,
        edge: roles.line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      // The wash over the backing rather than over whatever is underneath,
      // so where the blur is gone it still has a ground to be read on.
      NebaVariant.text => NebaSheet(
        fill: Color.alphaBlend(roles.soft, tokens.backing),
        plate: NebaPlate.none,
        borderRadius: radius,
        child: content,
      ),
    };

    Widget pill = NebaRing(borderRadius: radius, child: sheet);

    if (nebaIsPinned(position)) {
      final double edge =
          edgeDistance + nebaSafeInset(context, position: position, side: side, safeArea: safeArea);

      pill = Padding(
        padding: side == NebaSide.bottom
            ? EdgeInsets.only(bottom: edge)
            : EdgeInsets.only(top: edge),
        child: pill,
      );
    }

    return NebaPinnedBar(position: position, side: side, child: pill);
  }

  /// The column in the middle, or `null` when there is nothing to put in it.
  Widget? _middle(NebaSize size, NebaDensity density) {
    final Widget? title = this.title;
    final Widget? description = this.description;
    final Widget? child = this.child;

    if (title == null && description == null && child == null) {
      return null;
    }

    final double meta = NebaScale.metaText[size]!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: centerPadding[density]![size]!),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (title != null)
              DefaultTextStyle.merge(maxLines: 1, overflow: TextOverflow.ellipsis, child: title),
            // The same ink as the title, one step smaller and one weight
            // lighter, never dimmed: on a solid pill white just clears 4.5:1.
            if (description != null)
              DefaultTextStyle.merge(
                style: TextStyle(fontSize: meta, height: 1.5, fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: description,
              ),
            ?child,
          ],
        ),
      ),
    );
  }

  /// The leading box: a square the size of a standalone icon, clipped round,
  /// with a glyph centred in it or a picture filling it.
  Widget? _media(NebaSize size, double text) {
    final Widget? startIcon = this.startIcon;

    if (startIcon == null) {
      return null;
    }

    return Center(
      widthFactor: 1,
      child: SizedBox.square(
        dimension: NebaScale.iconSize[size],
        child: ClipOval(
          child: startIcon is Image
              ? FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge, child: startIcon)
              : Center(child: startIcon),
        ),
      ),
    );
  }
}

/// The pressable row: the light and the press on the one part a press
/// presses, so a control in the trailing slot or in the open details is
/// never washed over as if it were part of the button.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.onPressed,
    required this.expanded,
    required this.variant,
    required this.color,
    required this.radius,
    required this.padding,
    required this.focusNode,
    required this.autofocus,
    required this.child,
  });

  final VoidCallback onPressed;
  final bool? expanded;
  final NebaVariant variant;
  final NebaColor color;
  final BorderRadius radius;
  final double padding;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      expanded: expanded,
      child: NebaInteractive(
        onTap: onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        builder:
            (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
              // Laid over the shell's own surface, the step a CSS `:hover` and
              // `:active` take.
              final Color wash = switch (variant) {
                NebaVariant.solid =>
                  interaction.pressed
                      ? roles.fillActive
                      : interaction.hovered
                      ? roles.fillHover
                      : edgeless,
                NebaVariant.outline =>
                  interaction.pressed
                      ? roles.panelPress
                      : interaction.hovered
                      ? roles.panelHover
                      : edgeless,
                NebaVariant.text =>
                  interaction.pressed
                      ? roles.softHover
                      : interaction.hovered
                      ? roles.soft
                      : edgeless,
              };

              // A ring inside the edge: the shell clips, and one two pixels
              // outside the row would be cut off at its start and corners.
              return NebaFocusRing(
                visible: interaction.focusVisible,
                color: roles.ring,
                borderRadius: radius,
                offset: -focusRingWidth,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: wash),
                  duration: nebaDuration(
                    context,
                    NebaScale.durationFill,
                    instant: interaction.pressed,
                  ),
                  curve: NebaScale.ease,
                  builder: (BuildContext context, Color? fill, Widget? child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(color: fill, borderRadius: radius),
                      child: child,
                    );
                  },
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: child,
                      ),
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
              );
            },
      ),
    );
  }
}
