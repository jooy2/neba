/// `NebaSkeleton`, a placeholder in the shape of content that is on its way.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The shape of a [NebaSkeleton].
enum NebaSkeletonShape {
  /// A bar the height of a line of body text.
  line,

  /// A block: a picture, a card, a chart.
  rect,

  /// A disc the size of an avatar.
  circle,
}

/// A placeholder in the shape of content that is on its way: a line of text, a
/// block, an avatar.
///
/// A highlight travels across it while it waits, towards the end of the line
/// in the reading direction. A reader who asked for less motion sees it pulse
/// in place instead, slowly, because a placeholder that holds still looks like
/// an empty box that finished loading. It is silent to a screen reader unless
/// it has a [semanticLabel], which is then announced as a status.
///
/// ```dart
/// const NebaSkeleton(lines: 3)
/// ```
class NebaSkeleton extends StatefulWidget {
  /// A placeholder of [shape].
  const NebaSkeleton({
    this.shape = NebaSkeletonShape.line,
    this.lines = 1,
    this.size,
    this.color,
    this.width,
    this.height,
    this.animated = true,
    this.semanticLabel,
    super.key,
  }) : assert(lines >= 1);

  /// What the placeholder stands in for.
  final NebaSkeletonShape shape;

  /// How many lines a `line` skeleton draws, the last one shorter, as the end
  /// of a paragraph is.
  final int lines;

  /// The line height, the block height or the disc, on the size ladder.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the wash. Defaults to [NebaColor.secondary].
  final NebaColor? color;

  /// The width in logical pixels. A line and a block take the width they are
  /// given without one; a disc is square.
  final double? width;

  /// The height in logical pixels, for a block.
  final double? height;

  /// Whether the highlight travels. Off, the placeholder is a still wash.
  final bool animated;

  /// What a screen reader is told while it waits, "Loading comments". Left
  /// out, the placeholder says nothing.
  final String? semanticLabel;

  /// A line's height at each size: the body text it stands in for.
  static const Map<NebaSize, double> lineHeight = <NebaSize, double>{
    NebaSize.xs: 11,
    NebaSize.sm: 12,
    NebaSize.md: 13,
    NebaSize.lg: 15,
    NebaSize.xl: 17,
  };

  /// A block's height at each size, without a [height].
  static const Map<NebaSize, double> blockHeight = <NebaSize, double>{
    NebaSize.xs: 48,
    NebaSize.sm: 64,
    NebaSize.md: 80,
    NebaSize.lg: 112,
    NebaSize.xl: 144,
  };

  static const Map<NebaSize, double> _lineGap = <NebaSize, double>{
    NebaSize.xs: 5,
    NebaSize.sm: 6,
    NebaSize.md: 9,
    NebaSize.lg: 9,
    NebaSize.xl: 11,
  };

  static const Map<NebaSize, double> _barRadius = <NebaSize, double>{
    NebaSize.xs: 5,
    NebaSize.sm: 5,
    NebaSize.md: 6,
    NebaSize.lg: 7,
    NebaSize.xl: 8,
  };

  @override
  State<NebaSkeleton> createState() => _NebaSkeletonState();
}

class _NebaSkeletonState extends State<NebaSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this);
  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _run();
  }

  @override
  void didUpdateWidget(NebaSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animated != widget.animated) {
      _reduced = null;
      _run();
    }
  }

  void _run() {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (!widget.animated) {
      _clock.stop();
      return;
    }

    if (reduced != _reduced) {
      _reduced = reduced;
      // A sweep every 1.5 seconds, or a slower breath under reduced motion.
      _clock.repeat(period: Duration(milliseconds: reduced ? 2400 : 1500));
    }
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
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.secondary);
    final _Light light = _Light(
      clock: widget.animated ? _clock : null,
      wash: roles.softHover,
      highlight: roles.panelPress,
      pulse: _reduced ?? false,
      rtl: Directionality.of(context) == TextDirection.rtl,
    );

    Widget bar({required double fraction}) {
      return FractionallySizedBox(
        widthFactor: fraction,
        alignment: AlignmentDirectional.centerStart,
        child: _Shape(
          light: light,
          height: NebaSkeleton.lineHeight[size]!,
          radius: BorderRadius.circular(NebaSkeleton._barRadius[size]!),
        ),
      );
    }

    final Widget drawn = switch (widget.shape) {
      NebaSkeletonShape.line when widget.lines > 1 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: NebaSkeleton._lineGap[size]!,
        children: <Widget>[
          for (int i = 0; i < widget.lines; i++) bar(fraction: i == widget.lines - 1 ? 0.6 : 1),
        ],
      ),
      NebaSkeletonShape.line => _Shape(
        light: light,
        height: widget.height ?? NebaSkeleton.lineHeight[size]!,
        radius: BorderRadius.circular(NebaSkeleton._barRadius[size]!),
      ),
      NebaSkeletonShape.rect => _Shape(
        light: light,
        height: widget.height ?? NebaSkeleton.blockHeight[size]!,
        radius: BorderRadius.circular(tokens.radius[size]!),
      ),
      NebaSkeletonShape.circle => _Shape(
        light: light,
        height: widget.height ?? NebaScale.controlHeight[size]!,
        width: widget.width ?? NebaScale.controlHeight[size]!,
        radius: BorderRadius.circular(9999),
      ),
    };

    // A line or a block runs the width it is given; with no limit to take it
    // takes none, rather than asking for an infinite one.
    final double? width = widget.width;
    final Widget placed = widget.shape == NebaSkeletonShape.circle || width != null
        // A disc, and a width of its own, hold inside a wider box at its
        // start, as a block given a width does.
        ? Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: width == null ? drawn : SizedBox(width: width, child: drawn),
          )
        : LimitedBox(
            maxWidth: 0,
            child: SizedBox(width: double.infinity, child: drawn),
          );

    final String? label = widget.semanticLabel;

    return label == null
        ? ExcludeSemantics(child: placed)
        : Semantics(
            container: true,
            liveRegion: true,
            label: label,
            child: ExcludeSemantics(child: placed),
          );
  }
}

/// What every shape of one skeleton is lit with.
@immutable
class _Light {
  const _Light({
    required this.clock,
    required this.wash,
    required this.highlight,
    required this.pulse,
    required this.rtl,
  });

  /// The animation's clock, or `null` when the placeholder holds still.
  final Animation<double>? clock;
  final Color wash;
  final Color highlight;

  /// Whether the highlight breathes in place rather than travelling.
  final bool pulse;
  final bool rtl;
}

/// One bar, block or disc: the wash, and the light over it.
class _Shape extends StatelessWidget {
  const _Shape({required this.light, required this.height, required this.radius, this.width});

  final _Light light;
  final double height;
  final double? width;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _ShapePainter(light, radius)),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.light, this.radius) : super(repaint: light.clock);

  final _Light light;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = radius.toRRect(Offset.zero & size);

    canvas
      ..save()
      ..clipRRect(shape)
      ..drawRect(Offset.zero & size, Paint()..color = light.wash);

    final Animation<double>? clock = light.clock;

    if (clock != null) {
      final double t = NebaScale.ease.transform(clock.value);

      if (light.pulse) {
        // Up and back down over one period: the whole placeholder breathes.
        final double strength = t < 0.5 ? t * 2 : (1 - t) * 2;
        canvas.drawRect(
          Offset.zero & size,
          Paint()..color = light.highlight.withValues(alpha: light.highlight.a * strength),
        );
      } else {
        // A highlight 60% of the width, from one width of itself before the
        // start to the far end: a translation of the light, never of a box.
        final double reach = size.width * 0.6;
        final double travelled = -reach + (size.width + reach) * t;
        final double left = light.rtl ? size.width - travelled - reach : travelled;
        final Rect band = Rect.fromLTWH(left, 0, reach, size.height);
        final Color clear = light.highlight.withValues(alpha: 0);

        canvas.drawRect(
          band,
          Paint()
            ..shader = LinearGradient(
              colors: <Color>[clear, light.highlight, clear],
            ).createShader(band),
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.light.wash != light.wash ||
        oldDelegate.light.highlight != light.highlight ||
        oldDelegate.light.pulse != light.pulse ||
        oldDelegate.light.rtl != light.rtl ||
        oldDelegate.light.clock != light.clock;
  }
}
