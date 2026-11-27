/// `NebaCarousel`, slides shown one at a time in a frame.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Slides shown one at a time in a frame, moved by a swipe, by the arrows
/// drawn over the frame, by the dots under it or by the arrow keys.
///
/// It can turn on its own with [autoPlay], which a button beside the dots
/// stops, and which holds while the pointer is over it, while it holds the
/// focus, while the app is in the background and for a reader who asked for
/// less motion. A screen reader hears which slide is showing whenever the
/// reader moved it, and nothing while it turns on its own.
///
/// ```dart
/// NebaCarousel(children: <Widget>[slideOne, slideTwo, slideThree])
/// ```
class NebaCarousel extends StatefulWidget {
  /// A carousel of [children], one slide each.
  const NebaCarousel({
    required this.children,
    this.value,
    this.defaultValue = 0,
    this.onValueChange,
    this.loop = true,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 5),
    this.arrows = true,
    this.indicators = true,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.locale,
    this.semanticLabel,
    this.previousLabel,
    this.nextLabel,
    this.pauseLabel,
    this.playLabel,
    this.slideLabel,
    super.key,
  });

  /// The slides.
  final List<Widget> children;

  /// The slide showing, from 0, when the caller holds it.
  final int? value;

  /// The slide to start on, when the carousel holds its own.
  final int defaultValue;

  /// Called with the slide that comes to show.
  final ValueChanged<int>? onValueChange;

  /// Whether the step after the last slide is the first, and the step before
  /// the first is the last.
  final bool loop;

  /// Whether the slides turn on their own every [interval].
  final bool autoPlay;

  /// How long a slide shows before the next, with [autoPlay].
  final Duration interval;

  /// Whether a step back and a step on are drawn over the frame.
  final bool arrows;

  /// Whether a dot per slide is drawn under the frame.
  final bool indicators;

  /// The weight of the frame. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The frame's corners and the controls' size. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family of the frame, the arrows and the dots.
  final NebaColor color;

  /// The arrows' padding. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The frame's drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// The language of the words it says on its own behalf.
  final Locale? locale;

  /// The carousel's name for a screen reader, in place of "Carousel".
  final String? semanticLabel;

  /// The step back's name, in place of "Previous slide".
  final String? previousLabel;

  /// The step on's name, in place of "Next slide".
  final String? nextLabel;

  /// The stop button's name, in place of "Pause slide show".
  final String? pauseLabel;

  /// The start button's name, in place of "Play slide show".
  final String? playLabel;

  /// A slide's name, in place of "Slide 2 of 4", given its place from 1.
  final String Function(int index, int count)? slideLabel;

  /// How far in from the frame's edges the arrows sit, at each size.
  static const Map<NebaSize, double> arrowInset = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 12,
    NebaSize.xl: 16,
  };

  /// A dot's size at rest and as the current slide's, and the gap between
  /// dots, at each size.
  static const Map<NebaSize, ({double dot, double current, double gap})> dots =
      <NebaSize, ({double dot, double current, double gap})>{
        NebaSize.xs: (dot: 4, current: 12, gap: 4),
        NebaSize.sm: (dot: 4, current: 14, gap: 4),
        NebaSize.md: (dot: 6, current: 16, gap: 6),
        NebaSize.lg: (dot: 6, current: 20, gap: 8),
        NebaSize.xl: (dot: 8, current: 24, gap: 8),
      };

  @override
  State<NebaCarousel> createState() => _NebaCarouselState();
}

class _NebaCarouselState extends State<NebaCarousel> with WidgetsBindingObserver {
  late int _own = widget.defaultValue;
  final ScrollController _strip = ScrollController();
  double _width = 0;
  Timer? _timer;
  bool _hovered = false;
  bool _focused = false;
  bool _stopped = false;
  bool _turning = false;
  bool _resumed = true;
  final FocusNode _track = FocusNode(debugLabel: 'NebaCarousel track');

  int get _count => widget.children.length;

  int get _index => math.min(math.max(widget.value ?? _own, 0), math.max(_count - 1, 0));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  @override
  void didUpdateWidget(NebaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != null && widget.value != oldWidget.value) {
      _show(_index);
    }

    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _strip.dispose();
    _track.dispose();
    super.dispose();
  }

  bool get _reduced => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Whether the slides turn on their own at all.
  bool get _rotates => widget.autoPlay && !_reduced && _count > 1;

  /// Whether they are turning right now.
  bool get _running => _rotates && !_stopped && !_hovered && !_focused && _resumed;

  void _schedule() {
    _timer?.cancel();
    _timer = null;

    if (_running) {
      _timer = Timer.periodic(widget.interval, (Timer _) => _go(_index + 1));
    }
  }

  /// Scrolls the strip to [index].
  Future<void> _show(int index) async {
    if (!_strip.hasClients || _width == 0) {
      return;
    }

    final double to = index * _width;

    if ((_strip.offset - to).abs() < 0.5) {
      return;
    }

    if (_reduced) {
      _strip.jumpTo(to);
      return;
    }

    _turning = true;

    try {
      await _strip.animateTo(
        to,
        duration: const Duration(milliseconds: 400),
        curve: NebaScale.ease,
      );
    } finally {
      _turning = false;
    }
  }

  /// The slide a swipe settled on, once it has.
  bool _onScrollEnd(ScrollEndNotification notification) {
    if (!_turning && _width > 0 && _strip.hasClients) {
      final int settled = (_strip.offset / _width).round();

      if (settled != _index && settled >= 0 && settled < _count) {
        _go(settled, fromSwipe: true);
      }
    }

    return false;
  }

  void _go(int next, {bool fromSwipe = false}) {
    final int count = _count;

    if (count == 0) {
      return;
    }

    final int wrapped = widget.loop
        ? ((next % count) + count) % count
        : math.min(math.max(next, 0), count - 1);
    final int was = _index;

    if (widget.value == null) {
      setState(() => _own = wrapped);
    }

    if (wrapped != was) {
      widget.onValueChange?.call(wrapped);
    }

    if (!fromSwipe) {
      _show(wrapped);
    }

    _schedule();
  }

  String _slideName(Map<String, String> messages, int index) {
    return widget.slideLabel?.call(index, _count) ??
        fillNebaMessage(messages['slide']!, <String, String>{
          'index': '$index',
          'total': '$_count',
        });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)) {
      _go(_index + 1);
      return KeyEventResult.handled;
    }

    if (key == (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)) {
      _go(_index - 1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final Map<String, String> messages = nebaMessages(context, 'carousel', locale: widget.locale);
    final int count = _count;
    final int index = _index;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final bool showDots = widget.indicators && count > 1;
    final bool rotates = _rotates;

    // A row of slides each as wide as the frame, scrolled a page at a time,
    // as tall as the tallest of them, as a row of blocks in a snapping strip
    // is.
    Widget track = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;

        if (width != _width) {
          _width = width;
          // Keep the slide showing in place when the frame changes width.
          WidgetsBinding.instance.addPostFrameCallback((Duration _) {
            if (mounted && _strip.hasClients) {
              _strip.jumpTo(_index * _width);
            }
          });
        }

        return NotificationListener<ScrollEndNotification>(
          onNotification: _onScrollEnd,
          child: SingleChildScrollView(
            controller: _strip,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < count; i++)
                    SizedBox(
                      width: width,
                      child: Semantics(
                        container: true,
                        label: _slideName(messages, i + 1),
                        child: widget.children[i],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    track = Focus(
      focusNode: _track,
      onKeyEvent: _onKey,
      child: ListenableBuilder(
        listenable: _track,
        builder: (BuildContext context, Widget? child) {
          // The strip takes the focus to be scrolled from the keyboard, and
          // its ring is drawn inside the frame, which clips.
          return NebaFocusRing(
            visible: _track.hasFocus,
            color: roles.ring,
            borderRadius: radius,
            offset: -focusRingWidth,
            child: child!,
          );
        },
        child: track,
      ),
    );

    final (Color fill, Color? edge, NebaPlate plate, bool textured) = switch (variant) {
      NebaVariant.solid => (tokens.panelHover, null, NebaPlate.solid, true),
      NebaVariant.outline => (tokens.panel, roles.line, NebaPlate.glass, true),
      NebaVariant.text => (const Color(0x00000000), null, NebaPlate.none, false),
    };

    Widget arrow({required bool forward}) {
      final bool inert = !widget.loop && (forward ? index >= count - 1 : index <= 0);
      final int turns = forward ? (rtl ? 1 : 3) : (rtl ? 3 : 1);

      return NebaIconButton(
        variant: NebaVariant.solid,
        size: size,
        color: widget.color,
        density: density,
        elevation: 1,
        label: forward
            ? widget.nextLabel ?? messages['next']!
            : widget.previousLabel ?? messages['previous']!,
        disabled: inert,
        focusableWhenDisabled: true,
        icon: RotatedBox(quarterTurns: turns, child: NebaGlyph(NebaGlyphs.chevron)),
        onPressed: () => _go(index + (forward ? 1 : -1)),
      );
    }

    final Widget frame = NebaSheet(
      fill: fill,
      edge: edge,
      plate: plate,
      elevation: widget.elevation,
      borderRadius: radius,
      blur: textured,
      texture: textured,
      child: Stack(
        children: <Widget>[
          track,
          if (widget.arrows && count > 1)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: NebaCarousel.arrowInset[size]!),
                child: Row(
                  children: <Widget>[
                    arrow(forward: false),
                    // The space between the arrows is the strip's: a swipe
                    // there still reaches it.
                    const Spacer(),
                    arrow(forward: true),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final ({double dot, double current, double gap}) dot = NebaCarousel.dots[size]!;
    final Duration duration = nebaDuration(context, NebaScale.duration);

    Widget dotButton(int i) {
      final bool current = i == index;

      return Semantics(
        selected: current,
        child: NebaInteractive(
          onTap: () => _go(i),
          builder: (BuildContext context, NebaInteraction interaction, _) {
            final Widget drawn = AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              width: current ? dot.current : dot.dot,
              height: dot.dot,
              decoration: BoxDecoration(
                color: current || interaction.hovered ? roles.accent : roles.lineHover,
                borderRadius: BorderRadius.circular(dot.dot),
              ),
            );

            return Semantics(
              button: true,
              label: _slideName(messages, i + 1),
              child: Padding(
                // The gap is the dot's press target, so there is nowhere
                // between two dots a press is lost.
                padding: EdgeInsets.symmetric(horizontal: dot.gap / 2, vertical: 6),
                child: NebaFocusRing(
                  visible: interaction.focusVisible,
                  color: roles.ring,
                  borderRadius: BorderRadius.circular(dot.dot),
                  child: drawn,
                ),
              ),
            );
          },
        ),
      );
    }

    final List<Widget> column = <Widget>[frame];

    if (rotates || showDots) {
      column.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: rotates
                      ? NebaIconButton(
                          variant: NebaVariant.text,
                          size: size,
                          color: widget.color,
                          density: density,
                          label: _stopped
                              ? widget.playLabel ?? messages['play']!
                              : widget.pauseLabel ?? messages['pause']!,
                          icon: NebaGlyph(_stopped ? NebaGlyphs.play : NebaGlyphs.pause),
                          onPressed: () {
                            setState(() => _stopped = !_stopped);
                            _schedule();
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (showDots)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[for (int i = 0; i < count; i++) dotButton(i)],
                ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? messages['label'],
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) {
          setState(() => _hovered = true);
          _schedule();
        },
        onExit: (PointerExitEvent event) {
          setState(() => _hovered = false);
          _schedule();
        },
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onFocusChange: (bool focused) {
            setState(() => _focused = focused);
            _schedule();
          },
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: column,
              ),
              // Where the reader is, as a sentence, and quiet only while the
              // strip turns on its own: a slide's name every few seconds
              // would talk over everything else.
              if (count > 0)
                _running
                    ? Semantics(
                        label: _slideName(messages, index + 1),
                        child: const SizedBox.shrink(),
                      )
                    : NebaLiveRegion(
                        role: SemanticsRole.status,
                        child: Semantics(
                          label: _slideName(messages, index + 1),
                          child: const SizedBox.shrink(),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
