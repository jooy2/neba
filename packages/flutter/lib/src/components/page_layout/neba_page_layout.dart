/// `NebaPageLayout`, the skeleton a page is hung on.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/footer/neba_footer.dart';
import 'package:neba/src/components/header/neba_header.dart';
import 'package:neba/src/components/sidebar/neba_sidebar.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/page_layout.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/page_layout.dart' show NebaPageLayoutScroll, NebaPageLayoutSpan;

/// How tall a [NebaPageLayout] is: the React package's `height`.
@immutable
class NebaPageLayoutHeight {
  const NebaPageLayoutHeight._(this.pixels);

  /// A height of its own, in logical pixels.
  const NebaPageLayoutHeight.pixels(double this.pixels) : assert(pixels >= 0);

  /// The window's, which is what a page wants: a short page still has its
  /// footer at the bottom of the screen.
  static const NebaPageLayoutHeight viewport = NebaPageLayoutHeight._(null);

  /// Its parent's, for a layout that is not the whole page: an app shell in a
  /// preview or a pane of a larger tool. The parent has to bound it.
  static const NebaPageLayoutHeight auto = NebaPageLayoutHeight._(-1);

  /// The height, for one of [NebaPageLayoutHeight.pixels].
  final double? pixels;

  @override
  bool operator ==(Object other) => other is NebaPageLayoutHeight && other.pixels == pixels;

  @override
  int get hashCode => pixels.hashCode;
}

/// The skeleton a page is hung on: a [header], a [footer], a [sidebar] or two,
/// and the content between them.
///
/// What it is really for is the regions. A screen built out of boxes is one a
/// screen reader offers as one undifferentiated whole; the same screen built
/// out of a page's header, its sidebars, its main content and its footer is
/// one with a table of contents. Those come from the widgets this one
/// arranges, a `NebaHeader`, `NebaSidebar`s and a `NebaFooter`; it draws no
/// surface of its own, and adds the main region around [child] and a skip link
/// that jumps to it.
///
/// [scroll] decides what scrolls. With [NebaPageLayoutScroll.page] the whole
/// page does: a sticky header holds its place at the top with the content
/// passing under it, the sidebars hold theirs beside the content, and the
/// footer is at the end. With [NebaPageLayoutScroll.content] only the region
/// between the bars does. Below [collapseBelow] the sidebars stop being
/// columns and become drawers that a `NebaSidebarTrigger` opens.
///
/// On a phone each region is handed the system insets of the edges it
/// touches and none of the others: the header the top and the sides, the
/// footer the bottom and the sides, a sidebar its own side, and the content
/// whatever no bar or column has taken, in its `MediaQuery` for what is inside
/// it to keep clear of.
///
/// It draws no gutter and no measure: put a `NebaContainer` inside.
///
/// ```dart
/// NebaPageLayout(
///   header: const NebaHeader(brand: <Widget>[NebaSidebarTrigger(), Text('Neba')]),
///   sidebar: const NebaSidebar(child: navigation),
///   footer: const NebaFooter(child: Text('© 2026 Neba')),
///   child: page,
/// )
/// ```
class NebaPageLayout extends StatefulWidget {
  /// A layout around [child].
  const NebaPageLayout({
    this.child,
    this.header,
    this.footer,
    this.sidebar,
    this.endSidebar,
    this.headerSpan = NebaPageLayoutSpan.full,
    this.footerSpan = NebaPageLayoutSpan.full,
    this.scroll = NebaPageLayoutScroll.page,
    this.height = NebaPageLayoutHeight.viewport,
    this.collapseBelow = NebaBreakpoint.md,
    this.sidebarOpen,
    this.defaultSidebarOpen = false,
    this.onSidebarOpenChange,
    this.endSidebarOpen,
    this.defaultEndSidebarOpen = false,
    this.onEndSidebarOpenChange,
    this.skipLink = true,
    this.skipLabel,
    this.main,
    this.locale,
    this.color = NebaColor.primary,
    this.controller,
    super.key,
  });

  /// The page: the main region.
  final Widget? child;

  /// The bar across the top, usually a `NebaHeader`. The layout reads its
  /// `position` to decide whether it holds the bar at the top; anything else
  /// is held there as a sticky header is.
  final Widget? header;

  /// The sheet at the end, usually a `NebaFooter`. The layout reads its
  /// `position` to decide whether it holds it at the bottom; anything else
  /// scrolls with the page as a static footer does.
  final Widget? footer;

  /// The leading column, usually a `NebaSidebar`, which needs no `side` of its
  /// own here.
  final Widget? sidebar;

  /// The trailing column, for the layouts that have two: navigation down one
  /// side and a table of contents, an inspector or filters down the other.
  final Widget? endSidebar;

  /// Which of the header and the sidebars takes the top corner:
  /// [NebaPageLayoutSpan.full] spans the header across the whole width with
  /// the sidebars beginning under it; [NebaPageLayoutSpan.content] runs the
  /// sidebars the full height and puts the header between them.
  final NebaPageLayoutSpan headerSpan;

  /// The same question for the footer.
  final NebaPageLayoutSpan footerSpan;

  /// What scrolls: the whole page, or only the region between the bars.
  final NebaPageLayoutScroll scroll;

  /// How tall the layout is.
  final NebaPageLayoutHeight height;

  /// The window width below which the sidebars become drawers.
  /// [NebaBreakpoint.xs] keeps them columns at every width, as nothing is
  /// below it: the React package's `'none'`.
  final NebaBreakpoint collapseBelow;

  /// Whether the leading sidebar's drawer is open, for a controlled layout.
  final bool? sidebarOpen;

  /// Whether it starts open.
  final bool defaultSidebarOpen;

  /// Called when it opens or closes.
  final ValueChanged<bool>? onSidebarOpenChange;

  /// Whether the trailing sidebar's drawer is open, for a controlled layout.
  final bool? endSidebarOpen;

  /// Whether it starts open.
  final bool defaultEndSidebarOpen;

  /// Called when it opens or closes.
  final ValueChanged<bool>? onEndSidebarOpenChange;

  /// Puts a "Skip to content" link first in the focus order, drawn only while
  /// it holds the focus, which moves the focus to the main region: the one
  /// thing that spares a keyboard reader the whole navigation on every page.
  final bool skipLink;

  /// What that link says. Defaults to the [locale]'s words for it.
  final String? skipLabel;

  /// Whether the content is the main region with the skip link in front of
  /// it. A screen has one main region, so a layout inside another's content
  /// is not one unless it says so, and a layout that is not the page, such as
  /// a preview, turns it off.
  final bool? main;

  /// The language of the layout's own words, and of every `NebaSidebar` and
  /// `NebaSidebarTrigger` inside it. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// The colour family the skip link and the main region's focus ring are in.
  final NebaColor color;

  /// The controller of what scrolls: the page, or the content.
  final ScrollController? controller;

  /// How far the skip link stands in from the top and the start.
  static const double skipInset = 12;

  @override
  State<NebaPageLayout> createState() => _NebaPageLayoutState();
}

class _NebaPageLayoutState extends State<NebaPageLayout> {
  late bool _ownStart = widget.defaultSidebarOpen;
  late bool _ownEnd = widget.defaultEndSidebarOpen;

  /// The main region, which the skip link sends the focus to and a Tab never
  /// stops at on its own.
  final FocusNode _main = FocusNode(debugLabel: 'NebaPageLayout main', skipTraversal: true);

  bool _mainFocused = false;

  @override
  void initState() {
    super.initState();
    _main.addListener(_onMainFocus);
  }

  @override
  void dispose() {
    _main
      ..removeListener(_onMainFocus)
      ..dispose();
    super.dispose();
  }

  /// The ring is the main region's own focus, not a focus inside it.
  void _onMainFocus() {
    if (_main.hasPrimaryFocus != _mainFocused) {
      setState(() => _mainFocused = _main.hasPrimaryFocus);
    }
  }

  void _setOpen(NebaSidebarSide side, bool open) {
    if (side == NebaSidebarSide.start) {
      if (widget.sidebarOpen == null) {
        setState(() => _ownStart = open);
      }

      widget.onSidebarOpenChange?.call(open);
      return;
    }

    if (widget.endSidebarOpen == null) {
      setState(() => _ownEnd = open);
    }

    widget.onEndSidebarOpenChange?.call(open);
  }

  /// Whether [slot] is a column at the window's width: a sidebar below its
  /// breakpoint is a drawer and takes no room.
  bool _isColumn(Widget? slot) {
    if (slot == null) {
      return false;
    }

    final NebaBreakpoint breakpoint = slot is NebaSidebar
        ? slot.collapseBelow ?? widget.collapseBelow
        : widget.collapseBelow;

    return slot is! NebaSidebar || !nebaCollapsed(context, breakpoint);
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaPageRegion? around = NebaPageRegion.maybeOf(context);
    final Locale? locale = widget.locale ?? NebaTheme.defaultsOf(context).locale;
    final TextDirection direction = Directionality.of(context);
    final bool ltr = direction == TextDirection.ltr;

    // A screen has one main region: a layout inside another's content is not
    // one unless it says so.
    final bool landmark = widget.main ?? !(around?.landmarked ?? false);

    final Widget? header = widget.header;
    final Widget? footer = widget.footer;
    final bool fullHeader = header != null && widget.headerSpan == NebaPageLayoutSpan.full;
    final bool fullFooter = footer != null && widget.footerSpan == NebaPageLayoutSpan.full;
    final bool contentHeader = header != null && !fullHeader;
    final bool contentFooter = footer != null && !fullFooter;
    final bool headerPinned = header is! NebaHeader || header.position != NebaPosition.static;
    final bool footerPinned = footer is NebaFooter && footer.position != NebaPosition.static;

    final bool startColumn = _isColumn(widget.sidebar);
    final bool endColumn = _isColumn(widget.endSidebar);
    final bool leftColumn = ltr ? startColumn : endColumn;
    final bool rightColumn = ltr ? endColumn : startColumn;

    // Each region keeps the system insets of the edges it touches.
    Widget region(
      Widget child, {
      NebaPageBar? bar,
      NebaSidebarSide? side,
      bool landmarked = false,
      bool top = false,
      bool bottom = false,
      bool left = false,
      bool right = false,
    }) {
      return FocusTraversalGroup(
        child: NebaPageRegion(
          bar: bar,
          side: side,
          landmarked: landmarked,
          child: nebaKeepInsets(
            context: context,
            top: top,
            bottom: bottom,
            left: left,
            right: right,
            child: child,
          ),
        ),
      );
    }

    final Widget? headerSlot = header == null
        ? null
        : region(
            header,
            bar: NebaPageBar.header,
            top: true,
            left: fullHeader || !leftColumn,
            right: fullHeader || !rightColumn,
          );
    final Widget? footerSlot = footer == null
        ? null
        : region(
            footer,
            bar: NebaPageBar.footer,
            bottom: true,
            left: fullFooter || !leftColumn,
            right: fullFooter || !rightColumn,
          );

    Widget? sideSlot(Widget? sidebar, NebaSidebarSide side) {
      if (sidebar == null) {
        return null;
      }

      final bool onLeft = (side == NebaSidebarSide.start) == ltr;

      return region(
        sidebar,
        side: side,
        top: !fullHeader,
        bottom: !fullFooter,
        left: onLeft,
        right: !onLeft,
      );
    }

    final Widget? startSlot = sideSlot(widget.sidebar, NebaSidebarSide.start);
    final Widget? endSlot = sideSlot(widget.endSidebar, NebaSidebarSide.end);

    Widget content = Focus(
      focusNode: _main,
      // Inside the edge, since the ring would otherwise sit outside the
      // page's own; a press does not light it.
      child: NebaFocusRing(
        visible: _mainFocused,
        color: tokens.roles(widget.color).ring,
        offset: -focusRingWidth,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );

    if (landmark) {
      content = Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.main,
        child: content,
      );
    }

    final Widget mainSlot = region(
      content,
      landmarked: true,
      top: header == null,
      bottom: footer == null,
      left: !leftColumn,
      right: !rightColumn,
    );

    final Widget page = widget.scroll == NebaPageLayoutScroll.content
        ? _content(
            header: headerSlot,
            footer: footerSlot,
            fullHeader: fullHeader,
            fullFooter: fullFooter,
            start: startSlot,
            end: endSlot,
            main: mainSlot,
          )
        : _page(
            header: headerSlot,
            footer: footerSlot,
            fullHeader: fullHeader,
            fullFooter: fullFooter,
            contentHeader: contentHeader,
            contentFooter: contentFooter,
            headerPinned: headerPinned,
            footerPinned: footerPinned,
            start: startSlot,
            end: endSlot,
            main: mainSlot,
            direction: direction,
          );

    Widget layout = page;

    if (landmark && widget.skipLink) {
      // First in the focus order, whatever the geometry of the page says.
      layout = FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Stack(
          children: <Widget>[
            FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: FocusTraversalGroup(child: page),
            ),
            PositionedDirectional(
              top: NebaPageLayout.skipInset,
              start: NebaPageLayout.skipInset,
              child: FocusTraversalOrder(
                order: const NumericFocusOrder(0),
                child: _SkipLink(
                  label:
                      widget.skipLabel ??
                      nebaMessages(context, 'layout', locale: locale)['skipToContent']!,
                  color: widget.color,
                  onPressed: _main.requestFocus,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double? pixels = widget.height.pixels;

    if (widget.height == NebaPageLayoutHeight.viewport) {
      layout = SizedBox(height: MediaQuery.sizeOf(context).height, child: layout);
    } else if (pixels != null && pixels >= 0) {
      layout = SizedBox(height: pixels, child: layout);
    }

    return NebaPageLayoutScope(
      collapseBelow: widget.collapseBelow,
      startOpen: widget.sidebarOpen ?? _ownStart,
      endOpen: widget.endSidebarOpen ?? _ownEnd,
      onOpenChange: _setOpen,
      scroll: widget.scroll,
      locale: locale,
      child: layout,
    );
  }

  /// The layout of an application: exactly as tall as it was made, with only
  /// the region between the bars scrolling.
  Widget _content({
    required Widget? header,
    required Widget? footer,
    required bool fullHeader,
    required bool fullFooter,
    required Widget? start,
    required Widget? end,
    required Widget main,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (fullHeader) header!,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ?start,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (!fullHeader && header != null) header,
                    Expanded(
                      child: SingleChildScrollView(controller: widget.controller, child: main),
                    ),
                    if (!fullFooter && footer != null) footer,
                  ],
                ),
              ),
              ?end,
            ],
          ),
        ),
        if (fullFooter) footer!,
      ],
    );
  }

  /// The layout of a document: the whole page scrolls, with the bars and the
  /// sidebars holding their places as their positions say.
  Widget _page({
    required Widget? header,
    required Widget? footer,
    required bool fullHeader,
    required bool fullFooter,
    required bool contentHeader,
    required bool contentFooter,
    required bool headerPinned,
    required bool footerPinned,
    required Widget? start,
    required Widget? end,
    required Widget main,
    required TextDirection direction,
  }) {
    bool sticky(Widget? sidebar) => sidebar is! NebaSidebar || (sidebar.sticky ?? true);

    return CustomScrollView(
      controller: widget.controller,
      slivers: <Widget>[
        if (fullHeader)
          headerPinned ? PinnedHeaderSliver(child: header) : SliverToBoxAdapter(child: header),
        _PageBand(
          textDirection: direction,
          headerPinned: fullHeader && headerPinned,
          startSticky: sticky(widget.sidebar),
          endSticky: sticky(widget.endSidebar),
          contentHeaderPinned: contentHeader && headerPinned,
          contentFooterPinned: contentFooter && footerPinned,
          footerPinned: fullFooter && footerPinned,
          start: start,
          end: end,
          contentHeader: contentHeader ? header : null,
          main: main,
          contentFooter: contentFooter ? footer : null,
          footer: fullFooter ? footer : null,
        ),
      ],
    );
  }
}

/// "Skip to content": drawn only while it holds the focus, at the top of the
/// page's start, and in the focus order the whole time.
class _SkipLink extends StatefulWidget {
  const _SkipLink({required this.label, required this.color, required this.onPressed});

  final String label;
  final NebaColor color;
  final VoidCallback onPressed;

  @override
  State<_SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<_SkipLink> {
  final FocusNode _focus = FocusNode(debugLabel: 'NebaPageLayout skip link');
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus != _shown) {
      setState(() => _shown = _focus.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(widget.color);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    // One shape shown or not, so the focus is never dropped by a rebuild of
    // what holds it. Hidden, it is transparent and out of the pointer's
    // reach, and still in the focus order and read by a screen reader.
    return IgnorePointer(
      ignoring: !_shown,
      child: Semantics(
        link: true,
        child: NebaInteractive(
          focusNode: _focus,
          onTap: widget.onPressed,
          activatesOnSpace: false,
          builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
            return Opacity(
              opacity: _shown ? 1 : 0,
              alwaysIncludeSemantics: true,
              child: NebaFocusRing(
                visible: _shown,
                color: roles.ring,
                borderRadius: radius,
                keyboardOnly: false,
                child: NebaSheet(
                  fill: roles.fill,
                  elevation: 2,
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      widget.label,
                      style: TextStyle(color: roles.onSolid, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// What the page band holds, in the order it reads.
enum _BandSlot { start, contentHeader, main, contentFooter, end, footer }

/// Everything under the header of a page that scrolls: the sidebars, the
/// content between them with the bars that span only it, and the footer.
///
/// One sliver rather than several, because the sidebars hold their places
/// against the whole of the content beside them: a column is as tall as what
/// is left of the window under the header, and it travels with the page only
/// once the content beside it ends. A bar the header or the footer stands for
/// is held at its edge the same way. Everything a sticky part needs is in the
/// constraints a sliver is laid out with: how far it has scrolled past the
/// top, how much of it a pinned header covers, and how much of the window is
/// left.
class _PageBand extends SlottedMultiChildRenderObjectWidget<_BandSlot, RenderBox> {
  const _PageBand({
    required this.textDirection,
    required this.headerPinned,
    required this.startSticky,
    required this.endSticky,
    required this.contentHeaderPinned,
    required this.contentFooterPinned,
    required this.footerPinned,
    required this.start,
    required this.end,
    required this.contentHeader,
    required this.main,
    required this.contentFooter,
    required this.footer,
  });

  final TextDirection textDirection;
  final bool headerPinned;
  final bool startSticky;
  final bool endSticky;
  final bool contentHeaderPinned;
  final bool contentFooterPinned;
  final bool footerPinned;
  final Widget? start;
  final Widget? end;
  final Widget? contentHeader;
  final Widget main;
  final Widget? contentFooter;
  final Widget? footer;

  @override
  Iterable<_BandSlot> get slots => _BandSlot.values;

  @override
  Widget? childForSlot(_BandSlot slot) {
    return switch (slot) {
      _BandSlot.start => start,
      _BandSlot.contentHeader => contentHeader,
      _BandSlot.main => main,
      _BandSlot.contentFooter => contentFooter,
      _BandSlot.end => end,
      _BandSlot.footer => footer,
    };
  }

  @override
  _RenderPageBand createRenderObject(BuildContext context) {
    return _RenderPageBand(
      textDirection: textDirection,
      headerPinned: headerPinned,
      startSticky: startSticky,
      endSticky: endSticky,
      contentHeaderPinned: contentHeaderPinned,
      contentFooterPinned: contentFooterPinned,
      footerPinned: footerPinned,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPageBand renderObject) {
    renderObject
      ..textDirection = textDirection
      ..headerPinned = headerPinned
      ..startSticky = startSticky
      ..endSticky = endSticky
      ..contentHeaderPinned = contentHeaderPinned
      ..contentFooterPinned = contentFooterPinned
      ..footerPinned = footerPinned;
  }
}

class _RenderPageBand extends RenderSliver
    with SlottedContainerRenderObjectMixin<_BandSlot, RenderBox>, RenderSliverHelpers {
  _RenderPageBand({
    required TextDirection textDirection,
    required bool headerPinned,
    required bool startSticky,
    required bool endSticky,
    required bool contentHeaderPinned,
    required bool contentFooterPinned,
    required bool footerPinned,
  }) : _textDirection = textDirection,
       _headerPinned = headerPinned,
       _startSticky = startSticky,
       _endSticky = endSticky,
       _contentHeaderPinned = contentHeaderPinned,
       _contentFooterPinned = contentFooterPinned,
       _footerPinned = footerPinned;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  bool _headerPinned;
  set headerPinned(bool value) {
    if (value != _headerPinned) {
      _headerPinned = value;
      markNeedsLayout();
    }
  }

  bool _startSticky;
  set startSticky(bool value) {
    if (value != _startSticky) {
      _startSticky = value;
      markNeedsLayout();
    }
  }

  bool _endSticky;
  set endSticky(bool value) {
    if (value != _endSticky) {
      _endSticky = value;
      markNeedsLayout();
    }
  }

  bool _contentHeaderPinned;
  set contentHeaderPinned(bool value) {
    if (value != _contentHeaderPinned) {
      _contentHeaderPinned = value;
      markNeedsLayout();
    }
  }

  bool _contentFooterPinned;
  set contentFooterPinned(bool value) {
    if (value != _contentFooterPinned) {
      _contentFooterPinned = value;
      markNeedsLayout();
    }
  }

  bool _footerPinned;
  set footerPinned(bool value) {
    if (value != _footerPinned) {
      _footerPinned = value;
      markNeedsLayout();
    }
  }

  /// Where each child is, in the band's own scroll coordinates: across, and
  /// down from the band's top.
  final Map<RenderBox, Offset> _at = <RenderBox, Offset>{};

  RenderBox? _child(_BandSlot slot) => childForSlot(slot);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    final SliverConstraints c = constraints;
    assert(c.axis == Axis.vertical && c.growthDirection == GrowthDirection.forward);

    final double width = c.crossAxisExtent;
    final double window = c.viewportMainAxisExtent;
    // The header is the sliver before this one, and its whole extent.
    final double above = c.precedingScrollExtent;
    final double pinTop = _headerPinned ? above : 0;
    final bool ltr = _textDirection == TextDirection.ltr;

    final RenderBox? start = _child(_BandSlot.start);
    final RenderBox? end = _child(_BandSlot.end);
    final RenderBox? contentHeader = _child(_BandSlot.contentHeader);
    final RenderBox main = _child(_BandSlot.main)!;
    final RenderBox? contentFooter = _child(_BandSlot.contentFooter);
    final RenderBox? footer = _child(_BandSlot.footer);

    double heightOf(RenderBox? box, BoxConstraints constraints) {
      if (box == null) {
        return 0;
      }

      box.layout(constraints, parentUsesSize: true);
      return box.size.height;
    }

    final double footerHeight = heightOf(footer, BoxConstraints.tightFor(width: width));
    final double pinBottom = _footerPinned ? footerHeight : 0;
    // A column that holds its place is as tall as what is left of the window
    // under the header and over the footer that hold theirs.
    final double held = math.max(0, window - pinTop - pinBottom);

    double widthOf(RenderBox? box, bool sticky) {
      if (box == null) {
        return 0;
      }

      box.layout(
        sticky
            ? BoxConstraints(maxWidth: width, minHeight: held, maxHeight: held)
            : BoxConstraints(maxWidth: width),
        parentUsesSize: true,
      );

      return box.size.width;
    }

    final double startWidth = widthOf(start, _startSticky);
    final double endWidth = widthOf(end, _endSticky);
    final double inner = math.max(0, width - startWidth - endWidth);
    final BoxConstraints across = BoxConstraints.tightFor(width: inner);

    final double headerHeight = heightOf(contentHeader, across);
    final double contentFooterHeight = heightOf(contentFooter, across);

    // A short page still reaches the bottom of the window, and a band is at
    // least as tall as the columns held in it.
    final double floor = math.max(
      window - above - footerHeight,
      math.max(start != null && _startSticky ? held : 0, end != null && _endSticky ? held : 0),
    );

    main.layout(
      BoxConstraints(
        minWidth: inner,
        maxWidth: inner,
        minHeight: math.max(0, floor - headerHeight - contentFooterHeight),
      ),
      parentUsesSize: true,
    );

    final double row = headerHeight + main.size.height + contentFooterHeight;

    // A column that does not hold its place stretches to the band, as a flex
    // item does.
    if (start != null && !_startSticky) {
      start.layout(BoxConstraints.tightFor(width: startWidth, height: row), parentUsesSize: true);
    }

    if (end != null && !_endSticky) {
      end.layout(BoxConstraints.tightFor(width: endWidth, height: row), parentUsesSize: true);
    }

    final double total = row + footerHeight;
    final double scrolled = c.scrollOffset;
    // The first row of the band the header does not cover, and the last the
    // window shows, in the band's own coordinates.
    final double top = scrolled + c.overlap;
    final double bottom = scrolled + c.remainingPaintExtent;

    final double startX = ltr ? 0 : width - startWidth;
    final double endX = ltr ? width - endWidth : 0;
    final double innerX = ltr ? startWidth : endWidth;

    double heldAt(double extent, bool sticky) {
      return sticky ? clampDouble(top, 0, math.max(0, row - extent)) : 0;
    }

    _at
      ..clear()
      ..[main] = Offset(innerX, headerHeight);

    if (start != null) {
      _at[start] = Offset(startX, heldAt(start.size.height, _startSticky));
    }

    if (end != null) {
      _at[end] = Offset(endX, heldAt(end.size.height, _endSticky));
    }

    if (contentHeader != null) {
      _at[contentHeader] = Offset(innerX, heldAt(headerHeight, _contentHeaderPinned));
    }

    if (contentFooter != null) {
      final double natural = headerHeight + main.size.height;

      _at[contentFooter] = Offset(
        innerX,
        _contentFooterPinned
            ? clampDouble(bottom - pinBottom - contentFooterHeight, 0, natural)
            : natural,
      );
    }

    if (footer != null) {
      _at[footer] = Offset(0, _footerPinned ? clampDouble(bottom - footerHeight, 0, row) : row);
    }

    final double paintExtent = calculatePaintOffset(c, from: 0, to: total);

    geometry = SliverGeometry(
      scrollExtent: total,
      paintExtent: paintExtent,
      cacheExtent: calculateCacheOffset(c, from: 0, to: total),
      maxPaintExtent: total,
      hitTestExtent: paintExtent,
      hasVisualOverflow: true,
    );
  }

  /// The children from the back to the front: the content, the columns
  /// beside it, and the bars that hold their places over it.
  Iterable<RenderBox> get _paintOrder sync* {
    for (final _BandSlot slot in const <_BandSlot>[
      _BandSlot.main,
      _BandSlot.start,
      _BandSlot.end,
      _BandSlot.contentFooter,
      _BandSlot.contentHeader,
      _BandSlot.footer,
    ]) {
      final RenderBox? child = _child(slot);

      if (child != null) {
        yield child;
      }
    }
  }

  @override
  double childMainAxisPosition(RenderBox child) => _at[child]!.dy - constraints.scrollOffset;

  @override
  double childCrossAxisPosition(RenderBox child) => _at[child]!.dx;

  @override
  double? childScrollOffset(RenderObject child) => _at[child]?.dy ?? 0;

  @override
  void applyPaintTransform(covariant RenderBox child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      for (final RenderBox child in _paintOrder) {
        context.paintChild(
          child,
          offset + Offset(childCrossAxisPosition(child), childMainAxisPosition(child)),
        );
      }
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);

    for (final RenderBox child in _paintOrder.toList().reversed) {
      if (hitTestBoxChild(
        boxResult,
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      )) {
        return true;
      }
    }

    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // In reading order, which is the order of the slots.
    for (final _BandSlot slot in _BandSlot.values) {
      final RenderBox? child = _child(slot);

      if (child != null) {
        visitor(child);
      }
    }
  }
}
