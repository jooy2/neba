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
import 'package:flutter/widgets.dart' show BuildContext, Color, Widget;

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
/// A Header, a Footer and a BottomNavigation read it inside a
/// `NebaPageLayout`, whose page scroll gives it its meaning. A Toolbar and a
/// Pill read it on their own, where a widget is laid out where its parent puts
/// it: [sticky] draws the bar as it is drawn once held, for a scroll view to
/// hold it, and only [fixed] moves anything.
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

/// Which day a week starts on, counted the way [DateTime.weekday] counts it:
/// [DateTime.monday] is `1` and [DateTime.sunday] is `7`.
///
/// The React package counts the way JavaScript's `getDay` does, Sunday `0`,
/// and for the reason it gives: every date API on the platform already speaks
/// that encoding, so a value computed from a setting or a database row has
/// nothing to translate. Dart's platform speaks this one, so this is the one
/// a Dart caller already has. The pickers default it from the locale, so it
/// is rarely written down at all.
typedef NebaWeekday = int;

/// Which unit a date picker is asking for: one day, one whole month or one
/// whole year.
///
/// A calendar draws three grids, days, months and years, and this says which
/// one the reader may stop on. A coarser unit is not a different value type:
/// the value stays a [DateTime], the first day of what was chosen, because a
/// month picker that reported the 15th would be reporting a day nobody chose.
enum NebaDateGranularity {
  /// A day, from the grid of days.
  day,

  /// A whole month, from the grid of twelve months: the 1st of it.
  month,

  /// A whole year, from the grid of years: the 1st of January.
  year,
}

/// Which column of a time picker's clock a row belongs to, as a
/// `shouldDisableTime` check is told it.
///
/// A rule can then be as coarse as "no afternoons", asked of the meridiem, or
/// as fine as one minute.
enum NebaTimeUnit {
  /// The column of hours.
  hour,

  /// The column of minutes.
  minute,

  /// The column of seconds.
  second,

  /// The column of AM and PM.
  meridiem,
}

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
/// React's `timeline` and `range`, which hand the effect to the scroll
/// position, are taken by the `Animate*` widgets rather than by a transition.
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

/// What starts an `Animate*` widget's effect: the React package's
/// `NebaAnimateTrigger`.
enum NebaAnimateTrigger {
  /// As soon as it is built. The only one that needs nothing from the caller.
  mount,

  /// When it is scrolled into view: once, unless `once` is off.
  visible,

  /// While the pointer is on it, starting over on each entry. Keyboard focus
  /// inside it counts as the pointer, and on a touch screen a finger down on
  /// it does.
  hover,

  /// Never on its own: `play` is what runs it.
  manual,
}

/// Whether an effect brings its child in or takes it away: the React
/// package's `NebaAnimateMode`, whose `'in'` is a reserved word in Dart.
enum NebaAnimateMode {
  /// From the effect's start to the widget as it is laid out.
  enter,

  /// The same run backwards, held at the end, so what left stays gone.
  exit,
}

/// What drives an effect's progress: the React package's
/// `NebaAnimateTimeline`.
enum NebaAnimateTimeline {
  /// The clock, which every other timing setting is written against.
  time,

  /// How far the widget has travelled up through the scroll view it is in.
  /// Scrolling forwards plays the effect forwards and scrolling back plays it
  /// back, so `duration`, `delay`, `repeat` and `trigger` no longer apply.
  view,
}

/// A stretch of a widget's way up through the scroll view it is in: the
/// phases CSS names for `animation-range`.
enum NebaViewPhase {
  /// From its top edge entering at the bottom of the view to its bottom edge
  /// leaving at the top.
  cover,

  /// While it is wholly inside the view, or, when it is taller than the view,
  /// while it covers all of it.
  contain,

  /// From its top edge entering at the bottom to the start of [contain].
  entry,

  /// From the end of [contain] to its bottom edge leaving at the top.
  exit,

  /// From its top edge entering at the bottom to its bottom edge doing the
  /// same, whatever its height.
  entryCrossing,

  /// From its top edge reaching the top of the view to its bottom edge doing
  /// the same.
  exitCrossing,
}

/// The part of a widget's way through the scroll view that a
/// [NebaAnimateTimeline.view] effect is played over: the React package's
/// `range`, which CSS writes as `animation-range`.
///
/// The default, from the start of [NebaViewPhase.entry] to 45% of
/// [NebaViewPhase.cover], plays the effect out over the first part of the
/// widget's way up the screen. Each point is a phase and a fraction of it,
/// from 0 to 1.
@immutable
class NebaViewRange {
  /// From [start] of [startPhase] to [end] of [endPhase].
  const NebaViewRange({
    this.startPhase = NebaViewPhase.entry,
    this.start = 0,
    this.endPhase = NebaViewPhase.cover,
    this.end = 0.45,
  });

  /// The whole of one [phase], as CSS writes `animation-range: exit`.
  const NebaViewRange.phase(NebaViewPhase phase)
    : startPhase = phase,
      start = 0,
      endPhase = phase,
      end = 1;

  /// The phase the effect starts in.
  final NebaViewPhase startPhase;

  /// How far into [startPhase] the effect starts, from 0 to 1.
  final double start;

  /// The phase the effect ends in.
  final NebaViewPhase endPhase;

  /// How far into [endPhase] the effect ends, from 0 to 1.
  final double end;

  @override
  bool operator ==(Object other) {
    return other is NebaViewRange &&
        other.startPhase == startPhase &&
        other.start == start &&
        other.endPhase == endPhase &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(startPhase, start, endPhase, end);
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

// ---------------------------------------------------------------------------
// Charts
//
// The vocabulary the chart widgets share, and the reason it is here rather
// than in one of them: a `series` handed to a line chart has to be the same
// `series` a bar chart takes, or switching a dashboard tile from one to the
// other is a rewrite instead of a rename. Everything here describes data; how
// a chart draws it belongs to the widget.
// ---------------------------------------------------------------------------

/// One value, with everything a chart might want to know about it: the React
/// package's `NebaChartPoint`.
///
/// A [y] of `null` is a gap and not a zero: a sensor that was offline, a month
/// that has not closed yet. A line breaks across it and an area breaks with
/// it, because a chart that draws missing data as zero reports an outage as a
/// collapse.
@immutable
class NebaChartPoint {
  /// A point at [y].
  const NebaChartPoint({required this.y, this.x, this.z, this.color, this.label})
    : assert(x == null || x is String || x is num || x is DateTime),
      assert(color == null || color is NebaColor || color is Color);

  /// Its place on the category axis: a [String], a [num] or a [DateTime].
  /// Without it the point is placed by its index, against the chart's
  /// `categories` if it was given any.
  final Object? x;

  /// The value. `null` is a gap.
  final double? y;

  /// A second magnitude, for the marks that have one: the radius of a bubble,
  /// the weight of a tile. Ignored by the charts that do not.
  final double? z;

  /// Overrides the series' colour for this one point: a [NebaColor] family or
  /// a [Color].
  final Object? color;

  /// What the tooltip, the table and a value label say instead of [y].
  final String? label;

  @override
  bool operator ==(Object other) {
    return other is NebaChartPoint &&
        other.x == x &&
        other.y == y &&
        other.z == z &&
        other.color == color &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(x, y, z, color, label);
}

/// Which value axis a [NebaChartSeries] is measured against.
enum NebaChartSeriesAxis {
  /// The chart's `yAxis`.
  primary,

  /// The chart's `secondaryAxis`, on the far edge. Read only when the chart
  /// was given one, and never on a stacked chart.
  secondary,
}

/// One line, one band of bars, one ring of slices, and the unit identity is
/// attached to: the React package's `NebaChartSeries`.
///
/// A series' colour follows its place in the list it was passed in, never its
/// position among the ones currently drawn, so hiding one from the legend
/// never repaints the others.
@immutable
class NebaChartSeries {
  /// A series of [data].
  const NebaChartSeries({
    required this.data,
    this.name,
    this.color,
    this.hidden = false,
    this.axis = NebaChartSeriesAxis.primary,
  }) : assert(color == null || color is NebaColor || color is Color);

  /// Its name in the legend, the tooltip and the table. A chart with two or
  /// more series shows a legend, so a series with no name is one the reader
  /// cannot tell apart from the others.
  final String? name;

  /// The values, in category order. Each is a [num], `null` for a gap, or a
  /// [NebaChartPoint]; anything else is read as a gap.
  final List<Object?> data;

  /// Overrides the palette slot this series would otherwise take: a
  /// [NebaColor] family or a [Color].
  final Object? color;

  /// Starts the series hidden. Only meaningful with an interactive legend,
  /// which is what turns it back on.
  final bool hidden;

  /// Which value axis the series is measured against.
  final NebaChartSeriesAxis axis;

  @override
  bool operator ==(Object other) {
    return other is NebaChartSeries &&
        other.name == name &&
        listEquals(other.data, data) &&
        other.color == color &&
        other.hidden == hidden &&
        other.axis == axis;
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(data), color, hidden, axis);
}

/// How a line gets from one point to the next.
enum NebaChartCurve {
  /// Straight segments. The only one that claims nothing the data did not
  /// say.
  linear,

  /// A monotone cubic: curved, but it never dips below a value that both of
  /// its neighbours are above.
  smooth,

  /// Held at each value until the next one, for a value that was set rather
  /// than measured.
  step,
}

/// What a line or a band does where a value is missing.
enum NebaChartNulls {
  /// Breaks at it. The default, and the only one that states no number nobody
  /// measured.
  gap,

  /// Joins the two sides with a straight segment, for a gap that came from the
  /// collection rather than from the world.
  connect,

  /// Reads it as a nought everywhere: the mark goes to the baseline, the axis
  /// takes the nought into its range, and the tooltip and the table say `0`.
  zero,
}

/// Which values are written onto the marks themselves.
enum NebaChartValueLabels {
  /// None. A number beside every point is the most reliable way to make a
  /// chart unreadable.
  none,

  /// The last value each series has: where it ended up.
  last,

  /// Each series' own high and low.
  extremes,

  /// Every value.
  all,
}

/// Whether a point on a line gets a dot on it.
enum NebaChartMarkers {
  /// None, except the one the crosshair is on.
  none,

  /// One on every point while a series has fourteen or fewer of them.
  auto,

  /// One on every point.
  all,
}

/// How a chart stacks its series, where it takes more than on or off.
enum NebaChartStacking {
  /// Each series on its own, overlaid: the React package's `false`.
  off,

  /// Each series riding on the total of the ones before it, so the top edge is
  /// the sum: `true`.
  on,

  /// Every category normalised to a hundred, so the chart is about the mix
  /// rather than the size: `'full'`.
  full,
}

/// One axis of a cartesian chart: the React package's `NebaChartAxis`.
@immutable
class NebaChartAxis {
  /// An axis.
  const NebaChartAxis({
    this.hidden = false,
    this.label,
    this.grid,
    this.min,
    this.max,
    this.tickCount,
    this.tickFormat,
    this.tickAngle = 0,
    this.thickness,
  });

  /// Leaves the axis undrawn, its rule, its ticks and its labels, and gives
  /// its band back to the plot.
  final bool hidden;

  /// A name for what the axis measures, written beside it.
  final String? label;

  /// The gridlines this axis casts across the plot. On for the value axis and
  /// off for the category axis when left out.
  final bool? grid;

  /// Where the scale starts. Taken from the data when left out.
  final double? min;

  /// Where the scale ends. Taken from the data when left out.
  final double? max;

  /// Roughly how many ticks. The scale still rounds to clean numbers.
  final int? tickCount;

  /// How a tick is written, over the chart's own `format`. A value axis hands
  /// it the tick as a [num], an [int] when it is whole; a category axis hands
  /// it the category as it was given.
  final String Function(Object value, int index)? tickFormat;

  /// Turns the category labels by this many degrees, between `-90` and `90`.
  /// Negative tilts them up to the right.
  final double tickAngle;

  /// How much room the axis keeps for its ticks, in logical pixels. Measured
  /// from the ticks when left out.
  final double? thickness;

  @override
  bool operator ==(Object other) {
    return other is NebaChartAxis &&
        other.hidden == hidden &&
        other.label == label &&
        other.grid == grid &&
        other.min == min &&
        other.max == max &&
        other.tickCount == tickCount &&
        other.tickFormat == tickFormat &&
        other.tickAngle == tickAngle &&
        other.thickness == thickness;
  }

  @override
  int get hashCode {
    return Object.hash(hidden, label, grid, min, max, tickCount, tickFormat, tickAngle, thickness);
  }
}

/// Where a chart's legend sits, and whether it does anything when pressed:
/// the React package's `NebaChartLegend`.
@immutable
class NebaChartLegend {
  /// A legend.
  const NebaChartLegend({
    this.side = NebaSide.bottom,
    this.align = NebaAlign.center,
    this.interactive = true,
    this.showValue = false,
  });

  /// Which edge of the plot.
  final NebaSide side;

  /// Where along that edge.
  final NebaAlign align;

  /// Pressing an entry hides and shows its series, and pointing at one dims
  /// the rest.
  final bool interactive;

  /// Writes each series' value at the active category beside its name.
  final bool showValue;

  @override
  bool operator ==(Object other) {
    return other is NebaChartLegend &&
        other.side == side &&
        other.align == align &&
        other.interactive == interactive &&
        other.showValue == showValue;
  }

  @override
  int get hashCode => Object.hash(side, align, interactive, showValue);
}

/// What the pointer uncovers on a chart.
enum NebaChartTooltipMode {
  /// Every series at the category under the pointer, with a crosshair: the
  /// React package's `'index'`, which Dart reserves on an enum.
  category,

  /// The one series whose mark is nearest the pointer.
  item,

  /// No tooltip.
  none,
}

/// One series' answer at the category the pointer is on.
@immutable
class NebaChartTooltipItem {
  /// The reading of series [seriesIndex].
  const NebaChartTooltipItem({
    required this.seriesIndex,
    required this.color,
    required this.value,
    required this.formatted,
    this.name,
    this.label,
  });

  /// Its place in the chart's `series`: the same index its colour came from.
  final int seriesIndex;

  /// The series' name.
  final String? name;

  /// The colour its mark is drawn in.
  final Color color;

  /// The value.
  final double value;

  /// [value] written through the chart's `format`.
  final String formatted;

  /// What the point called itself, if it said.
  final String? label;
}

/// What a tooltip's [NebaChartTooltip.builder] is handed.
@immutable
class NebaChartTooltipContext {
  /// The reading at category [index].
  const NebaChartTooltipContext({required this.index, required this.category, required this.items});

  /// The category's place along the axis.
  final int index;

  /// The category as it was given: a [String], a [num] or a [DateTime].
  final Object category;

  /// Only the series that are shown and have a value here.
  final List<NebaChartTooltipItem> items;
}

/// A chart's tooltip, when `true` or `false` is not enough: the React
/// package's `NebaChartTooltip`.
@immutable
class NebaChartTooltip {
  /// A tooltip.
  const NebaChartTooltip({this.mode, this.crosshair = true, this.builder});

  /// What the pointer uncovers. [NebaChartTooltipMode.category] when left
  /// out.
  final NebaChartTooltipMode? mode;

  /// The line dropped through the plot at the active category, in
  /// [NebaChartTooltipMode.category] mode.
  final bool crosshair;

  /// Draws the panel. Without it the chart draws its own.
  final Widget Function(BuildContext context, NebaChartTooltipContext reading)? builder;

  @override
  bool operator ==(Object other) {
    return other is NebaChartTooltip &&
        other.mode == mode &&
        other.crosshair == crosshair &&
        other.builder == builder;
  }

  @override
  int get hashCode => Object.hash(mode, crosshair, builder);
}

/// Which axis a [NebaChartReference]'s numbers are read against.
enum NebaChartReferenceAxis {
  /// The one the marks are measured on: a target, a budget, a limit.
  value,

  /// The one they are placed along, for a rule that says when: on an axis of
  /// columns, the number is the column's index.
  category,
}

/// A line, or a band, drawn across a plot at a value the data has none of: the
/// React package's `NebaChartReference`.
///
/// The scale widens to hold it, so a target above everything measured is still
/// on the chart.
@immutable
class NebaChartReference {
  /// A rule at [value], or a band from [value] to [to].
  const NebaChartReference({
    required this.value,
    this.to,
    this.axis = NebaChartReferenceAxis.value,
    this.label,
    this.color,
    this.solid = false,
  }) : assert(color == null || color is NebaColor || color is Color);

  /// Where it sits, in the units of the axis it is read against.
  final double value;

  /// Turns the rule into a band from [value] to here.
  final double? to;

  /// Which axis the numbers are read against.
  final NebaChartReferenceAxis axis;

  /// What it is called, written at its far end and read out with the data.
  final String? label;

  /// Its colour: a [NebaColor] family or a [Color]. The muted ink when left
  /// out.
  final Object? color;

  /// Draws it as a solid rule rather than a dashed one.
  final bool solid;

  @override
  bool operator ==(Object other) {
    return other is NebaChartReference &&
        other.value == value &&
        other.to == to &&
        other.axis == axis &&
        other.label == label &&
        other.color == color &&
        other.solid == solid;
  }

  @override
  int get hashCode => Object.hash(value, to, axis, label, color, solid);
}
