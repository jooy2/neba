/// `NebaAppLogo`, a product's mark with or without its name.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/initials.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The shape a [NebaAppLogo] stands in.
enum NebaAppLogoShape {
  /// The artwork as it is, or the name set as a logotype.
  bare,

  /// A rounded square tile, as an app icon is.
  app,

  /// A disc.
  circle,
}

/// A product's mark, with or without its name beside it.
///
/// [image] is a picture of the mark and [child] a drawing of it, which takes
/// the colour around it; with neither, a `bare` logo sets the [name] as a
/// logotype and a tile sets its initials. [shape] puts the mark on a tile
/// that the colour [variant] fills, [showName] sets the name beside a mark,
/// and [onPressed] makes the whole logo a link, as a logo in a header is.
///
/// ```dart
/// const NebaAppLogo(name: 'Neba', shape: NebaAppLogoShape.app, showName: true)
/// ```
class NebaAppLogo extends StatelessWidget {
  /// The mark of [name].
  const NebaAppLogo({
    this.name,
    this.image,
    this.child,
    this.semanticLabel,
    this.initials,
    this.showName = false,
    this.shape = NebaAppLogoShape.bare,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.elevation = 0,
    this.padded = true,
    this.height,
    this.onPressed,
    this.href,
    this.newTab = false,
    this.locale,
    this.focusNode,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The product's name: the logotype, the initials, the name beside a mark
  /// and what a screen reader hears.
  final String? name;

  /// A picture of the mark, drawn as it came.
  final ImageProvider? image;

  /// A drawing of the mark, laid out at the mark's height. It takes the
  /// colour around it, and a drawing with no width of its own takes one from
  /// an [AspectRatio].
  final Widget? child;

  /// What a screen reader hears when it is not the name, React's `alt`.
  final String? semanticLabel;

  /// The letters a tile shows with no artwork. Defaults to the first letters
  /// of the name's first and last words.
  final String? initials;

  /// Whether the name is set beside the mark. A logotype is the name already.
  final bool showName;

  /// The shape the mark stands in.
  final NebaAppLogoShape shape;

  /// The weight of a tile. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.solid].
  final NebaVariant? variant;

  /// The mark's height, on the control ladder, and the name's type. Defaults
  /// to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of a tile and of the focus ring.
  final NebaColor color;

  /// A tile's drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether a tile leaves room around its artwork, which then fills 72% of
  /// it.
  final bool padded;

  /// The mark's height in logical pixels, in place of the size's.
  final double? height;

  /// What the logo does as a link, usually going home. `null` leaves it a
  /// picture.
  final VoidCallback? onPressed;

  /// Where the link goes, for a screen reader and, on the web, the browser.
  final Uri? href;

  /// Whether the link leaves the app, said to a screen reader.
  final bool newTab;

  /// The language the new-tab notice is written in.
  final Locale? locale;

  /// The link's focus node.
  final FocusNode? focusNode;

  /// A logotype's text size at each step.
  static const Map<NebaSize, double> logotypeText = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 14,
    NebaSize.md: 17,
    NebaSize.lg: 22,
    NebaSize.xl: 26,
  };

  /// A tile's letters at each step.
  static const Map<NebaSize, double> tileLetters = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 14,
    NebaSize.md: 17,
    NebaSize.lg: 21,
    NebaSize.xl: 25,
  };

  /// A tile's corners at each step.
  static const Map<NebaSize, double> tileRadius = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 7,
    NebaSize.md: 9,
    NebaSize.lg: 11,
    NebaSize.xl: 14,
  };

  /// How much of a padded tile its artwork fills.
  static const double inset = 0.72;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(color);
    final bool tile = shape != NebaAppLogoShape.bare;
    final String name = this.name ?? '';
    final bool lettering = image == null && child == null;
    final bool logotype = lettering && !tile;
    final bool drawName = showName && !logotype && name.isNotEmpty;
    final double box = height ?? NebaScale.controlHeight[size]!;
    final double art = tile && padded ? box * inset : box;
    final String letters = initials ?? initialsOf(name);

    // Letters and a logotype are set tight, as CSS `tracking-tight` sets them.
    TextStyle lettered(double fontSize, Color? colour) => TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.025 * fontSize,
      height: 1,
      color: colour,
    );

    Widget artwork() {
      final ImageProvider? image = this.image;
      final Widget? child = this.child;

      if (image != null) {
        return Image(
          image: image,
          height: art,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
              SizedBox(width: art, height: art),
        );
      }

      return SizedBox(height: art, child: child);
    }

    Widget mark;

    if (tile) {
      final (
        Color fill,
        Color? edge,
        NebaPlate plate,
        Color ink,
        bool textured,
      ) = switch (variant) {
        NebaVariant.solid => (roles.fill, null, NebaPlate.solid, roles.family.onSolid, true),
        NebaVariant.outline => (roles.panel, roles.line, NebaPlate.glass, roles.onTint, true),
        NebaVariant.text => (tintPlate(tokens, roles), null, NebaPlate.none, roles.onTint, false),
      };
      final BorderRadius radius = BorderRadius.circular(
        shape == NebaAppLogoShape.circle ? box / 2 : tileRadius[size]!,
      );

      mark = NebaSheet(
        fill: fill,
        edge: edge,
        plate: plate,
        elevation: elevation,
        borderRadius: radius,
        blur: textured,
        texture: textured,
        child: SizedBox.square(
          dimension: box - (edge == null ? 0 : 2),
          child: Center(
            child: DefaultTextStyle.merge(
              style: lettered(tileLetters[size]!, ink),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              child: IconTheme.merge(
                data: IconThemeData(color: ink, size: art),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: art, maxHeight: art),
                  child: lettering ? Text(letters) : artwork(),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (logotype) {
      mark = SizedBox(
        height: box,
        child: Center(
          widthFactor: 1,
          child: Text(
            name,
            style: lettered(logotypeText[size]!, tokens.fg),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      );
    } else {
      mark = IconTheme.merge(
        data: IconThemeData(color: tokens.fg, size: art),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: tokens.fg),
          child: artwork(),
        ),
      );
    }

    Widget logo = mark;

    if (drawName) {
      logo = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: NebaScale.gap[size]!,
        children: <Widget>[
          mark,
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: logotypeText[size],
                fontWeight: FontWeight.w600,
                color: tokens.fg,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // One node, named as the logo reads: the name drawn beside it or as it,
    // or else what the artwork means.
    final String? label = drawName || logotype
        ? name
        : semanticLabel ?? (name.isEmpty ? null : name);
    final bool link = onPressed != null;
    final String? notice = link && newTab
        ? nebaMessages(context, 'link', locale: locale)['newTab']
        : null;

    logo = ExcludeSemantics(child: logo);

    if (link) {
      final Widget drawn = logo;
      logo = NebaInteractive(
        onTap: onPressed,
        focusNode: focusNode,
        activatesOnSpace: false,
        builder: (BuildContext context, NebaInteraction interaction, _) => NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
          child: drawn,
        ),
      );
    }

    return Semantics(
      container: true,
      // Artwork that speaks for itself is a picture; a name in letters is
      // text, as it reads.
      image: !link && !lettering && !drawName && label != null,
      link: link,
      linkUrl: link ? nebaSafeHref(href) : null,
      label: notice == null || label == null ? label : '$label\n$notice',
      child: logo,
    );
  }
}
