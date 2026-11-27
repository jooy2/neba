/// `NebaSidebar`, a column beside a page's content that becomes a drawer
/// once the window is too narrow for it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/drawer/neba_drawer.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/page_layout.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/page_layout.dart' show NebaSidebarSide;

/// A column beside a page's content, and a drawer once the window is too
/// narrow to hold one.
///
/// Two presentations of one panel, as `NebaDrawer` is: at and above
/// [collapseBelow] it is a column the content is laid out around, and below it
/// the same [child] is an overlay `NebaDrawer` attached to its edge, with a
/// scrim, the focus held inside and a way back, which a `NebaSidebarTrigger`
/// opens. The child is built once either way.
///
/// The column is the complementary region a screen reader offers as related to
/// the page but not the page, named by [label]. It scrolls its own content,
/// and with [resizable] its inner edge is dragged, or moved with the arrow
/// keys, between [minWidth] and [maxWidth].
///
/// Inside a `NebaPageLayout`, in its `sidebar` or `endSidebar` slot, the slot
/// decides the [side], the layout decides when it collapses and owns whether
/// its drawer is open, and the column holds its place while the page scrolls
/// past it.
///
/// ```dart
/// NebaSidebar(label: 'Sections', child: navigation)
/// ```
class NebaSidebar extends StatefulWidget {
  /// A sidebar holding [child].
  const NebaSidebar({
    this.child,
    this.side,
    this.width,
    this.minWidth = 160,
    this.maxWidth = 480,
    this.resizable = false,
    this.onResize,
    this.onResizeEnd,
    this.collapseBelow,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.keepMounted = false,
    this.sticky,
    this.title,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.divider = true,
    this.padded = true,
    this.label,
    this.locale,
    this.safeArea = true,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       assert(minWidth <= maxWidth);

  /// Everything in it: a navigation, a filter panel, a table of contents.
  final Widget? child;

  /// Which end of the band it takes, which flips under a right-to-left
  /// direction. Inside a `NebaPageLayout` the slot decides it. Defaults to
  /// [NebaSidebarSide.start].
  final NebaSidebarSide? side;

  /// How wide the column is, in logical pixels. Left out, it is the width its
  /// [size] implies. With [resizable] it is only the width the column starts
  /// at.
  final double? width;

  /// How narrow the column may be dragged, in logical pixels.
  final double minWidth;

  /// And how wide.
  final double maxWidth;

  /// Lets the reader drag the inner edge, or move it with the arrow keys, to
  /// change the column's width.
  final bool resizable;

  /// Called with the width while the edge is being dragged.
  final ValueChanged<double>? onResize;

  /// Called once with the width when the edge is let go, and on every arrow
  /// key, which is a whole gesture of its own.
  final ValueChanged<double>? onResizeEnd;

  /// The window width below which the column becomes a drawer.
  /// [NebaBreakpoint.xs] keeps it a column at every width, as nothing is below
  /// it. Defaults to the `NebaPageLayout`'s, and to [NebaBreakpoint.xs] outside
  /// one, where nothing on the page could open the drawer.
  final NebaBreakpoint? collapseBelow;

  /// Whether the drawer is open, for a controlled sidebar. Only meaningful
  /// while it is collapsed. Inside a `NebaPageLayout` the layout owns it, so
  /// control it there.
  final bool? open;

  /// Whether an uncontrolled sidebar outside a layout starts open.
  final bool defaultOpen;

  /// Called when the drawer opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// Keeps the drawer's contents built while it is closed, once the sidebar
  /// has collapsed into one, so they keep their state.
  final bool keepMounted;

  /// Whether the column holds its place while a `NebaPageLayout`'s page
  /// scrolls past it, as tall as what is left of the window under the
  /// header. On inside a layout; a column outside one is a box like any other.
  final bool? sticky;

  /// The heading, drawn only while the sidebar is a drawer: a column has the
  /// page around it to say what it is, and a panel that covers the page does
  /// not.
  final Widget? title;

  /// The sheet's weight: `solid` is the brighter panel, `outline` the lighter
  /// one, `text` no sheet at all. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The column's default width and the space around its content. Defaults
  /// to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline, the drag handle and the focus ring. The
  /// sheet itself stays undyed.
  final NebaColor color;

  /// How much space there is around the content at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation elevation;

  /// Draws a hairline down the inner edge, the one facing the content.
  final bool divider;

  /// Whether the content has its gutter and the space above and below.
  final bool padded;

  /// The name a screen reader announces for the region. A page with two
  /// sidebars names both. Defaults to the [locale]'s "Sidebar".
  final String? label;

  /// The language of the sidebar's own words. Defaults to the layout's, then
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Keeps the content clear of the system's insets on the edges the column
  /// or the drawer touches, which a `NebaPageLayout` hands it: the side it is
  /// against, and the top and the bottom where no bar is.
  final bool safeArea;

  /// The default width at each size: 16rem at `md`, wide enough for two
  /// words and an icon.
  static const Map<NebaSize, double> widths = <NebaSize, double>{
    NebaSize.xs: 176,
    NebaSize.sm: 208,
    NebaSize.md: 256,
    NebaSize.lg: 288,
    NebaSize.xl: 336,
  };

  /// How far one arrow key moves the edge, the same step `NebaPanes` uses.
  static const double keyboardStep = 16;

  /// How wide the drag handle is, straddling nothing: it lies inside the
  /// inner edge, where the hairline is.
  static const double handleWidth = 8;

  @override
  State<NebaSidebar> createState() => _NebaSidebarState();
}

class _NebaSidebarState extends State<NebaSidebar> {
  late bool _ownOpen = widget.defaultOpen;

  /// The width a drag or a key set, over the one the sidebar was given.
  final ValueNotifier<double?> _dragged = ValueNotifier<double?>(null);

  bool? _wasCollapsed;

  @override
  void didUpdateWidget(NebaSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new width from the owner is the width again.
    if (widget.width != oldWidget.width) {
      _dragged.value = null;
    }
  }

  @override
  void dispose() {
    _dragged.dispose();
    super.dispose();
  }

  NebaSidebarSide _side(NebaPageRegion? region) {
    return widget.side ?? region?.side ?? NebaSidebarSide.start;
  }

  void _changeOpen(NebaPageLayoutScope? layout, NebaSidebarSide side, bool next) {
    if (widget.open == null) {
      if (layout != null) {
        layout.onOpenChange(side, next);
      } else {
        setState(() => _ownOpen = next);
      }
    }

    widget.onOpenChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final NebaPageLayoutScope? layout = NebaPageLayoutScope.maybeOf(context);
    final NebaPageRegion? region = NebaPageRegion.maybeOf(context);
    final NebaSidebarSide side = _side(region);
    final Locale? locale = widget.locale ?? layout?.locale;
    final Map<String, String> words = nebaMessages(context, 'layout', locale: locale);
    final NebaBreakpoint collapseBelow =
        widget.collapseBelow ?? layout?.collapseBelow ?? NebaBreakpoint.xs;
    final bool collapsed = nebaCollapsed(context, collapseBelow);
    final bool open = widget.open ?? (layout != null ? layout.openOf(side) : _ownOpen);

    // An open drawer's `true` means nothing once the column is back, and kept
    // it would open a modal drawer on its own the next time the window
    // narrowed: a tablet turned and turned back would have its focus held by a
    // drawer nobody asked for. So the drawer is closed as the column returns.
    if (_wasCollapsed == true && !collapsed && open) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          _changeOpen(context.getInheritedWidgetOfExactType<NebaPageLayoutScope>(), side, false);
        }
      });
    }

    _wasCollapsed = collapsed;

    if (collapsed) {
      return NebaDrawer(
        side: nebaDrawerSide(side, Directionality.of(context)),
        open: open,
        onOpenChange: (bool next) => _changeOpen(layout, side, next),
        keepMounted: widget.keepMounted,
        title: widget.title,
        size: widget.size,
        color: widget.color,
        density: widget.density,
        locale: locale,
        closeLabel: words['closeSidebar'],
        // A width the caller chose survives the change of shape; the default
        // one does not, because a column sized against the content beside it
        // and a panel sized against a phone are two different numbers.
        extent: widget.width,
        semanticLabel: widget.title == null ? widget.label ?? words['sidebar'] : null,
        safeArea: widget.safeArea,
        child: widget.child,
      );
    }

    return _column(context, side: side, words: words, region: region);
  }

  Widget _column(
    BuildContext context, {
    required NebaSidebarSide side,
    required Map<String, String> words,
    required NebaPageRegion? region,
  }) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final double inset = widget.padded ? NebaBox.padding[density]![size]! : 0;
    final EdgeInsets screen = widget.safeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;
    final double given = widget.width ?? NebaSidebar.widths[size]!;
    final BorderSide line = BorderSide(color: roles.line);

    final Widget body = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(inset) + screen,
        // What is inside is inside a landmark, so a footer in it is not the
        // page's and a sidebar in it is not a second complementary region.
        child: NebaPageRegion(landmarked: true, child: widget.child ?? const SizedBox.shrink()),
      ),
    );

    Widget column = Container(
      // A Container, because it adds the line's width to the column as a CSS
      // border does.
      decoration: BoxDecoration(
        border: widget.divider
            ? (side == NebaSidebarSide.start
                  ? BorderDirectional(end: line)
                  : BorderDirectional(start: line))
            : null,
      ),
      child: body,
    );

    if (widget.resizable) {
      // The column decides the height, so a sidebar laid out at its content's
      // height has a handle as tall as it, and one given a height fills it.
      column = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          column,
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: side == NebaSidebarSide.end ? 0 : null,
            end: side == NebaSidebarSide.start ? 0 : null,
            width: NebaSidebar.handleWidth,
            child: _Handle(
              side: side,
              roles: roles,
              label: words['resizeSidebar']!,
              dragged: _dragged,
              given: given,
              onResize: (double width) => _resize(width, settled: false),
              onResizeEnd: (double width) => _resize(width, settled: true),
            ),
          ),
        ],
      );
    }

    column = ValueListenableBuilder<double?>(
      valueListenable: _dragged,
      builder: (BuildContext context, double? dragged, Widget? column) {
        return SizedBox(width: dragged ?? given, child: column);
      },
      child: nebaBarSheet(
        tokens: tokens,
        variant: variant,
        elevation: widget.elevation,
        child: column,
      ),
    );

    final bool landmark = !(region?.landmarked ?? false);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: landmark ? SemanticsRole.complementary : null,
      label: widget.label ?? words['sidebar'],
      child: column,
    );
  }

  /// Sets the width to [width] held between the bounds, and says so.
  void _resize(double width, {required bool settled}) {
    final double held = width.clamp(widget.minWidth, widget.maxWidth).roundToDouble();

    _dragged.value = held;

    if (settled) {
      widget.onResizeEnd?.call(held);
    } else {
      widget.onResize?.call(held);
    }
  }
}

/// The inner edge, dragged by a pointer and moved by the arrow keys.
class _Handle extends StatefulWidget {
  const _Handle({
    required this.side,
    required this.roles,
    required this.label,
    required this.dragged,
    required this.given,
    required this.onResize,
    required this.onResizeEnd,
  });

  final NebaSidebarSide side;
  final NebaColorRoles roles;
  final String label;

  /// The width a drag or a key set, if one has.
  final ValueListenable<double?> dragged;

  /// The width the column was given.
  final double given;
  final ValueChanged<double> onResize;
  final ValueChanged<double> onResizeEnd;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  late final FocusNode _focus = FocusNode(debugLabel: 'NebaSidebar handle', onKeyEvent: _onKey);

  bool _hovered = false;
  bool _focusVisible = false;
  double _start = 0;
  double _latest = 0;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// Which way along the axis is wider: away from the side the column is on,
  /// whichever way the reading direction numbers it.
  double get _outwards {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return (widget.side == NebaSidebarSide.start) == rtl ? -1 : 1;
  }

  /// The column's width now.
  double get _width => widget.dragged.value ?? widget.given;

  void _nudge(double step) {
    final double next = _width + step;

    // A key is a whole gesture: there is no letting go to wait for.
    widget.onResize(next);
    widget.onResizeEnd(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _nudge(NebaSidebar.keyboardStep * _outwards);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _nudge(-NebaSidebar.keyboardStep * _outwards);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  Widget _drawn(BuildContext context, bool dragging) {
    // Press is instant and release is slow: the wash lands on the frame of
    // the press and drains back over the fill's duration.
    final Duration duration = nebaDuration(context, NebaScale.durationFill, instant: dragging);
    final Color wash = _hovered || dragging
        ? widget.roles.soft
        : widget.roles.soft.withValues(alpha: 0);

    // Inside the edge, because the handle runs the column's full height and a
    // layout that fills the window clips at its top and its bottom.
    return NebaFocusRing(
      visible: _focusVisible,
      color: widget.roles.ring,
      offset: -focusRingWidth,
      child: AnimatedContainer(duration: duration, curve: NebaScale.ease, color: wash),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget handle = FocusableActionDetector(
      focusNode: _focus,
      onShowFocusHighlight: (bool visible) => setState(() => _focusVisible = visible),
      child: MouseRegion(
        onEnter: (PointerEnterEvent e) => setState(() => _hovered = true),
        onExit: (PointerExitEvent e) => setState(() => _hovered = false),
        child: NebaDragRegion(
          cursor: SystemMouseCursors.resizeColumn,
          // A press leaves the focus where it was, as on a NebaPanes bar.
          onStart: (Offset position) {
            _start = _width;
            _latest = _start;
            return true;
          },
          onMove: (Offset travelled) {
            _latest = _start + travelled.dx * _outwards;
            widget.onResize(_latest);
          },
          onEnd: () => widget.onResizeEnd(_latest),
          builder: _drawn,
        ),
      ),
    );

    // What the handle says about the width, which a focusable separator has
    // to: where it is now, and where a step either way takes it.
    return ValueListenableBuilder<double?>(
      valueListenable: widget.dragged,
      builder: (BuildContext context, double? dragged, Widget? handle) {
        final double now = dragged ?? widget.given;

        return Semantics(
          container: true,
          slider: true,
          label: widget.label,
          value: '${now.round()}',
          increasedValue: '${(now + NebaSidebar.keyboardStep).round()}',
          decreasedValue: '${(now - NebaSidebar.keyboardStep).round()}',
          onIncrease: () => _nudge(NebaSidebar.keyboardStep),
          onDecrease: () => _nudge(-NebaSidebar.keyboardStep),
          child: handle,
        );
      },
      child: handle,
    );
  }
}
