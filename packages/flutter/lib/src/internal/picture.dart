/// What a photograph is drawn with, for `NebaImage` and `NebaGallery`: the
/// quarter turn and the mirror, the colour treatment, the watermark, the
/// protection, and the pointer treatment a Gallery tile lays on the picture
/// inside it.
///
/// The library talking to itself: nothing here is exported but the three
/// option types `NebaImage` exports, [NebaImageFlip], [NebaImageFilter] and
/// [NebaImageWatermark].
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/types.dart';

/// Which way a picture is mirrored, along the axes it is shown on, so
/// [horizontal] swaps left and right whatever its turn has done to it.
enum NebaImageFlip {
  /// As stored.
  none,

  /// Left and right swapped.
  horizontal,

  /// Top and bottom swapped.
  vertical,

  /// Both.
  both;

  /// Whether left and right are swapped.
  bool get acrossX => this == horizontal || this == both;

  /// Whether top and bottom are swapped.
  bool get acrossY => this == vertical || this == both;
}

/// How a picture is coloured: seven named treatments, or a colour matrix of
/// your own.
///
/// The React package's `filter`, whose names stand for CSS filter functions.
/// Each one here is the matrix the Filter Effects specification writes for
/// the same function, applied to the picture's sRGB values as a browser
/// applies it, so a treatment looks the same in both packages. Anything past
/// the seven is [NebaImageFilter.matrix], the twenty numbers
/// `ColorFilter.matrix` takes: four rows of red, green, blue, alpha and an
/// offset in 0 to 255.
///
/// A matrix rather than any `ColorFilter`, because a matrix can be eased
/// from one value to the next: a picture whose filter changes travels to the
/// new one over the fill's pace rather than snapping.
@immutable
class NebaImageFilter {
  /// A colour matrix of your own, as `ColorFilter.matrix` reads one: twenty
  /// numbers.
  const NebaImageFilter.matrix(List<double> this.matrix);

  const NebaImageFilter._none() : matrix = null;

  /// No treatment at all.
  static const NebaImageFilter none = NebaImageFilter._none();

  /// No colour: CSS `grayscale(1)`.
  static const NebaImageFilter grayscale = NebaImageFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// Warm and old: CSS `sepia(0.72)`.
  static const NebaImageFilter sepia = NebaImageFilter.matrix(<double>[
    0.393 + 0.607 * 0.28, 0.769 - 0.769 * 0.28, 0.189 - 0.189 * 0.28, 0, 0, //
    0.349 - 0.349 * 0.28, 0.686 + 0.314 * 0.28, 0.168 - 0.168 * 0.28, 0, 0, //
    0.272 - 0.272 * 0.28, 0.534 - 0.534 * 0.28, 0.131 + 0.869 * 0.28, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// A negative: CSS `invert(1)`.
  static const NebaImageFilter invert = NebaImageFilter.matrix(<double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ]);

  /// Half as colourful again: CSS `saturate(1.5)`.
  static const NebaImageFilter saturate = NebaImageFilter.matrix(<double>[
    0.213 + 0.787 * 1.5, 0.715 - 0.715 * 1.5, 0.072 - 0.072 * 1.5, 0, 0, //
    0.213 - 0.213 * 1.5, 0.715 + 0.285 * 1.5, 0.072 - 0.072 * 1.5, 0, 0, //
    0.213 - 0.213 * 1.5, 0.715 - 0.715 * 1.5, 0.072 + 0.928 * 1.5, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// Under half the colour: CSS `saturate(0.45)`.
  static const NebaImageFilter mute = NebaImageFilter.matrix(<double>[
    0.213 + 0.787 * 0.45, 0.715 - 0.715 * 0.45, 0.072 - 0.072 * 0.45, 0, 0, //
    0.213 - 0.213 * 0.45, 0.715 + 0.285 * 0.45, 0.072 - 0.072 * 0.45, 0, 0, //
    0.213 - 0.213 * 0.45, 0.715 - 0.715 * 0.45, 0.072 + 0.928 * 0.45, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  /// A quarter more contrast: CSS `contrast(1.25)`.
  static const NebaImageFilter contrast = NebaImageFilter.matrix(<double>[
    1.25, 0, 0, 0, -0.125 * 255, //
    0, 1.25, 0, 0, -0.125 * 255, //
    0, 0, 1.25, 0, -0.125 * 255, //
    0, 0, 0, 1, 0, //
  ]);

  /// The matrix, or `null` for [none].
  final List<double>? matrix;

  @override
  bool operator ==(Object other) {
    return other is NebaImageFilter && listEquals(other.matrix, matrix);
  }

  @override
  int get hashCode => matrix == null ? 0 : Object.hashAll(matrix!);
}

/// The matrix that changes nothing.
const List<double> nebaIdentityMatrix = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// CSS `brightness(amount)`, which a Gallery tile's `dim` darkens by.
List<double> nebaBrightness(double amount) {
  return <double>[
    amount, 0, 0, 0, 0, //
    0, amount, 0, 0, 0, //
    0, 0, amount, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// [first] and then [then], as one matrix: what a CSS filter chain of the two
/// does, in that order.
List<double> nebaComposeMatrices(List<double> first, List<double> then) {
  final List<double> out = List<double>.filled(20, 0);

  for (int row = 0; row < 4; row++) {
    for (int column = 0; column < 5; column++) {
      double sum = column == 4 ? then[row * 5 + 4] : 0;

      for (int k = 0; k < 4; k++) {
        sum += then[row * 5 + k] * first[k * 5 + column];
      }

      out[row * 5 + column] = sum;
    }
  }

  return out;
}

/// Whether [matrix] changes nothing, to within a rounding error.
bool nebaIsIdentity(List<double> matrix) {
  for (int i = 0; i < 20; i++) {
    if ((matrix[i] - nebaIdentityMatrix[i]).abs() > 1e-6) {
      return false;
    }
  }

  return true;
}

/// A turn as a count of quarters, whatever number of degrees arrived: `-90`
/// is the `270` it means, and `45` is the nearest quarter.
int nebaQuarters(num degrees) {
  if (!degrees.isFinite) {
    return 0;
  }

  return ((degrees / 90).round() % 4 + 4) % 4;
}

/// Where a picture is placed in its own frame, so that [position] holds on
/// the picture as it is shown after [quarters] clockwise quarter turns and
/// [flip].
///
/// The React package's `objectPosition`: a fit is laid out in the picture's
/// own frame, before it is turned, so `top` on a picture turned upside down
/// would keep what ends up at the bottom. The mirror is undone first, because
/// it is applied along the screen's axes after the turn, then the turn, a
/// quarter at a time.
Alignment nebaPlacedAlignment(Alignment position, int quarters, NebaImageFlip flip) {
  double across = (position.x + 1) / 2;
  double down = (position.y + 1) / 2;

  if (flip.acrossX) {
    across = 1 - across;
  }

  if (flip.acrossY) {
    down = 1 - down;
  }

  for (int turn = 0; turn < quarters; turn++) {
    // One quarter clockwise draws the picture's left edge along the top of
    // the screen, so what is across on the screen was down the picture.
    final double was = across;
    across = down;
    down = 1 - was;
  }

  return Alignment(across * 2 - 1, down * 2 - 1);
}

/// [child] turned clockwise by [quarters] and mirrored by [flip] along the
/// screen's axes.
///
/// Laid out at the box's height by its width when it is on its side, which
/// is what lets a fit work on a turned picture at all, as the React package
/// lays its `<img>` out at the swapped size. The turn and the mirror are
/// transforms of the picture and of nothing else: the design language allows
/// them on a photograph, which carries no label to resample, and never on a
/// control.
Widget nebaPose({required int quarters, required NebaImageFlip flip, required Widget child}) {
  Widget posed = quarters == 0 ? child : RotatedBox(quarterTurns: quarters, child: child);

  if (flip != NebaImageFlip.none) {
    posed = Transform.flip(flipX: flip.acrossX, flipY: flip.acrossY, child: posed);
  }

  return posed;
}

/// [child] coloured by [matrix], and eased to a new matrix over the fill's
/// pace when it changes: the React package names `filter` in the picture's
/// transition, so a treatment that changes travels rather than snapping.
class NebaColorTreated extends StatelessWidget {
  /// [child] under [matrix].
  const NebaColorTreated({required this.matrix, required this.child, super.key});

  /// The colour matrix, or `null` for none.
  final List<double>? matrix;

  /// The picture.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<List<double>>(
      tween: _MatrixTween(end: matrix ?? nebaIdentityMatrix),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      child: child,
      builder: (BuildContext context, List<double> value, Widget? child) {
        if (nebaIsIdentity(value)) {
          return child!;
        }

        return ColorFiltered(colorFilter: ColorFilter.matrix(value), child: child);
      },
    );
  }
}

class _MatrixTween extends Tween<List<double>> {
  _MatrixTween({super.end});

  @override
  List<double> lerp(double t) {
    final List<double> from = begin ?? end!;
    final List<double> to = end!;

    return <double>[for (int i = 0; i < 20; i++) from[i] + (to[i] - from[i]) * t];
  }
}

/// What a Gallery tile lays on the picture inside it while the pointer or the
/// keyboard focus is on it: the `zoom` that scales the photograph inside a
/// frame that never moves, and the `dim` that darkens it. A `NebaImage` reads
/// it for its picture alone, and not for the copy behind it or the stand-in
/// under it, as the React package hands the treatment to the `<img>` alone.
class NebaPictureTreatment extends InheritedWidget {
  /// A treatment of [scale] and [brightness] for the picture below.
  const NebaPictureTreatment({
    required this.scale,
    required this.brightness,
    required super.child,
    super.key,
  });

  /// How far the photograph is scaled about its centre, `1` for not at all.
  final double scale;

  /// CSS `brightness()`, `1` for none.
  final double brightness;

  /// The treatment above [context], if any.
  static NebaPictureTreatment? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaPictureTreatment>();
  }

  @override
  bool updateShouldNotify(NebaPictureTreatment oldWidget) {
    return scale != oldWidget.scale || brightness != oldWidget.brightness;
  }
}

/// [child] scaled by [scale] about its centre, eased over the fill's pace,
/// and in no time for a reader who asked for less motion.
class NebaPictureZoom extends StatelessWidget {
  /// [child] at [scale].
  const NebaPictureZoom({required this.scale, required this.child, super.key});

  /// How far it is scaled.
  final double scale;

  /// The photograph.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: scale),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      child: child,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(scale: value, child: child);
      },
    );
  }
}

/// A mark drawn over a picture: a credit line, a licence, the word DRAFT.
///
/// A deterrent and not a lock. It is drawn over the picture rather than into
/// it, so the file is exactly what it was; what a mark stops is the copy made
/// without thinking about it.
@immutable
class NebaImageWatermark {
  /// A line of [text], placed once at [position] or tiled across the whole
  /// picture with [repeat].
  const NebaImageWatermark(
    String this.text, {
    this.position = AlignmentDirectional.bottomEnd,
    this.repeat = false,
    this.opacity = 0.35,
    this.rotate,
    this.size,
    this.fontSize,
    this.color,
  }) : child = null,
       assert(opacity >= 0 && opacity <= 1);

  /// A widget of your own, a logo, placed once at [position]: a widget cannot
  /// be drawn into a tile.
  const NebaImageWatermark.widget(
    Widget this.child, {
    this.position = AlignmentDirectional.bottomEnd,
    this.opacity = 0.35,
    this.rotate,
    this.size,
    this.fontSize,
    this.color,
  }) : text = null,
       repeat = false,
       assert(opacity >= 0 && opacity <= 1);

  /// The line of text, for a mark made of one.
  final String? text;

  /// The widget, for a mark made of one.
  final Widget? child;

  /// Where a single mark sits, 8 pixels in from the edges. The React
  /// package's corners and `center` are the five [AlignmentDirectional]
  /// constants of the same names.
  final AlignmentDirectional position;

  /// Tiles the text across the whole picture instead of placing it once,
  /// which is the arrangement that actually deters a screenshot.
  final bool repeat;

  /// How strongly the mark shows, from `0` to `1`.
  final double opacity;

  /// Turns the mark, in degrees: `0` by default, `-24` when tiled.
  final double? rotate;

  /// The type size, a step of the meta ladder: [NebaSize.xs], 10 pixels, by
  /// default.
  final NebaSize? size;

  /// The type size in logical pixels, over [size].
  final double? fontSize;

  /// The ink. White by default, which is what reads over a photograph.
  final Color? color;
}

/// [mark] laid over the box it is given: once at its position, or tiled
/// across the whole box. It takes no pointer, no selection and no part in
/// the semantics tree, as the React package's mark is `aria-hidden` and
/// `select-none`: what it says belongs in the text around the picture.
class NebaWatermarkLayer extends StatelessWidget {
  /// The layer that draws [mark].
  const NebaWatermarkLayer({required this.mark, super.key});

  /// What to draw.
  final NebaImageWatermark mark;

  @override
  Widget build(BuildContext context) {
    final double fontSize = mark.fontSize ?? NebaScale.metaText[mark.size ?? NebaSize.xs]!;
    final Color ink = mark.color ?? const Color(0xFFFFFFFF);
    final String? text = mark.text;
    final Widget drawn;

    if (mark.repeat && text != null) {
      drawn = CustomPaint(
        painter: _TiledMarkPainter(
          text: text,
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: fontSize, height: 1),
          color: ink,
          degrees: mark.rotate ?? -24,
          direction: Directionality.of(context),
          scaler: MediaQuery.textScalerOf(context),
        ),
      );
    } else {
      final double degrees = mark.rotate ?? 0;
      final Widget content = DefaultTextStyle.merge(
        style: TextStyle(
          color: ink,
          fontSize: fontSize,
          height: 1.2,
          shadows: <Shadow>[
            Shadow(
              color: const Color(0x73000000),
              offset: const Offset(0, 1),
              blurRadius: shadowBlurRadius(2),
            ),
          ],
        ),
        child: text != null ? Text(text) : mark.child!,
      );

      drawn = Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: mark.position,
          // The one turn the no-transform rule does not cover, because this is
          // a mark on a photograph rather than a control: nothing here is
          // pressed, and nothing here is read.
          child: degrees == 0
              ? content
              : Transform.rotate(angle: degrees * math.pi / 180, child: content),
        ),
      );
    }

    return IgnorePointer(
      child: ExcludeSemantics(
        child: SelectionContainer.disabled(
          child: Opacity(opacity: mark.opacity, child: drawn),
        ),
      ),
    );
  }
}

/// The mark tiled across the box, the React package's `TiledMark`: a pattern
/// over a square 1.8 times the box, turned about its centre so the tiling has
/// no seam where the turn runs out, and clipped by the picture's box.
class _TiledMarkPainter extends CustomPainter {
  _TiledMarkPainter({
    required this.text,
    required this.style,
    required this.color,
    required this.degrees,
    required this.direction,
    required this.scaler,
  });

  final String text;
  final TextStyle style;
  final Color color;
  final double degrees;
  final TextDirection direction;
  final TextScaler scaler;

  /// How wide the mark runs, in ems, the React package's estimate: anything
  /// CJK is close to a full em where the Latin average is nearer 0.6.
  static double ems(String text) {
    final RegExp wide = RegExp('[ᄀ-ᇿ⺀-꓏가-퟿豈-﫿︰-﹏]');
    double total = 0;

    for (final int rune in text.runes) {
      total += wide.hasMatch(String.fromCharCode(rune)) ? 1 : 0.6;
    }

    return total;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double em = scaler.scale(style.fontSize ?? 10);
    // The tile, in units of a 16-pixel type size as React writes it.
    final double tileWidth = math.max(16, (16 * (ems(text) + 2.4)).roundToDouble()) / 16 * em;
    final double tileHeight = 52 / 16 * em;

    TextPainter painter(Paint foreground) {
      return TextPainter(
        text: TextSpan(
          text: text,
          // A style of its own rather than the one around it with the paint
          // swapped in, since a text style cannot carry a colour and a paint.
          style: TextStyle(
            fontFamily: style.fontFamily,
            fontFamilyFallback: style.fontFamilyFallback,
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            height: 1,
            foreground: foreground,
          ),
        ),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
    }

    // A thin dark stroke under the fill, so a white mark still reads over a
    // pale photograph: SVG's `paint-order: stroke`.
    final TextPainter stroke = painter(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.0375 * em
        ..color = const Color(0x47000000),
    );
    final TextPainter fill = painter(Paint()..color = color);
    final double baseline = fill.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-size.width * 0.9, -size.height * 0.9);

    for (double y = 0; y < size.height * 1.8; y += tileHeight) {
      for (double x = 0; x < size.width * 1.8; x += tileWidth) {
        final Offset at = Offset(x, y + 2 * em - baseline);
        stroke.paint(canvas, at);
        fill.paint(canvas, at);
      }
    }

    canvas.restore();
    stroke.dispose();
    fill.dispose();
  }

  @override
  bool shouldRepaint(_TiledMarkPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.color != color ||
        oldDelegate.degrees != degrees ||
        oldDelegate.direction != direction ||
        oldDelegate.scaler != scaler;
  }
}

/// The one way a Flutter picture is casually taken: the browser's own menu.
///
/// A picture Flutter draws is pixels on a canvas, so nothing on a phone or a
/// desktop offers to save, copy or drag it out, and a selection has nothing
/// of it to sweep up. On the web the browser's context menu over the canvas
/// still does, so while the pointer is over a protected picture the menu is
/// turned off, and it is turned back on when the pointer leaves, if it was on
/// before. Everywhere else this draws [child] and nothing more.
class NebaPictureGuard extends StatefulWidget {
  /// [child], guarded while [enabled].
  const NebaPictureGuard({required this.enabled, required this.child, super.key});

  /// Whether the menu is held off over [child].
  final bool enabled;

  /// The picture.
  final Widget child;

  @override
  State<NebaPictureGuard> createState() => _NebaPictureGuardState();
}

class _NebaPictureGuardState extends State<NebaPictureGuard> {
  /// Whether this guard turned the menu off and owes it back.
  bool _holding = false;

  void _enter(PointerEnterEvent event) {
    if (!kIsWeb || !widget.enabled || _holding || !BrowserContextMenu.enabled) {
      return;
    }

    _holding = true;
    BrowserContextMenu.disableContextMenu();
  }

  void _release() {
    if (!_holding) {
      return;
    }

    _holding = false;
    BrowserContextMenu.enableContextMenu();
  }

  @override
  void didUpdateWidget(NebaPictureGuard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled) {
      _release();
    }
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !widget.enabled) {
      return widget.child;
    }

    return MouseRegion(
      opaque: false,
      onEnter: _enter,
      onExit: (PointerExitEvent event) => _release(),
      child: widget.child,
    );
  }
}
