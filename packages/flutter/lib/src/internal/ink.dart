/// The colour of a control's label and icon, eased with its fill.
///
/// A CSS `color` is inherited and transitions on the element, so a button's
/// label follows its fill from one colour to the next. Flutter has no
/// inherited transition, so this eases [DefaultTextStyle] and [IconTheme]
/// together, over the house duration, and in zero time on a press.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// [child]'s text and icons in [color].
class NebaInk extends StatelessWidget {
  /// Ink in [color] for [child].
  const NebaInk({required this.color, required this.child, this.instant = false, super.key});

  /// The ink.
  final Color color;

  /// Whether the change is a press, which lands in zero time.
  final bool instant;

  /// The label and icons.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: nebaDuration(context, NebaScale.duration, instant: instant),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? ink, Widget? child) {
        return DefaultTextStyle.merge(
          style: TextStyle(color: ink),
          child: IconTheme.merge(
            data: IconThemeData(color: ink),
            child: child!,
          ),
        );
      },
      child: child,
    );
  }
}
