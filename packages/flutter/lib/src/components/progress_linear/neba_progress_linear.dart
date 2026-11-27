/// `NebaProgressLinear`, progress as a bar that fills.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Progress as a bar that fills: the one of the three progress shapes that
/// shows how much is left at a glance, because length is a quantity a reader
/// compares without counting.
///
/// Without a [value] it is indeterminate, and a short segment crosses the
/// groove in the reading direction; a reader who asked for less motion sees
/// the whole groove pulse instead. A `value` of `0` means something else,
/// that nothing has progressed yet, so keep the two apart.
///
/// The bar takes the width it is given. A [label] and the reading, with
/// [showValue], sit in a row above it.
///
/// ```dart
/// const NebaProgressLinear(value: 64, label: Text('Uploading assets'), showValue: true)
/// ```
class NebaProgressLinear extends StatefulWidget {
  /// A bar [value] of the way from [min] to [max], or an indeterminate one
  /// without a [value].
  const NebaProgressLinear({
    this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.format,
    this.size,
    this.color,
    this.thickness,
    this.semanticLabel,
    super.key,
  }) : assert(thickness == null || thickness > 0);

  /// How far along, between [min] and [max]. `null`, the default, is the
  /// indeterminate case: something is happening and nobody knows how much of
  /// it is left. A value past either end of the range is held to it.
  final double? value;

  /// The bottom of the range.
  final double min;

  /// The top of the range.
  final double max;

  /// What is loading, usually a [Text], at the start of the row above the
  /// bar. A [Text] is also the name a screen reader hears.
  final Widget? label;

  /// Whether the reading is drawn at the end of the row above the bar: a
  /// percentage of the range unless [format] says otherwise.
  final bool showValue;

  /// What the value is written as, once the number means something: given
  /// the value held to the range, it returns the text, so bytes, files and
  /// currencies can be written in any language with whatever formatter the
  /// app already uses. Without it the reading is a whole percentage of [min]
  /// to [max].
  final String Function(double value)? format;

  /// The thickness of the groove, and the type scale of the row above it;
  /// nothing else on a bar has a size. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the groove and its fill. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The groove's thickness in logical pixels, when the step's own is not
  /// the one wanted: a heavier bar for a screen that is about the one number.
  /// [size] still sets the type scale.
  final double? thickness;

  /// The name a screen reader hears in place of [label].
  final String? semanticLabel;

  @override
  State<NebaProgressLinear> createState() => _NebaProgressLinearState();
}

class _NebaProgressLinearState extends State<NebaProgressLinear>
    with SingleTickerProviderStateMixin {
  late final NebaProgressClock _clock = NebaProgressClock(this);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _clock.run(_fraction == null);
  }

  @override
  void didUpdateWidget(NebaProgressLinear oldWidget) {
    super.didUpdateWidget(oldWidget);
    _clock.run(_fraction == null);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final double? fraction = _fraction;
    final String? text = progressText(
      fraction: fraction,
      value: widget.value,
      min: widget.min,
      max: widget.max,
      format: widget.format,
    );
    final double thickness = widget.thickness ?? barThickness[size]!;

    NebaGroove groove(double? filled) {
      return NebaGroove(
        thickness: thickness,
        track: roles.soft,
        fill: roles.fill,
        rest: roles.softPress,
        fraction: filled,
        clock: filled == null ? _clock : null,
      );
    }

    // A reading that changes travels there over the fill's duration rather
    // than jumping; the length changes, never a transform.
    final Widget bar = fraction == null
        ? groove(null)
        : TweenAnimationBuilder<double>(
            tween: Tween<double>(end: fraction),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, double filled, Widget? _) => groove(filled),
          );
    final Widget? label = widget.label;

    return progressSemantics(
      value: text,
      semanticLabel: widget.semanticLabel,
      // The width it is given, and none where there is no limit to take.
      child: LimitedBox(
        maxWidth: 0,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: NebaScale.stackGap[size]!,
            children: <Widget>[
              if (label != null || widget.showValue)
                NebaProgressCaption(
                  size: size,
                  label: label,
                  value: text,
                  showValue: widget.showValue,
                ),
              bar,
            ],
          ),
        ),
      ),
    );
  }
}
