/// `NebaTypography`, text on the library's type scale.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a piece of text is, which decides its type scale and whether a screen
/// reader hears it as a heading.
///
/// Deliberately not called `variant`: in this library a variant is the weight
/// of a surface.
enum NebaTypographyLevel {
  /// 30 logical pixels, semibold; a first-level heading.
  h1,

  /// 24, semibold; a second-level heading.
  h2,

  /// 20, semibold; a third-level heading.
  h3,

  /// 17, semibold; a fourth-level heading.
  h4,

  /// 15, semibold; a fifth-level heading.
  h5,

  /// 13, semibold; a sixth-level heading.
  h6,

  /// 17, regular: the paragraph that opens a page.
  lead,

  /// 13, regular: a paragraph, the size of a medium Card's body.
  body,

  /// 12, regular and muted.
  caption,

  /// 11, medium, muted, tracked out and in capitals.
  overline,
}

/// One level of the type scale: its size, its leading as a multiple of the
/// size, its tracking as a fraction of the size, and its weight.
@immutable
class NebaTypeStep {
  /// A step of the scale.
  const NebaTypeStep({
    required this.size,
    required this.leading,
    required this.tracking,
    required this.weight,
  });

  /// The font size, in logical pixels.
  final double size;

  /// The line height as a multiple of [size], so a size set over it keeps a
  /// line box in proportion.
  final double leading;

  /// The letter spacing as a fraction of [size], CSS's `em`.
  final double tracking;

  /// The weight the level takes when nobody says otherwise.
  final FontWeight weight;
}

/// Text at one of the library's sizes, so headings, body copy and captions all
/// share the same steps.
///
/// [level] sets the scale and whether the text is a heading, which is the
/// common case; [headingLevel] breaks the tie when they have to differ. With
/// no [color] the text inherits the colour around it, apart from the two
/// quiet levels, which are muted.
///
/// ```dart
/// const NebaTypography('A sheet of cut acrylic', level: NebaTypographyLevel.h2)
/// ```
class NebaTypography extends StatelessWidget {
  /// [data] on the type scale.
  const NebaTypography(
    String this.data, {
    this.level = NebaTypographyLevel.body,
    this.color,
    this.weight,
    this.align,
    this.lines,
    this.gutter = false,
    this.headingLevel,
    this.style,
    this.semanticsLabel,
    this.transition,
    super.key,
  }) : span = null,
       assert(lines == null || lines > 0),
       assert(headingLevel == null || (headingLevel >= 0 && headingLevel <= 6));

  /// [span], a run of styled pieces, on the type scale.
  const NebaTypography.rich(
    InlineSpan this.span, {
    this.level = NebaTypographyLevel.body,
    this.color,
    this.weight,
    this.align,
    this.lines,
    this.gutter = false,
    this.headingLevel,
    this.style,
    this.semanticsLabel,
    this.transition,
    super.key,
  }) : data = null,
       assert(lines == null || lines > 0),
       assert(headingLevel == null || (headingLevel >= 0 && headingLevel <= 6));

  /// The text. An [NebaTypographyLevel.overline] draws it in capitals.
  final String? data;

  /// The text as styled pieces, drawn as given.
  final InlineSpan? span;

  /// The type scale, and whether the text is a heading.
  final NebaTypographyLevel level;

  /// The semantic colour role. No default: the text inherits the colour
  /// around it, because a paragraph should look like the paragraphs around it.
  final NebaColor? color;

  /// Overrides the weight the level would pick.
  final FontWeight? weight;

  /// How the lines sit in the width the text is given.
  final TextAlign? align;

  /// Clamps the text to this many lines with an ellipsis; `1` is a single-line
  /// truncation. Left out, the text wraps as far as it needs to.
  final int? lines;

  /// Adds the space below that a run of prose expects. Off by default: a
  /// widget that brings its own margin is one a layout has to fight.
  final bool gutter;

  /// The heading level a screen reader hears, from 1 to 6, or 0 for none.
  /// Left out, it is the level's own: `h2` is a second-level heading, and
  /// `body` is none.
  final int? headingLevel;

  /// A style laid over the level's. Its size keeps the level's leading in
  /// proportion; set `height` beside it to change that.
  final TextStyle? style;

  /// What a screen reader hears instead of the text.
  final String? semanticsLabel;

  /// How the text arrives when it is first built.
  final NebaTransition? transition;

  /// The scale, the React package's `levelScale`: body sits on a medium
  /// Card's body step, the headings climb by about a major third, and the
  /// leading tightens as they grow.
  static const Map<NebaTypographyLevel, NebaTypeStep> scale = <NebaTypographyLevel, NebaTypeStep>{
    NebaTypographyLevel.h1: NebaTypeStep(
      size: 30,
      leading: 1.2,
      tracking: -0.02,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.h2: NebaTypeStep(
      size: 24,
      leading: 1.25,
      tracking: -0.015,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.h3: NebaTypeStep(
      size: 20,
      leading: 1.3,
      tracking: -0.01,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.h4: NebaTypeStep(
      size: 17,
      leading: 1.41176,
      tracking: 0,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.h5: NebaTypeStep(
      size: 15,
      leading: 1.46667,
      tracking: 0,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.h6: NebaTypeStep(
      size: 13,
      leading: 1.53846,
      tracking: 0,
      weight: FontWeight.w600,
    ),
    NebaTypographyLevel.lead: NebaTypeStep(
      size: 17,
      leading: 1.64706,
      tracking: 0,
      weight: FontWeight.w400,
    ),
    NebaTypographyLevel.body: NebaTypeStep(
      size: 13,
      leading: 1.69231,
      tracking: 0,
      weight: FontWeight.w400,
    ),
    NebaTypographyLevel.caption: NebaTypeStep(
      size: 12,
      leading: 1.5,
      tracking: 0,
      weight: FontWeight.w400,
    ),
    NebaTypographyLevel.overline: NebaTypeStep(
      size: 11,
      leading: 1.45455,
      tracking: 0.08,
      weight: FontWeight.w500,
    ),
  };

  /// The space each level leaves under itself with [gutter], the React
  /// package's `gutterSteps` at four logical pixels a step.
  static const Map<NebaTypographyLevel, double> gutters = <NebaTypographyLevel, double>{
    NebaTypographyLevel.h1: 16,
    NebaTypographyLevel.h2: 14,
    NebaTypographyLevel.h3: 12,
    NebaTypographyLevel.h4: 10,
    NebaTypographyLevel.h5: 8,
    NebaTypographyLevel.h6: 8,
    NebaTypographyLevel.lead: 16,
    NebaTypographyLevel.body: 12,
    NebaTypographyLevel.caption: 8,
    NebaTypographyLevel.overline: 8,
  };

  /// The level's heading level, 0 for none.
  static int _headingOf(NebaTypographyLevel level) {
    return switch (level) {
      NebaTypographyLevel.h1 => 1,
      NebaTypographyLevel.h2 => 2,
      NebaTypographyLevel.h3 => 3,
      NebaTypographyLevel.h4 => 4,
      NebaTypographyLevel.h5 => 5,
      NebaTypographyLevel.h6 => 6,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaTypeStep step = scale[level]!;
    final NebaColor? color = this.color;
    final bool muted =
        level == NebaTypographyLevel.caption || level == NebaTypographyLevel.overline;
    final double size = style?.fontSize ?? step.size;

    // The tracking is a fraction of the size, as `em` is, so a size laid over
    // the level's carries tracking in proportion with it.
    final TextStyle levelStyle = TextStyle(
      fontSize: step.size,
      height: step.leading,
      // CSS shares a line's leading evenly above and below it.
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: step.tracking * size,
      fontWeight: weight ?? step.weight,
      color: color != null ? tokens.roles(color).accent : (muted ? tokens.mutedFg : null),
    ).merge(style);

    final int? maxLines = lines;
    final TextOverflow? overflow = maxLines == null ? null : TextOverflow.ellipsis;
    final InlineSpan? span = this.span;

    Widget text = span != null
        ? Text.rich(
            span,
            style: levelStyle,
            textAlign: align,
            maxLines: maxLines,
            overflow: overflow,
            semanticsLabel: semanticsLabel,
          )
        : Text(
            level == NebaTypographyLevel.overline ? data!.toUpperCase() : data!,
            style: levelStyle,
            textAlign: align,
            maxLines: maxLines,
            overflow: overflow,
            semanticsLabel: semanticsLabel,
          );

    final int heading = headingLevel ?? _headingOf(level);

    if (heading > 0) {
      text = Semantics(header: true, headingLevel: heading, child: text);
    }

    if (gutter) {
      text = Padding(
        padding: EdgeInsets.only(bottom: gutters[level]!),
        child: text,
      );
    }

    final NebaTransition? transition = this.transition;

    return transition == null ? text : NebaEntrance(transition: transition, child: text);
  }
}
