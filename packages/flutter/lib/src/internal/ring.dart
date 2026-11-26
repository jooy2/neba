/// The hairline a ringed pile draws around each of its items, handed down to
/// whatever draws the item's shape.
///
/// The React package writes the ring onto the child itself, three elements
/// down, because a ring has to follow the shape it is around: a ring on the
/// wrapper of a round avatar is a square. A Flutter widget's shape is its own
/// business, so the pile says which colour the ring is and the first widget
/// below it that draws a shape draws the ring around that shape, then takes
/// it off for everything inside it.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// The ring's width, Tailwind's `ring-2`.
const double nebaRingWidth = 2;

/// The colour of the ring the widgets below are to draw, or `null` for none.
class NebaRingScope extends InheritedWidget {
  /// Asks the first shape under [child] for a ring in [color].
  const NebaRingScope({required this.color, required super.child, super.key});

  /// The ring's colour, or `null` for no ring.
  final Color? color;

  /// The ring the widget at [context] is to draw, if it is the first shape
  /// under a ringed pile.
  static Color? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NebaRingScope>()?.color;
  }

  @override
  bool updateShouldNotify(NebaRingScope oldWidget) => oldWidget.color != color;
}

/// [child], a shape with [borderRadius] or of [shape], with the ring of the
/// pile it is in drawn just outside it and taken off for everything inside.
///
/// The tree is the same with a ring and without one, so a pile that turns
/// `ring` on or off rebuilds nothing inside its items.
class NebaRing extends StatelessWidget {
  /// The ring around [child].
  const NebaRing({
    required this.child,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  /// The corners of the shape the ring follows.
  final BorderRadius? borderRadius;

  /// The shape the ring follows.
  final BoxShape shape;

  /// The shape.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color? color = NebaRingScope.of(context);

    return DecoratedBox(
      // Outside the edge and a stroke rather than a shadow, so it takes no room
      // and nothing of it shows through a translucent sheet: CSS clips an outer
      // shadow to outside the border box for the same reason.
      decoration: color == null
          ? const BoxDecoration()
          : BoxDecoration(
              shape: shape,
              borderRadius: shape == BoxShape.circle ? null : borderRadius,
              border: Border.all(
                color: color,
                width: nebaRingWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
      child: NebaRingScope(color: null, child: child),
    );
  }
}
