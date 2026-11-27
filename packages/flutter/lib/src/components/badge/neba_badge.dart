/// `NebaBadge`, a small mark in the corner of something else.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The shape of what a [NebaBadge] sits on, which decides how far it tucks in.
enum NebaBadgeOverlap {
  /// A box: the mark sits on its corner.
  square,

  /// A circle, an avatar: the mark is pulled in by the 7% a circle's corner
  /// lies inside its box, so it does not float off with a gap under it.
  circle,
}

/// A small mark in the corner of something else: unread mail on an inbox
/// icon, a status dot on an avatar, a count on a tab.
///
/// With a [child] the mark hangs off the corner [placement] names, half of it
/// outside, and the child is laid out exactly as it would be bare. Without one
/// it is a standalone mark that sits in a row. [NebaBadge.count] caps a number
/// at [max] with a `+` and hides a zero; a badge with no [content] is a dot.
///
/// ```dart
/// NebaBadge.count(count: 3, semanticLabel: '3 unread', child: inboxButton)
/// ```
class NebaBadge extends StatelessWidget {
  /// A badge saying [content], or a dot when there is none.
  const NebaBadge({
    this.content,
    this.child,
    this.dot = false,
    this.invisible = false,
    this.placement = NebaCorner.topEnd,
    this.overlap = NebaBadgeOverlap.square,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : count = null,
       max = 99,
       showZero = false,
       assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// A badge counting [count], capped at [max] with a `+`, and hidden at zero
  /// unless [showZero].
  const NebaBadge.count({
    required int this.count,
    this.max = 99,
    this.showZero = false,
    this.child,
    this.dot = false,
    this.invisible = false,
    this.placement = NebaCorner.topEnd,
    this.overlap = NebaBadgeOverlap.square,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : content = null,
       assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// What the badge says, usually a [Text]. Left out, the badge is a dot.
  final Widget? content;

  /// The number a [NebaBadge.count] shows.
  final int? count;

  /// The largest [count] shown as it is; above it the badge says `99+`.
  final int max;

  /// Whether a [count] of zero is shown. Zero unread is not news.
  final bool showZero;

  /// What the badge is pinned to. Without it the badge is a mark of its own.
  final Widget? child;

  /// Draws a dot even when there is something to say, which a screen reader
  /// still hears.
  final bool dot;

  /// Hides the mark and keeps its room, so showing it again moves nothing.
  final bool invisible;

  /// Which corner of the [child] the mark sits on.
  final NebaCorner placement;

  /// The shape of the [child], which decides how far the mark tucks in.
  final NebaBadgeOverlap overlap;

  /// The mark's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.solid].
  final NebaVariant? variant;

  /// The mark's size, on a ladder of its own: a `md` badge is 18 logical
  /// pixels tall. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The room around the digits, and nothing else.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// What a screen reader hears instead of the bare content: "3 unread
  /// notifications" rather than "3".
  final String? semanticLabel;

  /// The mark's height at each size.
  static const Map<NebaSize, double> height = <NebaSize, double>{
    NebaSize.xs: 14,
    NebaSize.sm: 16,
    NebaSize.md: 18,
    NebaSize.lg: 20,
    NebaSize.xl: 24,
  };

  /// The dot's side at each size.
  static const Map<NebaSize, double> dotSize = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 10,
    NebaSize.lg: 10,
    NebaSize.xl: 12,
  };

  static const Map<NebaSize, double> _text = <NebaSize, double>{
    NebaSize.xs: 9,
    NebaSize.sm: 10,
    NebaSize.md: 11,
    NebaSize.lg: 12,
    NebaSize.xl: 13,
  };

  static const Map<NebaDensity, Map<NebaSize, double>> _padding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 4,
          NebaSize.md: 6,
          NebaSize.lg: 6,
          NebaSize.xl: 8,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 2,
          NebaSize.md: 4,
          NebaSize.lg: 4,
          NebaSize.xl: 6,
        },
      };

  /// How far a mark hangs past its corner, per size: half a badge, and less
  /// of a dot.
  static const Map<NebaSize, (double, double)> _overhang = <NebaSize, (double, double)>{
    NebaSize.xs: (6, 2),
    NebaSize.sm: (8, 4),
    NebaSize.md: (8, 4),
    NebaSize.lg: (10, 4),
    NebaSize.xl: (12, 6),
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(color ?? NebaColor.primary);

    final int? count = this.count;
    final bool zero = count == 0 && !showZero;
    final Widget? said = count != null
        ? (zero ? null : Text(count > max ? '$max+' : '$count'))
        : content;
    final bool asDot = dot || said == null;
    final bool hidden = invisible || (zero && !dot);
    final String? spoken = semanticLabel ?? (count != null && !zero ? (said! as Text).data : null);

    final (Color fill, Color? edge, NebaPlate plate, Color ink, bool textured) = switch (variant) {
      NebaVariant.solid => (roles.fill, null, NebaPlate.solid, roles.family.onSolid, true),
      NebaVariant.outline => (roles.panel, roles.line, NebaPlate.glass, roles.onTint, true),
      NebaVariant.text => (tintPlate(tokens, roles), null, NebaPlate.none, roles.onTint, false),
    };
    final double tall = asDot ? dotSize[size]! : height[size]!;
    final double inner = tall - (edge == null ? 0 : 2);
    final BorderRadius radius = BorderRadius.circular(tall);

    Widget mark = NebaSheet(
      fill: fill,
      edge: edge,
      plate: plate,
      elevation: elevation,
      borderRadius: radius,
      blur: textured,
      texture: textured,
      child: asDot
          ? SizedBox.square(dimension: inner)
          : ConstrainedBox(
              constraints: BoxConstraints(minWidth: inner, minHeight: inner, maxHeight: inner),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _padding[density]![size]!),
                child: Center(
                  widthFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: ink,
                      fontSize: _text[size],
                      height: 1,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                    ),
                    softWrap: false,
                    child: said,
                  ),
                ),
              ),
            ),
    );

    mark = NebaRing(borderRadius: radius, child: mark);

    // A mark that is not there says nothing, and a dot with nothing to say is
    // decoration; otherwise the sentence is read, or the count once.
    mark = hidden || (asDot && spoken == null && said == null)
        ? ExcludeSemantics(child: mark)
        : spoken != null
        ? Semantics(container: true, label: spoken, excludeSemantics: true, child: mark)
        : Semantics(container: true, child: mark);

    // Hidden but holding its box, so nothing around it moves when it returns.
    mark = Visibility(
      visible: !hidden,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: mark,
    );

    final Widget? anchor = child;

    if (anchor == null) {
      return mark;
    }

    final (double badgeOverhang, double dotOverhang) = _overhang[size]!;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        anchor,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomSingleChildLayout(
              delegate: _Corner(
                placement: placement,
                overhang: asDot ? dotOverhang : badgeOverhang,
                circle: overlap == NebaBadgeOverlap.circle,
                direction: Directionality.of(context),
              ),
              child: mark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Puts the mark on a corner of the anchor, [overhang] past each of its two
/// edges, and in by 7% of the anchor's width on a round one: what CSS does
/// with negative margins and a percentage margin, which resolves against the
/// width on both axes.
class _Corner extends SingleChildLayoutDelegate {
  _Corner({
    required this.placement,
    required this.overhang,
    required this.circle,
    required this.direction,
  });

  final NebaCorner placement;
  final double overhang;
  final bool circle;
  final TextDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double inset = circle ? size.width * 0.07 : 0;
    final bool top = placement == NebaCorner.topStart || placement == NebaCorner.topEnd;
    final bool start = placement == NebaCorner.topStart || placement == NebaCorner.bottomStart;
    final bool left = start == (direction == TextDirection.ltr);

    final double x = left ? -overhang + inset : size.width - childSize.width + overhang - inset;
    final double y = top ? -overhang + inset : size.height - childSize.height + overhang - inset;

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_Corner oldDelegate) {
    return oldDelegate.placement != placement ||
        oldDelegate.overhang != overhang ||
        oldDelegate.circle != circle ||
        oldDelegate.direction != direction;
  }
}
