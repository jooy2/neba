/// `NebaMeter`, how much of something there is on a scale known in advance.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How much of something there is, on a scale known in advance: disk used,
/// seats taken, quota spent, a password's strength.
///
/// It looks like a `NebaProgressLinear` and is not one. A progress bar is
/// about time: something is happening, it may have no value at all, and it is
/// expected to move on its own. A meter is about quantity: the [value] is
/// required, it moves only when what it measures does, and a reading can be
/// bad, which is what [thresholds] are for.
///
/// It takes the width it is given, and draws the same groove a progress bar
/// cuts, on the same ladder, so the two line up on one screen.
///
/// ```dart
/// const NebaMeter(value: 38, label: Text('Storage'), showValue: true)
/// ```
class NebaMeter extends StatelessWidget {
  /// A meter reading [value] between [min] and [max].
  const NebaMeter({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.format,
    this.thresholds,
    this.size,
    this.thickness,
    this.color,
    this.semanticLabel,
    super.key,
  }) : assert(thickness == null || thickness > 0);

  /// How much there is. Required: a meter reports a quantity that is already
  /// known, so there is no indeterminate case. A value past either end of
  /// the range is held to it.
  final double value;

  /// The bottom of the range.
  final double min;

  /// The top of the range.
  final double max;

  /// What is being measured, usually a [Text], at the start of the row above
  /// the bar. A [Text] is also the name a screen reader hears.
  final Widget? label;

  /// Whether the reading is drawn at the end of the row above the bar: a
  /// percentage of the range unless [format] says otherwise.
  final bool showValue;

  /// What the value is written as: given the value held to the range, it
  /// returns the text. A meter usually has real units, which is when this
  /// matters more than it does on a progress bar. Without it the reading is a
  /// whole percentage of [min] to [max].
  final String Function(double value)? format;

  /// Where the bar changes colour, smallest `from` first. The family of the
  /// last threshold the value has reached wins; below all of them [color]
  /// stands. They are read in the order given.
  final List<NebaThreshold>? thresholds;

  /// The thickness of the groove, on the ladder a `NebaProgressLinear` uses,
  /// and the type scale of the row above it. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The groove's thickness in logical pixels, when the step's own is not the
  /// one wanted: the same argument a `NebaProgressLinear` takes.
  final double? thickness;

  /// The family the bar carries before any threshold is reached. Defaults to
  /// [NebaColor.primary].
  final NebaColor? color;

  /// The name a screen reader hears in place of [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(
      thresholdColor(value, color ?? NebaColor.primary, thresholds),
    );
    // A meter always has a reading. A range with nothing in it, or a value
    // that is not a finite number, reads as an empty bar and says so.
    final double fraction = progressFraction(value, min, max) ?? 0;
    final String text = progressText(
      fraction: fraction,
      value: value,
      min: min,
      max: max,
      format: format,
    )!;
    final double groove = thickness ?? barThickness[size]!;
    final Widget? label = this.label;

    // A reading that changes travels there over the fill's duration, and a
    // threshold crossed on the way changes the fill's colour over the
    // shorter one; the track takes its new wash at once.
    final Widget bar = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: roles.fill),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? fill, Widget? _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: fraction),
          duration: nebaDuration(context, NebaScale.durationFill),
          curve: NebaScale.ease,
          builder: (BuildContext context, double filled, Widget? _) {
            return NebaGroove(
              thickness: groove,
              track: roles.soft,
              fill: fill ?? roles.fill,
              rest: roles.softPress,
              fraction: filled,
            );
          },
        );
      },
    );

    return progressSemantics(
      value: text,
      semanticLabel: semanticLabel,
      child: LimitedBox(
        maxWidth: 0,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: NebaScale.stackGap[size]!,
            children: <Widget>[
              if (label != null || showValue)
                NebaProgressCaption(size: size, label: label, value: text, showValue: showValue),
              bar,
            ],
          ),
        ),
      ),
    );
  }
}
