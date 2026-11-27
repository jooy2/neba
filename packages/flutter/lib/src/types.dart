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

import 'package:flutter/animation.dart';
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

/// How a bar sits against the edge of what it is in, spelled the way CSS
/// spells `position`.
///
/// A Header and a Footer read it inside a `NebaPageLayout`, whose page scroll
/// gives it its meaning. A Toolbar and a Pill read it on their own, where a
/// widget is laid out where its parent puts it: [sticky] draws the bar as it
/// is drawn once held, for a scroll view to hold it, and only [fixed] moves
/// anything.
enum NebaPosition {
  /// In place, scrolling away with what is around it.
  static,

  /// Held against its edge once it reaches it: by a page layout's scroll, or,
  /// for a bar on its own, by a `PinnedHeaderSliver` in a `CustomScrollView`
  /// or the end of a `Column` around an `Expanded` scroll view.
  sticky,

  /// Held at the edge: a page layout reserves its room, and a bar on its own
  /// is drawn in the nearest `Overlay`, taking no room where it was written.
  fixed,
}

/// How much of the page behind a popup is taken away while it is open: the
/// React package's `modal`, `boolean | 'trap-focus'`, which a Popover, a
/// Dialog, a Drawer and an Overlay share.
enum NebaModal {
  /// `false`: the page behind stays scrollable, pressable and reachable from
  /// the keyboard, and Tab leaves the popup the way it came in.
  off,

  /// `true`: the page behind takes no pointer, and Tab goes round the popup
  /// without leaving it.
  on,

  /// `'trap-focus'`: Tab goes round the popup without leaving it, and the
  /// page behind still scrolls and takes a press.
  trapFocus,
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

/// The window widths the layout widgets branch on, smallest first.
///
/// The same five names as [NebaSize] and not the same idea: a size of `md` is
/// how big a control is, a breakpoint of `md` is how wide the window is. The
/// widths are the React package's, which are Tailwind's: `sm` 640, `md` 768,
/// `lg` 1024 and `xl` 1280 logical pixels, and `xs` 0, the floor every width
/// is above.
enum NebaBreakpoint {
  /// 0, so every width is at or above it.
  xs(0),

  /// 640 logical pixels.
  sm(640),

  /// 768 logical pixels.
  md(768),

  /// 1024 logical pixels.
  lg(1024),

  /// 1280 logical pixels.
  xl(1280);

  const NebaBreakpoint(this.width);

  /// Where the step starts, in logical pixels.
  final double width;
}

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

/// An entrance effect, the React package's `NebaAnimation`.
///
/// Each one runs from a start state of its own to the widget as it is laid
/// out, so the last frame of every effect is the widget untouched.
enum NebaAnimation {
  /// From transparent.
  fade,

  /// From smaller and transparent, by a little: 0.8 of the size.
  grow,

  /// From one edge, by the widget's own size, and transparent.
  slide,

  /// From smaller and transparent, by a lot: 0.4 of the size.
  zoom,

  /// From half a turn back, and transparent.
  rotate,

  /// To transparent and back, over and over until a repeat count says
  /// otherwise.
  blink,

  /// Wiped in from one edge, with no fade.
  reveal,
}

/// An entrance on a widget that displays something, run once when it is first
/// built: the React package's `transition` prop.
///
/// A named constructor per effect, so an effect takes only the settings it
/// reads:
///
/// ```dart
/// NebaBox(transition: const NebaTransition.fade(), child: content);
/// NebaBox(
///   transition: const NebaTransition.slide(
///     from: NebaSide.left,
///     duration: Duration(milliseconds: 500),
///     delay: Duration(milliseconds: 100),
///   ),
///   child: content,
/// );
/// ```
///
/// It is offered on no widget that is pressed: a control that moves under the
/// pointer aiming at it is what the design language rules out. A reader who
/// asked the platform for less motion sees the last frame at once.
///
/// React's `timeline` and `range`, which hand the effect to the scrollbar, are
/// the React package's alone.
@immutable
class NebaTransition {
  /// A fade in.
  const NebaTransition.fade({
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.fade,
       scale = null,
       from = null,
       distance = null,
       angle = null,
       side = null;

  /// A grow in, from [scale] of the size.
  const NebaTransition.grow({
    this.scale = 0.8,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.grow,
       from = null,
       distance = null,
       angle = null,
       side = null;

  /// A slide in from the edge [from], by [distance] logical pixels, or by the
  /// widget's own size along that axis when [distance] is left out.
  const NebaTransition.slide({
    this.from = NebaSide.bottom,
    this.distance,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.slide,
       scale = null,
       angle = null,
       side = null;

  /// A zoom in, from [scale] of the size.
  const NebaTransition.zoom({
    this.scale = 0.4,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.zoom,
       from = null,
       distance = null,
       angle = null,
       side = null;

  /// A turn in, from [angle] degrees.
  const NebaTransition.rotate({
    this.angle = -180,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.rotate,
       scale = null,
       from = null,
       distance = null,
       side = null;

  /// A blink, which repeats until [repeat] says otherwise: a blink that ran
  /// once would be a flicker. One blink never takes less than 334
  /// milliseconds, since more than three flashes a second is what WCAG 2.3.1
  /// rules out.
  const NebaTransition.blink({
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.blink,
       scale = null,
       from = null,
       distance = null,
       angle = null,
       side = null;

  /// A wipe in from the edge [side].
  const NebaTransition.reveal({
    this.side = NebaSide.left,
    this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
  }) : type = NebaAnimation.reveal,
       scale = null,
       from = null,
       distance = null,
       angle = null;

  /// Which effect.
  final NebaAnimation type;

  /// How long one run takes. Left out, it is the effect's own: 320
  /// milliseconds for a fade, 340 for a grow or a zoom, 380 for a slide, 460
  /// for a rotate, 900 for one blink and 620 for a reveal.
  final Duration? duration;

  /// How long the first frame is held before it starts.
  final Duration delay;

  /// The easing. Left out, it is the house curve, `NebaScale.ease`.
  final Curve? curve;

  /// How many times it runs; `double.infinity` runs it until the widget goes.
  /// Left out, it is once, and forever for a blink.
  final num? repeat;

  /// Runs every other pass backwards, so a repeat returns instead of jumping.
  final bool alternate;

  /// Where a grow or a zoom starts, as a multiple of the final size.
  final double? scale;

  /// The edge a slide comes from. Physical, so it does not flip under RTL.
  final NebaSide? from;

  /// How far a slide travels, in logical pixels; the widget's own size when
  /// it is `null`.
  final double? distance;

  /// How far a rotate turns from, in degrees.
  final double? angle;

  /// The edge a reveal is wiped from. Physical, so it does not flip under RTL.
  final NebaSide? side;

  @override
  bool operator ==(Object other) {
    return other is NebaTransition &&
        other.type == type &&
        other.duration == duration &&
        other.delay == delay &&
        other.curve == curve &&
        other.repeat == repeat &&
        other.alternate == alternate &&
        other.scale == scale &&
        other.from == from &&
        other.distance == distance &&
        other.angle == angle &&
        other.side == side;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      duration,
      delay,
      curve,
      repeat,
      alternate,
      scale,
      from,
      distance,
      angle,
      side,
    );
  }
}

/// A point on a scale, and the colour family a reading takes once it has
/// reached it: the React package's `NebaThreshold`.
///
/// The one place a semantic colour is computed rather than chosen, so that a
/// `NebaMeter` and a gauge drawing the same reading never disagree about
/// where amber starts.
@immutable
class NebaThreshold {
  /// The family [color] from [from] up.
  const NebaThreshold({required this.from, required this.color});

  /// The value from which this family applies, in the reading's own units.
  final double from;

  /// What the bar, or the arc, turns at and above [from].
  final NebaColor color;

  @override
  bool operator ==(Object other) {
    return other is NebaThreshold && other.from == from && other.color == color;
  }

  @override
  int get hashCode => Object.hash(from, color);
}
