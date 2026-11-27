/// `NebaIconButton`, a round button with a glyph in it and nothing else.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A round button holding a single glyph, for where there is no room for a
/// label: a toolbar, a list row.
///
/// Everything but the shape is [NebaButton]'s: the variants, the elevation
/// ladder, the light, [loading], [readOnly], and what a `NebaButtonGroup` sets.
/// In a group the corners that face a neighbour are still squared off.
///
/// ```dart
/// NebaIconButton(onPressed: add, icon: plus, label: 'Add item')
/// ```
class NebaIconButton extends StatelessWidget {
  /// A round button showing [icon], named [label].
  const NebaIconButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.loading = false,
    this.readOnly = false,
    this.disabled,
    this.focusableWhenDisabled = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// What the button does. `null` disables it.
  final VoidCallback? onPressed;

  /// The glyph, sized at 1.2 times the label size the button would have, as
  /// a `startIcon` is.
  final Widget icon;

  /// What the button does, in words: the name a screen reader hears. It is
  /// required because a button whose whole label is a drawing has no other
  /// name. It is not shown on screen.
  final String label;

  /// The weight of the surface, as on [NebaButton].
  final NebaVariant? variant;

  /// The height, which is also the width.
  final NebaSize? size;

  /// The colour family.
  final NebaColor? color;

  /// Accepted for symmetry with [NebaButton]; a glyph alone has no padding to
  /// change.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation? elevation;

  /// A turning ring in place of the glyph; stops the press but keeps the
  /// focus.
  final bool loading;

  /// Keeps the shape and the colour but goes flat and stops reacting.
  final bool readOnly;

  /// Drops the colour family for neutral grey and leaves the focus order.
  final bool? disabled;

  /// Keeps a disabled button in the focus order.
  final bool focusableWhenDisabled;

  /// The button's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it is first built.
  final bool autofocus;

  /// Every step of the radius ladder, pinned round.
  static const Map<NebaSize, double> _round = <NebaSize, double>{
    NebaSize.xs: 9999,
    NebaSize.sm: 9999,
    NebaSize.md: 9999,
    NebaSize.lg: 9999,
    NebaSize.xl: 9999,
  };

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    // Round through the radius ladder the button already reads, so the corners
    // a group squares off still win over the circle.
    return NebaTheme(
      tokens: tokens.copyWith(radius: _round),
      defaults: NebaTheme.defaultsOf(context),
      child: NebaButton(
        onPressed: onPressed,
        variant: variant,
        size: size,
        color: color,
        density: density,
        elevation: elevation,
        // The icon goes where a start icon goes, which puts the button on its
        // icon-only path: a square footprint, no padding, and the turning ring
        // in the glyph's place while loading.
        startIcon: icon,
        loading: loading,
        readOnly: readOnly,
        disabled: disabled,
        focusableWhenDisabled: focusableWhenDisabled,
        semanticLabel: label,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }
}
