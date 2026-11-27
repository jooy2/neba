/// `NebaToolbar`, a bar of controls.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/pinned.dart';
import 'package:neba/src/internal/ring.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A bar of controls: an application header, a page's action row, the strip
/// along the bottom of an editor.
///
/// Three slots in a row: [start] and [end] are pinned to their ends and
/// [children] take the width between them, each slot laid out in a row with
/// 8 pixels between its widgets, so no spacer is needed to push things apart.
/// A toolbar has no height of its own: it is as tall as the controls in it
/// plus its padding, which [size] and [density] set, and it takes the width
/// it is given.
///
/// It is a layout and nothing more. It is not one focus stop with arrow keys
/// between its controls, and it says nothing to a screen reader: each control
/// in it is reached and heard on its own. A set of toggles moved between
/// with the arrow keys is a `NebaToggleGroup`.
///
/// ```dart
/// NebaToolbar(
///   start: const <Widget>[Text('Workspace')],
///   end: <Widget>[NebaButton(onPressed: deploy, child: const Text('Deploy'))],
/// )
/// ```
class NebaToolbar extends StatelessWidget {
  /// A bar with [start], [children] and [end] laid out along it.
  const NebaToolbar({
    this.start = const <Widget>[],
    this.end = const <Widget>[],
    this.children = const <Widget>[],
    this.position = NebaPosition.static,
    this.side = NebaSide.top,
    this.safeArea = true,
    this.divider = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    super.key,
  }) : assert(side == NebaSide.top || side == NebaSide.bottom),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// Pinned to the start of the bar: a logo, a title, a back button.
  final List<Widget> start;

  /// Pinned to the end: the actions.
  final List<Widget> end;

  /// The middle, which takes whatever width [start] and [end] leave. A widget
  /// in it that should fill that width, such as a field, goes in an
  /// [Expanded].
  final List<Widget> children;

  /// How the bar sits against its [side]. A [NebaPosition.static] bar is a
  /// sheet with corners; a [NebaPosition.sticky] one drops its corners and
  /// keeps clear of the safe area, for a scroll view to hold it at the edge;
  /// a [NebaPosition.fixed] one does the same in the nearest `Overlay`,
  /// across its width, and takes no room where it was written.
  final NebaPosition position;

  /// The edge a pinned bar is held against: [NebaSide.top] or
  /// [NebaSide.bottom].
  final NebaSide side;

  /// Whether a pinned bar adds the screen's inset on its [side] to its
  /// padding, so what is on it stays clear of a phone's notch and home
  /// indicator. The inset is the padding `MediaQuery` reports where the bar
  /// is built, so a bar under a `SafeArea` adds nothing.
  final bool safeArea;

  /// Draws a hairline in [color]'s family along the edge that faces the
  /// content: under a top bar, over a bottom one. An `outline` bar already
  /// has one there.
  final bool divider;

  /// The sheet's weight, which is never dyed: `solid` is a brighter sheet,
  /// `outline` a lighter one with a hairline, `text` no sheet at all.
  /// Defaults to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The padding and the corners, never a height. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline and the divider. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. `0`, the default, even when the bar is
  /// pinned: a shadow under a header says there is content beneath it, which
  /// is only true once the page has scrolled. A `text` bar has no sheet to
  /// lift and ignores it.
  final NebaElevation? elevation;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = this.color ?? NebaColor.primary;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = this.elevation ?? 0;
    final Color line = tokens.roles(color).line;
    final bool bottom = side == NebaSide.bottom;
    // A bar held against an edge spans it, and a rounded corner against the
    // edge of a screen is a gap with nothing behind it.
    final BorderRadius radius = nebaIsPinned(position)
        ? BorderRadius.zero
        : BorderRadius.circular(tokens.radius[size]!);
    final double padding = NebaBox.padding[density]![size]!;
    final double inset = nebaSafeInset(context, position: position, side: side, safeArea: safeArea);

    Widget slot(List<Widget> widgets, {MainAxisSize width = MainAxisSize.min}) {
      return Row(mainAxisSize: width, spacing: 8, children: widgets);
    }

    Widget bar = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padding,
          padding + (bottom ? 0 : inset),
          padding,
          padding + (bottom ? inset : 0),
        ),
        child: Row(
          spacing: NebaScale.sheetSectionGap[size]!,
          children: <Widget>[
            if (start.isNotEmpty) slot(start),
            // Even when empty, so the two ends stay at their ends.
            Expanded(child: slot(children, width: MainAxisSize.max)),
            if (end.isNotEmpty) slot(end),
          ],
        ),
      ),
    );

    if (divider && variant != NebaVariant.outline) {
      final BorderSide rule = BorderSide(color: line);

      // A Container, so the line takes its pixel as a CSS border does.
      bar = Container(
        decoration: BoxDecoration(
          border: bottom ? Border(top: rule) : Border(bottom: rule),
        ),
        child: bar,
      );
    }

    final Widget sheet = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: bar,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: bar,
      ),
      NebaVariant.text => bar,
    };

    return NebaPinnedBar(
      position: position,
      side: side,
      // The ring of a pile the bar is in, around its corners.
      child: NebaRing(borderRadius: radius, child: sheet),
    );
  }
}
