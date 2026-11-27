/// `NebaFooter`, the sheet at the end of a page.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/page_layout.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The sheet at the end of a page: the copyright line, the columns of links,
/// the address.
///
/// It has no slots, which is the difference between it and `NebaHeader`: a
/// footer is four columns on one product and one line on the next, so what it
/// decides is the sheet, the gutter, the hairline along its top edge that says
/// the page ended, and whether it stays in reach. Everything on it is the
/// [child]'s.
///
/// Inside a `NebaPageLayout`, as its `footer`, it is the page's own footer: the
/// one a screen reader offers as the site's information, and the one the
/// layout holds at the bottom while the page scrolls when its [position] says
/// so.
///
/// ```dart
/// const NebaFooter(child: Text('© 2026 Neba'))
/// ```
class NebaFooter extends StatelessWidget {
  /// A footer holding [child].
  const NebaFooter({
    this.child,
    this.position = NebaPosition.static,
    this.safeArea = true,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.divider = true,
    this.maxWidth = NebaMeasure.none,
    this.padded = true,
    this.label,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// Everything on the footer.
  final Widget? child;

  /// How a `NebaPageLayout` holds the footer while the page scrolls:
  /// [NebaPosition.static], the default, is reached by scrolling to the end;
  /// [NebaPosition.sticky] and [NebaPosition.fixed] are held at the bottom,
  /// for a form's save row that has to stay in reach. Outside a layout it
  /// changes nothing.
  final NebaPosition position;

  /// Keeps what is on the footer clear of the system's insets on the edges it
  /// touches: the bottom and the two sides, where the home indicator and a
  /// notch are. The sheet still runs under them. A footer at the end of a
  /// page is against the bottom of the screen once the page is scrolled to
  /// it, so this holds whatever its [position].
  final bool safeArea;

  /// The sheet's weight: `solid` is the brighter panel, `outline` the lighter
  /// one, `text` no sheet at all. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The footer's gutter and the space above and below what is on it.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline. The sheet itself stays undyed.
  final NebaColor color;

  /// How wide the gutter is at its [size]. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation elevation;

  /// Draws the hairline along the top edge.
  final bool divider;

  /// Holds what is on the footer to a measure and centres it, while the sheet
  /// still spans the width.
  final NebaMeasure maxWidth;

  /// Whether the footer has its gutter and the space above and below.
  final bool padded;

  /// The name a screen reader announces for the page's own footer.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final EdgeInsets screen = safeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;

    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.maxWidth),
      child: Padding(
        padding: padded ? EdgeInsets.all(NebaBox.padding[density]![size]!) : EdgeInsets.zero,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );

    final Widget bar = Container(
      // A Container, because it adds the line's width to the footer as a CSS
      // border does.
      decoration: BoxDecoration(
        border: divider ? Border(top: BorderSide(color: tokens.roles(color).line)) : null,
      ),
      padding: EdgeInsets.only(left: screen.left, right: screen.right, bottom: screen.bottom),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg),
        child: Align(alignment: Alignment.topCenter, heightFactor: 1, child: content),
      ),
    );

    final NebaPageRegion? region = NebaPageRegion.maybeOf(context);
    final bool pageBar = region?.bar == NebaPageBar.footer && !region!.landmarked;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: pageBar ? SemanticsRole.contentInfo : null,
      label: pageBar ? label : null,
      child: nebaBarSheet(tokens: tokens, variant: variant, elevation: elevation, child: bar),
    );
  }
}
