/// `NebaPanes` and `NebaPane`, a box split into regions with a draggable
/// handle between each pair.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A pane's share of a split: a percentage of the room the panes share, or a
/// length in logical pixels.
///
/// A percentage is what a split is usually described in, and it keeps its
/// meaning when the split changes size. A length is what a sidebar with a
/// minimum needs: "at least 200 pixels" does not survive being written down
/// as a percentage of a width nobody knows yet.
@immutable
class NebaPaneSize {
  /// [percent] of the room the panes share once the handles are paid for:
  /// the React package's bare number, or its `'20%'`.
  const NebaPaneSize.percent(double this.percent) : pixels = null;

  /// [pixels] logical pixels: the React package's `'240px'`.
  const NebaPaneSize.pixels(double this.pixels) : percent = null;

  /// The percentage this size is, if it is one.
  final double? percent;

  /// The length this size is, if it is one.
  final double? pixels;

  /// This size in logical pixels, in a split with [extent] to share.
  double resolve(double extent) => pixels ?? extent * percent! / 100;

  @override
  bool operator ==(Object other) {
    return other is NebaPaneSize && other.percent == percent && other.pixels == pixels;
  }

  @override
  int get hashCode => Object.hash(percent, pixels);

  @override
  String toString() {
    return pixels != null ? 'NebaPaneSize.pixels($pixels)' : 'NebaPaneSize.percent($percent)';
  }
}

/// One region of a [NebaPanes].
///
/// It draws nothing of its own: a split is layout, and a pane that drew a
/// sheet could no longer hold a card, a table or an editor. Put a `NebaBox`
/// or a `NebaCard` in it when a surface is wanted.
///
/// [defaultSize], [minSize] and [maxSize] are read by the [NebaPanes] around
/// it rather than used here, because a pane cannot know what "half" is; only
/// the split can. The pane lays [child] out at its own size and clips what
/// runs past it, so content that may be longer than the pane goes in a
/// `NebaScrollArea`.
class NebaPane extends StatelessWidget {
  /// A pane holding [child].
  const NebaPane({required this.child, this.defaultSize, this.minSize, this.maxSize, super.key});

  /// The share this pane starts with. Panes without one split whatever is left
  /// over equally.
  final NebaPaneSize? defaultSize;

  /// How small it may be dragged, which is also its neighbour's ceiling. Zero
  /// when left out.
  final NebaPaneSize? minSize;

  /// How large it may be dragged. Unbounded when left out.
  final NebaPaneSize? maxSize;

  /// What is inside the pane.
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(child: child);
}

/// A box split into [NebaPane]s, with a draggable handle between each pair.
///
/// The panes are sized in fractions of the room they share, so a split keeps
/// its proportions when the box changes size. A length is turned into a
/// fraction once, when the split is first laid out, and again only when a
/// pane is added or removed.
///
/// A handle is a thin hairline in a track wider than it, grabbed across 24
/// logical pixels however thin it is drawn. A press on it claims the pointer
/// and leaves the focus where it was; from the keyboard it takes the focus and
/// moves 16 pixels with each arrow key. To a screen reader it is a slider,
/// whose value is the share of the pane before it.
///
/// A split fills the space it is given, so give it a bounded width and height.
///
/// ```dart
/// NebaPanes(
///   children: <NebaPane>[
///     NebaPane(
///       defaultSize: const NebaPaneSize.pixels(240),
///       minSize: const NebaPaneSize.pixels(160),
///       child: files,
///     ),
///     NebaPane(child: editor),
///   ],
/// )
/// ```
class NebaPanes extends StatefulWidget {
  /// A split of [children].
  const NebaPanes({
    required this.children,
    this.orientation = NebaOrientation.horizontal,
    this.resizable = true,
    this.color,
    this.size,
    this.onResize,
    this.onResizeEnd,
    this.handleLabel,
    this.handleLabelBuilder,
    this.locale,
    super.key,
  }) : assert(
         handleLabel == null || handleLabelBuilder == null,
         'Give a handleLabel or a handleLabelBuilder, not both.',
       );

  /// The panes, in order.
  final List<NebaPane> children;

  /// Which way the panes run. [NebaOrientation.horizontal] puts them side by
  /// side with upright handles between them, and lays them out from the end
  /// under a right-to-left text direction; [NebaOrientation.vertical] stacks
  /// them.
  final NebaOrientation orientation;

  /// Whether the handles can be dragged. Off, a handle is a rule between the
  /// panes that is out of the focus order: a split that is a layout rather
  /// than a control.
  final bool resizable;

  /// The family the handles light up in. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// How thick a handle's track is, 4 to 12 logical pixels. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// Called with every pane's share, in percent, on every move of a drag and
  /// on every arrow key.
  final ValueChanged<List<double>>? onResize;

  /// Called once with the same shares when a handle is let go, and on every
  /// arrow key, which is a whole gesture on its own.
  final ValueChanged<List<double>>? onResizeEnd;

  /// Names every handle. Defaults to "Resize panes" in the [locale]'s words.
  final String? handleLabel;

  /// Names each handle, handed its index from 0, for a split of more than two
  /// panes where each handle wants a name of its own.
  final String Function(int index)? handleLabelBuilder;

  /// The language of the default name. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// The track a handle is drawn in at each size, which is what the panes give
  /// up to each handle.
  static const Map<NebaSize, double> tracks = <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 6,
    NebaSize.md: 8,
    NebaSize.lg: 10,
    NebaSize.xl: 12,
  };

  /// The target a pointer has to hit to grab a handle, however thin its track.
  static const double hitTarget = 24;

  /// How far one arrow key moves a handle.
  static const double keyboardStep = 16;

  @override
  State<NebaPanes> createState() => _NebaPanesState();
}

/// What a drag or a key press needs to know about the two panes either side
/// of one handle, worked out when it starts.
///
/// A handle only ever moves the boundary between two panes, so their total is
/// fixed and one pane's floor is the other's ceiling. Folding all four bounds
/// into one range on the first of the pair keeps every move to one clamp.
class _Grip {
  const _Grip({
    required this.index,
    required this.current,
    required this.extent,
    required this.start,
    required this.pair,
    required this.lower,
    required this.upper,
  });

  final int index;
  final List<double> current;
  final double extent;
  final double start;
  final double pair;
  final double lower;
  final double upper;

  /// The split with the boundary moved [delta] pixels towards the end.
  List<double> moved(double delta) {
    final double sized = (start + delta).clamp(lower, upper);

    return <double>[...current]
      ..[index] = sized / extent
      ..[index + 1] = (pair - sized) / extent;
  }
}

/// Every pane's share of [extent], summing to 1, from their default sizes.
List<double> _initialFractions(List<NebaPaneSize?> defaults, double extent) {
  final List<double?> sizes = <double?>[
    for (final NebaPaneSize? size in defaults) size?.resolve(extent),
  ];
  final double named = sizes.fold<double>(0, (double sum, double? size) => sum + (size ?? 0));
  final int unnamed = sizes.where((double? size) => size == null).length;
  // Whatever the named panes leave, split evenly; nothing when they asked for
  // more than there is.
  final double share = unnamed > 0 ? math.max(0, extent - named) / unnamed : 0;
  final List<double> resolved = <double>[
    for (final double? size in sizes) math.max(0, size ?? share),
  ];
  final double total = resolved.fold<double>(0, (double sum, double size) => sum + size);

  if (total <= 0) {
    return <double>[for (final double _ in resolved) 1 / math.max(1, resolved.length)];
  }

  return <double>[for (final double size in resolved) size / total];
}

class _NebaPanesState extends State<NebaPanes> {
  /// The split, in fractions. `null` until a split with a length in it has
  /// been laid out.
  List<double>? _fractions;

  /// The room the panes shared at the last layout.
  double _extent = 0;

  bool _refreshScheduled = false;

  _Grip? _held;
  List<double>? _latest;

  bool get _horizontal => widget.orientation == NebaOrientation.horizontal;

  /// The split to draw: the stored one while it still has a share for every
  /// pane, or one worked out without measuring when every size is a share,
  /// which comes out as the very fractions a measurement would. Only a length
  /// has to wait for the split to know how big it is.
  List<double>? _split() {
    final List<double>? stored = _fractions;
    final List<NebaPane> panes = widget.children;

    if (stored != null && stored.length == panes.length) {
      return stored;
    }

    if (panes.every((NebaPane pane) => pane.defaultSize?.pixels == null)) {
      return _fractions = _initialFractions(<NebaPaneSize?>[
        for (final NebaPane pane in panes) pane.defaultSize,
      ], 100);
    }

    return null;
  }

  /// Hears the layout: the room there was, and the split it measured when
  /// the build had none to hand it.
  void _onLayout(double extent, List<double>? measured) {
    final bool resized = extent != _extent;

    _extent = extent;

    if (measured != null) {
      _fractions = measured;
    }

    // The handles were built before the layout, so what they tell a screen
    // reader — the share, and the share one key press away, which depends on
    // how long a pixel is — waits for one more build.
    if ((measured != null || resized) && !_refreshScheduled) {
      _refreshScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        _refreshScheduled = false;

        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  _Grip? _grip(int index) {
    final List<double>? current = _fractions;
    final double extent = _extent;

    if (!widget.resizable || current == null || index + 1 >= current.length || extent <= 0) {
      return null;
    }

    final NebaPane before = widget.children[index];
    final NebaPane after = widget.children[index + 1];
    final double start = current[index] * extent;
    final double pair = start + current[index + 1] * extent;
    final double lower = math.max(
      before.minSize?.resolve(extent) ?? 0,
      pair - (after.maxSize?.resolve(extent) ?? pair),
    );
    final double upper = math.min(
      before.maxSize?.resolve(extent) ?? pair,
      pair - (after.minSize?.resolve(extent) ?? 0),
    );

    if (upper < lower) {
      return null;
    }

    return _Grip(
      index: index,
      current: current,
      extent: extent,
      start: start,
      pair: pair,
      lower: lower,
      upper: upper,
    );
  }

  static List<double> _percents(List<double> fractions) {
    return <double>[for (final double fraction in fractions) fraction * 100];
  }

  List<double> _apply(List<double> next) {
    setState(() => _fractions = next);
    widget.onResize?.call(_percents(next));

    return next;
  }

  bool _startDrag(int index) {
    final _Grip? grip = _grip(index);

    _held = grip;
    _latest = grip?.current;

    return grip != null;
  }

  void _moveDrag(Offset travelled) {
    final _Grip? grip = _held;

    if (grip == null) {
      return;
    }

    // Positive is always towards the end, so a drag under a right-to-left
    // direction moves the boundary the way the pointer went.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double delta = _horizontal ? (rtl ? -travelled.dx : travelled.dx) : travelled.dy;

    _latest = _apply(grip.moved(delta));
  }

  void _endDrag() {
    final List<double>? latest = _latest;

    _held = null;
    _latest = null;

    if (latest != null) {
      widget.onResizeEnd?.call(_percents(latest));
    }
  }

  void _nudge(int index, double pixels) {
    final _Grip? grip = _grip(index);

    if (grip == null) {
      return;
    }

    final List<double> next = _apply(grip.moved(pixels));

    // A key press is a whole gesture on its own: there is no letting go to
    // wait for, so the settled callback goes with it.
    widget.onResizeEnd?.call(_percents(next));
  }

  /// The share, in percent, the pane before handle [index] would have after
  /// a key press of [pixels].
  double? _peek(int index, double pixels) {
    final _Grip? grip = _grip(index);

    return grip == null ? null : grip.moved(pixels)[index] * 100;
  }

  String _label(BuildContext context, int index) {
    final String Function(int index)? builder = widget.handleLabelBuilder;

    if (builder != null) {
      return builder(index);
    }

    return widget.handleLabel ?? nebaMessages(context, 'panes', locale: widget.locale)['handle']!;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final double track = NebaPanes.tracks[size]!;
    final bool resizable = widget.resizable;
    final List<NebaPane> panes = widget.children;
    final List<double>? split = _split();

    return _Split(
      fractions: split,
      panes: panes,
      horizontal: _horizontal,
      rtl: Directionality.of(context) == TextDirection.rtl,
      track: track,
      hit: resizable ? math.max(track, NebaPanes.hitTarget) : track,
      onLayout: _onLayout,
      children: <Widget>[
        ...panes,
        // The handles after the panes, so they are painted over them and hit
        // first where their target reaches past the track.
        for (int index = 0; index < panes.length - 1; index += 1)
          _Handle(
            key: _HandleKey(index),
            horizontal: _horizontal,
            resizable: resizable,
            track: track,
            roles: roles,
            rule: tokens.border,
            label: _label(context, index),
            share: split == null ? null : split[index] * 100,
            increased: split == null ? null : _peek(index, NebaPanes.keyboardStep),
            decreased: split == null ? null : _peek(index, -NebaPanes.keyboardStep),
            onStart: () => _startDrag(index),
            onMove: _moveDrag,
            onEnd: _endDrag,
            onNudge: (double pixels) => _nudge(index, pixels),
          ),
      ],
    );
  }
}

/// A handle's key among the panes: a type of its own, so it can never equal a
/// key a caller gave a pane.
class _HandleKey extends ValueKey<int> {
  const _HandleKey(super.value);
}

/// One handle: a hairline down the middle of a track, in a target that may be
/// wider than the track.
class _Handle extends StatefulWidget {
  const _Handle({
    required this.horizontal,
    required this.resizable,
    required this.track,
    required this.roles,
    required this.rule,
    required this.label,
    required this.share,
    required this.increased,
    required this.decreased,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
    required this.onNudge,
    super.key,
  });

  /// Whether the panes run side by side, which stands the handle upright.
  final bool horizontal;
  final bool resizable;
  final double track;
  final NebaColorRoles roles;

  /// The hairline's colour at rest.
  final Color rule;
  final String label;

  /// The share, in percent, of the pane before the handle.
  final double? share;
  final double? increased;
  final double? decreased;
  final bool Function() onStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onEnd;
  final ValueChanged<double> onNudge;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  late final FocusNode _focus = FocusNode(debugLabel: 'NebaPanes handle', onKeyEvent: _onKey);

  bool _hovered = false;
  bool _focusVisible = false;

  @override
  void didUpdateWidget(_Handle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.resizable) {
      _hovered = false;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Under a right-to-left direction the panes run from the right, so the
    // boundary moves towards the end on the left arrow, as a drag does.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey back = widget.horizontal
        ? (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)
        : LogicalKeyboardKey.arrowUp;
    final LogicalKeyboardKey forward = widget.horizontal
        ? (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowDown;

    if (event.logicalKey == forward) {
      widget.onNudge(NebaPanes.keyboardStep);
    } else if (event.logicalKey == back) {
      widget.onNudge(-NebaPanes.keyboardStep);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  static String? _percent(double? share) => share == null ? null : '${share.round()}%';

  void _increase() => widget.onNudge(NebaPanes.keyboardStep);

  void _decrease() => widget.onNudge(-NebaPanes.keyboardStep);

  Widget _drawn(BuildContext context, bool dragging) {
    final bool resizable = widget.resizable;
    final bool horizontal = widget.horizontal;
    final NebaColorRoles roles = widget.roles;
    // Press is instant and release is slow: the track lights on the frame of
    // the press and drains back over the fill's duration.
    final Duration duration = nebaDuration(context, NebaScale.durationFill, instant: dragging);
    final Color tint = resizable && (_hovered || dragging) ? roles.soft : const Color(0x00000000);
    final Color line = resizable && (_hovered || _focusVisible || dragging)
        ? roles.accent
        : widget.rule;

    // The track has a fixed width, so nothing either side of it moves when
    // the pointer arrives; only colours change.
    return Center(
      child: SizedBox(
        width: horizontal ? widget.track : null,
        height: horizontal ? null : widget.track,
        // Inside the edge, because the track runs the full length of the
        // panes and a pane around a nested split clips what lies past it.
        child: NebaFocusRing(
          visible: _focusVisible,
          color: roles.ring,
          offset: -focusRingWidth,
          child: AnimatedContainer(
            duration: duration,
            curve: NebaScale.ease,
            color: tint,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              width: horizontal ? 1 : null,
              height: horizontal ? null : 1,
              color: line,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool resizable = widget.resizable;
    final double? share = widget.share;

    return Semantics(
      container: true,
      slider: true,
      enabled: resizable,
      label: widget.label,
      value: _percent(share),
      increasedValue: resizable ? _percent(widget.increased) : null,
      decreasedValue: resizable ? _percent(widget.decreased) : null,
      onIncrease: resizable && widget.increased != null ? _increase : null,
      onDecrease: resizable && widget.decreased != null ? _decrease : null,
      child: FocusableActionDetector(
        focusNode: _focus,
        enabled: resizable,
        onShowFocusHighlight: (bool visible) => setState(() => _focusVisible = visible),
        child: MouseRegion(
          onEnter: resizable ? (PointerEnterEvent e) => setState(() => _hovered = true) : null,
          onExit: resizable ? (PointerExitEvent e) => setState(() => _hovered = false) : null,
          child: NebaDragRegion(
            enabled: resizable,
            cursor: widget.horizontal
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow,
            // A press leaves the focus where it was, as every Flutter control
            // does: a field being typed in beside the split keeps it, and a
            // desktop, whose focus highlight follows the focus rather than the
            // keyboard, draws no ring after a drag.
            onStart: (Offset position) => widget.onStart(),
            onMove: widget.onMove,
            onEnd: widget.onEnd,
            builder: _drawn,
          ),
        ),
      ),
    );
  }
}

class _SplitParentData extends ContainerBoxParentData<RenderBox> {}

/// The panes and then the handles, laid out along one axis: each pane at its
/// share of the room left once the handles are paid for, each handle centred
/// on its track.
class _Split extends MultiChildRenderObjectWidget {
  const _Split({
    required this.fractions,
    required this.panes,
    required this.horizontal,
    required this.rtl,
    required this.track,
    required this.hit,
    required this.onLayout,
    required super.children,
  });

  final List<double>? fractions;
  final List<NebaPane> panes;
  final bool horizontal;
  final bool rtl;
  final double track;
  final double hit;
  final void Function(double extent, List<double>? measured) onLayout;

  @override
  _RenderSplit createRenderObject(BuildContext context) {
    return _RenderSplit(
      fractions: fractions,
      defaults: <NebaPaneSize?>[for (final NebaPane pane in panes) pane.defaultSize],
      horizontal: horizontal,
      rtl: rtl,
      track: track,
      hit: hit,
      onLayout: onLayout,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSplit renderObject) {
    renderObject
      ..fractions = fractions
      ..defaults = <NebaPaneSize?>[for (final NebaPane pane in panes) pane.defaultSize]
      ..horizontal = horizontal
      ..rtl = rtl
      ..track = track
      ..hit = hit
      ..onLayout = onLayout;
  }
}

class _RenderSplit extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SplitParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SplitParentData> {
  _RenderSplit({
    required List<double>? fractions,
    required List<NebaPaneSize?> defaults,
    required bool horizontal,
    required bool rtl,
    required double track,
    required double hit,
    required this.onLayout,
  }) : _fractions = fractions,
       _defaults = defaults,
       _horizontal = horizontal,
       _rtl = rtl,
       _track = track,
       _hit = hit;

  void Function(double extent, List<double>? measured) onLayout;

  List<double>? _fractions;
  set fractions(List<double>? value) {
    if (!listEquals(_fractions, value)) {
      _fractions = value;
      markNeedsLayout();
    }
  }

  List<NebaPaneSize?> _defaults;
  set defaults(List<NebaPaneSize?> value) {
    if (!listEquals(_defaults, value)) {
      _defaults = value;
      markNeedsLayout();
    }
  }

  bool _horizontal;
  set horizontal(bool value) {
    if (_horizontal != value) {
      _horizontal = value;
      markNeedsLayout();
    }
  }

  bool _rtl;
  set rtl(bool value) {
    if (_rtl != value) {
      _rtl = value;
      markNeedsLayout();
    }
  }

  double _track;
  set track(double value) {
    if (_track != value) {
      _track = value;
      markNeedsLayout();
    }
  }

  double _hit;
  set hit(double value) {
    if (_hit != value) {
      _hit = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SplitParentData) {
      child.parentData = _SplitParentData();
    }
  }

  double get _gutter => _track * math.max(0, _defaults.length - 1);

  /// A split is as big as it is allowed to be: it divides the space it is
  /// given rather than wrapping its content.
  Size _sizeFor(BoxConstraints constraints) {
    return constraints.constrain(
      Size(
        constraints.hasBoundedWidth ? constraints.maxWidth : 0,
        constraints.hasBoundedHeight ? constraints.maxHeight : 0,
      ),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _sizeFor(constraints);

  // Nothing about the content decides the split's size, so only the handles
  // are asked for, along the axis they take room on.
  @override
  double computeMinIntrinsicWidth(double height) => _horizontal ? _gutter : 0;

  @override
  double computeMaxIntrinsicWidth(double height) => _horizontal ? _gutter : 0;

  @override
  double computeMinIntrinsicHeight(double width) => _horizontal ? 0 : _gutter;

  @override
  double computeMaxIntrinsicHeight(double width) => _horizontal ? 0 : _gutter;

  @override
  void performLayout() {
    // Reported rather than thrown, so the rest of the page still lays out and
    // the split is drawn with nothing on the unbounded axis.
    assert(() {
      if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('NebaPanes was given an unbounded width or height.'),
              ErrorDescription(
                'A split divides the space it is given, so it needs both a bounded width and '
                'a bounded height. The constraints were $constraints.',
              ),
              ErrorHint(
                'Put it in a SizedBox with a height, an Expanded, or anything else that bounds '
                'it.',
              ),
            ]),
            library: 'neba',
            context: ErrorDescription('while laying out a NebaPanes'),
          ),
        );
      }
      return true;
    }());

    size = _sizeFor(constraints);

    final int count = _defaults.length;
    final double main = _horizontal ? size.width : size.height;
    final double cross = _horizontal ? size.height : size.width;
    final double extent = math.max(0, main - _gutter);
    final List<double>? given = _fractions;
    final bool measuring = given == null || given.length != count;
    final List<double> used = measuring
        ? _initialFractions(_defaults, extent > 0 ? extent : 100)
        : given;

    // A split zero long, inside something closed, has nothing to divide yet;
    // it measures again once it has.
    onLayout(extent, measuring && extent > 0 ? used : null);

    final List<RenderBox> children = getChildrenAsList();
    double position = 0;

    void place(RenderBox child, double start, double length) {
      child.layout(
        _horizontal
            ? BoxConstraints.tightFor(width: length, height: cross)
            : BoxConstraints.tightFor(width: cross, height: length),
      );

      final double along = _horizontal && _rtl ? main - start - length : start;
      (child.parentData! as _SplitParentData).offset = _horizontal
          ? Offset(along, 0)
          : Offset(0, along);
    }

    for (int index = 0; index < children.length; index += 1) {
      if (index < count) {
        final double length = used[index] * extent;
        place(children[index], position, length);
        position += length;

        // The handle that follows this pane, centred on its track.
        final int handle = count + index;

        if (handle < children.length) {
          place(children[handle], position + _track / 2 - _hit / 2, _hit);
          position += _track;
        }
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
