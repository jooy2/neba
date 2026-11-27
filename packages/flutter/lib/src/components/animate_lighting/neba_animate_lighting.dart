/// `NebaAnimateLighting`, a light travelling around the outside of something.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A light travelling around the outside of something.
///
/// The light is behind [child] rather than on it, so what a reader sees is a
/// glow escaping from under its edges: it works on a card or a button without
/// touching how they are drawn, and the content stays exactly as legible as it
/// was. Use it to mark the one thing on a screen that is live, the row being
/// processed or the plan being recommended, alongside a word that says so.
///
/// [size] has to agree with the radius of what is inside, since the light
/// follows the wrapper's own corners. It travels at a constant rate, forever
/// unless [repeat] says, and holds where it is while it is off the screen.
/// Under reduced motion the arc stops travelling and becomes an even glow.
///
/// ```dart
/// NebaAnimateLighting(
///   child: NebaCard(title: Text('Analysing 4,281 rows'), child: Text('About a minute.')),
/// )
/// ```
class NebaAnimateLighting extends StatelessWidget {
  /// A light travelling around [child].
  const NebaAnimateLighting({
    required this.child,
    this.color = NebaColor.primary,
    this.glow,
    this.size,
    this.spread = 3,
    this.arc = 50,
    this.blur = 4,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 3000),
    this.delay = Duration.zero,
    this.repeat = double.infinity,
    this.alternate = false,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    super.key,
  });

  /// What the light travels around.
  final Widget child;

  /// Which family the light is drawn in: its accent.
  final NebaColor color;

  /// A colour of your own, when a family is not what is wanted. Overrides
  /// [color].
  final Color? glow;

  /// The radius the light follows, on the shared ladder. It has to match what
  /// is inside, or the glow cuts a corner the content has rounded off.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// How far past the content the light reaches, in logical pixels.
  final double spread;

  /// How much of the outline is lit at once, in degrees. Small is a
  /// travelling spark; large is a sweep.
  final double arc;

  /// How soft the light is, in logical pixels. At 0 it is a hard-edged
  /// wedge, which reads as a graphic rather than as light.
  final double blur;

  /// Runs the light the other way round.
  final bool reverse;

  /// How long one lap takes.
  final Duration duration;

  /// How long it waits before it starts.
  final Duration delay;

  /// How many laps it runs; `double.infinity` runs it until the widget goes,
  /// and holds it while it is off the screen.
  final num repeat;

  /// Runs every other lap the other way.
  final bool alternate;

  /// Holds the light where it is. A page whose light keeps moving needs a
  /// way to stop it; bind a pause button to this.
  final bool paused;

  /// What starts it. An endless one on [NebaAnimateTrigger.hover] runs while
  /// the pointer is on it and stops when it leaves.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that starts it over each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final Color light = glow ?? tokens.roles(color).accent;
    final NebaTiming timing = NebaTiming(
      duration: math.max(0, duration.inMicroseconds / 1000),
      delay: delay.inMicroseconds / 1000,
      repeat: math.max(0, repeat).toDouble(),
      alternate: alternate,
      reversed: reverse,
    );

    return NebaAnimateRun(
      timing: timing,
      trigger: trigger,
      play: play,
      once: once,
      threshold: threshold,
      paused: paused,
      builder: (BuildContext context, NebaRunSnapshot run) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Behind the content and past it by the spread, out of the
            // pointer's way and the semantics tree.
            Positioned(
              left: -spread,
              top: -spread,
              right: -spread,
              bottom: -spread,
              child: IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: math.max(0, blur),
                    sigmaY: math.max(0, blur),
                    tileMode: TileMode.decal,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radius[size]!),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _Beam(
                        clock: run.clock,
                        timing: timing,
                        color: light,
                        arc: arc,
                        even: run.reduced,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

/// The light inside the ring: a conic wedge from transparent to the colour
/// at [arc] degrees and back to transparent at twice that, turned by the run
/// once a lap, starting at the top and going clockwise. An [even] one is the
/// colour all round, which is what reduced motion leaves.
class _Beam extends CustomPainter {
  _Beam({
    required this.clock,
    required this.timing,
    required this.color,
    required this.arc,
    required this.even,
  }) : super(repaint: clock);

  final ValueListenable<double> clock;

  final NebaTiming timing;

  final Color color;

  final double arc;

  final bool even;

  double get turn => timing.at(clock.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    if (even) {
      canvas.drawRect(bounds, Paint()..color = color);

      return;
    }

    final double share = (arc / 360).clamp(0.0, 0.5);
    final Color clear = color.withValues(alpha: 0);
    final Shader shader = SweepGradient(
      colors: <Color>[clear, color, clear, clear],
      stops: <double>[0, share, share * 2, 1],
      // A sweep starts at three o'clock and a conic gradient at twelve.
      transform: GradientRotation(-math.pi / 2 + turn * 2 * math.pi),
    ).createShader(bounds);

    canvas.drawRect(bounds, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_Beam oldDelegate) {
    return oldDelegate.clock != clock ||
        oldDelegate.timing != timing ||
        oldDelegate.color != color ||
        oldDelegate.arc != arc ||
        oldDelegate.even != even;
  }
}
