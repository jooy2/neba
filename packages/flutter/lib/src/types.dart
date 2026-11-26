/// The shared prop vocabulary every Neba widget draws from.
///
/// These are the React package's `src/types.ts`, value for value. A `size` of
/// [NebaSize.md] or a `color` of [NebaColor.primary] means the same thing on a
/// button, a chip, a text field or a dialog, and on either package: a screen
/// built with both reads as one product. A widget takes the subset it needs and
/// never invents a second spelling for an idea that already has one.
///
/// One name differs from React, and only because Dart reserves the word:
/// React's density `'default'` is [NebaDensity.standard] here.
library;

import 'package:flutter/foundation.dart';

/// Scale of a component. [md] is the desktop default.
///
/// A control's height at each step is 22, 26, 32, 40 and 48 logical pixels;
/// `NebaScale.controlHeight` holds them.
enum NebaSize {
  /// The smallest step, 22 logical pixels tall.
  xs,

  /// 26 logical pixels tall.
  sm,

  /// The default, 32 logical pixels tall.
  md,

  /// 40 logical pixels tall.
  lg,

  /// The largest step, 48 logical pixels tall.
  xl,
}

/// Semantic colour role. Each maps to a family of tokens in `NebaTokens`.
enum NebaColor {
  /// The product's accent.
  primary,

  /// A neutral, for actions that should not compete with the primary one.
  secondary,

  /// Something went well.
  success,

  /// Something needs attention before it goes wrong.
  warning,

  /// Something went wrong, or is about to be destroyed.
  danger,

  /// Something worth knowing, with no judgement in it.
  info,
}

/// How tightly a component packs its content.
///
/// Only spacing changes, never the type scale or the control's own height, so
/// a compact and a standard control of the same [NebaSize] still line up on a
/// shared baseline. React spells [standard] as `'default'`, which Dart reserves.
enum NebaDensity {
  /// The default padding.
  standard,

  /// Less padding at the same height.
  compact,
}

/// Visual weight of a component's surface.
enum NebaVariant {
  /// Filled, and carries the colour. One per view, for the primary action.
  solid,

  /// A translucent surface with a hairline border. Secondary actions.
  outline,

  /// No surface until hovered. Tertiary and inline actions.
  text,
}

/// Which way a component runs.
///
/// [horizontal] everywhere it is offered, because a vertical control is the
/// exception and an exception should have to be asked for.
enum NebaOrientation {
  /// Left to right, or right to left under RTL.
  horizontal,

  /// Top to bottom.
  vertical,
}

/// Which edge of an anchor something is placed against.
///
/// Physical rather than logical: a tooltip above a button is above it in every
/// writing direction.
enum NebaSide {
  /// Above the anchor.
  top,

  /// To the right of the anchor, in every writing direction.
  right,

  /// Below the anchor.
  bottom,

  /// To the left of the anchor, in every writing direction.
  left,
}

/// Where something sits along the axis it is not placed on.
///
/// [start] and [end] rather than left and right, because these flip under RTL.
enum NebaAlign {
  /// The leading edge: left in a left-to-right layout.
  start,

  /// The middle.
  center,

  /// The trailing edge: right in a left-to-right layout.
  end,
}

/// Which corner of a box something is pinned to.
enum NebaCorner {
  /// The top corner on the leading side.
  topStart,

  /// The top corner on the trailing side.
  topEnd,

  /// The bottom corner on the leading side.
  bottomStart,

  /// The bottom corner on the trailing side.
  bottomEnd,
}

/// Where a field-shaped component draws its label.
///
/// [notch] and [float] take no height of their own: the label stands half a
/// line above the field's top edge instead of a line above it, so a column of
/// notched fields is shorter than the same column with their labels on top.
enum NebaLabelPlacement {
  /// Above the field, in a line of its own. The default.
  top,

  /// On the field's top edge, in a gap cut out of the border.
  notch,

  /// Inside the field, where the placeholder would be, while the field is
  /// empty and nothing in it has the focus; it rises into the notch the moment
  /// either stops being true.
  float,
}

/// Whether the colours follow the platform's brightness or are pinned.
enum NebaColorScheme {
  /// Follow `MediaQueryData.platformBrightness`.
  system,

  /// Always the light tokens.
  light,

  /// Always the dark tokens.
  dark,
}

/// How far a surface sits off the page, as a drop shadow, from `0` to `3`.
///
/// `0` is the default everywhere and means flat: the acrylic edge alone is what
/// separates the control from its background. Raise it only for surfaces that
/// genuinely float above the content around them. Hovering adds a level and
/// pressing removes one, so a flat control still answers a press without
/// moving.
typedef NebaElevation = int;

/// The lowest [NebaElevation], with no shadow.
const NebaElevation nebaElevationMin = 0;

/// The highest [NebaElevation] a caller may ask for.
const NebaElevation nebaElevationMax = 3;

/// How wide something may grow: a step of the measure ladder, a width in
/// logical pixels, or no limit at all.
///
/// The React package's `NebaMeasure`, which also takes any CSS length; Dart
/// has no CSS, so a length of your own is [NebaMeasure.width].
@immutable
class NebaMeasure {
  /// A step of the measure ladder: `xs` 480, `sm` 640, `md` 768, `lg` 1024
  /// and `xl` 1280 logical pixels. The four upper steps are the breakpoint
  /// floors.
  const NebaMeasure.size(NebaSize this.size) : width = null;

  /// A width of your own, in logical pixels.
  const NebaMeasure.width(double this.width) : size = null;

  const NebaMeasure._none() : size = null, width = null;

  /// No limit.
  static const NebaMeasure none = NebaMeasure._none();

  /// The step this measure is, if it is one.
  final NebaSize? size;

  /// The width this measure is, if it is one of your own.
  final double? width;

  /// The measure ladder, the React package's `measureWidths`.
  static const Map<NebaSize, double> ladder = <NebaSize, double>{
    NebaSize.xs: 480,
    NebaSize.sm: 640,
    NebaSize.md: 768,
    NebaSize.lg: 1024,
    NebaSize.xl: 1280,
  };

  /// The widest this measure lets something be; infinite for [none].
  double get maxWidth {
    final NebaSize? step = size;

    return step != null ? ladder[step]! : width ?? double.infinity;
  }

  @override
  bool operator ==(Object other) {
    return other is NebaMeasure && other.size == size && other.width == width;
  }

  @override
  int get hashCode => Object.hash(size, width);
}

/// How a row distributes the space it has left over along its main axis.
///
/// The three positional values are [NebaAlign]'s and flip under RTL; the
/// distribution values are CSS's, spelled the Dart way.
enum NebaJustifyContent {
  /// Packed at the start.
  start,

  /// Packed in the middle.
  center,

  /// Packed at the end.
  end,

  /// The first item at the start, the last at the end, the rest evenly
  /// between.
  spaceBetween,

  /// Equal space around every item, so the ends get half a share.
  spaceAround,

  /// Equal space between every item and at both ends.
  spaceEvenly,

  /// No distribution: the items keep their place at the start.
  stretch,
}

/// How items sit across the axis they are laid out on. [stretch] is the
/// default everywhere it is offered: a row of cards is a row of cards of one
/// height.
enum NebaAlignItems {
  /// Against the start of the cross axis.
  start,

  /// In the middle of the cross axis.
  center,

  /// Against the end of the cross axis.
  end,

  /// As tall as the row.
  stretch,

  /// On a shared first baseline.
  baseline,
}

/// The same, for one item overriding the row around it.
enum NebaAlignSelf {
  /// Whatever the row says.
  auto,

  /// Against the start of the cross axis.
  start,

  /// In the middle of the cross axis.
  center,

  /// Against the end of the cross axis.
  end,

  /// As tall as the row.
  stretch,

  /// On the row's first baseline.
  baseline,
}
