/// The × that takes something out: a chip's, and the one a picker's trigger
/// shows while it holds a value. The React package's `chipRemoveClasses`.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// A round × [extent] across, drawn at the size of the words beside it and
/// at seven tenths of their ink until the pointer or the keyboard reaches it,
/// with [padding] around it that takes the press as well.
class NebaRemoveButton extends StatelessWidget {
  /// A × named [label] that calls [onPressed].
  const NebaRemoveButton({
    required this.onPressed,
    required this.label,
    required this.ring,
    required this.extent,
    required this.glyph,
    this.padding = EdgeInsetsDirectional.zero,
    super.key,
  });

  /// What pressing it does; `null` leaves it inert.
  final VoidCallback? onPressed;

  /// What a screen reader hears it as.
  final String label;

  /// The colour of its focus ring.
  final Color ring;

  /// The round button's width and height.
  final double extent;

  /// The × inside it, which overhangs the round button a little.
  final double glyph;

  /// The room around it that also takes the press.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: label,
      child: NebaInteractive(
        onTap: onPressed,
        enabled: enabled,
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return Padding(
            padding: padding,
            child: Center(
              child: NebaFocusRing(
                visible: interaction.focusVisible,
                color: ring,
                borderRadius: BorderRadius.circular(extent),
                offset: 1,
                child: AnimatedOpacity(
                  opacity: interaction.hovered || interaction.focusVisible ? 1 : 0.7,
                  duration: nebaDuration(context, NebaScale.duration),
                  curve: NebaScale.ease,
                  child: SizedBox.square(
                    dimension: extent,
                    child: OverflowBox(
                      maxWidth: glyph,
                      maxHeight: glyph,
                      child: NebaGlyph(NebaGlyphs.close, size: glyph),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
