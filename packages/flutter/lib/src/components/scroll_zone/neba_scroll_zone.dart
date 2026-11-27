/// `NebaScrollZone`, a strip of anything scrolled along one direction.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/scroll_keys.dart';
import 'package:neba/src/internal/wheel.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// When a [NebaScrollZone] draws its scroll buttons.
enum NebaScrollZoneButtons {
  /// Neither while everything fits, and at an end whichever costs less: an
  /// overlaid button with nowhere to go is not drawn at all, and an inline one
  /// is drawn disabled, in the lane that is held open either way.
  auto,

  /// Both, from the first frame, with the one that has nowhere to go disabled
  /// rather than gone: for a strip whose content arrives later.
  always,

  /// None. A drag, the keys and whatever the platform already scrolls with
  /// are still there.
  none,
}

/// What pressing a [NebaScrollZone]'s button does.
enum NebaScrollZoneMode {
  /// Moves to the next child along, [NebaScrollZone.step] of them at a time.
  item,

  /// Moves by everything on screen, the way Page Down does.
  page,

  /// Scrolls for as long as the button is held, at [NebaScrollZone.speed]
  /// pixels a second. A press too short to be a hold moves one item, so a
  /// quick tap is never a dead press.
  hold,
}

/// Where a [NebaScrollZone]'s buttons sit, which is also where the strip ends.
enum NebaScrollZoneButtonPlacement {
  /// Beside the strip. The strip stops where a button starts, so an item is
  /// cut off at the button's edge rather than sliding beneath it.
  inline,

  /// Over the ends of the strip, which keeps the whole box for content and
  /// lets an item pass under a button: for a shelf of pictures.
  overlay,
}

/// A strip of anything, laid out in one direction and scrolled in it.
///
/// Cards, chips, avatars or thumbnails run across the box or down it, in as
/// many [lines] as asked for, with a pair of buttons for the pointer that has
/// neither a wheel nor a finger. Underneath it is an ordinary Flutter scroll
/// view, so a finger, a trackpad and momentum are the platform's own; what is
/// added on top is the buttons, a mouse drag, the keys and, where it is asked
/// for, the wheel turned onto the strip. Nothing is transformed: the strip
/// moves by its scroll offset, which is also what runs it the other way under
/// RTL.
///
/// Like any Flutter scroll view it needs a bounded size along the way it
/// runs: a horizontal zone inside a [Row] goes in an [Expanded], and a
/// vertical one is given a height.
///
/// ```dart
/// NebaScrollZone(label: 'Continue watching', spacing: 3, children: cards)
/// ```
class NebaScrollZone extends StatefulWidget {
  /// A strip of [children].
  const NebaScrollZone({
    required this.children,
    this.orientation = NebaOrientation.horizontal,
    this.lines = 1,
    this.spacing = 2,
    this.buttons = NebaScrollZoneButtons.auto,
    this.buttonPlacement = NebaScrollZoneButtonPlacement.inline,
    this.mode = NebaScrollZoneMode.item,
    this.step = 1,
    this.speed = 900,
    this.snap = false,
    this.drag = true,
    this.wheel = false,
    this.scrollbar = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.locale,
    this.label,
    this.previousLabel,
    this.nextLabel,
    this.controller,
    this.onScroll,
    super.key,
  });

  /// Which way the children run, and therefore which way the zone scrolls.
  final NebaOrientation orientation;

  /// How many rows a horizontal zone lays its children out in before it
  /// starts a new column, and how many columns a vertical one uses. `2` is
  /// the shelf that holds twice as much in the same width. Below `1` counts
  /// as `1`.
  final int lines;

  /// The gap between children, on the spacing scale: `2` is 8 logical pixels.
  final double spacing;

  /// When the scroll buttons are drawn.
  final NebaScrollZoneButtons buttons;

  /// Whether the buttons sit beside the strip or over it.
  final NebaScrollZoneButtonPlacement buttonPlacement;

  /// What pressing a button does.
  final NebaScrollZoneMode mode;

  /// How many children one press moves, in [NebaScrollZoneMode.item]. Below
  /// `1` counts as `1`.
  final int step;

  /// How fast a held button scrolls, in logical pixels a second.
  final double speed;

  /// Brings the nearest child to the leading edge when the scrolling stops,
  /// however it was scrolled: a drag and the wheel as well as the buttons.
  final bool snap;

  /// Lets a mouse drag the strip along, the way a finger, a stylus and a
  /// trackpad already do.
  final bool drag;

  /// Turns a wheel rolled over a horizontal strip into travel along it, and
  /// holds it there, at the ends as well: the pointer leaving the strip is
  /// what gives the page its wheel back. A sideways swipe is left to the
  /// strip, which already scrolls with it, and a vertical zone ignores this.
  final bool wheel;

  /// Shows the platform's scrollbar, as the app's `ScrollBehavior` draws it.
  final bool scrollbar;

  /// The weight of the scroll buttons; the zone itself draws nothing.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.solid].
  final NebaVariant? variant;

  /// The buttons' size, and how far they sit from the edge or the strip.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the buttons and of the strip's focus ring. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The buttons' padding, and nothing else. Defaults to `NebaProvider`'s,
  /// then [NebaDensity.standard].
  final NebaDensity? density;

  /// The language the buttons and the region name themselves in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// What the scrollable region is called: "Categories", "Recent files".
  /// Without one, a screen reader hears "Scrollable content" in the
  /// [locale]'s words.
  final String? label;

  /// The back button's own name.
  final String? previousLabel;

  /// The forward button's own name.
  final String? nextLabel;

  /// The strip's scroll controller, to read or restore its position through.
  final ScrollController? controller;

  /// Called whenever the strip scrolls, with where it is.
  final ValueChanged<ScrollMetrics>? onScroll;

  /// The strip's items. Each child is one cell of the strip's grid.
  final List<Widget> children;

  /// How far overlaid buttons sit in from the edge they are held against.
  static const Map<NebaSize, double> buttonInsets = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 12,
    NebaSize.xl: 16,
  };

  /// The air between an inline button and the strip beside it.
  static const Map<NebaSize, double> buttonGaps = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 12,
    NebaSize.xl: 16,
  };

  @override
  State<NebaScrollZone> createState() => _NebaScrollZoneState();
}

/// Under this long, a press in [NebaScrollZoneMode.hold] was a tap.
const Duration _tap = Duration(milliseconds: 140);

/// Under this much room left, the strip has nowhere to go that way.
const double _slack = 1;

enum _Side { back, forward }

class _NebaScrollZoneState extends State<NebaScrollZone> with SingleTickerProviderStateMixin {
  ScrollController? _own;

  late final FocusNode _stripFocus = FocusNode(
    debugLabel: 'NebaScrollZone',
    onKeyEvent: _onStripKey,
  );
  late final FocusNode _backFocus = FocusNode(
    debugLabel: 'NebaScrollZone back',
    onKeyEvent: (FocusNode node, KeyEvent event) => _onButtonKey(false, event),
  );
  late final FocusNode _forwardFocus = FocusNode(
    debugLabel: 'NebaScrollZone forward',
    onKeyEvent: (FocusNode node, KeyEvent event) => _onButtonKey(true, event),
  );

  final GlobalKey _trackKey = GlobalKey();
  late final _SnapGrid _grid = _SnapGrid(_starts);

  // Whether there is anything left behind and ahead, or `null` before the
  // strip has been measured.
  (bool, bool)? _reach;

  // The button holding the focus, which an overlaid `auto` button that runs
  // out is kept for: taking it away would take the focus with it.
  _Side? _held;

  bool _focusVisible = false;
  bool _dragging = false;

  // How much of the zone the held lanes take, from the last build.
  double _heldExtent = 0;

  // The hold, while a button is held down.
  Ticker? _ticker;
  bool? _holdForward;
  bool _holdByKey = false;
  Duration _holdElapsed = Duration.zero;
  Duration _holdLastTick = Duration.zero;
  AppLifecycleListener? _lifecycle;

  ScrollController get _controller => widget.controller ?? (_own ??= ScrollController());

  bool get _horizontal => widget.orientation == NebaOrientation.horizontal;

  bool get _inline => widget.buttonPlacement == NebaScrollZoneButtonPlacement.inline;

  // Before its first measurement an inline `auto` zone holds both lanes open
  // with nothing visible in them, so the first frame already has the shape a
  // strip that overflows will have.
  bool get _holding => _reach == null && _inline && widget.buttons == NebaScrollZoneButtons.auto;

  @override
  void initState() {
    super.initState();
    _backFocus.addListener(_onButtonFocus);
    _forwardFocus.addListener(_onButtonFocus);
    FocusManager.instance.addListener(_onPrimaryFocus);
  }

  @override
  void didUpdateWidget(NebaScrollZone oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mode == NebaScrollZoneMode.hold && widget.mode != NebaScrollZoneMode.hold) {
      _releaseHold(advance: false);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onPrimaryFocus);
    _backFocus.removeListener(_onButtonFocus);
    _forwardFocus.removeListener(_onButtonFocus);
    _releaseHold(advance: false);
    _ticker?.dispose();
    _stripFocus.dispose();
    _backFocus.dispose();
    _forwardFocus.dispose();
    _own?.dispose();
    super.dispose();
  }

  /// Where each child starts along the strip, from the track's last layout.
  List<double> _starts() {
    final RenderObject? track = _trackKey.currentContext?.findRenderObject();

    return track is _RenderTrack && track.hasSize ? track.starts : const <double>[];
  }

  bool _onMetrics(ScrollMetrics metrics) {
    // Measured against the room the zone would have without the held lanes,
    // or a strip that fits only once they are gone would keep them.
    final (bool, bool) reach = (
      metrics.extentBefore > _slack,
      metrics.extentAfter - _heldExtent > _slack,
    );

    if (reach != _reach) {
      setState(() => _reach = reach);
    }

    return false;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      // A drag settles on the nearest child, not the next one along.
      _grid.direction = 0;

      if (notification.dragDetails!.kind == PointerDeviceKind.mouse) {
        setState(() => _dragging = true);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_dragging && notification.dragDetails == null) {
        setState(() => _dragging = false);
      }

      widget.onScroll?.call(notification.metrics);
    } else if (notification is ScrollEndNotification && _dragging) {
      setState(() => _dragging = false);
    }

    return _onMetrics(notification.metrics);
  }

  /// One press, in whichever unit [unit] counts: a hold counts in items.
  void _advance(bool forward, [NebaScrollZoneMode? unit]) {
    if (!_controller.hasClients) {
      return;
    }

    final ScrollPosition position = _controller.position;
    final double sign = forward ? 1 : -1;
    final double at = position.pixels;

    _grid.direction = 0;

    if ((unit ?? widget.mode) == NebaScrollZoneMode.page) {
      nebaScrollTo(context, position, at + position.viewportDimension * sign);
      return;
    }

    // Measured rather than assumed: the children are whatever the caller put
    // there, so no two of them are necessarily the same width.
    final int items = math.max(1, widget.step);
    final List<double> starts = _starts();
    final List<double> ahead = <double>[
      for (final double start in starts)
        if (start - at > _slack) start,
    ];
    final List<double> behind = <double>[
      for (final double start in starts)
        if (start - at < -_slack) start,
    ];
    final double? target = forward
        ? (ahead.length >= items ? ahead[items - 1] : null)
        : (behind.length >= items ? behind[behind.length - items] : null);

    // Nothing that far along: go as far as there is, or the last half-item of
    // a strip would be out of the buttons' reach.
    nebaScrollTo(context, position, target ?? at + position.viewportDimension * sign);
  }

  void _beginHold(bool forward, {required bool byKey}) {
    if (_holdForward != null) {
      return;
    }

    _holdForward = forward;
    _holdByKey = byKey;
    _holdElapsed = Duration.zero;
    _holdLastTick = Duration.zero;
    _grid.direction = 0;
    // A press let go outside the app sends nothing back, and a loop nobody
    // can stop is the worst kind.
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        if (state != AppLifecycleState.resumed) {
          _releaseHold();
        }
      },
    );
    (_ticker ??= createTicker(_onHoldTick)).start();
  }

  void _onHoldTick(Duration elapsed) {
    final bool? forward = _holdForward;

    if (forward == null || !_controller.hasClients) {
      return;
    }

    // By the clock rather than by the frame, so the strip moves at [speed]
    // whatever the display is doing.
    final double seconds =
        (elapsed - _holdLastTick).inMicroseconds / Duration.microsecondsPerSecond;
    final ScrollPosition position = _controller.position;
    final double next = (position.pixels + widget.speed * seconds * (forward ? 1 : -1)).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _holdLastTick = elapsed;
    _holdElapsed = elapsed;

    if (next != position.pixels) {
      position.jumpTo(next);
    }
  }

  void _releaseHold({bool advance = true}) {
    final bool? forward = _holdForward;

    if (forward == null) {
      return;
    }

    _holdForward = null;
    _ticker?.stop();
    _lifecycle?.dispose();
    _lifecycle = null;

    // A press shorter than a hold was a tap, and a tap that scrolled three
    // pixels reads as a broken button.
    if (advance && _holdElapsed < _tap && mounted) {
      _advance(forward, NebaScrollZoneMode.item);
    }
  }

  KeyEventResult _onButtonKey(bool forward, KeyEvent event) {
    final LogicalKeyboardKey key = event.logicalKey;

    if (widget.mode != NebaScrollZoneMode.hold ||
        (key != LogicalKeyboardKey.enter &&
            key != LogicalKeyboardKey.numpadEnter &&
            key != LogicalKeyboardKey.space)) {
      return KeyEventResult.ignored;
    }

    // The keyboard's own half of a hold: without it the button is a control
    // a pointer can use and a keyboard cannot.
    if (event is KeyDownEvent) {
      if (forward ? (_reach?.$2 ?? false) : (_reach?.$1 ?? false)) {
        _beginHold(forward, byKey: true);
      }
    } else if (event is KeyUpEvent) {
      _releaseHold();
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _onStripKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;

    // Which way a snapping strip settles once the step is over: on the next
    // child in the direction of the key, as a browser snaps after one.
    _grid.direction = switch (key) {
      LogicalKeyboardKey.arrowRight when _horizontal => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowLeft when _horizontal => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowDown when !_horizontal => 1,
      LogicalKeyboardKey.arrowUp when !_horizontal => -1,
      LogicalKeyboardKey.pageDown || LogicalKeyboardKey.end => 1,
      LogicalKeyboardKey.pageUp || LogicalKeyboardKey.home => -1,
      _ => 0,
    };

    final KeyEventResult result = nebaScrollKey(
      context,
      event,
      vertical: _horizontal ? null : _controller,
      horizontal: _horizontal ? _controller : null,
    );

    if (result == KeyEventResult.ignored) {
      _grid.direction = 0;
    }

    return result;
  }

  void _onButtonFocus() {
    final _Side? held = _forwardFocus.hasFocus
        ? _Side.forward
        : (_backFocus.hasFocus ? _Side.back : null);

    if (_holdByKey && _holdForward != null && held == null) {
      _releaseHold(advance: false);
    }

    if (held != _held) {
      setState(() => _held = held);
    }
  }

  /// The wheel over the strip, as `nebaStripWheel` answers it, and the way it
  /// went for the snap to settle towards.
  void _onSignal(PointerSignalEvent event) {
    if (!_controller.hasClients) {
      return;
    }

    final int? direction = nebaStripWheel(
      event,
      _controller.position,
      axis: _horizontal ? Axis.horizontal : Axis.vertical,
      turn: widget.wheel,
      textDirection: Directionality.of(context),
    );

    if (direction != null) {
      _grid.direction = direction;
    }
  }

  /// Keeps a child the keyboard focused inside the strip clear of its edge,
  /// so the ring drawn outside it is not cut off where the strip clips.
  void _onPrimaryFocus() {
    final FocusNode? focus = FocusManager.instance.primaryFocus;

    if (focus == null ||
        focus == _stripFocus ||
        FocusManager.instance.highlightMode != FocusHighlightMode.traditional ||
        !_controller.hasClients ||
        !focus.ancestors.contains(_stripFocus)) {
      return;
    }

    final RenderObject? object = focus.context?.findRenderObject();

    if (object == null || !object.attached) {
      return;
    }

    // The strip's own viewport, the track's parent, and not a scroll view
    // inside one of its children.
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(object);

    if (viewport == null || viewport != _trackKey.currentContext?.findRenderObject()?.parent) {
      return;
    }

    final ScrollPosition position = _controller.position;
    // With snap the child lands on the edge it snaps to, and a margin would
    // set every one of them a few pixels in from it.
    final double margin = widget.snap ? 0 : focusRingOffset + focusRingWidth;
    final double lead = viewport.getOffsetToReveal(object, 0).offset - margin;
    final double trail = viewport.getOffsetToReveal(object, 1).offset + margin;
    final double? to = position.pixels > lead ? lead : (position.pixels < trail ? trail : null);

    if (to != null) {
      position.jumpTo(to.clamp(position.minScrollExtent, position.maxScrollExtent));
    }
  }

  ScrollBehavior _behavior(BuildContext context) {
    final ScrollBehavior ambient = ScrollConfiguration.of(context);
    final Set<PointerDeviceKind> devices = <PointerDeviceKind>{...ambient.dragDevices};

    if (widget.drag) {
      devices.add(PointerDeviceKind.mouse);
    } else {
      devices.remove(PointerDeviceKind.mouse);
    }

    return ambient.copyWith(dragDevices: devices, scrollbars: widget.scrollbar);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final Map<String, String> messages = nebaMessages(context, 'scroll', locale: widget.locale);
    final TextDirection direction = Directionality.of(context);
    final bool horizontal = _horizontal;
    final bool inline = _inline;
    final bool holding = _holding;
    final Axis axis = horizontal ? Axis.horizontal : Axis.vertical;
    final double gap = NebaScrollZone.buttonGaps[size]!;
    // A scroll button is round, as wide as it is tall.
    final double lane = NebaScale.controlHeight[size]!;

    _heldExtent = holding ? 2 * (lane + gap) : 0;

    final bool canGoBack = _reach?.$1 ?? false;
    final bool canGoForward = _reach?.$2 ?? false;
    final bool overflows = canGoBack || canGoForward;
    final bool drawn =
        widget.buttons != NebaScrollZoneButtons.none &&
        (widget.buttons == NebaScrollZoneButtons.always || holding || overflows);

    Widget? scrollButton(bool forward) {
      final bool available = forward ? canGoForward : canGoBack;
      final _Side side = forward ? _Side.forward : _Side.back;

      // An overlaid button takes no room, so the one with nowhere to go is
      // not drawn at all, unless it holds the focus: pressing it is what ran
      // it out. An inline one sits in a lane kept either way, so it stays.
      if (widget.buttons == NebaScrollZoneButtons.auto && !available && !inline && _held != side) {
        return null;
      }

      final bool hold = widget.mode == NebaScrollZoneMode.hold;
      // Drawn pointing down and turned, which is the one allowance the
      // no-transform rule makes. A quarter turn clockwise points it back
      // along a left-to-right strip.
      final int turns = horizontal
          ? (forward == (direction == TextDirection.ltr) ? 3 : 1)
          : (forward ? 0 : 2);

      Widget button = _ScrollButton(
        variant: variant,
        size: size,
        color: color,
        density: density,
        label: forward
            ? (widget.nextLabel ?? messages['next']!)
            : (widget.previousLabel ?? messages['previous']!),
        available: available,
        focusNode: forward ? _forwardFocus : _backFocus,
        // A hold is driven by the pointer going down and up below; the tap
        // itself does nothing, and keeps the button enabled.
        onPressed: hold ? () {} : () => _advance(forward),
        turns: turns,
      );

      if (hold) {
        button = Listener(
          onPointerDown: available
              ? (PointerDownEvent event) {
                  if (event.buttons & kPrimaryButton != 0) {
                    _beginHold(forward, byKey: false);
                  }
                }
              : null,
          // Ended whatever the button has become since, or a hold that ran
          // the strip out would never stop.
          onPointerUp: (PointerUpEvent event) => _releaseHold(),
          onPointerCancel: (PointerCancelEvent event) => _releaseHold(),
          child: button,
        );
      }

      return button;
    }

    Widget strip = _Track(
      key: _trackKey,
      axis: axis,
      lines: math.max(1, widget.lines),
      gap: widget.spacing * NebaScale.spacingUnit,
      textDirection: direction,
      children: nebaPresentChildren(context, widget.children),
    );

    strip = SingleChildScrollView(
      controller: _controller,
      scrollDirection: axis,
      primary: false,
      physics: widget.snap ? _SnapPhysics(_grid) : null,
      // Clipped below instead, a little wider than the strip across it.
      clipBehavior: Clip.none,
      child: strip,
    );

    strip = NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification notification) =>
          notification.depth == 0 && _onMetrics(notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: ScrollConfiguration(behavior: _behavior(context), child: strip),
      ),
    );

    strip = MouseRegion(
      cursor: widget.drag && overflows
          ? (_dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab)
          : MouseCursor.defer,
      child: Listener(onPointerSignal: _onSignal, child: strip),
    );

    // What a strip holds is most often a row of things to press, whose focus
    // rings stand four pixels outside them. Across a horizontal strip the
    // clip gives them that room; along it, and across a vertical one, the
    // strip clips at its edge, since the lanes are measured off its box.
    strip = ClipRect(
      clipper: _Bleed(horizontal ? focusRingOffset + focusRingWidth : 0),
      child: strip,
    );

    strip = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label ?? messages['label'],
      child: FocusableActionDetector(
        focusNode: _stripFocus,
        // A tab stop only while there is somewhere to go: a row of chips that
        // fits is a stop that does nothing.
        enabled: overflows,
        onShowFocusHighlight: (bool visible) => setState(() => _focusVisible = visible),
        child: NebaFocusRing(
          visible: _focusVisible && overflows,
          color: tokens.roles(color).ring,
          offset: -focusRingWidth,
          child: strip,
        ),
      ),
    );

    // The same three children on every build, so the strip is never built
    // again when the lanes come or go and its scroll position is kept.
    final Widget? back = drawn && inline ? scrollButton(false) : null;
    final Widget? forward = drawn && inline ? scrollButton(true) : null;
    final Widget frame = Flex(
      direction: axis,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Lane(axis: axis, gap: gap, leading: true, held: holding, child: back),
        Expanded(child: strip),
        _Lane(axis: axis, gap: gap, leading: false, held: holding, child: forward),
      ],
    );

    final Widget? overlaidBack = drawn && !inline ? scrollButton(false) : null;
    final Widget? overlaidForward = drawn && !inline ? scrollButton(true) : null;

    return FocusTraversalGroup(
      // The order the widgets are in, as a browser tabs through the order of
      // the markup: a strip's children run past the forward button on
      // screen, and reading order would visit it in the middle of them.
      policy: WidgetOrderTraversalPolicy(),
      child: Stack(
        children: <Widget>[
          // Stretched across, so a lane is as tall as the strip and its button
          // sits in the middle of it.
          if (horizontal) IntrinsicHeight(child: frame) else frame,
          if (drawn && !inline)
            Positioned.fill(
              child: Padding(
                // Along the strip only: across it the button is centred, and
                // a strip thinner than a button lets it stand out either side
                // rather than squeezing it, as a flex item overflows its line.
                padding: horizontal
                    ? EdgeInsets.symmetric(horizontal: NebaScrollZone.buttonInsets[size]!)
                    : EdgeInsets.symmetric(vertical: NebaScrollZone.buttonInsets[size]!),
                child: Flex(
                  direction: axis,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (final Widget? button in <Widget?>[overlaidBack, overlaidForward])
                      if (button == null)
                        const SizedBox.shrink()
                      else
                        SizedBox(
                          width: horizontal ? lane : null,
                          height: horizontal ? null : lane,
                          child: OverflowBox(
                            minWidth: horizontal ? null : lane,
                            maxWidth: horizontal ? null : lane,
                            minHeight: horizontal ? lane : null,
                            maxHeight: horizontal ? lane : null,
                            child: button,
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The room beside the strip an inline button sits in.
class _Lane extends StatelessWidget {
  const _Lane({
    required this.axis,
    required this.gap,
    required this.leading,
    required this.held,
    required this.child,
  });

  final Axis axis;
  final double gap;
  final bool leading;

  /// Held open with nothing visible in it, before the strip is measured.
  final bool held;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget? button = child;

    if (button == null) {
      return const SizedBox.shrink();
    }

    final bool horizontal = axis == Axis.horizontal;

    return Padding(
      padding: horizontal
          ? EdgeInsetsDirectional.only(end: leading ? gap : 0, start: leading ? 0 : gap)
          : EdgeInsets.only(bottom: leading ? gap : 0, top: leading ? 0 : gap),
      child: Center(
        widthFactor: horizontal ? 1 : null,
        heightFactor: horizontal ? null : 1,
        // Hidden rather than left out, so the lane is already as wide as it
        // will be; a hidden button can neither take the focus nor be heard.
        child: ExcludeFocus(
          excluding: held,
          child: Visibility(
            visible: !held,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: button,
          ),
        ),
      ),
    );
  }
}

/// A scroll button: a `NebaIconButton` around a chevron.
class _ScrollButton extends StatelessWidget {
  const _ScrollButton({
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.label,
    required this.available,
    required this.focusNode,
    required this.onPressed,
    required this.turns,
  });

  final NebaVariant variant;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final String label;
  final bool available;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final int turns;

  @override
  Widget build(BuildContext context) {
    return NebaIconButton(
      onPressed: onPressed,
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: 1,
      // Disabled rather than gone while it has nowhere to go, and still in the
      // focus order, so the press that reached the end leaves the focus on it.
      disabled: !available,
      focusableWhenDisabled: true,
      label: label,
      focusNode: focusNode,
      icon: RotatedBox(quarterTurns: turns, child: NebaGlyph(NebaGlyphs.chevron)),
    );
  }
}

/// The strip's clip: its own box, widened by [across] on both sides across
/// the strip.
class _Bleed extends CustomClipper<Rect> {
  const _Bleed(this.across);

  final double across;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, -across, size.width, size.height + across);

  @override
  bool shouldReclip(_Bleed oldClipper) => oldClipper.across != across;
}

/// What a snapping strip snaps to, and which way the last input went.
class _SnapGrid {
  _SnapGrid(this.starts);

  /// Where each child starts along the strip.
  final List<double> Function() starts;

  /// Which way the next settle goes: the next child ahead (`1`), the one
  /// behind (`-1`), or the nearest (`0`). Spent by the settle that reads it.
  int direction = 0;
}

/// A strip that comes to rest with a child at its leading edge.
///
/// A fling lands on the child nearest where it would have stopped; a drag let
/// go settles on the nearest one; the wheel and the keys go on to the next
/// one in their direction, as a browser snaps after them, or a notch shorter
/// than half a child would always fall back where it started.
class _SnapPhysics extends ScrollPhysics {
  const _SnapPhysics(this.grid, {super.parent});

  final _SnapGrid grid;

  @override
  _SnapPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapPhysics(grid, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Simulation? natural = super.createBallisticSimulation(position, velocity);
    final int direction = grid.direction;

    grid.direction = 0;

    // Past an end, the platform's own bounce or clamp brings it back first.
    if (position.outOfRange) {
      return natural;
    }

    final List<double> targets = <double>{
      for (final double start in grid.starts())
        start.clamp(position.minScrollExtent, position.maxScrollExtent),
    }.toList()..sort();

    if (targets.isEmpty) {
      return natural;
    }

    final Tolerance tolerance = toleranceFor(position);
    final double at = position.pixels;
    final double target;

    if (velocity.abs() > tolerance.velocity) {
      final double end = natural?.x(double.infinity) ?? at;

      target = _nearest(targets, end.isFinite ? end : at);
    } else if (direction > 0) {
      target = targets.firstWhere((double t) => t > at + 0.5, orElse: () => targets.last);
    } else if (direction < 0) {
      target = targets.lastWhere((double t) => t < at - 0.5, orElse: () => targets.first);
    } else {
      target = _nearest(targets, at);
    }

    if ((target - at).abs() < tolerance.distance && velocity.abs() < tolerance.velocity) {
      return null;
    }

    return ScrollSpringSimulation(spring, at, target, velocity, tolerance: tolerance);
  }

  static double _nearest(List<double> targets, double to) {
    return targets.reduce((double a, double b) => (a - to).abs() <= (b - to).abs() ? a : b);
  }
}

/// The strip's children on a grid: a fixed number of rows and as many
/// columns as it takes across, or a fixed number of columns down.
class _Track extends MultiChildRenderObjectWidget {
  const _Track({
    required this.axis,
    required this.lines,
    required this.gap,
    required this.textDirection,
    required super.children,
    super.key,
  });

  final Axis axis;
  final int lines;
  final double gap;
  final TextDirection textDirection;

  @override
  _RenderTrack createRenderObject(BuildContext context) {
    return _RenderTrack(axis: axis, lines: lines, gap: gap, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTrack renderObject) {
    renderObject
      ..axis = axis
      ..lines = lines
      ..gap = gap
      ..textDirection = textDirection;
  }
}

class _TrackParentData extends ContainerBoxParentData<RenderBox> {}

/// Where every child of the track goes, worked out once.
class _TrackLayout {
  const _TrackLayout(this.size, this.cells, this.starts);

  final Size size;

  /// Each child's cell, measured from the track's leading edge.
  final List<Rect> cells;

  /// The distinct places a child starts along the track, from its leading
  /// edge.
  final List<double> starts;
}

/// The track's grid, as CSS lays out a grid that flows in columns.
///
/// Across, every column is as wide as its widest child and every row as tall
/// as its tallest; down, the columns share the width evenly. A child fills its
/// cell, as a grid item stretches. Children are measured by their dry layout
/// and then laid out once, tightly: laid out tight a child is its own relayout
/// boundary, so a track that measured by laying out loosely first would never
/// hear that a child grew, while a dry layout that changes tells the parent.
class _RenderTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TrackParentData> {
  _RenderTrack({
    required Axis axis,
    required int lines,
    required double gap,
    required TextDirection textDirection,
  }) : _axis = axis,
       _lines = lines,
       _gap = gap,
       _textDirection = textDirection;

  Axis _axis;
  set axis(Axis value) {
    if (_axis != value) {
      _axis = value;
      markNeedsLayout();
    }
  }

  int _lines;
  set lines(int value) {
    if (_lines != value) {
      _lines = value;
      markNeedsLayout();
    }
  }

  double _gap;
  set gap(double value) {
    if (_gap != value) {
      _gap = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  List<double> _starts = const <double>[];

  /// Where each child starts along the track, from its leading edge, as of
  /// the last layout. Several children in one column share a start.
  List<double> get starts => _starts;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TrackParentData) {
      child.parentData = _TrackParentData();
    }
  }

  _TrackLayout _lay(BoxConstraints constraints) {
    final List<RenderBox> children = getChildrenAsList();
    final int count = children.length;

    if (count == 0) {
      return const _TrackLayout(Size.zero, <Rect>[], <double>[]);
    }

    final bool across = _axis == Axis.horizontal;
    final int rows = across ? _lines : (count / _lines).ceil();
    final int columns = across ? (count / _lines).ceil() : _lines;
    // Across, a child sits in column `i ~/ rows`; down, in row `i ~/ columns`.
    int columnOf(int i) => across ? i ~/ rows : i % columns;
    int rowOf(int i) => across ? i % rows : i ~/ columns;

    final List<double> widths = List<double>.filled(columns, 0);
    final List<double> heights = List<double>.filled(rows, 0);

    if (across) {
      // `max-content` columns: as wide as the widest child in each.
      final BoxConstraints natural = BoxConstraints(maxHeight: constraints.maxHeight);
      final List<Size> sizes = <Size>[
        for (final RenderBox child in children) child.getDryLayout(natural),
      ];

      for (int i = 0; i < count; i++) {
        widths[columnOf(i)] = math.max(widths[columnOf(i)], sizes[i].width);
      }

      for (int i = 0; i < count; i++) {
        final double width = widths[columnOf(i)];
        final double height = sizes[i].width == width
            ? sizes[i].height
            : children[i]
                  .getDryLayout(
                    BoxConstraints.tightFor(
                      width: width,
                    ).copyWith(maxHeight: constraints.maxHeight),
                  )
                  .height;

        heights[rowOf(i)] = math.max(heights[rowOf(i)], height);
      }
    } else {
      // Even columns across the width, as `repeat(n, minmax(0, 1fr))` shares
      // it, and rows as tall as their tallest child.
      final double width = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : children.fold<double>(
                      0,
                      (double widest, RenderBox child) =>
                          math.max(widest, child.getMaxIntrinsicWidth(double.infinity)),
                    ) *
                    columns +
                _gap * (columns - 1);
      final double column = math.max(0, (width - _gap * (columns - 1)) / columns);

      widths.fillRange(0, columns, column);

      for (int i = 0; i < count; i++) {
        final double height = children[i]
            .getDryLayout(BoxConstraints.tightFor(width: column))
            .height;

        heights[rowOf(i)] = math.max(heights[rowOf(i)], height);
      }
    }

    List<double> offsets(List<double> extents) {
      final List<double> result = <double>[];
      double position = 0;

      for (final double extent in extents) {
        result.add(position);
        position += extent + _gap;
      }

      return result;
    }

    double total(List<double> extents) {
      return extents.fold<double>(0, (double sum, double e) => sum + e) +
          _gap * (extents.length - 1);
    }

    final List<double> lefts = offsets(widths);
    final List<double> tops = offsets(heights);
    final List<Rect> cells = <Rect>[
      for (int i = 0; i < count; i++)
        Rect.fromLTWH(lefts[columnOf(i)], tops[rowOf(i)], widths[columnOf(i)], heights[rowOf(i)]),
    ];

    return _TrackLayout(Size(total(widths), total(heights)), cells, across ? lefts : tops);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.constrain(_lay(constraints).size);
  }

  @override
  void performLayout() {
    final _TrackLayout layout = _lay(constraints);
    final bool mirrored = _textDirection == TextDirection.rtl;

    size = constraints.constrain(layout.size);
    _starts = layout.starts;

    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      final Rect cell = layout.cells[index];
      final _TrackParentData data = child.parentData! as _TrackParentData;

      child.layout(BoxConstraints.tight(cell.size));
      // Under RTL the first column is the one at the right edge, as a grid's
      // columns run from the start.
      data.offset = Offset(mirrored ? layout.size.width - cell.right : cell.left, cell.top);

      child = data.nextSibling;
      index += 1;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth();

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth();

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  double _intrinsicWidth() => _lay(const BoxConstraints()).size.width;

  double _intrinsicHeight(double width) {
    final bool across = _axis == Axis.horizontal;

    // Across, the columns are as wide as their content whatever the room;
    // down, they share the width the track is given.
    return _lay(
      across || !width.isFinite ? const BoxConstraints() : BoxConstraints(maxWidth: width),
    ).size.height;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
