/// `NebaDivider`, a rule between two things.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A rule between two things, with a label set into it when it has a
/// [child]: "OR" between two sign-in options.
///
/// It is the same hairline a card scores its sections with, in [color]'s
/// family. Left without a [length], a horizontal divider takes the width it
/// is given and a vertical one the height its row is given, the way a rule
/// between two things should; with nothing to take, it is as long as its
/// label. It is not a surface: no sheet, no light, no shadow.
///
/// ```dart
/// const NebaDivider(child: Text('OR'))
/// ```
class NebaDivider extends StatelessWidget {
  /// A rule, labelled [child] when there is one.
  const NebaDivider({
    this.child,
    this.orientation = NebaOrientation.horizontal,
    this.color,
    this.size,
    this.length,
    this.thickness = 1,
    this.textAlign = NebaAlign.center,
    super.key,
  }) : assert(thickness > 0);

  /// A label set into the line. A [Text] is also what a screen reader hears.
  final Widget? child;

  /// Which way the line runs.
  final NebaOrientation orientation;

  /// The family of the hairline. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The type scale of the label; nothing else on a divider has a size.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// How far the rule runs, in logical pixels: the width of a horizontal
  /// divider, the height of a vertical one. A fraction of the room is a
  /// `FractionallySizedBox` around it.
  final double? length;

  /// How thick the rule is, in logical pixels.
  final double thickness;

  /// Where the label sits. `center` splits the line in half; `start` and
  /// `end` leave a short stub on the near side, so the label still reads as
  /// set into the rule.
  final NebaAlign textAlign;

  /// The stub on the near side of an off-centre label.
  static const double stub = 16;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final Color line = tokens.roles(color ?? NebaColor.primary).line;
    final bool vertical = orientation == NebaOrientation.vertical;
    final Widget? child = this.child;

    if (child == null) {
      // A rule with no length takes the room it is given across its long
      // axis, and none at all where there is no limit to take.
      return ExcludeSemantics(child: _span(vertical, _Rule(line, thickness, vertical)));
    }

    Widget rule({required bool stubbed}) {
      final Widget drawn = _Rule(line, thickness, vertical);

      if (stubbed) {
        return SizedBox(
          width: vertical ? null : stub,
          height: vertical ? stub : null,
          child: drawn,
        );
      }

      return Expanded(child: drawn);
    }

    final Widget label = DefaultTextStyle.merge(
      style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
      softWrap: false,
      // A vertical rule's label turns with it, or the line would grow to the
      // width of the word.
      child: vertical ? RotatedBox(quarterTurns: 1, child: child) : child,
    );

    final List<Widget> parts = <Widget>[
      rule(stubbed: textAlign == NebaAlign.start),
      label,
      rule(stubbed: textAlign == NebaAlign.end),
    ];
    final double gap = NebaScale.sheetSectionGap[size]!;
    final Widget flex = vertical
        ? Column(mainAxisSize: MainAxisSize.max, spacing: gap, children: parts)
        : Row(mainAxisSize: MainAxisSize.max, spacing: gap, children: parts);
    final String? name = child is Text ? child.data : null;

    return Semantics(
      container: true,
      label: name,
      excludeSemantics: name != null,
      child: _span(vertical, flex),
    );
  }

  /// [child] across [length], or across the room it is given.
  Widget _span(bool vertical, Widget child) {
    final double? length = this.length;

    if (length != null) {
      return SizedBox(
        width: vertical ? null : length,
        height: vertical ? length : null,
        child: child,
      );
    }

    return vertical
        ? LimitedBox(
            maxHeight: 0,
            child: SizedBox(height: double.infinity, child: child),
          )
        : LimitedBox(
            maxWidth: 0,
            child: SizedBox(width: double.infinity, child: child),
          );
  }
}

/// The line itself: a strip of [color] [thickness] thick, as long as the box
/// it is given.
class _Rule extends StatelessWidget {
  const _Rule(this.color, this.thickness, this.vertical);

  final Color color;
  final double thickness;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vertical ? thickness : null,
      height: vertical ? null : thickness,
      child: ColoredBox(color: color),
    );
  }
}
