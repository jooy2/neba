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

  /// Between a label, the control under it and the text under that: a field's
  /// parts, and the label above a progress bar and its groove.
  static const Map<NebaSize, double> stackGap = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 4,
    NebaSize.md: 6,
    NebaSize.lg: 6,
    NebaSize.xl: 8,
  };

  /// Between the sections of a sheet, and the rows of a vertical option list.
  static const Map<NebaSize, double> sectionGap = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 12,
    NebaSize.lg: 14,
    NebaSize.xl: 16,
  };

  /// A sheet's heading: a card's, an alert's, a dialog's. One step above the
  /// body, so a title lines up with the buttons that end up inside the sheet.
  static const Map<NebaSize, double> sheetTitleText = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 13,
    NebaSize.md: 15,
    NebaSize.lg: 17,
    NebaSize.xl: 20,
  };

  /// The line height of [sheetTitleText].
  static const Map<NebaSize, double> sheetTitleLeading = <NebaSize, double>{
    NebaSize.xs: 16,
    NebaSize.sm: 18,
    NebaSize.md: 20,
    NebaSize.lg: 24,
    NebaSize.xl: 28,
  };

  /// A sheet's body copy: the control type scale with the leading opened up,
  /// because a label is one line and a body is a paragraph.
  static const Map<NebaSize, double> sheetBodyText = <NebaSize, double>{
    NebaSize.xs: 11,
    NebaSize.sm: 12,
    NebaSize.md: 13,
    NebaSize.lg: 15,
    NebaSize.xl: 17,
  };

  /// The line height of [sheetBodyText].
  static const Map<NebaSize, double> sheetBodyLeading = <NebaSize, double>{
    NebaSize.xs: 16,
    NebaSize.sm: 18,
    NebaSize.md: 22,
    NebaSize.lg: 24,
    NebaSize.xl: 28,
  };

  /// From a sheet's title to its subtitle: tight, because they are one block
  /// of text rather than two sections.
  static const Map<NebaSize, double> sheetHeaderGap = <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 4,
    NebaSize.xl: 6,
  };

  /// Between a sheet's sections, when there are no dividers to separate them.
  static const Map<NebaSize, double> sheetSectionGap = <NebaSize, double>{
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

  /// The monospaced faces a key cap and code are set in, Tailwind's
  /// `font-mono` stack by the names a platform knows them by: the first is the
  /// family, the rest its fallbacks, and a platform with none of them uses its
  /// own default.
  static const List<String> monoFonts = <String>[
    'SF Mono',
    'SFMono-Regular',
    'Menlo',
    'Monaco',
    'Consolas',
    'Liberation Mono',
    'Roboto Mono',
    'Courier New',
    'monospace',
  ];
}
