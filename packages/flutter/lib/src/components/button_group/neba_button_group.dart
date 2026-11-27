/// `NebaButtonGroup`, a row of buttons that belong together.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// A row of buttons that belong together.
///
/// The corners that face a neighbour are squared off, so the run reads as one
/// cut piece with score lines in it. [variant], [size], [color], [density],
/// [elevation] and [disabled] are set once for the set: a button inside takes
/// its own argument first, then the group's, then `NebaProvider`'s. The
/// buttons stay buttons; this does not manage a selection.
///
/// ```dart
/// NebaButtonGroup(
///   variant: NebaVariant.outline,
///   children: <Widget>[
///     NebaButton(onPressed: day, child: const Text('Day')),
///     NebaButton(onPressed: week, child: const Text('Week')),
///   ],
/// )
/// ```
class NebaButtonGroup extends StatelessWidget {
  /// A group of [children].
  const NebaButtonGroup({
    required this.children,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.orientation = NebaOrientation.horizontal,
    this.disabled,
    this.fullWidth = false,
    this.semanticLabel,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The buttons.
  final List<Widget> children;

  /// The variant of every button that does not set its own. Defaults to
  /// `NebaProvider`'s, then to each button's own.
  final NebaVariant? variant;

  /// The size of every button that does not set its own.
  final NebaSize? size;

  /// The colour family of every button that does not set its own.
  final NebaColor? color;

  /// The density of every button that does not set its own.
  final NebaDensity? density;

  /// The elevation of every button that does not set its own.
  final NebaElevation? elevation;

  /// Which way the buttons run: a toolbar is horizontal, a stacked menu of
  /// equal actions vertical. A vertical group is as wide as its widest button.
  final NebaOrientation orientation;

  /// Disables every button that does not say otherwise.
  final bool? disabled;

  /// Stretches the group to the width it is given and shares it evenly between
  /// the buttons.
  final bool fullWidth;

  /// What a screen reader calls the group.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant? variant = this.variant ?? defaults.variant;

    Widget group = NebaButtonGroupScope(
      variant: variant,
      size: size ?? defaults.size,
      color: color,
      density: density ?? defaults.density,
      elevation: elevation,
      disabled: disabled,
      child: NebaJoinedRun(
        axis: orientation == NebaOrientation.horizontal ? Axis.horizontal : Axis.vertical,
        // Two outline buttons meeting would show both hairlines, a seam twice
        // as heavy as every other edge. A filled group's seam is the plate's
        // own white edge, which an overlap would cover. A group left unset is
        // a solid one, a button's own default.
        overlap: (variant ?? NebaVariant.solid) == NebaVariant.outline ? 1 : 0,
        fill: fullWidth,
        children: children,
      ),
    );

    if (fullWidth && orientation == NebaOrientation.horizontal) {
      group = SizedBox(width: double.infinity, child: group);
    }

    return Semantics(container: true, explicitChildNodes: true, label: semanticLabel, child: group);
  }
}
