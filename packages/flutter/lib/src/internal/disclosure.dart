/// A section that folds: the header that opens it, the panel that opens onto
/// what it holds, and the sheet around the two. What a Collapsible and an
/// Accordion's sections share, so the two open and close the same way.
///
/// The panel's height moves, which looks like an exception to the rule
/// against moving things and is not: nothing is transformed, no text is
/// resampled, and the content does not shift relative to the panel it is in.
/// The panel is a window opening onto it, laid out at its full height and
/// clipped to the height the panel has reached. Content that appeared at once
/// would be a page that jumps, which is the failure the rule is there to
/// prevent.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Room above what a panel holds, inside its clip, CSS `0.5625rem`.
///
/// The panel clips at its top edge, and what it holds starts right there,
/// because the header above has already paid for the space between them. So
/// whatever is drawn above the first thing in it would be cut off: the focus
/// ring of a button, and a field's label set into its top edge, which rises
/// half its line. The clip reaches this far up, over the bottom of the
/// header, which is the largest of those, a label at `xl`.
const double nebaPanelRoom = 9;

/// [child] behind a panel that opens to its height and closes to none.
///
/// The height travels over `NebaScale.duration` on `NebaScale.ease` from
/// wherever it is, so a fold reversed halfway turns back from there, and in
/// zero time for a reader who asked for less motion. A closed panel is out of
/// the semantics tree, the focus order and the pointer's reach from the moment
/// it starts closing; once it has closed it paints nothing, and it is kept
/// built with its state only when [keepMounted] says so.
class NebaDisclosurePanel extends StatefulWidget {
  /// A panel around [child], open or not.
  const NebaDisclosurePanel({
    required this.open,
    required this.child,
    this.keepMounted = true,
    this.keepWidth = false,
    this.bottomRadius = 0,
    super.key,
  });

  /// Whether the panel is open, or opening.
  final bool open;

  /// Whether a closed panel keeps [child] built, so what it holds keeps its
  /// state through being folded away.
  final bool keepMounted;

  /// Whether a closed panel still lays [child] out and reports its width, as
  /// a CSS box of no height is still as wide as what it holds: for a panel in
  /// something as wide as its widest part, such as a Pill, which would
  /// otherwise widen at the moment it opens. Keeps [child] built.
  final bool keepWidth;

  /// The radius of the panel's bottom corners, for a panel that ends a sheet
  /// which does not clip it.
  final double bottomRadius;

  /// What the panel opens onto.
  final Widget child;

  @override
  State<NebaDisclosurePanel> createState() => _NebaDisclosurePanelState();
}

class _NebaDisclosurePanelState extends State<NebaDisclosurePanel>
    with SingleTickerProviderStateMixin {
  /// The move from one height to the next, at rest at its end.
  late final AnimationController _move = AnimationController(vsync: this, value: 1)
    ..addListener(_onTick)
    ..addStatusListener(_onStatus);

  /// The share of the content's height the panel shows: where the move
  /// started, where it is going, and where it is now.
  late double _from = widget.open ? 1 : 0;
  late double _to = _from;
  late double _shown = _from;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _move.duration = nebaDuration(context, NebaScale.duration);
  }

  @override
  void didUpdateWidget(NebaDisclosurePanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.open != widget.open) {
      // From wherever the panel is, so a fold that turns back halfway does
      // not jump to an end first.
      _from = _shown;
      _to = widget.open ? 1 : 0;
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  void _onTick() {
    final double shown = _from + (_to - _from) * NebaScale.ease.transform(_move.value);

    if (shown != _shown) {
      setState(() => _shown = shown);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // A zero duration completes without a tick in between.
      setState(() => _shown = _to);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool open = widget.open;
    // Drawn while it has any height, or is about to.
    final bool drawn = open || _shown > 0;

    return ClipRRect(
      clipper: _Room(widget.bottomRadius),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        heightFactor: _shown,
        child: Visibility(
          visible: drawn,
          maintainState: widget.keepMounted || widget.keepWidth,
          maintainAnimation: widget.keepWidth,
          maintainSize: widget.keepWidth,
          child: IgnorePointer(
            ignoring: !open,
            child: ExcludeFocus(
              excluding: !open,
              child: ExcludeSemantics(excluding: !open, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// The panel's box with [nebaPanelRoom] above it, and the bottom corners
/// rounded when the sheet does not round them.
class _Room extends CustomClipper<RRect> {
  const _Room(this.radius);

  final double radius;

  @override
  RRect getClip(Size size) {
    final Radius corner = Radius.circular(radius);

    return RRect.fromRectAndCorners(
      Rect.fromLTRB(0, -nebaPanelRoom, size.width, size.height),
      bottomLeft: corner,
      bottomRight: corner,
    );
  }

  @override
  bool shouldReclip(_Room oldClipper) => oldClipper.radius != radius;
}

/// The chevron at the end of a header, turned half a turn while the panel is
/// open.
///
/// Turned rather than moved: a chevron is a glyph, so rotating it is the one
/// transform the design language allows. It is also the only thing on a
/// header that reports the state by moving, which is why the header itself
/// only changes colour.
class NebaDisclosureChevron extends StatelessWidget {
  /// A chevron pointing down, or up while [open].
  const NebaDisclosureChevron({required this.open, this.size, this.color, super.key});

  /// Whether the panel it reports on is open.
  final bool open;

  /// The glyph's size; the ambient icon size when left out.
  final double? size;

  /// The glyph's colour; the ambient icon colour when left out.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      child: NebaGlyph(NebaGlyphs.chevron, size: size, color: color),
    );
  }
}

/// The sheet a folding section sits on, in the three weights a container
/// takes: `solid` a brighter sheet, `outline` a frosted one with a hairline in
/// [color]'s family, `text` none. The sheet is never dyed, because what it
/// holds arrives with colours of its own.
///
/// With [clip] the sheet's corners clip what is on it, so a header's hover
/// wash and a moving panel stay inside them. Without it the sheet is drawn
/// behind, and a caller's own trigger keeps a focus ring that stands off it.
class NebaDisclosureSheet extends StatelessWidget {
  /// A sheet of [variant] with [child] on it.
  const NebaDisclosureSheet({
    required this.variant,
    required this.color,
    required this.size,
    required this.elevation,
    required this.child,
    this.clip = true,
    super.key,
  });

  /// The sheet's weight.
  final NebaVariant variant;

  /// The family of the hairline.
  final NebaColor color;

  /// The sheet's corners.
  final NebaSize size;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the corners clip [child].
  final bool clip;

  /// The header and the panel.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    NebaSheet sheet(Widget? child) {
      return switch (variant) {
        NebaVariant.solid => NebaSheet(
          fill: tokens.panelHover,
          elevation: elevation,
          borderRadius: radius,
          child: child,
        ),
        _ => NebaSheet(
          fill: tokens.panel,
          edge: tokens.roles(color).line,
          plate: NebaPlate.glass,
          elevation: elevation,
          borderRadius: radius,
          child: child,
        ),
      };
    }

    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: child,
    );
    final Widget drawn;

    if (variant == NebaVariant.text) {
      drawn = clip ? ClipRRect(borderRadius: radius, child: content) : content;
    } else if (clip) {
      drawn = sheet(content);
    } else {
      // Behind rather than around, so nothing on it is clipped. The hairline
      // still takes its pixel, as a CSS border does.
      drawn = Stack(
        children: <Widget>[
          Positioned.fill(child: sheet(null)),
          Padding(padding: EdgeInsets.all(variant == NebaVariant.outline ? 1 : 0), child: content),
        ],
      );
    }

    return NebaRing(borderRadius: radius, child: drawn);
  }
}

/// The header of a folding section: a trigger holding [startIcon], [title]
/// over [subtitle] and the chevron, with [action] beside it rather than in it.
///
/// The action sits outside the trigger on purpose: a header that both folds
/// and holds a switch has two things to press, and one of them cannot be
/// inside the other. A screen reader hears the trigger as a button that is
/// expanded or collapsed, and with [headingLevel] as a button inside a heading
/// of that level, the action left out of both.
class NebaDisclosureHeader extends StatelessWidget {
  /// A header for a panel that is [open], or not.
  const NebaDisclosureHeader({
    required this.open,
    required this.onToggle,
    required this.size,
    required this.padding,
    required this.color,
    this.title,
    this.subtitle,
    this.lines,
    this.startIcon,
    this.action,
    this.indicator = true,
    this.disabled = false,
    this.insetRing = true,
    this.borderRadius = BorderRadius.zero,
    this.headingLevel,
    super.key,
  });

  /// Whether the panel is open.
  final bool open;

  /// Opens or closes the panel.
  final VoidCallback onToggle;

  /// The type of the title and the subtitle, and the padding.
  final NebaSize size;

  /// The room around the trigger's content, and at the sides of [action]:
  /// a box's padding at the section's size and density.
  final double padding;

  /// The family of the hover wash, the open ink and the focus ring.
  final NebaColor color;

  /// The heading, set one step above the body in semibold.
  final Widget? title;

  /// A second line under the title, one step down the type scale and muted.
  final Widget? subtitle;

  /// How many lines the title and the subtitle keep before an ellipsis. Left
  /// out, both wrap.
  final int? lines;

  /// Before the title, muted.
  final Widget? startIcon;

  /// A control pinned to the end of the header, outside the trigger.
  final Widget? action;

  /// Whether the chevron is drawn.
  final bool indicator;

  /// Whether the trigger stops answering.
  final bool disabled;

  /// Whether the focus ring is drawn inside the trigger's edge rather than
  /// two pixels off it: for a trigger that spans a sheet which clips.
  final bool insetRing;

  /// The trigger's corners, which its wash and its ring follow.
  final BorderRadius borderRadius;

  /// The heading level the trigger sits in, or `null` for none.
  final int? headingLevel;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);
    final TextStyle ambient = DefaultTextStyle.of(context).style;
    // An icon tracks the type around the trigger, as CSS `1.2em` does, and
    // sits in a box a line of that type tall.
    final double em = ambient.fontSize ?? 14;
    final double iconSize = em * 1.2;
    final double line = em * (ambient.height ?? 1.5);
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double metaSize = NebaScale.metaText[size]!;
    final Widget? title = this.title;
    final Widget? subtitle = this.subtitle;
    final Widget? startIcon = this.startIcon;
    final TextOverflow? overflow = lines == null ? null : TextOverflow.ellipsis;

    Widget muted(Widget child) {
      return DefaultTextStyle.merge(
        style: TextStyle(color: tokens.mutedFg),
        child: IconTheme.merge(
          data: IconThemeData(color: tokens.mutedFg, size: iconSize),
          child: SizedBox(
            height: line,
            child: Center(widthFactor: 1, child: child),
          ),
        ),
      );
    }

    final Widget content = Row(
      spacing: NebaScale.gap[size]!,
      children: <Widget>[
        if (startIcon != null) muted(startIcon),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: NebaScale.sheetHeaderGap[size]!,
            children: <Widget>[
              if (title != null)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: titleSize,
                    height: NebaScale.sheetTitleLeading[size]! / titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: lines,
                  overflow: overflow,
                  child: title,
                ),
              if (subtitle != null)
                DefaultTextStyle.merge(
                  style: TextStyle(fontSize: metaSize, height: 1.5, color: tokens.mutedFg),
                  maxLines: lines,
                  overflow: overflow,
                  child: subtitle,
                ),
            ],
          ),
        ),
        if (indicator) muted(NebaDisclosureChevron(open: open)),
      ],
    );

    Widget trigger = NebaInteractive(
      enabled: !disabled,
      onTap: onToggle,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        final Color ink = disabled
            ? tokens.disabledFg
            : open
            ? roles.onTint
            : tokens.fg;

        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: borderRadius,
          offset: insetRing ? -focusRingWidth : focusRingOffset,
          child: TweenAnimationBuilder<Color?>(
            // The wash drains back over the fill's duration, as a CSS
            // background does under the house transition.
            tween: ColorTween(end: interaction.hovered ? roles.soft : edgeless),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? wash, Widget? child) {
              return DecoratedBox(
                decoration: BoxDecoration(color: wash, borderRadius: borderRadius),
                child: child,
              );
            },
            child: NebaInk(
              color: ink,
              child: Padding(padding: EdgeInsets.all(padding), child: content),
            ),
          ),
        );
      },
    );

    trigger = Semantics(
      container: true,
      button: true,
      enabled: !disabled,
      expanded: open,
      child: trigger,
    );

    final int? headingLevel = this.headingLevel;

    if (headingLevel != null) {
      trigger = Semantics(
        container: true,
        header: true,
        headingLevel: headingLevel,
        child: trigger,
      );
    }

    final Widget? action = this.action;

    return Row(
      children: <Widget>[
        Expanded(child: trigger),
        if (action != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: action,
          ),
      ],
    );
  }
}

/// What a folding section holds, in the sheet's body type and muted, padded
/// at the sides and below: the header has already paid for the space above.
class NebaDisclosureBody extends StatelessWidget {
  /// [child] in the body type of [size], inside [padding].
  const NebaDisclosureBody({
    required this.size,
    required this.padding,
    required this.child,
    super.key,
  });

  /// The body's type.
  final NebaSize size;

  /// The room around [child].
  final EdgeInsetsGeometry padding;

  /// What the panel holds.
  final Widget child;

  /// The room below a body that a header sits above: `pb-4`, or `pb-2` when
  /// compact.
  static double bottom(NebaDensity density) => density == NebaDensity.compact ? 8 : 16;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.sheetBodyText[size]!;

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: tokens.mutedFg,
        fontSize: text,
        height: NebaScale.sheetBodyLeading[size]! / text,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
