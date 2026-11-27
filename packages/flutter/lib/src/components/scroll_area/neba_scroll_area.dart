/// `NebaScrollArea`, a box with a scrollbar of its own.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/scroll_fade.dart';
import 'package:neba/src/internal/scroll_keys.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which axes a [NebaScrollArea] scrolls along.
enum NebaScrollAreaOrientation {
  /// Down the page, with the rail at the end edge.
  vertical,

  /// Across, with the rail along the bottom.
  horizontal,

  /// Both, with a rail on each.
  both,
}

/// A box with a scrollbar of its own, the same on every platform and made of
/// the library's tokens.
///
/// The rail appears while the pointer is over the area or while it scrolls,
/// and the thumb carries [color]'s family at a fraction of itself, so it does
/// not read as a second column beside the text. Underneath it is an ordinary
/// Flutter scroll view: the wheel, the trackpad, a drag and momentum are the
/// platform's own.
///
/// ```dart
/// NebaScrollArea(height: 200, fade: true, child: changelog)
/// ```
class NebaScrollArea extends StatefulWidget {
  /// A scroll area around [child].
  const NebaScrollArea({
    required this.child,
    this.orientation = NebaScrollAreaOrientation.vertical,
    this.height,
    this.maxHeight,
    this.size,
    this.color = NebaColor.primary,
    this.fade = false,
    this.label,
    this.locale,
    this.controller,
    this.horizontalController,
    super.key,
  });

  /// Which axes may scroll.
  final NebaScrollAreaOrientation orientation;

  /// A fixed height. A vertical scroll area has to be bounded by something or
  /// there is nothing to scroll; this is the shortest way to say what by.
  final double? height;

  /// The same, as a ceiling rather than a fixed height.
  final double? maxHeight;

  /// The rail's thickness, 4 to 10 logical pixels, and how far the [fade]
  /// reaches in. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the thumb carries.
  final NebaColor color;

  /// Fades the content out at each edge that has more beyond it, and only at
  /// those edges, so there is no fade at the top while the top is showing.
  final bool fade;

  /// What the scrolling content is: "Terms of service", "Activity". Without
  /// one, a screen reader hears "Scrollable content" in the [locale]'s words.
  final String? label;

  /// The language of the fallback name. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// The controller of the vertical scroll, or of the only one for a
  /// [NebaScrollAreaOrientation.horizontal] area.
  final ScrollController? controller;

  /// The controller of the horizontal scroll of a
  /// [NebaScrollAreaOrientation.both] area.
  final ScrollController? horizontalController;

  /// What scrolls.
  final Widget child;

  /// The rail's thickness at each size, a ladder of its own far below the
  /// control heights: a scrollbar is a rail, not a control.
  static const Map<NebaSize, double> rails = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 5,
    NebaSize.md: 6,
    NebaSize.lg: 8,
    NebaSize.xl: 10,
  };

  /// How far the [fade] reaches in from an edge with more beyond it.
  static const Map<NebaSize, double> fades = <NebaSize, double>{
    NebaSize.xs: 16,
    NebaSize.sm: 20,
    NebaSize.md: 24,
    NebaSize.lg: 32,
    NebaSize.xl: 40,
  };

  @override
  State<NebaScrollArea> createState() => _NebaScrollAreaState();
}

class _NebaScrollAreaState extends State<NebaScrollArea> {
  ScrollController? _ownMain;
  ScrollController? _ownCross;
  late final FocusNode _focus = FocusNode(debugLabel: 'NebaScrollArea', onKeyEvent: _onKey);

  bool _hovering = false;
  bool _focusVisible = false;

  // Which edges have more beyond them, per axis: what the fade and the focus
  // stop are decided by, read off the scroll views' own metrics.
  final Map<Axis, (bool, bool)> _overflow = <Axis, (bool, bool)>{};

  bool get _scrollsDown => widget.orientation != NebaScrollAreaOrientation.horizontal;

  bool get _scrollsAcross => widget.orientation != NebaScrollAreaOrientation.vertical;

  /// The controller of the vertical scroll, when there is one.
  ScrollController? get _vertical => _scrollsDown ? _main : null;

  /// The controller of the horizontal scroll, when there is one.
  ScrollController? get _horizontal => widget.orientation == NebaScrollAreaOrientation.horizontal
      ? _main
      : (_scrollsAcross ? _cross : null);

  ScrollController get _main => widget.controller ?? (_ownMain ??= ScrollController());

  ScrollController get _cross => widget.horizontalController ?? (_ownCross ??= ScrollController());

  bool get _overflows => _overflow.values.any(((bool, bool) edges) => edges.$1 || edges.$2);

  @override
  void dispose() {
    _ownMain?.dispose();
    _ownCross?.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetrics metrics) {
    final (bool, bool) edges = (metrics.extentBefore > 0, metrics.extentAfter > 0);

    if (_overflow[metrics.axis] != edges) {
      final bool focusable = _overflows;

      setState(() => _overflow[metrics.axis] = edges);

      if (focusable && !_overflows && _focus.hasFocus) {
        _focus.unfocus();
      }
    }

    return false;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    return nebaScrollKey(context, event, vertical: _vertical, horizontal: _horizontal);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(widget.color);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final double rail = NebaScrollArea.rails[size]!;
    final String label =
        widget.label ?? nebaMessages(context, 'scroll', locale: widget.locale)['label']!;
    final ScrollController? down = _vertical;
    final ScrollController? across = _horizontal;

    // The scroll views, the inner one vertical when both axes scroll, so both
    // rails stay on the viewport's edges rather than travelling with either.
    Widget content = widget.child;

    if (down != null) {
      content = SingleChildScrollView(controller: down, primary: false, child: content);
    }

    if (across != null) {
      content = SingleChildScrollView(
        controller: across,
        primary: false,
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    content = NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification notification) => _onMetrics(notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) => _onMetrics(notification.metrics),
        child: content,
      ),
    );

    if (widget.fade) {
      content = NebaEdgeFade(
        reach: NebaScrollArea.fades[size]!,
        vertical: _overflow[Axis.vertical] ?? (false, false),
        horizontal: _overflow[Axis.horizontal] ?? (false, false),
        child: content,
      );
    }

    if (across != null) {
      content = _NebaScrollbar(
        controller: across,
        // The horizontal view is the outer one when both scroll.
        notificationPredicate: (ScrollNotification n) => n.depth == 0,
        rail: rail,
        roles: roles,
        hovering: _hovering,
        child: content,
      );
    }

    if (down != null) {
      content = _NebaScrollbar(
        controller: down,
        notificationPredicate: (ScrollNotification n) => n.depth == (across == null ? 0 : 1),
        rail: rail,
        roles: roles,
        hovering: _hovering,
        child: content,
      );
    }

    final double? height = widget.height;
    final double? maxHeight = widget.maxHeight;

    if (height != null || maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height ?? 0,
          maxHeight: height ?? maxHeight ?? double.infinity,
        ),
        child: content,
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: MouseRegion(
        onEnter: (PointerEnterEvent event) => setState(() => _hovering = true),
        onExit: (PointerExitEvent event) => setState(() => _hovering = false),
        child: FocusableActionDetector(
          focusNode: _focus,
          // A tab stop only while there is something to scroll to, so the focus
          // never lands on a box the keys cannot move.
          enabled: _overflows,
          onShowFocusHighlight: (bool visible) => setState(() => _focusVisible = visible),
          // Inside the edge: the area clips what runs past it, and a ring
          // outside it would be cut off with the rest.
          child: NebaFocusRing(
            visible: _focusVisible,
            color: roles.ring,
            offset: -focusRingWidth,
            child: ClipRect(child: content),
          ),
        ),
      ),
    );
  }
}

/// The rail and its thumb, drawn in a colour family's tokens.
class _NebaScrollbar extends RawScrollbar {
  _NebaScrollbar({
    required ScrollController super.controller,
    required super.notificationPredicate,
    required this.rail,
    required this.roles,
    required this.hovering,
    required super.child,
  }) : super(
         // The thumb sits a pixel inside the rail, as the rail's own padding
         // holds it, and the rail two pixels off each end.
         thickness: rail - 2,
         crossAxisMargin: 1,
         mainAxisMargin: 3,
         radius: Radius.circular((rail - 2) / 2),
         trackRadius: Radius.circular(rail / 2),
         thumbVisibility: hovering,
         fadeDuration: NebaScale.duration,
       );

  final double rail;
  final NebaColorRoles roles;
  final bool hovering;

  @override
  RawScrollbarState<_NebaScrollbar> createState() => _NebaScrollbarState();
}

class _NebaScrollbarState extends RawScrollbarState<_NebaScrollbar> {
  bool _overRail = false;
  bool _overThumb = false;

  @override
  void updateScrollbarPainter() {
    super.updateScrollbarPainter();

    // The family at a fraction of itself: a saturated rail down the side of a
    // paragraph reads as a second column.
    final Color accent = widget.roles.accent;

    scrollbarPainter
      ..color = accent.withValues(alpha: accent.a * (_overThumb ? 0.55 : 0.35))
      ..trackColor = _overRail ? widget.roles.soft : const Color(0x00000000)
      ..trackBorderColor = const Color(0x00000000);
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);

    final bool overRail = isPointerOverScrollbar(event.position, event.kind, forHover: true);
    final bool overThumb = isPointerOverThumb(event.position, event.kind);

    if (overRail != _overRail || overThumb != _overThumb) {
      setState(() {
        _overRail = overRail;
        _overThumb = overThumb;
        updateScrollbarPainter();
      });
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);

    setState(() {
      _overRail = false;
      _overThumb = false;
      updateScrollbarPainter();
    });
  }
}
