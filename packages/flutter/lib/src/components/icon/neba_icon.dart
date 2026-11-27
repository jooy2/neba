/// `NebaIcon`, a glyph on the library's size and colour axes.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A glyph on the library's size and colour axes. Neba ships no icon set, so
/// [icon] comes from whichever one the app chose: an `Icon` of an icon font,
/// a drawing, a picture.
///
/// The glyph is handed the size and the colour through [IconTheme] and
/// [DefaultTextStyle], and laid out in a square of [size]. With no [color] it
/// takes the colour of the text around it, as CSS `currentColor` does, so an
/// icon inside a button comes out in the button's ink. It is silent to a
/// screen reader unless it has a [semanticLabel].
///
/// ```dart
/// const NebaIcon(icon: BoltGlyph(), size: NebaSize.lg, color: NebaColor.warning)
/// ```
class NebaIcon extends StatelessWidget {
  /// [icon] at [size] in [color].
  const NebaIcon({
    required this.icon,
    this.size = NebaSize.md,
    this.color,
    this.semanticLabel,
    this.transition,
    super.key,
  });

  /// The glyph.
  final Widget icon;

  /// The icon's own steps, 14, 16, 20, 24 and 28 pixels: the sizes icon sets
  /// are drawn at, so a glyph lands on the pixel grid.
  final NebaSize size;

  /// The family the glyph is drawn in. Left out, the colour of the text
  /// around it.
  final NebaColor? color;

  /// What the glyph means, for a glyph that carries meaning on its own. Left
  /// out, the icon is left out of the semantics tree, as most icons sit beside
  /// text that already says the same thing.
  final String? semanticLabel;

  /// How the icon arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final double dimension = NebaScale.iconSize[size]!;
    final NebaColor? color = this.color;
    final Color? ink = color != null
        ? NebaTheme.of(context).roles(color).accent
        : DefaultTextStyle.of(context).style.color ?? IconTheme.of(context).color;

    Widget glyph = SizedBox.square(
      dimension: dimension,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(size: dimension, color: ink),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: dimension, height: 1, color: ink),
            child: icon,
          ),
        ),
      ),
    );

    final String? label = semanticLabel;

    glyph = label == null
        ? ExcludeSemantics(child: glyph)
        : Semantics(
            container: true,
            image: true,
            label: label,
            child: ExcludeSemantics(child: glyph),
          );

    final NebaTransition? transition = this.transition;

    return transition == null ? glyph : NebaEntrance(transition: transition, child: glyph);
  }
}
