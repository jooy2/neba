/// `NebaBox`, the plainest sheet in the library.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The basic surface to put content on: it groups content and lifts it off
/// the page.
///
/// None of the three variants floods the sheet with colour, because what a
/// box holds is content that arrives with colours of its own. `solid` is a
/// brighter sheet, `outline` a lighter one with a hairline in [color]'s
/// family, and `text` no sheet at all. [size] sets the sheet's corners and its
/// padding, never a height or a type size: a box is as tall as what it holds.
///
/// ```dart
/// const NebaBox(child: Text('Content'))
/// ```
class NebaBox extends StatelessWidget {
  /// A sheet with [child] on it.
  const NebaBox({
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.padded = true,
    this.transition,
    this.child,
    super.key,
  }) : assert(elevation >= nebaElevationMin && elevation <= nebaElevationMax);

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The sheet's corners and padding. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline. The sheet itself stays undyed.
  final NebaColor color;

  /// How much padding the sheet has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. A `text` box has no sheet to lift, so
  /// it ignores this.
  final NebaElevation elevation;

  /// Whether the sheet pads its content. Off for content that runs to the
  /// edges: a picture, a table, a list that draws its own rows.
  final bool padded;

  /// How the box arrives when it is first built: `const
  /// NebaTransition.fade()`, or any of the others. The whole sheet moves, its
  /// shadow with it.
  final NebaTransition? transition;

  /// What is on the sheet.
  final Widget? child;

  /// The padding at each size, per density: the React package's
  /// `boxPaddingClasses`.
  static const Map<NebaDensity, Map<NebaSize, double>> padding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 8,
          NebaSize.sm: 12,
          NebaSize.md: 16,
          NebaSize.lg: 20,
          NebaSize.xl: 24,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 6,
          NebaSize.sm: 8,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 16,
        },
      };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: tokens.fg),
      child: child ?? const SizedBox.shrink(),
    );

    if (padded) {
      content = Padding(padding: EdgeInsets.all(padding[density]![size]!), child: content);
    }

    final Widget box = switch (variant) {
      NebaVariant.solid => NebaSheet(
        fill: tokens.panelHover,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.outline => NebaSheet(
        fill: tokens.panel,
        edge: tokens.roles(color).line,
        plate: NebaPlate.glass,
        elevation: elevation,
        borderRadius: radius,
        child: content,
      ),
      NebaVariant.text => content,
    };
    final NebaTransition? transition = this.transition;

    return transition == null ? box : NebaEntrance(transition: transition, child: box);
  }
}
