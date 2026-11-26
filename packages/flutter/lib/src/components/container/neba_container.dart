/// `NebaContainer`, the gutters around a page's content.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// Puts horizontal gutters around a page's content and centres it. Keeping
/// content off the edge of the window is its only job: it draws no surface, so
/// a sheet is a [NebaBox] inside it.
///
/// ```dart
/// const NebaContainer(maxWidth: NebaMeasure.size(NebaSize.lg), child: page)
/// ```
class NebaContainer extends StatelessWidget {
  /// Gutters around [child], held to [maxWidth].
  const NebaContainer({
    this.maxWidth = NebaMeasure.none,
    this.padded = true,
    this.size,
    this.density,
    this.centered = true,
    this.child,
    super.key,
  });

  /// How wide the content may get. No limit by default.
  final NebaMeasure maxWidth;

  /// Whether the gutters are drawn. Off keeps the centring and the measure
  /// and drops only the padding.
  final bool padded;

  /// How wide the gutters are, on [NebaBox]'s steps. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// How wide the gutters are at [size]. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// Whether the content is centred once [maxWidth] is narrower than the room
  /// there is. No effect while [maxWidth] is [NebaMeasure.none].
  final bool centered;

  /// What the gutters go around.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    Widget content = child ?? const SizedBox.shrink();

    if (padded) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: NebaBox.padding[density]![size]!),
        child: content,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // A block that is as wide as it may be, as `w-full max-w-*` is; in a
        // row that gives it no width of its own, as wide as its content.
        final Widget measured = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth.maxWidth),
          child: constraints.hasBoundedWidth
              ? SizedBox(width: double.infinity, child: content)
              : content,
        );

        return Align(
          alignment: centered ? Alignment.topCenter : AlignmentDirectional.topStart,
          heightFactor: 1,
          widthFactor: constraints.hasBoundedWidth ? null : 1,
          child: measured,
        );
      },
    );
  }
}
