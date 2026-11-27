/// `NebaTour`, a guided walk over a page that already exists, and
/// `NebaTourStep`, one stop on it.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/popover/neba_popover.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/menu.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/modal.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How far the card stands off its target: Base UI's `sideOffset`.
const double _cardOffset = 10;

/// How far the card keeps from the window's edges: Base UI's
/// `collisionPadding`.
const double _cardPadding = 12;

/// The corners of the hole cut out of the dimming around a target.
const double _holeRadius = 8;

/// How long a target takes to glide into view, as a browser's smooth scroll
/// does; a reader who asked for less motion gets the jump.
const Duration _scrollDuration = Duration(milliseconds: 400);

/// The size the buttons on the card take, one rung under the card's own.
const Map<NebaSize, NebaSize> _buttonSizes = <NebaSize, NebaSize>{
  NebaSize.xs: NebaSize.xs,
  NebaSize.sm: NebaSize.xs,
  NebaSize.md: NebaSize.sm,
  NebaSize.lg: NebaSize.sm,
  NebaSize.xl: NebaSize.md,
};

/// One stop on a [NebaTour].
@immutable
class NebaTourStep {
  /// A stop about [target], titled [title] and saying [content].
  const NebaTourStep({
    this.target,
    this.title,
    this.content,
    this.side = NebaSide.bottom,
    this.align = NebaAlign.center,
    this.padding = 6,
  }) : assert(padding >= 0);

  /// The widget this step is about, by the key it is built with: React's CSS
  /// selector. Left out, or not built, the step is centred over the window
  /// with nothing cut out of the dimming, which is what a welcome step and a
  /// closing step are.
  final GlobalKey? target;

  /// The step's heading, usually a [Text], whose words also name the card
  /// for a screen reader.
  final Widget? title;

  /// What it says.
  final Widget? content;

  /// Which edge of the target the card sits on.
  final NebaSide side;

  /// Where along that edge.
  final NebaAlign align;

  /// How far the hole in the dimming reaches past the target, in logical
  /// pixels. A control with a focus ring wants a couple; a whole panel wants
  /// none.
  final double padding;
}

/// A guided walk over a page that already exists: the three things a new
/// reader has to be shown once, pointed at where they actually are.
///
/// The steps name their targets by key rather than holding them, because
/// what a tour is about is already on the screen. Each step's card is drawn
/// in the root overlay against its target, on the frosted sheet a popover
/// draws, with the page dimmed around it and the target cut out of the
/// dimming. The dimming never takes the pointer: the control being pointed
/// at can be used while the card is up, which is the difference between a
/// tour and a sequence of dialogs. Neither a press outside the card nor the
/// focus leaving it ends the tour; Escape and the card's own buttons do.
///
/// ```dart
/// NebaTour(
///   open: open,
///   onOpenChange: (bool next) => setState(() => open = next),
///   steps: <NebaTourStep>[
///     NebaTourStep(target: searchKey, title: const Text('Find anything')),
///     NebaTourStep(target: deployKey, title: const Text('Ship it'), side: NebaSide.left),
///   ],
/// )
/// ```
class NebaTour extends StatefulWidget {
  /// A tour of [steps].
  const NebaTour({
    required this.steps,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.step,
    this.defaultStep = 0,
    this.onStepChange,
    this.onFinish,
    this.mask = true,
    this.skippable = true,
    this.dismissible = true,
    this.scrollIntoView = true,
    this.locale,
    this.previousLabel,
    this.nextLabel,
    this.doneLabel,
    this.skipLabel,
    this.closeLabel,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    super.key,
  }) : assert(defaultStep >= 0);

  /// The stops, in order.
  final List<NebaTourStep> steps;

  /// Whether the tour is running, for a controlled tour, with [onOpenChange].
  /// Leave it `null` and the tour keeps its own state, starting from
  /// [defaultOpen].
  final bool? open;

  /// Whether an uncontrolled tour starts running.
  final bool defaultOpen;

  /// Called when the tour starts or ends.
  final ValueChanged<bool>? onOpenChange;

  /// Which stop, from `0`, for a controlled tour, with [onStepChange]. Leave
  /// it `null` and the tour keeps its own, starting from [defaultStep].
  final int? step;

  /// Which stop an uncontrolled tour starts on.
  final int defaultStep;

  /// Called with the stop the card moved to.
  final ValueChanged<int>? onStepChange;

  /// Called when the last step's button is pressed, before the tour closes.
  final VoidCallback? onFinish;

  /// Whether the page is dimmed with the target cut out of the dimming. Off,
  /// the card is the only thing the tour draws.
  final bool mask;

  /// Whether the Skip button is drawn beside the counter.
  final bool skippable;

  /// Whether Escape and the × end the tour. Off, a tour is left only through
  /// its own buttons.
  final bool dismissible;

  /// Whether each target is scrolled into view as the tour reaches it.
  final bool scrollIntoView;

  /// The language the buttons and the counter are written in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The Previous button, in place of the locale's word.
  final Widget? previousLabel;

  /// The Next button.
  final Widget? nextLabel;

  /// What Next becomes on the last step.
  final Widget? doneLabel;

  /// The Skip button.
  final Widget? skipLabel;

  /// What a screen reader calls the × that ends the tour. Defaults to the
  /// locale's word.
  final String? closeLabel;

  /// The card's type, corners, padding and widest width, and its buttons'
  /// size, a rung under it. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the card's edge and of the Previous and Next buttons.
  final NebaColor color;

  /// How much padding the card has. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  @override
  State<NebaTour> createState() => _NebaTourState();
}

/// Where a target was found, tagged with the key it was found by, so a step
/// whose target has not been measured yet is never drawn around the last
/// step's.
@immutable
class _Spot {
  const _Spot(this.key, this.rect);

  final GlobalKey key;
  final Rect rect;

  @override
  bool operator ==(Object other) => other is _Spot && other.key == key && other.rect == rect;

  @override
  int get hashCode => Object.hash(key, rect);
}

class _NebaTourState extends State<NebaTour> {
  static const Object _noTarget = Object();

  late bool _open = widget.defaultOpen;
  late int _step = widget.defaultStep;

  _Spot? _spot;
  // What the last measurement looked for, found or not: a step's target, or
  // [_noTarget]. Until a step's target has been looked for after a frame
  // that could have laid it out, its card waits rather than being drawn in
  // the middle of the window for that frame.
  Object? _lookedFor;
  bool _watching = false;
  bool _listening = false;
  GlobalKey? _scrolledTo;

  bool get _running => (widget.open ?? _open) && widget.steps.isNotEmpty;

  int get _index {
    final int last = math.max(0, widget.steps.length - 1);

    return (widget.step ?? _step).clamp(0, last);
  }

  NebaTourStep? get _current => widget.steps.isEmpty ? null : widget.steps[_index];

  @override
  void initState() {
    super.initState();

    if (_running) {
      _measure(settled: false);
    }
  }

  @override
  void didUpdateWidget(NebaTour oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A step or a run a controlled owner changed: the target is read from the
    // last frame's layout, before this one is drawn.
    if (_running) {
      _measure(settled: false);
    }
  }

  @override
  void dispose() {
    _listen(false);
    super.dispose();
  }

  void _setOpen(bool next) {
    if (widget.open == null) {
      setState(() => _open = next);
    }

    widget.onOpenChange?.call(next);
  }

  void _goTo(int next) {
    if (widget.step == null) {
      setState(() {
        _step = next;
        _measure(settled: false);
      });
    }

    widget.onStepChange?.call(next);
  }

  void _finish() {
    widget.onFinish?.call();
    _setOpen(false);
  }

  // ----- Escape -------------------------------------------------------------

  void _listen(bool on) {
    if (on == _listening) {
      return;
    }

    _listening = on;

    if (on) {
      HardwareKeyboard.instance.addHandler(_onKey);
    } else {
      HardwareKeyboard.instance.removeHandler(_onKey);
    }
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        !mounted ||
        !_running ||
        !widget.dismissible) {
      return false;
    }

    _setOpen(false);

    return true;
  }

  // ----- Following the target ------------------------------------------------

  // The target's box in the overlay the card is drawn in, or `null` when the
  // step has none or it is not built.
  Rect? _targetRect(GlobalKey key) {
    final RenderObject? target = key.currentContext?.findRenderObject();
    final RenderObject? overlay = Overlay.maybeOf(
      context,
      rootOverlay: true,
    )?.context.findRenderObject();

    if (target is! RenderBox ||
        overlay is! RenderBox ||
        !target.attached ||
        !target.hasSize ||
        !overlay.attached) {
      return null;
    }

    return MatrixUtils.transformRect(target.getTransformTo(overlay), Offset.zero & target.size);
  }

  // Reads where the current target is, and says whether that changed. It is
  // called inside a frame's build before the overlay is built, so it only
  // writes fields, and the frame watcher sets state when something moved. A
  // target that is not there is only taken as missing once a frame has been
  // [settled] since: it may be built in the frame that is being built.
  bool _measure({required bool settled}) {
    final GlobalKey? key = _current?.target;
    final Rect? rect = key == null ? null : _targetRect(key);

    if (key != null && rect == null && !settled) {
      return false;
    }

    final _Spot? spot = key == null || rect == null ? null : _Spot(key, rect);
    final Object looked = key ?? _noTarget;
    final bool changed = spot != _spot || looked != _lookedFor;

    _spot = spot;
    _lookedFor = looked;

    return changed;
  }

  // After every frame that is drawn while the tour runs, whatever drew it: a
  // scroll, an image arriving, the window resized. A frame that moved nothing
  // sets nothing, and no frame is drawn for the watcher's own sake.
  void _watch() {
    if (_watching) {
      return;
    }

    _watching = true;
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration _) {
    if (!mounted || !_running) {
      _watching = false;

      return;
    }

    if (_measure(settled: true)) {
      setState(() {});
    }

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _scrollTo(GlobalKey key) {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      final BuildContext? target = key.currentContext;

      if (!mounted || !_running || target == null || !target.mounted) {
        return;
      }

      final Duration duration = nebaDuration(context, _scrollDuration);

      Scrollable.ensureVisible(target, alignment: 0.5, duration: duration, curve: NebaScale.ease);
    });
  }

  // ----- Building -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool running = _running;
    final NebaTourStep? current = _current;

    _listen(running && widget.dismissible);

    if (!running) {
      // The next run scrolls to its first target again.
      _scrolledTo = null;
    } else {
      _watch();

      final GlobalKey? target = current?.target;

      if (widget.scrollIntoView && target != null && target != _scrolledTo) {
        _scrolledTo = target;
        _scrollTo(target);
      }
    }

    if (widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final Widget? title = current?.title;

    return NebaModalLayer(
      open: running,
      onDismiss: () {},
      modal: NebaModal.off,
      // Escape is the tour's own, heard wherever the focus is; a press
      // outside the card is the page being used, and ends nothing.
      dismissible: false,
      label: nebaMenuTextOf(title),
      scrim: const NebaScrim(),
      builder: _surface,
    );
  }

  Widget _surface(BuildContext context, Animation<double> arrival) {
    final NebaTourStep? current = _current;

    if (current == null) {
      return const SizedBox.shrink();
    }

    final GlobalKey? key = current.target;
    final Rect? anchor = key != null && _spot?.key == key ? _spot!.rect : null;
    // Looked for and not found, or not about anything: the middle of the
    // window. Not looked for yet: nothing for this one frame.
    final bool waiting = key != null && _lookedFor != key;
    final NebaTokens tokens = NebaTheme.of(context);

    return FadeTransition(
      opacity: arrival,
      // Waiting, the card is laid out and not drawn, so the focus it is
      // opened with still lands in it.
      child: Opacity(
        opacity: waiting ? 0 : 1,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (widget.mask)
              IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _TourMask(color: tokens.scrim, hole: anchor?.inflate(current.padding)),
                  ),
                ),
              ),
            IgnorePointer(
              ignoring: waiting,
              child: _TourLayout(
                anchor: anchor,
                side: current.side,
                align: current.align,
                textDirection: Directionality.of(context),
                child: _card(context, current),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, NebaTourStep current) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaSize buttonSize = _buttonSizes[size]!;
    final Map<String, String> messages = nebaMessages(context, 'steps', locale: widget.locale);
    final int index = _index;
    final int total = widget.steps.length;
    final bool first = index == 0;
    final bool last = index == total - 1;
    final Widget? title = current.title;
    final Widget? content = current.content;
    final String? titleText = nebaMenuTextOf(title);
    final String position = fillNebaMessage(messages['position']!, <String, String>{
      'index': '${index + 1}',
      'total': '$total',
    });
    final double body = NebaScale.sheetBodyText[size]!;
    final double leading = NebaScale.sheetBodyLeading[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double inset = NebaBox.padding[density]![size]!;

    final Widget? header = title == null && content == null
        ? null
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: NebaScale.sheetHeaderGap[size]!,
                  children: <Widget>[
                    if (title != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: titleSize,
                          height: NebaScale.sheetTitleLeading[size]! / titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Semantics(header: true, child: title),
                      ),
                    ?content,
                  ],
                ),
              ),
              if (widget.dismissible)
                NebaSheetClose(
                  onPressed: () => _setOpen(false),
                  label:
                      widget.closeLabel ??
                      nebaMessages(context, 'action', locale: widget.locale)['close']!,
                  color: widget.color,
                ),
            ],
          );

    final Widget footer = Row(
      spacing: 8,
      children: <Widget>[
        Text(
          position,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: NebaScale.metaText[size],
            color: tokens.mutedFg,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            // Keyed, so the button that was pressed keeps its focus as the
            // others come and go around it.
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (widget.skippable && !last)
                  NebaButton(
                    key: const ValueKey<String>('skip'),
                    onPressed: () => _setOpen(false),
                    size: buttonSize,
                    variant: NebaVariant.text,
                    color: NebaColor.secondary,
                    child: widget.skipLabel ?? Text(messages['skip']!),
                  ),
                if (!first)
                  NebaButton(
                    key: const ValueKey<String>('previous'),
                    onPressed: () => _goTo(index - 1),
                    size: buttonSize,
                    variant: NebaVariant.outline,
                    color: widget.color,
                    child: widget.previousLabel ?? Text(messages['previous']!),
                  ),
                NebaButton(
                  key: const ValueKey<String>('next'),
                  onPressed: last ? _finish : () => _goTo(index + 1),
                  size: buttonSize,
                  color: widget.color,
                  child: last
                      ? (widget.doneLabel ?? Text(messages['done']!))
                      : (widget.nextLabel ?? Text(messages['next']!)),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget card = Padding(
      padding: EdgeInsets.all(inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: NebaScale.sheetSectionGap[size]!,
        children: <Widget>[
          // Next rewrites the card in place and the focus stays on Next, so
          // the new step is read out here; the first is here as the card
          // arrives and is not.
          NebaLiveRegion(
            role: SemanticsRole.status,
            child: Semantics(
              label: titleText != null
                  ? fillNebaMessage(messages['step']!, <String, String>{
                      'index': '${index + 1}',
                      'title': titleText,
                    })
                  : position,
              child: const SizedBox.shrink(),
            ),
          ),
          ?header,
          footer,
        ],
      ),
    );

    card = DefaultTextStyle.merge(
      style: TextStyle(fontSize: body, height: leading / body, color: tokens.fg),
      child: card,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      onDismiss: widget.dismissible ? () => _setOpen(false) : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: NebaPopover.maxWidths[size]!),
        child: IntrinsicWidth(
          child: NebaSheet(
            fill: tokens.panelPress,
            edge: tokens.roles(widget.color).line,
            plate: NebaPlate.glass,
            elevation: 3,
            borderRadius: BorderRadius.circular(tokens.radius[size]!),
            child: card,
          ),
        ),
      ),
    );
  }
}

/// The page dimmed with a hole the shape of the target cut out of it, drawn
/// as one shape rather than four pieces around the hole, whose seams would
/// show wherever the dimming is not opaque.
class _TourMask extends CustomPainter {
  const _TourMask({required this.color, required this.hole});

  final Color color;
  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    final Rect? hole = this.hole;

    if (hole != null) {
      path.addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(_holeRadius)));
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TourMask oldDelegate) {
    return oldDelegate.color != color || oldDelegate.hole != hole;
  }
}

/// Places the card against its target, as a popover is placed, or in the
/// middle of the window for a step with none. Anywhere but the card, the
/// pointer goes through to the page.
class _TourLayout extends SingleChildRenderObjectWidget {
  const _TourLayout({
    required this.anchor,
    required this.side,
    required this.align,
    required this.textDirection,
    required Widget super.child,
  });

  final Rect? anchor;
  final NebaSide side;
  final NebaAlign align;
  final TextDirection textDirection;

  @override
  _RenderTourLayout createRenderObject(BuildContext context) {
    return _RenderTourLayout(
      anchor: anchor,
      side: side,
      align: align,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTourLayout renderObject) {
    renderObject
      ..anchor = anchor
      ..side = side
      ..align = align
      ..textDirection = textDirection;
  }
}

class _RenderTourLayout extends RenderShiftedBox {
  _RenderTourLayout({
    required Rect? anchor,
    required NebaSide side,
    required NebaAlign align,
    required TextDirection textDirection,
  }) : _anchor = anchor,
       _side = side,
       _align = align,
       _textDirection = textDirection,
       super(null);

  Rect? _anchor;
  set anchor(Rect? value) {
    if (value != _anchor) {
      _anchor = value;
      markNeedsLayout();
    }
  }

  NebaSide _side;
  set side(NebaSide value) {
    if (value != _side) {
      _side = value;
      markNeedsLayout();
    }
  }

  NebaAlign _align;
  set align(NebaAlign value) {
    if (value != _align) {
      _align = value;
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

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    final RenderBox? child = this.child;

    if (child == null) {
      return;
    }

    child.layout(
      BoxConstraints(maxWidth: math.max(0, size.width - 2 * _cardPadding)),
      parentUsesSize: true,
    );

    final Rect? anchor = _anchor;
    final Offset at = anchor == null
        ? Offset((size.width - child.size.width) / 2, (size.height - child.size.height) / 2)
        : nebaPlaceFloating(
            anchor: anchor,
            popup: child.size,
            bounds: size,
            side: _side,
            align: _align,
            textDirection: _textDirection,
            sideOffset: _cardOffset,
            padding: _cardPadding,
          ).rect.topLeft;

    (child.parentData! as BoxParentData).offset = at;
  }
}
