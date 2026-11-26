/// The size ladders every widget reads: heights, type, icons, padding, gaps
/// and motion.
///
/// These are the tables in the React package's `src/internal/styles.ts`, in
/// logical pixels where React writes Tailwind classes and rems. A `md` control
/// is 32 pixels tall on both packages, so a screen built with both lines up.
/// One rem is 16 logical pixels, which is the browser default the React values
/// assume.
library;

import 'package:flutter/animation.dart';

import 'package:neba/src/types.dart';

/// The size, spacing and motion ladders shared by every widget.
abstract final class NebaScale {
  /// A control's exact height: a button, a toggle, a segmented button.
  ///
  /// A field uses the same numbers as a minimum instead, because it holds a
  /// caller's own text, which may be set larger than the step.
  static const Map<NebaSize, double> controlHeight = <NebaSize, double>{
    NebaSize.xs: 22,
    NebaSize.sm: 26,
    NebaSize.md: 32,
    NebaSize.lg: 40,
    NebaSize.xl: 48,
  };

  /// A control's label size. One line, so it sets its own leading.
  static const Map<NebaSize, double> controlText = <NebaSize, double>{
    NebaSize.xs: 11,
    NebaSize.sm: 12,
    NebaSize.md: 13,
    NebaSize.lg: 15,
    NebaSize.xl: 17,
  };

  /// The line height that goes with [controlText] where the text can wrap.
  static const Map<NebaSize, double> controlLeading = <NebaSize, double>{
    NebaSize.xs: 14,
    NebaSize.sm: 16,
    NebaSize.md: 20,
    NebaSize.lg: 22,
    NebaSize.xl: 26,
  };

  /// Labels, descriptions and error messages: one step below [controlText].
  static const Map<NebaSize, double> metaText = <NebaSize, double>{
    NebaSize.xs: 10,
    NebaSize.sm: 11,
    NebaSize.md: 12,
    NebaSize.lg: 13,
    NebaSize.xl: 14,
  };

  /// The icon inside a control.
  static const Map<NebaSize, double> iconSize = <NebaSize, double>{
    NebaSize.xs: 14,
    NebaSize.sm: 16,
    NebaSize.md: 20,
    NebaSize.lg: 24,
    NebaSize.xl: 28,
  };

  /// A control's inline padding, per density. Density changes this and
  /// nothing else.
  static const Map<NebaDensity, Map<NebaSize, double>> paddingX =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 10,
          NebaSize.sm: 12,
          NebaSize.md: 16,
          NebaSize.lg: 20,
          NebaSize.xl: 24,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 16,
        },
      };

  /// Between a control's own parts: an icon and its label.
  static const Map<NebaSize, double> gap = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 6,
    NebaSize.lg: 8,
    NebaSize.xl: 10,
  };

  /// Between the sections of a sheet, and the rows of a vertical option list.
  static const Map<NebaSize, double> sectionGap = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 12,
    NebaSize.lg: 14,
    NebaSize.xl: 16,
  };

  /// One step of the spacing scale a `spacing` prop counts in, as Tailwind's
  /// does: `spacing: 4` is 16 logical pixels.
  static const double spacingUnit = 4;

  /// How long an edge, a shadow or a text colour takes to change.
  ///
  /// Controls answer in colour and depth, never by moving.
  static const Duration duration = Duration(milliseconds: 160);

  /// How long a fill takes to drain back out after a press.
  ///
  /// A press lands on the frame of the click, in zero time, and this is how
  /// long the colour takes to settle afterwards: press is instant, release is
  /// slow.
  static const Duration durationFill = Duration(milliseconds: 340);

  /// A window being maximised, restored or rolled up, and nothing else.
  static const Duration durationWindow = Duration(milliseconds: 240);

  /// The one easing curve, `cubic-bezier(0.32, 0.72, 0, 1)`.
  static const Curve ease = Cubic(0.32, 0.72, 0, 1);
}
