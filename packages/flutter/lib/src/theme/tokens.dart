/// The design tokens: the React package's `src/styles.css`, in Dart.
///
/// Every base token is written here the way the stylesheet writes it, as an
/// `oklch()` or an `rgb()` value, and every derived token is the stylesheet's
/// `color-mix()` evaluated with the same numbers. Nothing is copied as hex,
/// so the two packages cannot drift by a rounding: a change to a value in the
/// stylesheet is a change here, and `test/theme/tokens_parity_test.dart`
/// reads the stylesheet and fails until it is made.
///
/// The tokens are resolved once per brightness into an immutable object. A
/// product brings its own colours with [NebaTokens.copyWith] and
/// [NebaTokens.withFamily], and the derived tokens follow, exactly as a CSS
/// override of a base token carries its derived ones along.
library;

import 'dart:ui' show Brightness, Color, Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/types.dart';

/// The five base tokens of one colour family.
///
/// Everything else a widget draws in the family's colour is derived from these
/// and the theme, in [NebaColorRoles].
@immutable
class NebaColorFamily {
  /// A family from its five base tokens and its wash strengths.
  const NebaColorFamily({
    required this.solid,
    required this.solidHover,
    required this.solidActive,
    required this.onSolid,
    required this.accent,
    this.softSteps = const <double>[0.10, 0.17, 0.25],
    this.lineSteps = const <double>[0.22, 0.40],
  });

  /// The filled surface, before it is laid over the page at the fill alpha.
  final Color solid;

  /// [solid] under the pointer.
  final Color solidHover;

  /// [solid] while it is pressed.
  final Color solidActive;

  /// The ink on a filled surface.
  final Color onSolid;

  /// The family's colour on a neutral surface: a hairline, a ring, a tint.
  final Color accent;

  /// How much of [accent] a soft wash is at rest, under the pointer and while
  /// pressed. `warning` is a pale hue and takes a little more of it.
  final List<double> softSteps;

  /// How much of [accent] a hairline is, at rest and under the pointer.
  final List<double> lineSteps;

  /// This family with the given tokens replaced.
  NebaColorFamily copyWith({
    Color? solid,
    Color? solidHover,
    Color? solidActive,
    Color? onSolid,
    Color? accent,
    List<double>? softSteps,
    List<double>? lineSteps,
  }) {
    return NebaColorFamily(
      solid: solid ?? this.solid,
      solidHover: solidHover ?? this.solidHover,
      solidActive: solidActive ?? this.solidActive,
      onSolid: onSolid ?? this.onSolid,
      accent: accent ?? this.accent,
      softSteps: softSteps ?? this.softSteps,
      lineSteps: lineSteps ?? this.lineSteps,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NebaColorFamily &&
        other.solid == solid &&
        other.solidHover == solidHover &&
        other.solidActive == solidActive &&
        other.onSolid == onSolid &&
        other.accent == accent &&
        listEquals(other.softSteps, softSteps) &&
        listEquals(other.lineSteps, lineSteps);
  }

  @override
  int get hashCode {
    return Object.hash(
      solid,
      solidHover,
      solidActive,
      onSolid,
      accent,
      Object.hashAll(softSteps),
      Object.hashAll(lineSteps),
    );
  }
}

/// Every colour a widget draws in one family, resolved against a theme.
///
/// These are the React package's derived tokens, `--neba-{color}-fill` through
/// `--neba-{color}-ring`, under the same names.
@immutable
class NebaColorRoles {
  /// The roles of [family] under [tokens].
  factory NebaColorRoles.resolve(NebaColorFamily family, NebaTokens tokens) {
    final double alpha = tokens.fillAlpha;
    final Color backing = tokens.backing;

    return NebaColorRoles._(
      family: family,
      fill: mixSrgb(family.solid, alpha, backing),
      fillHover: mixSrgb(family.solidHover, alpha, backing),
      fillActive: mixSrgb(family.solidActive, alpha, backing),
      soft: mixSrgb(family.accent, family.softSteps[0], transparent),
      softHover: mixSrgb(family.accent, family.softSteps[1], transparent),
      softPress: mixSrgb(family.accent, family.softSteps[2], transparent),
      onTint: mixOklab(family.accent, 0.72, tokens.fg),
      panel: mixSrgb(family.accent, 0.08, tokens.glassBg),
      panelHover: mixSrgb(family.accent, 0.16, tokens.glassBg),
      panelPress: mixSrgb(family.accent, 0.24, tokens.glassBg),
      line: mixSrgb(family.accent, family.lineSteps[0], transparent),
      lineHover: mixSrgb(family.accent, family.lineSteps[1], transparent),
      ring: mixSrgb(family.accent, tokens.ringAlpha, transparent),
    );
  }

  const NebaColorRoles._({
    required this.family,
    required this.fill,
    required this.fillHover,
    required this.fillActive,
    required this.soft,
    required this.softHover,
    required this.softPress,
    required this.onTint,
    required this.panel,
    required this.panelHover,
    required this.panelPress,
    required this.line,
    required this.lineHover,
    required this.ring,
  });

  /// The base tokens these were derived from.
  final NebaColorFamily family;

  /// A filled surface: [NebaColorFamily.solid] at the fill alpha.
  final Color fill;

  /// [fill] under the pointer.
  final Color fillHover;

  /// [fill] while pressed.
  final Color fillActive;

  /// The faint wash a `text` surface shows under the pointer.
  final Color soft;

  /// [soft] under the pointer.
  final Color softHover;

  /// [soft] while pressed.
  final Color softPress;

  /// Ink on a tinted surface: the accent pulled toward the text colour.
  final Color onTint;

  /// A tinted translucent sheet: what a control's own surface is.
  final Color panel;

  /// [panel] under the pointer.
  final Color panelHover;

  /// [panel] while pressed.
  final Color panelPress;

  /// The hairline edge of a tinted surface.
  final Color line;

  /// [line] under the pointer.
  final Color lineHover;

  /// The focus ring.
  final Color ring;

  /// The filled surface before the fill alpha, for a mark that must be opaque.
  Color get solid => family.solid;

  /// The ink on a filled surface.
  Color get onSolid => family.onSolid;

  /// The family's colour on a neutral surface.
  Color get accent => family.accent;
}

/// The tokens of one theme, light or dark.
///
/// [NebaTokens.light] and [NebaTokens.dark] are the React package's two theme
/// blocks. A widget never builds one: it asks `NebaTheme.of(context)`, which
/// answers with the tokens of the platform's brightness when nothing in the
/// tree pinned a theme.
@immutable
class NebaTokens {
  /// Tokens from their base values. Every derived token is computed here.
  factory NebaTokens({
    required Brightness brightness,
    required Color surface,
    required Color fg,
    required Color mutedFg,
    required Color border,
    required Color disabledBg,
    required Color disabledFg,
    required Color disabledBorder,
    required double fillAlpha,
    required double blurSigma,
    required double saturation,
    required Color backing,
    required double ringAlpha,
    required Color plateEdge,
    required Color plateTop,
    required Color sheen,
    required double glassStrength,
    required List<double> panelSteps,
    required Color groove,
    required Color grooveHover,
    required Color glowOnFill,
    required Color flashOnFill,
    required Color scrim,
    required Color shadowAmbient,
    required Map<NebaColor, NebaColorFamily> families,
    Map<NebaSize, double> radius = defaultRadius,
  }) {
    final NebaTokens tokens = NebaTokens._(
      brightness: brightness,
      surface: surface,
      fg: fg,
      mutedFg: mutedFg,
      border: border,
      disabledBg: disabledBg,
      disabledFg: disabledFg,
      disabledBorder: disabledBorder,
      fillAlpha: fillAlpha,
      blurSigma: blurSigma,
      saturation: saturation,
      backing: backing,
      ringAlpha: ringAlpha,
      plateEdge: plateEdge,
      plateTop: plateTop,
      sheen: sheen,
      glassStrength: glassStrength,
      panelSteps: List<double>.unmodifiable(panelSteps),
      groove: groove,
      grooveHover: grooveHover,
      glowOnFill: glowOnFill,
      flashOnFill: flashOnFill,
      scrim: scrim,
      shadowAmbient: shadowAmbient,
      families: Map<NebaColor, NebaColorFamily>.unmodifiable(families),
      radius: Map<NebaSize, double>.unmodifiable(radius),
      roles: <NebaColor, NebaColorRoles>{},
    );

    for (final NebaColor color in NebaColor.values) {
      final NebaColorFamily? family = families[color];

      if (family == null) {
        throw ArgumentError.value(families, 'families', 'has no $color family');
      }

      tokens._roles[color] = NebaColorRoles.resolve(family, tokens);
    }

    return tokens;
  }

  NebaTokens._({
    required this.brightness,
    required this.surface,
    required this.fg,
    required this.mutedFg,
    required this.border,
    required this.disabledBg,
    required this.disabledFg,
    required this.disabledBorder,
    required this.fillAlpha,
    required this.blurSigma,
    required this.saturation,
    required this.backing,
    required this.ringAlpha,
    required this.plateEdge,
    required this.plateTop,
    required this.sheen,
    required this.glassStrength,
    required this.panelSteps,
    required this.groove,
    required this.grooveHover,
    required this.glowOnFill,
    required this.flashOnFill,
    required this.scrim,
    required this.shadowAmbient,
    required this.families,
    required this.radius,
    required Map<NebaColor, NebaColorRoles> roles,
  }) : _roles = roles,
       glassBg = mixSrgb(white, glassStrength, backing),
       panel = mixSrgb(white, panelSteps[0], backing),
       panelHover = mixSrgb(white, panelSteps[1], backing),
       panelPress = mixSrgb(white, panelSteps[2], backing);

  /// The light theme: the stylesheet's `:root` block.
  factory NebaTokens.light() => _light;

  /// The dark theme: the stylesheet's `.dark` block.
  factory NebaTokens.dark() => _dark;

  /// The theme for [brightness].
  factory NebaTokens.of(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }

  static final NebaTokens _light = NebaTokens(
    brightness: Brightness.light,
    surface: oklch(1, 0, 0),
    fg: oklch(0.24, 0.015, 262),
    mutedFg: oklch(0.56, 0.014, 262),
    border: oklch(0.91, 0.008, 262),
    disabledBg: oklch(0.945, 0.005, 262),
    disabledFg: oklch(0.73, 0.012, 262),
    disabledBorder: oklch(0.90, 0.008, 262),
    fillAlpha: 0.88,
    blurSigma: 9,
    saturation: 1.5,
    backing: transparent,
    ringAlpha: 0.80,
    plateEdge: rgb(255, 255, 255, 0.18),
    plateTop: rgb(255, 255, 255, 0.26),
    sheen: rgb(255, 255, 255, 0.13),
    glassStrength: 0.66,
    panelSteps: const <double>[0.66, 0.82, 0.92],
    groove: rgb(16, 24, 40, 0.14),
    grooveHover: rgb(16, 24, 40, 0.19),
    glowOnFill: rgb(255, 255, 255, 0.16),
    flashOnFill: rgb(255, 255, 255, 0.22),
    scrim: rgb(16, 24, 40, 0.34),
    shadowAmbient: rgb(16, 24, 40, 0.13),
    families: <NebaColor, NebaColorFamily>{
      NebaColor.primary: NebaColorFamily(
        solid: oklch(0.50, 0.198, 262),
        solidHover: oklch(0.455, 0.196, 262),
        solidActive: oklch(0.38, 0.172, 262),
        onSolid: oklch(0.99, 0.004, 262),
        accent: oklch(0.55, 0.222, 262),
      ),
      NebaColor.secondary: NebaColorFamily(
        solid: oklch(0.48, 0.038, 262),
        solidHover: oklch(0.435, 0.036, 262),
        solidActive: oklch(0.36, 0.03, 262),
        onSolid: oklch(0.99, 0.003, 262),
        accent: oklch(0.54, 0.045, 262),
      ),
      NebaColor.success: NebaColorFamily(
        solid: oklch(0.485, 0.136, 148),
        solidHover: oklch(0.44, 0.126, 148),
        solidActive: oklch(0.365, 0.106, 148),
        onSolid: oklch(0.99, 0.004, 148),
        accent: oklch(0.525, 0.143, 148),
      ),
      NebaColor.warning: NebaColorFamily(
        solid: oklch(0.80, 0.146, 80),
        solidHover: oklch(0.755, 0.148, 78),
        solidActive: oklch(0.665, 0.14, 74),
        onSolid: oklch(0.28, 0.06, 70),
        accent: oklch(0.545, 0.111, 68),
        softSteps: const <double>[0.12, 0.20, 0.28],
        lineSteps: const <double>[0.26, 0.44],
      ),
      NebaColor.danger: NebaColorFamily(
        solid: oklch(0.525, 0.194, 30),
        solidHover: oklch(0.48, 0.186, 30),
        solidActive: oklch(0.405, 0.162, 30),
        onSolid: oklch(0.99, 0.004, 30),
        accent: oklch(0.565, 0.212, 30),
      ),
      NebaColor.info: NebaColorFamily(
        solid: oklch(0.485, 0.088, 223),
        solidHover: oklch(0.44, 0.081, 223),
        solidActive: oklch(0.365, 0.068, 223),
        onSolid: oklch(0.99, 0.004, 223),
        accent: oklch(0.535, 0.096, 223),
      ),
    },
  );

  static final NebaTokens _dark = NebaTokens(
    brightness: Brightness.dark,
    surface: oklch(0.19, 0.012, 262),
    fg: oklch(0.95, 0.008, 262),
    mutedFg: oklch(0.72, 0.014, 262),
    border: oklch(0.38, 0.012, 262),
    disabledBg: oklch(0.27, 0.012, 262),
    disabledFg: oklch(0.52, 0.012, 262),
    disabledBorder: oklch(0.40, 0.012, 262),
    fillAlpha: 0.87,
    blurSigma: 9,
    saturation: 1.3,
    backing: transparent,
    ringAlpha: 0.55,
    plateEdge: rgb(255, 255, 255, 0.12),
    plateTop: rgb(255, 255, 255, 0.16),
    sheen: rgb(255, 255, 255, 0.09),
    glassStrength: 0.05,
    panelSteps: const <double>[0.05, 0.07, 0.09],
    groove: rgb(255, 255, 255, 0.05),
    grooveHover: rgb(255, 255, 255, 0.07),
    glowOnFill: rgb(255, 255, 255, 0.13),
    flashOnFill: rgb(255, 255, 255, 0.18),
    scrim: rgb(0, 0, 0, 0.58),
    shadowAmbient: rgb(0, 0, 0, 0.55),
    families: <NebaColor, NebaColorFamily>{
      NebaColor.primary: NebaColorFamily(
        solid: oklch(0.57, 0.208, 262),
        solidHover: oklch(0.61, 0.181, 262),
        solidActive: oklch(0.48, 0.196, 262),
        onSolid: oklch(0.99, 0.004, 262),
        accent: oklch(0.78, 0.103, 262),
      ),
      NebaColor.secondary: NebaColorFamily(
        solid: oklch(0.50, 0.036, 262),
        solidHover: oklch(0.55, 0.036, 262),
        solidActive: oklch(0.41, 0.03, 262),
        onSolid: oklch(0.99, 0.003, 262),
        accent: oklch(0.78, 0.026, 262),
      ),
      NebaColor.success: NebaColorFamily(
        solid: oklch(0.54, 0.147, 148),
        solidHover: oklch(0.59, 0.161, 148),
        solidActive: oklch(0.45, 0.123, 148),
        onSolid: oklch(0.99, 0.004, 148),
        accent: oklch(0.78, 0.17, 148),
      ),
      NebaColor.warning: NebaColorFamily(
        solid: oklch(0.76, 0.145, 80),
        solidHover: oklch(0.81, 0.154, 80),
        solidActive: oklch(0.695, 0.126, 80),
        onSolid: oklch(0.25, 0.06, 70),
        accent: oklch(0.82, 0.14, 80),
        softSteps: const <double>[0.12, 0.20, 0.28],
        lineSteps: const <double>[0.26, 0.44],
      ),
      NebaColor.danger: NebaColorFamily(
        solid: oklch(0.55, 0.207, 30),
        solidHover: oklch(0.60, 0.226, 30),
        solidActive: oklch(0.46, 0.174, 30),
        onSolid: oklch(0.99, 0.004, 30),
        accent: oklch(0.76, 0.136, 32),
      ),
      NebaColor.info: NebaColorFamily(
        solid: oklch(0.55, 0.098, 223),
        solidHover: oklch(0.60, 0.107, 223),
        solidActive: oklch(0.46, 0.082, 223),
        onSolid: oklch(0.99, 0.004, 223),
        accent: oklch(0.79, 0.11, 223),
      ),
    },
  );

  /// The corner radius at each size: about 45% of the control's height, held
  /// just short of a pill so the flat run along the edge still reads as a
  /// sheet with its corners cut off.
  static const Map<NebaSize, double> defaultRadius = <NebaSize, double>{
    NebaSize.xs: 10,
    NebaSize.sm: 12,
    NebaSize.md: 14,
    NebaSize.lg: 18,
    NebaSize.xl: 22,
  };

  /// Which theme these are.
  final Brightness brightness;

  /// The page's own surface.
  final Color surface;

  /// The text colour.
  final Color fg;

  /// Secondary text: descriptions, placeholders, captions.
  final Color mutedFg;

  /// A neutral hairline.
  final Color border;

  /// An unavailable control's surface: a muted neutral rather than a faded
  /// copy of its colour, because a greyed-out surface reads as unavailable and
  /// a half-transparent one only reads as blurry.
  final Color disabledBg;

  /// An unavailable control's ink.
  final Color disabledFg;

  /// An unavailable control's edge.
  final Color disabledBorder;

  /// How opaque a filled surface is, over the page behind it.
  final double fillAlpha;

  /// The standard deviation of the backdrop blur, CSS `blur(9px)`.
  ///
  /// The radius, not the alpha, decides whether anything behind a surface is
  /// legible: too much blur smears the backdrop into flat colour and the
  /// surface reads opaque again.
  final double blurSigma;

  /// How much the backdrop's colour is boosted under the blur, CSS
  /// `saturate()`.
  final double saturation;

  /// What every translucent sheet and fill is laid over before it reaches the
  /// page: transparent for the acrylic, the page's own surface when the reader
  /// asked for less transparency. See [withReducedTransparency].
  final Color backing;

  /// How much of a family's accent its focus ring is.
  final double ringAlpha;

  /// The hairline that reads as the cut edge of an acrylic sheet.
  final Color plateEdge;

  /// The brighter top edge, where the light lands. There is deliberately no
  /// dark bottom bevel.
  final Color plateTop;

  /// The start of the sheen laid across a sheet at 148°, fading out by 52%.
  final Color sheen;

  /// How much white the undyed acrylic is, mixed into [backing].
  final double glassStrength;

  /// How much white a container's sheet is at rest, under the pointer and
  /// while pressed. The ladder is opacity, not lightness: the sheet catches
  /// more light as it is engaged rather than turning grey.
  final List<double> panelSteps;

  /// The one surface that is a groove rather than a sheet: a switch's track.
  final Color groove;

  /// [groove] under the pointer.
  final Color grooveHover;

  /// The pointer spotlight over a filled surface.
  final Color glowOnFill;

  /// The release afterglow over a filled surface.
  final Color flashOnFill;

  /// The scrim behind a modal surface.
  final Color scrim;

  /// The colour of every elevation shadow. Neutral, never the control's own.
  final Color shadowAmbient;

  /// The base tokens of each colour family.
  final Map<NebaColor, NebaColorFamily> families;

  /// The corner radius at each size.
  final Map<NebaSize, double> radius;

  final Map<NebaColor, NebaColorRoles> _roles;

  /// The acrylic with no dye in it: what a coloured panel is mixed into.
  final Color glassBg;

  /// The undyed container sheet a box, a card or a field reads directly.
  final Color panel;

  /// [panel] under the pointer.
  final Color panelHover;

  /// [panel] while pressed.
  final Color panelPress;

  /// Every colour a widget draws in [color]'s family.
  NebaColorRoles roles(NebaColor color) => _roles[color]!;

  /// The drop shadow at [level], from `0`, which is none, to `4`, which only a
  /// hovered level-3 surface reaches.
  List<BoxShadow> elevation(int level) {
    BoxShadow shadow(double y, double blur, double spread) {
      return BoxShadow(
        color: shadowAmbient,
        offset: Offset(0, y),
        blurRadius: shadowBlurRadius(blur),
        spreadRadius: spread,
      );
    }

    switch (level.clamp(0, 4)) {
      case 1:
        return <BoxShadow>[shadow(1, 2, -1)];
      case 2:
        return <BoxShadow>[shadow(2, 4, -2), shadow(5, 12, -7)];
      case 3:
        return <BoxShadow>[shadow(4, 8, -3), shadow(12, 24, -11)];
      case 4:
        return <BoxShadow>[shadow(6, 12, -4), shadow(20, 40, -15)];
      default:
        return const <BoxShadow>[];
    }
  }

  /// These tokens with the sheets made opaque and the blur turned off, for a
  /// reader who asked for less transparency.
  ///
  /// Every translucent sheet and fill is mixed into [backing], so setting it
  /// to the page's surface is the whole change, as it is in the stylesheet.
  /// Washes, grooves and hairlines stay translucent: they lie on a sheet.
  NebaTokens withReducedTransparency() {
    return _opaque[this] ??= copyWith(backing: surface, blurSigma: 0, saturation: 1);
  }

  /// [withReducedTransparency] per set of tokens, so a widget that asks on
  /// every build is handed the same object rather than a new derivation.
  static final Expando<NebaTokens> _opaque = Expando<NebaTokens>('opaque tokens');

  /// These tokens with [family] in place of [color]'s.
  NebaTokens withFamily(NebaColor color, NebaColorFamily family) {
    return copyWith(families: <NebaColor, NebaColorFamily>{...families, color: family});
  }

  /// These tokens with the given base values replaced. The derived tokens are
  /// computed again from the result.
  NebaTokens copyWith({
    Color? surface,
    Color? fg,
    Color? mutedFg,
    Color? border,
    Color? disabledBg,
    Color? disabledFg,
    Color? disabledBorder,
    double? fillAlpha,
    double? blurSigma,
    double? saturation,
    Color? backing,
    double? ringAlpha,
    Color? plateEdge,
    Color? plateTop,
    Color? sheen,
    double? glassStrength,
    List<double>? panelSteps,
    Color? groove,
    Color? grooveHover,
    Color? glowOnFill,
    Color? flashOnFill,
    Color? scrim,
    Color? shadowAmbient,
    Map<NebaColor, NebaColorFamily>? families,
    Map<NebaSize, double>? radius,
  }) {
    return NebaTokens(
      brightness: brightness,
      surface: surface ?? this.surface,
      fg: fg ?? this.fg,
      mutedFg: mutedFg ?? this.mutedFg,
      border: border ?? this.border,
      disabledBg: disabledBg ?? this.disabledBg,
      disabledFg: disabledFg ?? this.disabledFg,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      fillAlpha: fillAlpha ?? this.fillAlpha,
      blurSigma: blurSigma ?? this.blurSigma,
      saturation: saturation ?? this.saturation,
      backing: backing ?? this.backing,
      ringAlpha: ringAlpha ?? this.ringAlpha,
      plateEdge: plateEdge ?? this.plateEdge,
      plateTop: plateTop ?? this.plateTop,
      sheen: sheen ?? this.sheen,
      glassStrength: glassStrength ?? this.glassStrength,
      panelSteps: panelSteps ?? this.panelSteps,
      groove: groove ?? this.groove,
      grooveHover: grooveHover ?? this.grooveHover,
      glowOnFill: glowOnFill ?? this.glowOnFill,
      flashOnFill: flashOnFill ?? this.flashOnFill,
      scrim: scrim ?? this.scrim,
      shadowAmbient: shadowAmbient ?? this.shadowAmbient,
      families: families ?? this.families,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NebaTokens &&
        other.brightness == brightness &&
        other.surface == surface &&
        other.fg == fg &&
        other.mutedFg == mutedFg &&
        other.border == border &&
        other.disabledBg == disabledBg &&
        other.disabledFg == disabledFg &&
        other.disabledBorder == disabledBorder &&
        other.fillAlpha == fillAlpha &&
        other.blurSigma == blurSigma &&
        other.saturation == saturation &&
        other.backing == backing &&
        other.ringAlpha == ringAlpha &&
        other.plateEdge == plateEdge &&
        other.plateTop == plateTop &&
        other.sheen == sheen &&
        other.glassStrength == glassStrength &&
        listEquals(other.panelSteps, panelSteps) &&
        other.groove == groove &&
        other.grooveHover == grooveHover &&
        other.glowOnFill == glowOnFill &&
        other.flashOnFill == flashOnFill &&
        other.scrim == scrim &&
        other.shadowAmbient == shadowAmbient &&
        mapEquals(other.families, families) &&
        mapEquals(other.radius, radius);
  }

  @override
  int get hashCode {
    return Object.hashAll(<Object>[
      brightness,
      surface,
      fg,
      mutedFg,
      border,
      disabledBg,
      disabledFg,
      disabledBorder,
      fillAlpha,
      blurSigma,
      saturation,
      backing,
      ringAlpha,
      plateEdge,
      plateTop,
      sheen,
      glassStrength,
      Object.hashAll(panelSteps),
      groove,
      grooveHover,
      glowOnFill,
      flashOnFill,
      scrim,
      shadowAmbient,
      Object.hashAllUnordered(
        families.entries.map((MapEntry<NebaColor, NebaColorFamily> e) {
          return Object.hash(e.key, e.value);
        }),
      ),
      Object.hashAllUnordered(
        radius.entries.map((MapEntry<NebaSize, double> e) {
          return Object.hash(e.key, e.value);
        }),
      ),
    ]);
  }
}
