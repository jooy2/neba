/// The vocabulary a page's structure is written in, and what the widgets that
/// build one share: the React package's `src/internal/page-layout.ts`.
///
/// Five widgets read it: `NebaPageLayout`, `NebaHeader`, `NebaFooter`,
/// `NebaSidebar` and `NebaSidebarTrigger`, and every one but the first is also
/// usable on its own. Keeping it in the layout's file would make a header
/// import a layout it may never be inside.
///
/// What is here is only what a part cannot work out from where it sits: the
/// width at which a sidebar stops being a column, whether a drawer is open,
/// which bar of the page a header or a footer is, and whether it is already
/// inside a landmark. The arrangement itself is the layout's.
///
/// The library talking to itself, except for the three enums, which
/// `NebaPageLayout` and `NebaSidebar` export as the React package exports its
/// `PageLayoutSpan`, `PageLayoutScroll` and `SidebarSide`.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which end of the band a sidebar takes. Logical, so it flips under a
/// right-to-left direction.
enum NebaSidebarSide {
  /// The leading end: the left of a left-to-right page.
  start,

  /// The trailing end: the right of a left-to-right page.
  end,
}

/// How far across a header or a footer reaches.
enum NebaPageLayoutSpan {
  /// The whole width, with the sidebars beginning underneath it: the
  /// arrangement of a website.
  full,

  /// Only the column between the sidebars, which run the full height beside
  /// it: the arrangement of an application.
  content,
}

/// What scrolls.
enum NebaPageLayoutScroll {
  /// The whole page does, as a document does: a sticky header holds its place
  /// at the top, the sidebars hold theirs beside the content, and the footer
  /// is reached by scrolling to it.
  page,

  /// Only the region between the header and the footer does, as an
  /// application does: the layout is exactly as tall as it was made.
  content,
}

/// Which bar of a `NebaPageLayout` a widget is the one the layout was handed
/// as, if it is.
enum NebaPageBar {
  /// The layout's `header`.
  header,

  /// The layout's `footer`.
  footer,
}

/// What a `NebaPageLayout` tells the parts inside it.
class NebaPageLayoutScope extends InheritedWidget {
  /// The layout's facts, for [child].
  const NebaPageLayoutScope({
    required this.collapseBelow,
    required this.startOpen,
    required this.endOpen,
    required this.onOpenChange,
    required this.scroll,
    required this.locale,
    required super.child,
    super.key,
  });

  /// The window width below which the sidebars are drawers.
  final NebaBreakpoint collapseBelow;

  /// Whether the leading sidebar's drawer is open.
  final bool startOpen;

  /// Whether the trailing sidebar's drawer is open.
  final bool endOpen;

  /// Opens or closes a sidebar's drawer.
  final void Function(NebaSidebarSide side, bool open) onOpenChange;

  /// What scrolls.
  final NebaPageLayoutScroll scroll;

  /// The language the layout's own words are in.
  final Locale? locale;

  /// Whether a sidebar's drawer is open.
  bool openOf(NebaSidebarSide side) => side == NebaSidebarSide.start ? startOpen : endOpen;

  /// The nearest layout, or `null` outside one.
  static NebaPageLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaPageLayoutScope>();
  }

  @override
  bool updateShouldNotify(NebaPageLayoutScope oldWidget) {
    return collapseBelow != oldWidget.collapseBelow ||
        startOpen != oldWidget.startOpen ||
        endOpen != oldWidget.endOpen ||
        onOpenChange != oldWidget.onOpenChange ||
        scroll != oldWidget.scroll ||
        locale != oldWidget.locale;
  }
}

/// Where in a page a widget sits: which bar it is, which end a sidebar is
/// at, and whether it is already inside a landmark.
///
/// A `NebaPageLayout` puts one around each of its regions. Only the header
/// and the footer it was handed are its bars, so a header anywhere else, such
/// as an article's own, is a header of that part. And a landmark inside
/// another is not one, as a `<footer>` inside `<main>` is not the
/// `contentinfo` landmark, which is also what keeps a layout nested in
/// another's content from announcing a second main region.
class NebaPageRegion extends InheritedWidget {
  /// The region [child] is in.
  const NebaPageRegion({
    required super.child,
    this.bar,
    this.side,
    this.landmarked = false,
    super.key,
  });

  /// Which bar of the layout [child] is, if it is one.
  final NebaPageBar? bar;

  /// Which end of the band a sidebar slot is.
  final NebaSidebarSide? side;

  /// Whether [child] is inside a landmark already.
  final bool landmarked;

  /// The nearest region, or `null` outside a layout and a sidebar.
  static NebaPageRegion? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaPageRegion>();
  }

  @override
  bool updateShouldNotify(NebaPageRegion oldWidget) {
    return bar != oldWidget.bar || side != oldWidget.side || landmarked != oldWidget.landmarked;
  }
}

/// Whether the window is narrower than [breakpoint], which is when a sidebar
/// is a drawer. [NebaBreakpoint.xs] is the floor of every width, so nothing is
/// ever below it: the React package's `'none'`.
bool nebaCollapsed(BuildContext context, NebaBreakpoint breakpoint) {
  return !nebaShownAt(MediaQuery.sizeOf(context).width, above: breakpoint);
}

/// A sidebar's logical [side] as the physical edge of the window a drawer is
/// attached to, which the reading direction decides.
NebaSide nebaDrawerSide(NebaSidebarSide side, TextDirection direction) {
  final bool rtl = direction == TextDirection.rtl;

  if (side == NebaSidebarSide.start) {
    return rtl ? NebaSide.right : NebaSide.left;
  }

  return rtl ? NebaSide.left : NebaSide.right;
}

/// The sheet a bar or a sidebar is drawn on, said the way a container says
/// it: never dyed, because what is on it arrives with colours of its own.
/// `solid` is the brighter panel with the full plate, `outline` the lighter
/// one with the top light, and `text` no sheet at all. The edge is the bar's
/// own hairline, drawn by the bar, so the sheet has none.
Widget nebaBarSheet({
  required NebaTokens tokens,
  required NebaVariant variant,
  required int elevation,
  required Widget child,
}) {
  return switch (variant) {
    NebaVariant.solid => NebaSheet(fill: tokens.panelPress, elevation: elevation, child: child),
    NebaVariant.outline => NebaSheet(
      fill: tokens.panel,
      plate: NebaPlate.glass,
      elevation: elevation,
      child: child,
    ),
    NebaVariant.text => child,
  };
}

/// [child] with only the system insets of the edges it touches left in its
/// `MediaQuery`, which is how the layout hands each region its share of the
/// screen's insets.
Widget nebaKeepInsets({
  required BuildContext context,
  required Widget child,
  bool top = false,
  bool bottom = false,
  bool left = false,
  bool right = false,
}) {
  return MediaQuery.removePadding(
    context: context,
    removeTop: !top,
    removeBottom: !bottom,
    removeLeft: !left,
    removeRight: !right,
    child: child,
  );
}
