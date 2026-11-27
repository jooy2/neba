/// The scaffold around a pointer drag, the React package's
/// `src/internal/drag.ts` in Dart.
///
/// Several widgets drag something: a Panes boundary, and later a Sidebar's
/// edge, a WindowPane by its bar or its corner, a ScrollZone's strip and a
/// DataTable's columns and rows. The arithmetic differs in every one of them
/// and stays with the widget; what is shared is the scaffold around it.
///
/// Flutter already does much of what the React scaffold does by hand. A
/// pointer that went down on a widget keeps sending that widget its moves
/// wherever it goes, which is what capturing the pointer buys a browser. A
/// gesture a widget has claimed is one no scroll view and no `SelectionArea`
/// can claim as well, which is what taking the document's text selection and
/// `touch-action: none` buy it. What is left is three decisions, made here
/// once:
///
/// - **When the gesture is claimed.** On the press, for a handle that does
///   nothing else, so a finger on it never starts a scroll; or only once the
///   pointer has travelled past the platform's slop, for a drag that starts on
///   something the reader may only have meant to press.
/// - **How far it has gone**, from the press, in the region's own pixels. An
///   event's local position is already transformed, so a drag inside a scaled
///   ancestor moves an edge as far as the hand did with nothing to divide by:
///   this is the React package's `drawnScale`, done by the framework.
/// - **How it ends.** A release and a cancel report the end. A region disposed
///   mid-drag reports nothing, because a widget that went away did not finish
///   resizing, and telling its owner it did would set state on the way out.
///
/// There is deliberately no frame coalescing, for the React package's
/// reason: a move is already delivered once per frame, and coalescing again
/// would add a frame of latency to the one gesture where latency is the whole
/// feel of it.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Draws a [NebaDragRegion], with whether a drag on it is running.
typedef NebaDragBuilder = Widget Function(BuildContext context, bool dragging);

/// A region a pointer drags.
///
/// The region takes the press over its whole box, painted or not, so a thin
/// handle can be given a target wider than what it draws.
class NebaDragRegion extends StatefulWidget {
  /// A region drawn by [builder].
  const NebaDragRegion({
    required this.builder,
    this.onStart,
    this.onMove,
    this.onEnd,
    this.enabled = true,
    this.eager = true,
    this.cursor = MouseCursor.defer,
    super.key,
  });

  /// Draws the region.
  final NebaDragBuilder builder;

  /// Called on the press, with where it landed in the region's own pixels,
  /// before the gesture is claimed. Returning false lets the pointer go, so a
  /// drag with nowhere to move takes nothing from what is around it.
  final bool Function(Offset position)? onStart;

  /// Called on every move once the gesture is claimed, with how far the
  /// pointer has travelled since the press, in the region's own pixels.
  final ValueChanged<Offset>? onMove;

  /// Called once when a claimed drag is released or cancelled, and never when
  /// the region is disposed while one is running.
  final VoidCallback? onEnd;

  /// Whether a press starts anything. A drag already running when this turns
  /// false runs to its end, as the React one does.
  final bool enabled;

  /// Whether the gesture is claimed on the press rather than once the pointer
  /// has travelled past the platform's slop.
  final bool eager;

  /// The pointer's cursor over the region while it is [enabled].
  final MouseCursor cursor;

  @override
  State<NebaDragRegion> createState() => _NebaDragRegionState();
}

class _NebaDragRegionState extends State<NebaDragRegion> {
  late final _NebaDragRecognizer _recognizer = _NebaDragRecognizer(debugOwner: this)
    ..onAccept = _handleAccept
    ..onMove = _handleMove
    ..onEnd = _handleEnd;

  bool _dragging = false;

  @override
  void dispose() {
    // Disposing the recogniser stops listening without reporting an end.
    _recognizer.dispose();
    super.dispose();
  }

  void _handleAccept() {
    setState(() => _dragging = true);
  }

  void _handleMove(Offset travelled) {
    widget.onMove?.call(travelled);
  }

  void _handleEnd() {
    setState(() => _dragging = false);
    widget.onEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    _recognizer
      ..eager = widget.eager
      ..onStart = widget.onStart
      ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: widget.enabled ? _recognizer.addPointer : null,
      child: MouseRegion(
        cursor: widget.enabled ? widget.cursor : MouseCursor.defer,
        child: widget.builder(context, _dragging),
      ),
    );
  }
}

/// One pointer at a time, claimed on the press or past the slop, reporting
/// its travel from the press.
class _NebaDragRecognizer extends OneSequenceGestureRecognizer {
  _NebaDragRecognizer({super.debugOwner});

  bool eager = true;
  bool Function(Offset position)? onStart;
  VoidCallback? onAccept;
  ValueChanged<Offset>? onMove;
  VoidCallback? onEnd;

  int? _pointer;
  Offset _origin = Offset.zero;
  bool _accepted = false;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    // The primary button only, as the React handles check `button === 0`: a
    // secondary press opens a menu, it does not drag.
    return _pointer == null && event.buttons == kPrimaryButton && super.isPointerAllowed(event);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!(onStart?.call(event.localPosition) ?? true)) {
      return;
    }

    // Tracked with the press's transform, so every later position is in the
    // same frame as the origin even if the region moves under the pointer.
    super.addAllowedPointer(event);
    _pointer = event.pointer;
    _origin = event.localPosition;

    if (eager) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }

    if (event is PointerMoveEvent) {
      final Offset travelled = event.localPosition - _origin;

      if (!_accepted && travelled.distance > computeHitSlop(event.kind, gestureSettings)) {
        resolve(GestureDisposition.accepted);
      }

      if (_accepted) {
        onMove?.call(travelled);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      final bool ended = _accepted;

      if (!ended) {
        // Never claimed, so nothing ended; the arena must not hand it over
        // after the pointer has gone.
        resolve(GestureDisposition.rejected);
      }

      stopTrackingPointer(event.pointer);

      if (ended) {
        onEnd?.call();
      }
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (pointer != _pointer || _accepted) {
      return;
    }

    _accepted = true;
    onAccept?.call();
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer == _pointer) {
      stopTrackingPointer(pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointer = null;
    _accepted = false;
  }

  @override
  String get debugDescription => 'neba drag';
}
