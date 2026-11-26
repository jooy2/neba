/// `NebaAspectRatio`, a box that keeps a proportion whatever width it is
/// given.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A box that keeps a proportion whatever width it is given.
///
/// It draws nothing of its own: it reserves the space, so a card whose image
/// arrives late does not move what is below it, and it holds what is inside
/// to the shape, clipping whatever runs past it.
///
/// A child that is an [Image] is stretched to the box and fitted by [fit], as
/// the React package fits an `img`; anything else is stretched to the box and
/// lays its own content out.
///
/// ```dart
/// NebaAspectRatio(
///   ratio: 16 / 9,
///   rounded: true,
///   child: Image.asset('assets/lake.jpg', semanticLabel: 'A still alpine lake at dawn'),
/// )
/// ```
class NebaAspectRatio extends StatelessWidget {
  /// A box of [ratio], width over height, holding [child].
  const NebaAspectRatio({
    this.ratio = 1,
    this.fit = BoxFit.cover,
    this.rounded = false,
    this.size,
    this.child,
    super.key,
  }) : assert(ratio > 0);

  /// The proportion the box holds, width over height: `16 / 9`, `1.5`.
  final double ratio;

  /// How an [Image] child is fitted to the box. [BoxFit.cover] crops,
  /// [BoxFit.contain] letterboxes, [BoxFit.fill] squashes, [BoxFit.none] keeps
  /// the image's own size and [BoxFit.scaleDown] never enlarges it.
  final BoxFit fit;

  /// Whether the corners are cut to the [size] step of the radius ladder.
  final bool rounded;

  /// Which step of the radius ladder [rounded] uses. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// What the box holds.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final Widget? child = this.child;

    return AspectRatio(
      aspectRatio: ratio,
      // The clip is not decoration: without it a covering image spills out of
      // the proportion it was just given, and the box would only be reserving
      // the space rather than holding anything to it.
      child: ClipRRect(
        borderRadius: rounded ? BorderRadius.circular(tokens.radius[size]!) : BorderRadius.zero,
        clipBehavior: rounded ? Clip.antiAlias : Clip.hardEdge,
        child: SizedBox.expand(
          child: child is Image ? FittedBox(fit: fit, child: child) : child,
        ),
      ),
    );
  }
}
