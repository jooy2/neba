/// The acrylic sheet every surface is cut from: the React package's
/// `surfaceClasses`, the plate and the elevation ladder, in one widget.
///
/// From the back: the drop shadow, outside the sheet's corners; the page
/// behind, blurred and saturated (`--neba-blur`); the fill; the grain laid
/// over it in `overlay`; the sheen falling across at 148°; the plate, which is
/// the brighter top edge where the light lands and, on a solid plate, the full
/// white hairline of the cut edge; and the coloured edge of an outlined
/// surface on top. There is no dark bottom bevel. That was what made a surface
/// read as moulded plastic.
///
/// The fill changes in zero time while [NebaSheet.pressed] and settles over
/// `NebaScale.durationFill` after, the edge and the shadow over
/// `NebaScale.duration`, which is the house press signature.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';

/// Which plate a sheet carries.
enum NebaPlate {
  /// The top light and the full hairline: a filled surface.
  solid,

  /// The top light alone: a translucent surface whose edge is its border.
  glass,

  /// Nothing: a groove, a wash, or a control too small for a 1-pixel line to
  /// be light on an edge rather than a fifteenth of the object.
  none,
}

/// An acrylic sheet of [fill], with [child] on it.
class NebaSheet extends StatelessWidget {
  /// A sheet of [fill] with the given edge, plate and elevation.
  const NebaSheet({
    required this.fill,
    this.edge,
    this.plate = NebaPlate.solid,
    this.elevation = 0,
    this.borderRadius = BorderRadius.zero,
    this.pressed = false,
    this.blur = true,
    this.texture = true,
    this.plateOnTop = false,
    this.fillDuration,
    this.child,
    super.key,
  });

  /// The sheet's colour, usually translucent.
  final Color fill;

  /// A 1-pixel border inside the sheet, for an outlined surface.
  final Color? edge;

  /// The light on the sheet's edge.
  final NebaPlate plate;

  /// The drop shadow, from `0`, which is none, to `4`.
  final int elevation;

  /// The sheet's corners.
  final BorderRadius borderRadius;

  /// Whether the sheet is held down, which lands every change in zero time.
  final bool pressed;

  /// Whether the page behind is blurred. A sheet with nothing behind it worth
  /// blurring, or many small ones in a row, may leave it off.
  final bool blur;

  /// Whether the grain and the sheen are laid over the fill. A wash or a
  /// groove has neither.
  final bool texture;

  /// Whether the plate is drawn over [child] rather than under it: for a
  /// sheet whose content reaches its edge, such as a picture, which would
  /// otherwise cover the light along the top and the hairline with it.
  final bool plateOnTop;

  /// How long the fill takes to settle, `NebaScale.durationFill` when left
  /// out. A field answers its focus over `NebaScale.duration` instead, the
  /// edge's and the ring's, because a fill that took longer would still be
  /// arriving once the reader had started typing.
  final Duration? fillDuration;

  /// What is on the sheet.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Duration edgeDuration = nebaDuration(context, NebaScale.duration, instant: pressed);
    final Duration fillDuration = nebaDuration(
      context,
      this.fillDuration ?? NebaScale.durationFill,
      instant: pressed,
    );
    // An edge is a CSS border, which takes a pixel of the box rather than
    // lying over what is in it: content that runs to the edges of an outlined
    // sheet stops inside the hairline.
    final Widget? content = edge == null || child == null
        ? child
        : Padding(padding: const EdgeInsets.all(1), child: child);

    Widget sheet = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: edge ?? edgeless),
      duration: edgeDuration,
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? edgeColor, Widget? child) {
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: fill),
          duration: fillDuration,
          curve: NebaScale.ease,
          builder: (BuildContext context, Color? fillColor, Widget? child) {
            return CustomPaint(
              painter: _SheetPainter(
                fill: fillColor ?? fill,
                edge: edgeColor ?? edgeless,
                tokens: tokens,
                plate: plateOnTop ? NebaPlate.none : plate,
                texture: texture,
                borderRadius: borderRadius,
              ),
              foregroundPainter: plateOnTop && plate != NebaPlate.none
                  ? _PlatePainter(tokens: tokens, plate: plate, borderRadius: borderRadius)
                  : null,
              child: child,
            );
          },
          child: child,
        );
      },
      child: content,
    );

    if (blur && tokens.blurSigma > 0) {
      sheet = BackdropFilter(filter: backdropFilter(tokens), child: sheet);
    }

    return AnimatedContainer(
      duration: edgeDuration,
      curve: NebaScale.ease,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: tokens.elevation(elevation)),
      child: ClipRRect(borderRadius: borderRadius, child: sheet),
    );
  }
}

/// No edge: transparent, so an edge that arrives fades in rather than snaps.
const Color edgeless = Color(0x00000000);

/// `--neba-blur`: the backdrop blurred by the theme's sigma and saturated by
/// its factor.
ui.ImageFilter backdropFilter(NebaTokens tokens) {
  return ui.ImageFilter.compose(
    outer: ui.ColorFilter.matrix(saturationMatrix(tokens.saturation)),
    inner: ui.ImageFilter.blur(sigmaX: tokens.blurSigma, sigmaY: tokens.blurSigma),
  );
}

/// CSS `saturate(amount)` as a colour matrix, as the Filter Effects
/// specification defines it.
List<double> saturationMatrix(double amount) {
  final double s = amount;

  return <double>[
    0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0, //
    0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0, //
    0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// The two ends of a CSS `linear-gradient(<angle>deg, …)` over [size].
///
/// CSS measures the angle clockwise from "to top" and makes the gradient line
/// exactly long enough that the corners touch its ends, which is not where an
/// [Alignment] pair would put them on anything but a square.
(Offset, Offset) cssGradientEnds(Size size, double degrees) {
  final double angle = degrees * math.pi / 180;
  final Offset direction = Offset(math.sin(angle), -math.cos(angle));
  final double length =
      (size.width * math.sin(angle)).abs() + (size.height * math.cos(angle)).abs();
  final Offset center = size.center(Offset.zero);
  final Offset half = direction * (length / 2);

  return (center - half, center + half);
}

class _SheetPainter extends CustomPainter {
  _SheetPainter({
    required this.fill,
    required this.edge,
    required this.tokens,
    required this.plate,
    required this.texture,
    required this.borderRadius,
  }) : super(repaint: texture ? NebaGrain.tile : null);

  final Color fill;
  final Color edge;
  final NebaTokens tokens;
  final NebaPlate plate;
  final bool texture;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Offset.zero & size;
    final RRect shape = borderRadius.toRRect(box);

    canvas.drawRRect(shape, Paint()..color = fill);

    if (texture) {
      final ui.Image? grain = NebaGrain.tile.value;

      if (grain != null) {
        canvas.drawRRect(
          shape,
          Paint()
            ..blendMode = BlendMode.overlay
            ..shader = ImageShader(
              grain,
              TileMode.repeated,
              TileMode.repeated,
              Matrix4.identity().storage,
            ),
        );
      }

      final (Offset from, Offset to) = cssGradientEnds(size, 148);
      canvas.drawRRect(
        shape,
        Paint()
          ..shader = ui.Gradient.linear(
            from,
            to,
            <Color>[tokens.sheen, tokens.sheen.withValues(alpha: 0)],
            <double>[0, 0.52],
          ),
      );
    }

    _paintPlate(canvas, shape, tokens, plate);

    if (edge.a > 0) {
      _strokeInside(canvas, shape, edge);
    }
  }

  @override
  bool shouldRepaint(_SheetPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.edge != edge ||
        oldDelegate.tokens != tokens ||
        oldDelegate.plate != plate ||
        oldDelegate.texture != texture ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// The plate on its own, over a sheet's content.
class _PlatePainter extends CustomPainter {
  _PlatePainter({required this.tokens, required this.plate, required this.borderRadius});

  final NebaTokens tokens;
  final NebaPlate plate;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    _paintPlate(canvas, borderRadius.toRRect(Offset.zero & size), tokens, plate);
  }

  @override
  bool shouldRepaint(_PlatePainter oldDelegate) {
    return oldDelegate.tokens != tokens ||
        oldDelegate.plate != plate ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// The light along the top of [shape] and, on a solid plate, the full white
/// hairline of the cut edge.
void _paintPlate(Canvas canvas, RRect shape, NebaTokens tokens, NebaPlate plate) {
  if (plate != NebaPlate.none) {
    // `inset 0 1px 0`: the sheet minus itself moved down a pixel, which
    // leaves a 1-pixel band along the top that follows the corners.
    final Path top = Path.combine(
      PathOperation.difference,
      Path()..addRRect(shape),
      Path()..addRRect(shape.shift(const Offset(0, 1))),
    );
    canvas.drawPath(top, Paint()..color = tokens.plateTop);
  }

  if (plate == NebaPlate.solid) {
    _strokeInside(canvas, shape, tokens.plateEdge);
  }
}

/// A 1-pixel line just inside [shape], as an inset `0 0 0 1px` shadow or a
/// border draws it.
void _strokeInside(Canvas canvas, RRect shape, Color color) {
  canvas.drawRRect(
    shape.deflate(0.5),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color,
  );
}

/// A `text` mark's own bed, the React package's `.neba-tint-plate`: the
/// family's wash laid over the page's surface rather than over whatever the
/// mark was dropped on, so its ink reads the same on every sheet. For a
/// Badge, an Avatar and an AppLogo, which a caller puts inside other things.
Color tintPlate(NebaTokens tokens, NebaColorRoles roles) {
  return Color.alphaBlend(roles.softHover, tokens.surface);
}

/// The grain, `--neba-grain`: one 120-pixel tile of greyscale noise under 12%,
/// decoded once and laid over every sheet in `overlay`.
///
/// Frosted, not polished: the grain is what separates sandblasted acrylic from
/// a pane of glass, and the one thing a flat fill cannot fake. The React
/// package draws it with an SVG fractal-noise filter; at its frequency the
/// noise is close to a pixel per sample, so a seeded per-pixel noise is the
/// same tooth. Seeded, so every build and every test draws the same grain.
abstract final class NebaGrain {
  /// The tile's side, in logical pixels.
  static const int size = 120;

  /// How much of the tile is drawn.
  static const double opacity = 0.12;

  static final ValueNotifier<ui.Image?> _tile = ValueNotifier<ui.Image?>(null);
  static bool _started = false;

  /// The decoded tile, `null` until the first sheet asked for it has been
  /// painted and the decode has finished. A sheet repaints when it arrives.
  static ValueListenable<ui.Image?> get tile {
    if (!_started) {
      _started = true;
      ui.decodeImageFromPixels(
        pixels(),
        size,
        size,
        ui.PixelFormat.rgba8888,
        (ui.Image image) => _tile.value = image,
      );
    }

    return _tile;
  }

  /// The tile's RGBA bytes, premultiplied, as [ui.PixelFormat.rgba8888]
  /// reads them.
  ///
  /// Each pixel follows what the SVG does to its noise. `feTurbulence` gives
  /// four channels that sit around the middle of their range, so each is the
  /// mean of four draws rather than one; the colour is their luminance, as
  /// `saturate(0)` takes it, turned from the linear light a filter works in to
  /// sRGB; and the alpha is the noise's own under the rect's 12%. One uniform
  /// draw per pixel at the full 12% was a grain several times as coarse.
  @visibleForTesting
  static Uint8List pixels() {
    final math.Random random = math.Random(85);
    final Uint8List bytes = Uint8List(size * size * 4);

    double channel() {
      return (random.nextDouble() +
              random.nextDouble() +
              random.nextDouble() +
              random.nextDouble()) /
          4;
    }

    double toSrgb(double linear) {
      return linear <= 0.0031308
          ? linear * 12.92
          : 1.055 * math.pow(linear, 1 / 2.4).toDouble() - 0.055;
    }

    for (int i = 0; i < size * size; i++) {
      final double grey = toSrgb(0.2126 * channel() + 0.7152 * channel() + 0.0722 * channel());
      final double alpha = opacity * channel();
      final int premultiplied = (grey * alpha * 255).round();

      bytes[i * 4] = premultiplied;
      bytes[i * 4 + 1] = premultiplied;
      bytes[i * 4 + 2] = premultiplied;
      bytes[i * 4 + 3] = (alpha * 255).round();
    }

    return bytes;
  }
}
