/// `NebaAnimateMarquee`, content scrolling steadily past, forever.
library;

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/types.dart';

/// Content scrolling steadily past, forever.
///
/// [children] are laid down [copies] times end to end, and the whole strip
/// travels exactly one copy plus [gap] a lap, so the moment the first copy has
/// left the second stands precisely where it began: no seam, no jump and no
/// frame where the strip is empty. [speed] is in pixels a second and measured
/// against the copy's own length, so four logos and forty move at the same
/// pace; the strip is measured again whenever it changes size, and keeps its
/// place when it is.
///
/// [pauseOnHover] stops it while the pointer is on it or the focus is inside
/// it, so a link on it can be followed and a reader who tabs to one finds it
/// standing still. Only the first copy is read out, reached by the keyboard
/// and pressed; the others are drawn and nothing else. Under reduced motion
/// the content is laid down once and wraps onto more lines rather than being
/// cut off.
///
/// ```dart
/// NebaAnimateMarquee(
///   speed: 45,
///   children: <Widget>[for (final String name in customers) NebaChip(child: Text(name))],
/// )
/// ```
class NebaAnimateMarquee extends StatefulWidget {
  /// [children] scrolling past at [speed].
  const NebaAnimateMarquee({
    required this.children,
    this.orientation = NebaOrientation.horizontal,
    this.reverse = false,
    this.speed = 60,
    this.gap = 32,
    this.copies = 2,
    this.pauseOnHover = true,
    this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.linear,
    this.repeat = double.infinity,
    this.alternate = false,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    super.key,
  });

  /// The things that scroll past. Each copy builds them again, so none of
  /// them may carry a `GlobalKey` or a `FocusNode` of its own: a node handed
  /// to two widgets belongs to whichever was built last, which is a copy.
  final List<Widget> children;

  /// Which way the strip runs. A vertical one needs a height to run in.
  final NebaOrientation orientation;

  /// Runs it the other way: left to right, or bottom to top.
  final bool reverse;

  /// How fast the content travels, in logical pixels per second.
  final double speed;

  /// The gap between items, and between the last item and the first of the
  /// next lap, in logical pixels.
  final double gap;

  /// How many copies of the content are laid end to end. Two is enough for
  /// anything at least as long as the strip; raise it when the content is
  /// short enough to leave a hole behind itself.
  final int copies;

  /// Stops while the pointer is on it, or while the focus is inside it. Not
  /// applied with [NebaAnimateTrigger.hover], where those two are what start
  /// it.
  final bool pauseOnHover;

  /// How long one lap takes, over the one [speed] works out.
  final Duration? duration;

  /// How long it waits before it starts.
  final Duration delay;

  /// The easing of each lap. Linear unless you insist: an eased strip slows
  /// at both ends of a loop that has no ends.
  final Curve curve;

  /// How many laps it runs; `double.infinity` runs it until the widget goes,
  /// and holds it while it is off the screen.
  final num repeat;

  /// Runs every other lap the other way.
  final bool alternate;

  /// Holds it where it is. A strip that keeps moving needs a way to stop it
  /// on a screen with no pointer to rest on it; bind a pause button to this.
  final bool paused;

  /// What starts it.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that starts it over each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  @override
  State<NebaAnimateMarquee> createState() => _NebaAnimateMarqueeState();
}

class _NebaAnimateMarqueeState extends State<NebaAnimateMarquee> {
  /// How long one copy is along the strip, once it has been laid out.
  double? _length;
  bool _hovered = false;
  bool _focused = false;

  bool get _vertical => widget.orientation == NebaOrientation.vertical;

  /// Takes the copy's length after the frame it was laid out in.
  void _measured(Size size) {
    final double length = _vertical ? size.height : size.width;

    if (length == _length) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted && length != _length) {
        setState(() => _length = length);
      }
    });
  }

  Widget _track(int index) {
    final Widget track = Flex(
      direction: _vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      spacing: widget.gap,
      children: widget.children,
    );

    if (index == 0) {
      return _Measure(onSize: _measured, child: track);
    }

    // A copy is drawn and nothing else: a screen reader would read the strip
    // as many times as it was laid down, and the keyboard would stop at each
    // link in it as many times.
    return ExcludeSemantics(
      child: ExcludeFocus(child: IgnorePointer(child: track)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = widget.children;

    if (nebaReducedMotion(context)) {
      // A strip that cannot move is a row of content, so it is laid down
      // once and wraps.
      return _vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: widget.gap,
              children: children,
            )
          : Wrap(
              spacing: widget.gap,
              runSpacing: widget.gap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            );
    }

    final double? length = _length;
    final double travel = (length ?? 0) + widget.gap;
    final Duration? duration = widget.duration;
    final double lap = duration != null
        ? duration.inMicroseconds / 1000
        : length != null && widget.speed > 0
        ? (travel / widget.speed * 1000).roundToDouble()
        : 12000;
    final bool hoverStops = widget.pauseOnHover && widget.trigger != NebaAnimateTrigger.hover;
    final NebaTiming timing = NebaTiming(
      duration: math.max(0, lap),
      delay: widget.delay.inMicroseconds / 1000,
      repeat: math.max(0, widget.repeat).toDouble(),
      alternate: widget.alternate,
      reversed: widget.reverse,
    );
    final int copies = math.max(1, widget.copies);

    Widget strip = NebaAnimateRun(
      timing: timing,
      curve: widget.curve,
      trigger: widget.trigger,
      play: widget.play,
      once: widget.once,
      threshold: widget.threshold,
      // Held on its first frame until the copy has been measured, so it
      // never runs at a guessed speed; and under the pointer or the focus.
      paused: widget.paused || length == null || (hoverStops && (_hovered || _focused)),
      keepsPlace: true,
      builder: (BuildContext context, NebaRunSnapshot run) {
        return _Strip(
          vertical: _vertical,
          textDirection: Directionality.of(context),
          child: ValueListenableBuilder<double>(
            valueListenable: run.clock,
            child: Flex(
              direction: _vertical ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: _vertical
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              spacing: widget.gap,
              children: <Widget>[for (int index = 0; index < copies; index++) _track(index)],
            ),
            builder: (BuildContext context, double elapsed, Widget? child) {
              final double shift = -widget.curve.transform(timing.at(elapsed)) * travel;
              final bool rtl = !_vertical && Directionality.of(context) == TextDirection.rtl;

              return Transform.translate(
                offset: _vertical ? Offset(0, shift) : Offset(rtl ? -shift : shift, 0),
                child: child,
              );
            },
          ),
        );
      },
    );

    if (hoverStops) {
      strip = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        child: MouseRegion(
          opaque: false,
          onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
          onExit: (PointerExitEvent event) => setState(() => _hovered = false),
          child: strip,
        ),
      );
    }

    return strip;
  }
}

/// Reports the size its child is laid out at, every time it changes.
class _Measure extends SingleChildRenderObjectWidget {
  const _Measure({required this.onSize, required super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasure(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasure renderObject) {
    renderObject.onSize = onSize;
  }
}

class _RenderMeasure extends RenderProxyBox {
  _RenderMeasure(this.onSize);

  ValueChanged<Size> onSize;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();

    if (size != _last) {
      _last = size;
      onSize(size);
    }
  }
}

/// The box the strip runs in: as long as the room it is given, or its
/// content's length when the room is unbounded, and as thick as its content,
/// with the content laid out at its own length and clipped to the box.
class _Strip extends SingleChildRenderObjectWidget {
  const _Strip({required this.vertical, required this.textDirection, required super.child});

  final bool vertical;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStrip(vertical: vertical, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderStrip renderObject) {
    renderObject
      ..vertical = vertical
      ..textDirection = textDirection;
  }
}

class _RenderStrip extends RenderShiftedBox {
  _RenderStrip({required bool vertical, required TextDirection textDirection})
    : _vertical = vertical,
      _textDirection = textDirection,
      super(null);

  bool _vertical;

  set vertical(bool value) {
    if (value != _vertical) {
      _vertical = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  /// The constraints the content is laid out under: free along the strip,
  /// and the box's own across it.
  BoxConstraints _inner(BoxConstraints constraints) {
    return _vertical
        ? BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth)
        : BoxConstraints(minHeight: constraints.minHeight, maxHeight: constraints.maxHeight);
  }

  Size _sizeFor(BoxConstraints constraints, Size content) {
    return constraints.constrain(
      _vertical
          ? Size(
              content.width,
              constraints.hasBoundedHeight ? constraints.maxHeight : content.height,
            )
          : Size(
              constraints.hasBoundedWidth ? constraints.maxWidth : content.width,
              content.height,
            ),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;

    if (child == null) {
      return constraints.smallest;
    }

    return _sizeFor(constraints, child.getDryLayout(_inner(constraints)));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;

    if (child == null) {
      size = constraints.smallest;

      return;
    }

    child.layout(_inner(constraints), parentUsesSize: true);
    size = _sizeFor(constraints, child.size);
    // A strip that reads from the right starts at the right edge.
    (child.parentData! as BoxParentData).offset = !_vertical && _textDirection == TextDirection.rtl
        ? Offset(size.width - child.size.width, 0)
        : Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;

    if (child == null) {
      return;
    }

    _clip.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (PaintingContext context, Offset offset) => context.paintChild(child, offset),
      oldLayer: _clip.layer,
    );
  }

  final LayerHandle<ClipRectLayer> _clip = LayerHandle<ClipRectLayer>();

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => Offset.zero & size;

  @override
  void dispose() {
    _clip.layer = null;
    super.dispose();
  }
}
