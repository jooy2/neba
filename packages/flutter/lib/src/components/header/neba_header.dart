/// `NebaHeader`, the bar across the top of a page.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/page_layout.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The bar across the top of a page, in three slots: the [brand] at the
/// start, the [children] in the middle and the [actions] at the end.
///
/// Each slot is a row of its own, so a logo and a name, or a pair of buttons,
/// need no wrapper; the three are spaced about twice as far apart as what is
/// inside one, so each reads as a region. A slot given nothing builds nothing.
///
/// The sheet spans the width it is given and carries a hairline along its
/// bottom edge, against the content passing under it. On a phone it keeps
/// what is on it clear of the status bar and a notch ([safeArea]), and the
/// sheet runs under them.
///
/// Inside a `NebaPageLayout`, as its `header`, it is the bar the layout holds
/// at the top while the page scrolls, as its [position] says. Anywhere else it
/// is a bar like any other box.
///
/// ```dart
/// NebaHeader(
///   brand: const <Widget>[Text('Neba')],
///   actions: <Widget>[NebaButton(onPressed: signIn, child: const Text('Sign in'))],
/// )
/// ```
class NebaHeader extends StatelessWidget {
  /// A bar with [brand], [children] and [actions] on it.
  const NebaHeader({
    this.brand = const <Widget>[],
    this.children = const <Widget>[],
    this.actions = const <Widget>[],
    this.align = NebaAlign.start,
    this.position = NebaPosition.sticky,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.divider = true,
    this.maxWidth = NebaMeasure.none,
    this.padded = true,
    this.label,
    this.safeArea = true,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The leading slot: the logo, the product's name, a `NebaSidebarTrigger`
  /// ahead of them.
  final List<Widget> brand;

  /// The middle slot, usually the navigation.
  final List<Widget> children;

  /// The trailing slot: the account menu, a theme switch, a call to action.
  final List<Widget> actions;

  /// Where the middle slot sits: packed against the [brand] at
  /// [NebaAlign.start], on the bar's own midline at [NebaAlign.center], with
  /// the two ends given equal shares so it stays there however wide either
  /// is, or packed against the [actions] at [NebaAlign.end].
  final NebaAlign align;

  /// How a `NebaPageLayout` holds the bar while the page scrolls:
  /// [NebaPosition.sticky] and [NebaPosition.fixed] at the top, with the
  /// content passing under it, and [NebaPosition.static] scrolling away with
  /// it. Outside a layout it changes nothing.
  final NebaPosition position;

  /// The sheet's weight: `solid` is the brighter panel, `outline` the lighter
  /// one, `text` no sheet at all. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The bar's height floor, its gutter and the space around its slots.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline. The sheet itself stays undyed.
  final NebaColor color;

  /// How wide the gutter is at its [size]. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, which is none, to `3`.
  final NebaElevation elevation;

  /// Draws the hairline along the bottom edge.
  final bool divider;

  /// Holds the row of slots to a measure and centres it, while the sheet
  /// still spans the width: the same ladder `NebaContainer` takes, so the bar
  /// and the container under it line up on the same edge.
  final NebaMeasure maxWidth;

  /// Whether the row has a gutter down each side.
  final bool padded;

  /// The name a screen reader announces for the bar. Flutter has no banner
  /// role, so the header a `NebaPageLayout` was handed is a named region when
  /// it has one, and a group read in order when it has none.
  final String? label;

  /// Keeps what is on the bar clear of the system's insets on the edges it
  /// touches: the top and the two sides. The sheet still runs under them.
  final bool safeArea;

  /// The bar's height floor at each size: 56 logical pixels at `md`, a 32
  /// pixel control with 12 above and below it.
  static const Map<NebaSize, double> heights = <NebaSize, double>{
    NebaSize.xs: 40,
    NebaSize.sm: 48,
    NebaSize.md: 56,
    NebaSize.lg: 64,
    NebaSize.xl: 80,
  };

  /// The space inside one slot: between a logo and its name, or two buttons.
  static const Map<NebaSize, double> slotGaps = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 12,
    NebaSize.lg: 16,
    NebaSize.xl: 20,
  };

  /// The space between the three slots, about twice the space inside one.
  static const Map<NebaSize, double> barGaps = <NebaSize, double>{
    NebaSize.xs: 12,
    NebaSize.sm: 16,
    NebaSize.md: 24,
    NebaSize.lg: 32,
    NebaSize.xl: 40,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final double slotGap = slotGaps[size]!;
    final EdgeInsets screen = safeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;

    Widget slot(List<Widget> items, MainAxisAlignment alignment) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        spacing: slotGap,
        children: items,
      );
    }

    final bool centred = align == NebaAlign.center;
    final List<Widget> slots = <Widget>[
      if (brand.isNotEmpty)
        centred
            ? Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: slot(brand, MainAxisAlignment.start),
                ),
              )
            : slot(brand, MainAxisAlignment.start)
      // An empty end still takes its half, or the middle would be centred on
      // what is left over rather than on the bar.
      else if (centred)
        const Expanded(child: SizedBox.shrink()),
      if (children.isNotEmpty)
        // Its own width, with the two ends sharing what is left equally, which
        // is what puts it on the midline.
        centred
            ? slot(children, MainAxisAlignment.center)
            : Expanded(
                child: Row(
                  mainAxisAlignment: align == NebaAlign.end
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  spacing: slotGap,
                  children: children,
                ),
              ),
      if (actions.isNotEmpty)
        centred
            ? Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: slot(actions, MainAxisAlignment.end),
                ),
              )
            : slot(actions, MainAxisAlignment.end)
      else if (centred)
        const Expanded(child: SizedBox.shrink()),
    ];

    final Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: heights[size]!, maxWidth: maxWidth.maxWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padded ? NebaBox.padding[density]![size]! : 0),
        child: Row(spacing: barGaps[size]!, children: slots),
      ),
    );

    final Widget bar = Container(
      // A Container, because it adds the line's width to the bar as a CSS
      // border does.
      decoration: BoxDecoration(
        border: divider ? Border(bottom: BorderSide(color: tokens.roles(color).line)) : null,
      ),
      padding: EdgeInsets.only(left: screen.left, top: screen.top, right: screen.right),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: tokens.fg),
        child: Align(alignment: Alignment.topCenter, heightFactor: 1, child: row),
      ),
    );

    final Widget sheet = nebaBarSheet(
      tokens: tokens,
      variant: variant,
      elevation: elevation,
      child: bar,
    );
    final NebaPageRegion? region = NebaPageRegion.maybeOf(context);
    final bool pageBar = region?.bar == NebaPageBar.header;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: pageBar && label != null ? SemanticsRole.region : null,
      label: pageBar ? label : null,
      child: sheet,
    );
  }
}
