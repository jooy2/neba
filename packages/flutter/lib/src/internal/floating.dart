/// A surface anchored to a trigger: where it goes, how it arrives and leaves,
/// and what opens and closes it.
///
/// The React package gets all of this from Base UI's positioner, which is
/// floating-ui underneath: the placement on a `side` and an `align`, the flip
/// to the other side and the shift along the edge that keep a popup on the
/// screen, the wedge, the portal, Escape, the press outside, the focus moved
/// in and given back. [NebaFloating] is that, once, for every popup that hangs
/// off something: Popover, Tooltip and HoverCard now, and Select, Combobox,
/// Menu, the date pickers, Popconfirm and InlineCitation when they arrive.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How far a popup keeps from the overlay's edges: Base UI's
/// `collisionPadding`.
const double nebaCollisionPadding = 5;

/// How far the wedge keeps from the popup's corners: Base UI's
/// `arrowPadding`.
const double nebaArrowPadding = 5;

/// Why a floating surface asks to open or to close.
enum NebaFloatingReason {
  /// The trigger was pressed.
  triggerPress,

  /// The pointer rested on the trigger, or left both it and the popup.
  triggerHover,

  /// The trigger took the keyboard focus, or lost it.
  triggerFocus,

  /// Escape, while this was the open surface on top.
  escape,

  /// A press that landed outside the trigger and the popup.
  outsidePress,

  /// The focus left the popup for something outside it.
  focusOut,

  /// Something inside the popup closed it: its close button.
  closePress,

  /// Another surface took its place, as the next tooltip in a group does.
  replaced,
}

/// The wedge a popup points at its trigger with.
@immutable
class NebaFloatingArrow {
  /// A wedge [size] wide and half as tall, filled with [fill].
  const NebaFloatingArrow({required this.size, required this.fill, this.edge, this.border = 0});

  /// The wedge's width along the popup's edge. It is half as tall.
  final double size;

  /// The wedge's colour: the popup's own.
  final Color fill;

  /// A 1-pixel line along the wedge's two slanted sides, for a popup whose
  /// edge is a hairline.
  final Color? edge;

  /// The width of the popup's border. The stylesheet places the wedge
  /// against the popup's padding box, which a border moves in by this much.
  final double border;

  @override
  bool operator ==(Object other) {
    return other is NebaFloatingArrow &&
        other.size == size &&
        other.fill == fill &&
        other.edge == edge &&
        other.border == border;
  }

  @override
  int get hashCode => Object.hash(size, fill, edge, border);
}

/// Where a popup ended up.
@immutable
class NebaFloatingPlacement {
  /// A popup at [rect], on [side] of its anchor.
  const NebaFloatingPlacement({required this.rect, required this.side, this.arrow});

  /// The popup, in the overlay's coordinates.
  final Rect rect;

  /// The side it is on, which is the asked-for side unless it flipped.
  final NebaSide side;

  /// The wedge's two base corners and its tip between them, in the popup's
  /// own coordinates, when it draws one.
  final List<Offset>? arrow;
}

bool _alongX(NebaSide side) => side == NebaSide.top || side == NebaSide.bottom;

NebaSide _opposite(NebaSide side) {
  return switch (side) {
    NebaSide.top => NebaSide.bottom,
    NebaSide.bottom => NebaSide.top,
    NebaSide.left => NebaSide.right,
    NebaSide.right => NebaSide.left,
  };
}

NebaAlign _oppositeAlign(NebaAlign align) {
  return switch (align) {
    NebaAlign.start => NebaAlign.end,
    NebaAlign.end => NebaAlign.start,
    NebaAlign.center => NebaAlign.center,
  };
}

/// Places a [popup]-sized box against [anchor] inside [bounds], as Base UI's
/// positioner does with the defaults every Neba popup uses.
///
/// The box goes on [side] of the anchor, [sideOffset] away, and at [align]
/// along that edge, moved [alignOffset] inwards from it; `start` and `end`
/// follow [textDirection] on a top or a bottom edge. Then, in floating-ui's
/// order: an aligned box tries its other alignment, then the opposite side,
/// then the two sides across, and takes the first that fits [padding] inside
/// [bounds], or the one that spills least; and it slides along its edge to
/// stay on the screen, but never so far that it stops facing the anchor. A
/// centred box slides before it flips, so it only flips for want of room on
/// its own side.
///
/// With an [arrow] the slide stops a wedge's half-width plus [padding] short
/// of the anchor's far corner, and the wedge is placed where the stylesheet
/// puts it: against the facing edge of the popup's padding box, a pixel
/// outward, turned to point at the anchor, and over the anchor's centre as
/// far as [nebaArrowPadding] from the corners allows.
NebaFloatingPlacement nebaPlaceFloating({
  required Rect anchor,
  required Size popup,
  required Size bounds,
  NebaSide side = NebaSide.bottom,
  NebaAlign align = NebaAlign.center,
  TextDirection textDirection = TextDirection.ltr,
  double sideOffset = 0,
  double alignOffset = 0,
  double padding = nebaCollisionPadding,
  NebaFloatingArrow? arrow,
}) {
  final bool rtl = textDirection == TextDirection.rtl;

  Rect raw(NebaSide s, NebaAlign a) {
    final bool alongX = _alongX(s);
    double x = anchor.center.dx - popup.width / 2;
    double y = anchor.center.dy - popup.height / 2;

    switch (s) {
      case NebaSide.top:
        y = anchor.top - popup.height;
      case NebaSide.bottom:
        y = anchor.bottom;
      case NebaSide.left:
        x = anchor.left - popup.width;
      case NebaSide.right:
        x = anchor.right;
    }

    // `start` is the inline start on a top or a bottom edge, so it flips in
    // a right-to-left layout; on a side edge it is the top.
    final double inline = alongX && rtl ? -1 : 1;

    if (alongX) {
      final double common = anchor.width / 2 - popup.width / 2;

      if (a == NebaAlign.start) {
        x -= common * inline;
      } else if (a == NebaAlign.end) {
        x += common * inline;
      }
    } else {
      final double common = anchor.height / 2 - popup.height / 2;

      if (a == NebaAlign.start) {
        y -= common;
      } else if (a == NebaAlign.end) {
        y += common;
      }
    }

    final double main = s == NebaSide.top || s == NebaSide.left ? -sideOffset : sideOffset;
    final double cross = (a == NebaAlign.end ? -alignOffset : alignOffset) * inline;

    return alongX
        ? Rect.fromLTWH(x + cross, y + main, popup.width, popup.height)
        : Rect.fromLTWH(x + main, y + cross, popup.width, popup.height);
  }

  // `limitShift`, which checks the low end first and so settles on the high
  // one when an anchor is too short for both.
  double hold(double value, double low, double high) {
    if (value < low) {
      return low;
    }

    return value > high ? high : value;
  }

  // floating-ui's `shift` with `limitShift`: along the edge only, clamped to
  // the padding, and held to the anchor so that the popup still faces it.
  Rect shift(Rect rect, NebaSide s) {
    final double held = arrow == null ? 0 : arrow.size / 2 + padding;

    if (_alongX(s)) {
      double x = math.max(padding, math.min(rect.left, bounds.width - padding - rect.width));
      x = hold(x, anchor.left - rect.width + held, anchor.right - held);

      return Rect.fromLTWH(x, rect.top, rect.width, rect.height);
    }

    double y = math.max(padding, math.min(rect.top, bounds.height - padding - rect.height));
    y = hold(y, anchor.top - rect.height + held, anchor.bottom - held);

    return Rect.fromLTWH(rect.left, y, rect.width, rect.height);
  }

  // `flip` measures against the padding and a pixel more, and a pixel more
  // again on the side opposite the asked-for one, which biases a tie towards
  // the side that was asked for.
  final double top = padding + 1 + (side == NebaSide.bottom ? 1 : 0);
  final double bottom = padding + 1 + (side == NebaSide.top ? 1 : 0);
  final double left = padding + 1 + (side == NebaSide.right ? 1 : 0);
  final double right = padding + 1 + (side == NebaSide.left ? 1 : 0);

  double spill(Rect rect, NebaSide s) {
    return switch (s) {
      NebaSide.top => top - rect.top,
      NebaSide.bottom => rect.bottom - (bounds.height - bottom),
      NebaSide.left => left - rect.left,
      NebaSide.right => rect.right - (bounds.width - right),
    };
  }

  // floating-ui's `getAlignmentSides`: the edge an aligned box grows towards
  // first, turned round when the anchor is the longer of the two.
  (NebaSide, NebaSide) alignmentSides(NebaSide s, NebaAlign a) {
    NebaSide first;

    if (_alongX(s)) {
      first = a == (rtl ? NebaAlign.end : NebaAlign.start) ? NebaSide.right : NebaSide.left;

      if (anchor.width > popup.width) {
        first = _opposite(first);
      }
    } else {
      first = a == NebaAlign.start ? NebaSide.bottom : NebaSide.top;

      if (anchor.height > popup.height) {
        first = _opposite(first);
      }
    }

    return (first, _opposite(first));
  }

  // The order floating-ui's `flip` tries placements in, with Base UI's
  // `fallbackAxisSideDirection: 'end'`.
  final List<(NebaSide, NebaAlign)> placements = <(NebaSide, NebaAlign)>[(side, align)];
  final NebaSide across = _opposite(side);

  if (align != NebaAlign.center) {
    placements.add((side, _oppositeAlign(align)));
  }

  placements.add((across, align));

  if (align != NebaAlign.center) {
    placements.add((across, _oppositeAlign(align)));
  }

  final List<NebaSide> sideways = _alongX(side)
      ? (rtl
            ? <NebaSide>[NebaSide.left, NebaSide.right]
            : <NebaSide>[NebaSide.right, NebaSide.left])
      : <NebaSide>[NebaSide.bottom, NebaSide.top];

  for (final NebaSide s in sideways) {
    placements.add((s, align));
  }

  if (align != NebaAlign.center) {
    for (final NebaSide s in sideways) {
      placements.add((s, _oppositeAlign(align)));
    }
  }

  final List<({(NebaSide, NebaAlign) placement, List<double> spills})> tried =
      <({(NebaSide, NebaAlign) placement, List<double> spills})>[];
  (NebaSide, NebaAlign)? chosen;

  for (int i = 0; i < placements.length; i++) {
    final (NebaSide s, NebaAlign a) = placements[i];
    Rect rect = raw(s, a);

    if (a == NebaAlign.center) {
      rect = shift(rect, s);
    }

    final (NebaSide first, NebaSide second) = alignmentSides(s, a);
    final List<double> spills = <double>[spill(rect, s), spill(rect, first), spill(rect, second)];
    tried.add((placement: (s, a), spills: spills));

    if (spills.every((double value) => value <= 0)) {
      chosen = (s, a);
      break;
    }

    if (i + 1 < placements.length) {
      // A placement across the axis is only tried once every one along it
      // has run out of room on its own side; spilling past a corner is not
      // reason enough to turn a popup sideways.
      final bool nextAcross = _alongX(placements[i + 1].$1) != _alongX(side);
      final bool allOut = tried.every(
        (({(NebaSide, NebaAlign) placement, List<double> spills}) t) =>
            _alongX(t.placement.$1) != _alongX(side) || t.spills.first > 0,
      );

      if (!nextAcross || allOut) {
        continue;
      }
    }

    break;
  }

  if (chosen == null) {
    final List<({(NebaSide, NebaAlign) placement, List<double> spills})> fitting =
        tried.where((t) => t.spills.first <= 0).toList()
          ..sort((a, b) => a.spills[1].compareTo(b.spills[1]));

    if (fitting.isNotEmpty) {
      chosen = fitting.first.placement;
    } else {
      double total(List<double> spills) =>
          spills.where((double value) => value > 0).fold(0, (double sum, double v) => sum + v);
      final List<({(NebaSide, NebaAlign) placement, List<double> spills})> best =
          tried
              .where((t) => _alongX(t.placement.$1) == _alongX(side) || _alongX(t.placement.$1))
              .toList()
            ..sort((a, b) => total(a.spills).compareTo(total(b.spills)));
      chosen = best.isEmpty ? (side, align) : best.first.placement;
    }
  }

  final (NebaSide finalSide, NebaAlign finalAlign) = chosen;
  Rect rect = shift(raw(finalSide, finalAlign), finalSide);

  if (arrow == null) {
    return NebaFloatingPlacement(rect: rect, side: finalSide);
  }

  // floating-ui's `arrow`, measured as the browser measures the wedge: by
  // its box before it is turned, so a wedge on a side edge counts as its
  // height along that edge, not its width.
  final bool alongX = _alongX(finalSide);
  final double width = arrow.size;
  final double height = arrow.size / 2;
  final double length = alongX ? width : height;
  final double border = arrow.border;
  final double client = (alongX ? rect.width : rect.height) - 2 * border;
  final double anchorCentre = alongX ? anchor.center.dx : anchor.center.dy;
  final double popupCentre = alongX ? rect.center.dx : rect.center.dy;
  final double largest = client / 2 - length / 2 - 1;
  final double edgeRoom = math.min(nebaArrowPadding, largest);
  final double low = edgeRoom;
  final double high = client - length - edgeRoom;
  final double centre = client / 2 - length / 2 + (anchorCentre - popupCentre);
  final double along = math.max(low, math.min(centre, high));

  // An aligned popup on an anchor too small for the wedge to reach moves
  // over until it can.
  if (finalAlign != NebaAlign.center &&
      centre != along &&
      (alongX ? anchor.width : anchor.height) / 2 - edgeRoom - length / 2 < 0) {
    final double nudge = centre < low ? centre - low : centre - high;
    rect = rect.translate(alongX ? nudge : 0, alongX ? 0 : nudge);
  }

  // The wedge's box against the facing edge of the padding box, a pixel
  // outward (`bottom: -1px` and the rest), then turned about its centre.
  final double inner = (alongX ? rect.height : rect.width) - 2 * border;
  final Rect box = switch (finalSide) {
    NebaSide.top => Rect.fromLTWH(border + along, border + inner + 1 - height, width, height),
    NebaSide.bottom => Rect.fromLTWH(border + along, border - 1, width, height),
    NebaSide.left => Rect.fromLTWH(border + inner + 1 - width, border + along, width, height),
    NebaSide.right => Rect.fromLTWH(border - 1, border + along, width, height),
  };
  final double turn = switch (finalSide) {
    NebaSide.top => 0,
    NebaSide.bottom => math.pi,
    NebaSide.left => -math.pi / 2,
    NebaSide.right => math.pi / 2,
  };
  final Offset pivot = box.center;

  Offset turned(Offset point) {
    final Offset d = point - pivot;

    return pivot +
        Offset(
          d.dx * math.cos(turn) - d.dy * math.sin(turn),
          d.dx * math.sin(turn) + d.dy * math.cos(turn),
        );
  }

  return NebaFloatingPlacement(
    rect: rect,
    side: finalSide,
    arrow: <Offset>[
      turned(box.topLeft),
      turned(Offset(box.center.dx, box.bottom)),
      turned(box.topRight),
    ],
  );
}

/// When the pointer resting on a trigger opens its surface, and how long the
/// surface stays once it has left.
@immutable
class NebaFloatingHover {
  /// Opens [delay] after the pointer arrives and closes [closeDelay] after it
  /// has left both the trigger and the popup.
  const NebaFloatingHover({
    required this.delay,
    this.closeDelay = Duration.zero,
    this.rest = false,
  });

  /// How long the pointer stays before the surface opens, read when it
  /// arrives, so a group of tooltips can shorten it for the next one.
  final ValueGetter<Duration> delay;

  /// How long the surface stays after the pointer has left.
  final Duration closeDelay;

  /// Whether every movement over the trigger starts the wait again, so the
  /// surface opens once the pointer comes to rest rather than once it
  /// arrives: Base UI's `restMs`, which a tooltip uses.
  final bool rest;
}

/// A surface drawn in the root overlay against [child], its trigger.
///
/// [open] is the caller's; this widget only asks to change it, through
/// [onOpenChange], and the caller decides. While [open] is true, [popup] is
/// placed against the trigger by [nebaPlaceFloating], faded in over
/// `NebaScale.duration`, and closed by Escape and by a press outside the
/// trigger and the popup; a surface opened from inside another one's popup
/// counts as inside it. It never slides or scales: a floating surface
/// arrives in opacity only.
///
/// The popup is laid out no wider than the overlay less [nebaCollisionPadding]
/// on each side, and as tall as it needs; it starts from the text style a
/// portal would, the app's family at the body weight, not that of the
/// paragraph its trigger is in.
///
/// It is drawn through an [OverlayPortal] into the root [Overlay], so a tree
/// with no overlay above it fails the moment it opens rather than drawing
/// nothing.
class NebaFloating extends StatefulWidget {
  /// A surface showing [popup] against [child] while [open].
  const NebaFloating({
    required this.open,
    required this.onOpenChange,
    required this.popup,
    required this.child,
    this.side = NebaSide.bottom,
    this.align = NebaAlign.center,
    this.sideOffset = 0,
    this.alignOffset = 0,
    this.arrow,
    this.openOnPress = false,
    this.hover,
    this.focusDelay,
    this.closeOnTriggerPress = false,
    this.moveFocus = false,
    this.modal = NebaModal.off,
    this.intentionalOutsidePress = false,
    this.instant = false,
    this.enabled = true,
    super.key,
  });

  /// Whether the surface is shown.
  final bool open;

  /// Asks for [open] to change, and says why.
  final void Function(bool open, NebaFloatingReason reason) onOpenChange;

  /// What is drawn against the trigger.
  final Widget popup;

  /// The trigger.
  final Widget child;

  /// Which edge of the trigger the popup goes on.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// How far it stands off the trigger, in logical pixels.
  final double sideOffset;

  /// How far it moves along the edge, inwards from where [align] puts it.
  final double alignOffset;

  /// The wedge pointing at the trigger, if one is drawn.
  final NebaFloatingArrow? arrow;

  /// Whether pressing the control in [child] opens the surface, and closes
  /// it again. The control has to be a Neba one: it hears the press through
  /// [NebaPressTrigger].
  final bool openOnPress;

  /// Whether the pointer resting on the trigger opens the surface, and how.
  /// A mouse or a stylus only: a finger never hovers. The pointer can cross
  /// from the trigger into the popup without closing it.
  final NebaFloatingHover? hover;

  /// How long after the trigger takes the keyboard focus the surface opens,
  /// or `null` when the focus does not open it. A focus that a pointer press
  /// gave the trigger never does, as `:focus-visible` would not show it.
  final Duration? focusDelay;

  /// Whether a press on the trigger closes the surface and keeps it closed
  /// until the pointer has left: a tooltip's.
  final bool closeOnTriggerPress;

  /// Whether the focus goes into the popup when it opens, comes back to the
  /// trigger when it closes, and closes it when it leaves for something
  /// else: a popover's.
  final bool moveFocus;

  /// How much of the page behind is taken away while the surface is open.
  /// Anything but [NebaModal.off] keeps Tab inside the popup; [NebaModal.on]
  /// also lays a barrier over the page that takes every pointer.
  final NebaModal modal;

  /// Whether a mouse closes the surface on a whole click outside it rather
  /// than on the press going down. A finger always closes it on a tap, and
  /// never on a drag that scrolls.
  final bool intentionalOutsidePress;

  /// Whether the next change of [open] lands at once rather than fading.
  final bool instant;

  /// Whether hovering, focusing or pressing the trigger opens the surface.
  final bool enabled;

  @override
  State<NebaFloating> createState() => _NebaFloatingState();
}

class _NebaFloatingState extends State<NebaFloating> with SingleTickerProviderStateMixin {
  // The surfaces open right now, oldest first. Escape closes the last.
  static final List<_NebaFloatingState> _layers = <_NebaFloatingState>[];

  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _triggerKey = GlobalKey();
  final GlobalKey _popupKey = GlobalKey();
  final FocusNode _triggerFocus = FocusNode(
    debugLabel: 'NebaFloating trigger',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final FocusScopeNode _popupScope = FocusScopeNode(debugLabel: 'NebaFloating popup');
  late final AnimationController _fade = AnimationController(vsync: this);
  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: _fade,
    curve: NebaScale.ease,
    // A CSS transition runs the same curve whichever way it goes.
    reverseCurve: NebaScale.ease.flipped,
  );

  final Set<_NebaFloatingState> _children = <_NebaFloatingState>{};
  _NebaFloatingState? _parent;
  _NebaFloatingState? _scopeParent;

  Timer? _openTimer;
  Timer? _closeTimer;
  bool _overTrigger = false;
  bool _overPopup = false;
  // Whether the pointer has been on the trigger or the popup since it
  // opened: only then does its leaving close it.
  bool _hovered = false;
  bool _holdClosed = false;
  bool _routing = false;
  bool _layered = false;
  NebaFloatingReason? _openedBy;
  FocusNode? _returnTo;
  final Map<int, ({Offset at, bool outside, bool moved})> _presses =
      <int, ({Offset at, bool outside, bool moved})>{};

  @override
  void initState() {
    super.initState();
    _fade.addStatusListener(_onFadeStatus);
    _popupScope.addListener(_onPopupFocus);

    if (widget.open) {
      // Already open when it arrives: no fade in, as Base UI skips the
      // transition on mount.
      _fade.value = 1;
      // Before the first build the controller only takes note.
      _portal.show();
      _attach();

      if (widget.moveFocus) {
        SchedulerBinding.instance.addPostFrameCallback((Duration _) => _focusPopup());
      }
    }
  }

  @override
  void didUpdateWidget(NebaFloating oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open) {
      widget.open ? _opened() : _closed();
    }

    if (!widget.enabled && oldWidget.enabled) {
      _cancelTimers();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _detach();
    _fade.removeStatusListener(_onFadeStatus);
    _opacity.dispose();
    _fade.dispose();
    _popupScope.removeListener(_onPopupFocus);
    _popupScope.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  // ----- Opening and closing ------------------------------------------------

  void _opened() {
    _cancelTimers();
    _hovered = _overTrigger || _overPopup;
    _syncPortal();
    _attach();

    if (widget.instant || _duration == Duration.zero) {
      _fade.value = 1;
    } else {
      _fade.forward();
    }

    if (widget.moveFocus) {
      _returnTo = _triggerTarget();
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => _focusPopup());
    }
  }

  void _closed() {
    _cancelTimers();
    _detach();
    _hovered = false;

    if (widget.moveFocus) {
      _giveFocusBack();
    }

    _openedBy = null;

    if (widget.instant || _duration == Duration.zero) {
      _fade.value = 0;
    } else {
      _fade.reverse();
    }
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.open && mounted) {
      _syncPortal();
    }
  }

  // The overlay child comes and goes outside a build, which is the one time
  // the controller refuses to: an `open` that changed arrives in one, so it
  // is applied once the frame is drawn, a frame later.
  void _syncPortal() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => _applyPortal());
    } else {
      _applyPortal();
    }
  }

  void _applyPortal() {
    if (!mounted) {
      return;
    }

    if (widget.open) {
      // Shown again to come to the top, over anything opened since.
      _portal.show();
    } else if (_fade.isDismissed && _portal.isShowing) {
      _portal.hide();
    }
  }

  Duration get _duration => nebaDuration(context, NebaScale.duration);

  void _request(bool open, NebaFloatingReason reason) {
    if (!mounted || open == widget.open) {
      return;
    }

    if (open) {
      _openedBy = reason;
    }

    widget.onOpenChange(open, reason);
  }

  void _attach() {
    if (!_layered) {
      _layered = true;

      if (_layers.isEmpty) {
        HardwareKeyboard.instance.addHandler(_onKey);
      }

      _layers.add(this);
    }

    if (!_routing) {
      _routing = true;
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    }

    _parent = _scopeParent;
    _parent?._children.add(this);
  }

  void _detach() {
    if (_layered) {
      _layered = false;
      _layers.remove(this);

      if (_layers.isEmpty) {
        HardwareKeyboard.instance.removeHandler(_onKey);
      }
    }

    if (_routing) {
      _routing = false;
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    }

    _presses.clear();
    _parent?._children.remove(this);
    _parent = null;
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  // ----- Escape and the press outside ---------------------------------------

  static bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape) {
      return false;
    }

    if (_layers.isEmpty) {
      return false;
    }

    _layers.last._request(false, NebaFloatingReason.escape);

    return true;
  }

  Rect? _globalRect(GlobalKey key) {
    final RenderObject? box = key.currentContext?.findRenderObject();

    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return null;
    }

    return MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
  }

  bool _contains(Offset position) {
    final Rect? trigger = _globalRect(_triggerKey);
    final Rect? popup = _globalRect(_popupKey);

    if ((trigger?.contains(position) ?? false) || (popup?.contains(position) ?? false)) {
      return true;
    }

    return _children.any((_NebaFloatingState child) => child._containsPopup(position));
  }

  bool _containsPopup(Offset position) {
    final Rect? popup = _globalRect(_popupKey);

    if (popup?.contains(position) ?? false) {
      return true;
    }

    return _children.any((_NebaFloatingState child) => child._containsPopup(position));
  }

  void _onPointer(PointerEvent event) {
    if (!widget.open) {
      return;
    }

    if (event is PointerHoverEvent) {
      _followHover(event.position);

      return;
    }

    final bool finger = event.kind == PointerDeviceKind.touch;

    if (event is PointerDownEvent) {
      final bool outside = !_contains(event.position);

      if (outside && !finger && !widget.intentionalOutsidePress) {
        _request(false, NebaFloatingReason.outsidePress);

        return;
      }

      _presses[event.pointer] = (at: event.position, outside: outside, moved: false);
    } else if (event is PointerMoveEvent) {
      final ({Offset at, bool outside, bool moved})? press = _presses[event.pointer];

      if (press != null && !press.moved && (event.position - press.at).distance > kTouchSlop) {
        _presses[event.pointer] = (at: press.at, outside: press.outside, moved: true);
      }
    } else if (event is PointerUpEvent) {
      final ({Offset at, bool outside, bool moved})? press = _presses.remove(event.pointer);

      // A finger that scrolled the page did not mean to close anything.
      if (press != null && press.outside && !(finger && press.moved)) {
        if (!_contains(event.position)) {
          _request(false, NebaFloatingReason.outsidePress);
        }
      }
    } else if (event is PointerCancelEvent) {
      _presses.remove(event.pointer);
    }
  }

  // ----- Hover --------------------------------------------------------------

  void _enterTrigger(PointerEnterEvent event) {
    _overTrigger = true;
    _hovered = true;
    _closeTimer?.cancel();
    _closeTimer = null;

    if (!widget.open) {
      _scheduleOpen();
    }
  }

  void _hoverTrigger(PointerHoverEvent event) {
    final NebaFloatingHover? hover = widget.hover;

    if (hover != null && hover.rest && !widget.open && _openTimer != null) {
      _openTimer?.cancel();
      _openTimer = null;
      _scheduleOpen();
    }
  }

  void _exitTrigger(PointerExitEvent event) {
    _overTrigger = false;
    _holdClosed = false;
    _openTimer?.cancel();
    _openTimer = null;

    if (widget.open) {
      _followHover(event.position);
    }
  }

  void _scheduleOpen() {
    final NebaFloatingHover? hover = widget.hover;

    if (hover == null || !widget.enabled || _holdClosed || _openTimer != null) {
      return;
    }

    final Duration delay = hover.delay();

    if (delay == Duration.zero) {
      _request(true, NebaFloatingReason.triggerHover);
    } else {
      _openTimer = Timer(delay, () {
        _openTimer = null;

        if (_overTrigger) {
          _request(true, NebaFloatingReason.triggerHover);
        }
      });
    }
  }

  // Base UI's `safePolygon`, loosened to a box: while the pointer is on the
  // way from the trigger to the popup, or back, the surface stays.
  void _followHover(Offset position) {
    final NebaFloatingHover? hover = widget.hover;

    if (hover == null || !widget.open || !_hovered) {
      return;
    }

    // Opened by the keyboard and still holding it: the pointer passing by
    // has no say.
    if (_openedBy == NebaFloatingReason.triggerFocus && _triggerFocus.hasFocus) {
      return;
    }

    if (_overTrigger || _overPopup || _onTheWay(position)) {
      _closeTimer?.cancel();
      _closeTimer = null;

      return;
    }

    if (_closeTimer != null) {
      return;
    }

    if (hover.closeDelay == Duration.zero) {
      _request(false, NebaFloatingReason.triggerHover);
    } else {
      _closeTimer = Timer(hover.closeDelay, () {
        _closeTimer = null;
        _request(false, NebaFloatingReason.triggerHover);
      });
    }
  }

  bool _onTheWay(Offset position) {
    final Rect? trigger = _globalRect(_triggerKey);
    final Rect? popup = _globalRect(_popupKey);

    if (trigger == null || popup == null) {
      return false;
    }

    return trigger.expandToInclude(popup).contains(position) ||
        _children.any((_NebaFloatingState child) => child._containsPopup(position));
  }

  void _enterPopup(PointerEnterEvent event) {
    _overPopup = true;
    _hovered = true;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _exitPopup(PointerExitEvent event) {
    _overPopup = false;
    _followHover(event.position);
  }

  // ----- Press and focus on the trigger -------------------------------------

  void _onTriggerPress() {
    if (widget.enabled) {
      _request(!widget.open, NebaFloatingReason.triggerPress);
    }
  }

  void _onTriggerPointerDown(PointerDownEvent event) {
    _openTimer?.cancel();
    _openTimer = null;

    if (event.kind != PointerDeviceKind.touch) {
      _holdClosed = true;
    }

    _request(false, NebaFloatingReason.triggerPress);
  }

  void _onTriggerFocus(bool focused) {
    final Duration? delay = widget.focusDelay;

    if (delay == null || !widget.enabled) {
      return;
    }

    if (focused) {
      // A focus a press gave the trigger is not one `:focus-visible` shows.
      if (NebaInputModality.pointer.value || widget.open) {
        return;
      }

      if (delay == Duration.zero) {
        _request(true, NebaFloatingReason.triggerFocus);
      } else {
        _openTimer?.cancel();
        _openTimer = Timer(delay, () {
          _openTimer = null;

          if (_triggerFocus.hasFocus) {
            _request(true, NebaFloatingReason.triggerFocus);
          }
        });
      }

      return;
    }

    _openTimer?.cancel();
    _openTimer = null;

    if (widget.open && _openedBy == NebaFloatingReason.triggerFocus && !_popupScope.hasFocus) {
      _request(false, NebaFloatingReason.triggerFocus);
    }
  }

  // ----- The focus inside the popup ------------------------------------------

  // The control in the trigger that can take the focus: what Base UI gives
  // the focus back to.
  FocusNode? _triggerTarget() {
    for (final FocusNode node in _triggerFocus.descendants) {
      if (node.canRequestFocus && !node.skipTraversal && node is! FocusScopeNode) {
        return node;
      }
    }

    return null;
  }

  void _focusPopup([int tries = 2]) {
    if (!mounted || !widget.open || !widget.moveFocus) {
      return;
    }

    // The popup arrives a frame after `open` does.
    if (_popupScope.context == null) {
      if (tries > 0) {
        SchedulerBinding.instance.addPostFrameCallback((Duration _) => _focusPopup(tries - 1));
      }

      return;
    }

    // A finger gets the popup itself, so that a field inside does not bring
    // a phone's keyboard up over it; everything else gets the first control.
    if (NebaInputModality.pointer.value &&
        NebaInputModality.lastPointerKind == PointerDeviceKind.touch) {
      _popupScope.requestFocus();

      return;
    }

    final FocusNode? first = FocusTraversalGroup.maybeOfNode(
      _popupScope,
    )?.findFirstFocus(_popupScope, ignoreCurrentFocus: true);

    if (first != null && first != _popupScope) {
      first.requestFocus();
    } else {
      _popupScope.requestFocus();
    }
  }

  void _giveFocusBack() {
    final FocusNode? target = _returnTo;
    _returnTo = null;
    final FocusNode? current = FocusManager.instance.primaryFocus;

    // Only when the focus is in the popup, or nowhere: a press outside that
    // put it in a field over there leaves it there.
    if (target != null &&
        target.context != null &&
        (current == null || current == _popupScope || current.ancestors.contains(_popupScope))) {
      target.requestFocus();
    }
  }

  void _onPopupFocus() {
    if (!widget.moveFocus || !widget.open || _popupScope.hasFocus) {
      return;
    }

    final FocusNode? current = FocusManager.instance.primaryFocus;

    if (current == null) {
      return;
    }

    if (current == _triggerFocus || current.ancestors.contains(_triggerFocus)) {
      return;
    }

    _request(false, NebaFloatingReason.focusOut);
  }

  // ----- Building -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _fade.duration = _duration;
    _scopeParent = _NebaFloatingScope.maybeOf(context);

    if (widget.open && _parent == null && _scopeParent != null) {
      _parent = _scopeParent;
      _parent!._children.add(this);
    }

    Widget trigger = KeyedSubtree(key: _triggerKey, child: widget.child);

    if (widget.openOnPress) {
      trigger = NebaPressTrigger(onPress: _onTriggerPress, child: trigger);
    }

    if (widget.closeOnTriggerPress) {
      trigger = Listener(onPointerDown: _onTriggerPointerDown, child: trigger);
    }

    if (widget.hover != null) {
      trigger = MouseRegion(
        opaque: false,
        onEnter: _enterTrigger,
        onHover: _hoverTrigger,
        onExit: _exitTrigger,
        child: trigger,
      );
    }

    trigger = Focus(focusNode: _triggerFocus, onFocusChange: _onTriggerFocus, child: trigger);

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      // A closure of its own on every build: the layout builder behind it
      // builds again only when its builder changes or the trigger moves, and
      // a new popup from the caller is neither.
      overlayChildBuilder: (BuildContext context, OverlayChildLayoutInfo info) =>
          _buildOverlay(context, info),
      child: trigger,
    );
  }

  Widget _buildOverlay(BuildContext context, OverlayChildLayoutInfo info) {
    final Rect anchor = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    final bool open = widget.open;

    Widget popup = KeyedSubtree(key: _popupKey, child: widget.popup);

    if (widget.hover != null) {
      popup = MouseRegion(opaque: false, onEnter: _enterPopup, onExit: _exitPopup, child: popup);
    }

    // Tab leaves a popup the way it came in unless the popup holds it.
    _popupScope.traversalEdgeBehavior = widget.modal == NebaModal.off
        ? TraversalEdgeBehavior.parentScope
        : TraversalEdgeBehavior.closedLoop;
    popup = FocusScope(
      node: _popupScope,
      child: _NebaFloatingScope(
        state: this,
        child: NebaPortalText(child: popup),
      ),
    );

    Widget layer = _FloatingLayout(
      anchor: anchor,
      side: widget.side,
      align: widget.align,
      sideOffset: widget.sideOffset,
      alignOffset: widget.alignOffset,
      textDirection: Directionality.of(context),
      arrow: widget.arrow,
      child: popup,
    );

    // A closing popup is on its way out: it takes no press and is no longer
    // read.
    layer = FadeTransition(
      opacity: _opacity,
      child: IgnorePointer(
        ignoring: !open,
        child: ExcludeSemantics(excluding: !open, child: layer),
      ),
    );

    if (widget.modal == NebaModal.on) {
      layer = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (open)
            const Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.basic,
                child: Listener(behavior: HitTestBehavior.opaque),
              ),
            ),
          layer,
        ],
      );
    }

    return layer;
  }
}

/// The surface whose popup a widget is built in, so that a surface opened
/// from inside another one counts as inside it.
class _NebaFloatingScope extends InheritedWidget {
  const _NebaFloatingScope({required this.state, required super.child});

  final _NebaFloatingState state;

  static _NebaFloatingState? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_NebaFloatingScope>()?.state;
  }

  @override
  bool updateShouldNotify(_NebaFloatingScope oldWidget) => state != oldWidget.state;
}

/// The text a popup starts from: the app's family at the body weight in the
/// page's foreground, left-aligned and wrapping, not the paragraph its
/// trigger happens to be in. A portalled popup in the browser inherits from
/// `<body>` for the same reason, and so does a toast's stack.
class NebaPortalText extends StatelessWidget {
  /// [child] on the text a portalled surface starts from.
  const NebaPortalText({required this.child, super.key});

  /// The surface.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextStyle outer = DefaultTextStyle.of(context).style;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: outer.fontFamily,
        fontFamilyFallback: outer.fontFamilyFallback,
        locale: outer.locale,
        color: NebaTheme.of(context).fg,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
      ),
      child: child,
    );
  }
}

/// Lays the popup out against the anchor and draws the wedge.
class _FloatingLayout extends SingleChildRenderObjectWidget {
  const _FloatingLayout({
    required this.anchor,
    required this.side,
    required this.align,
    required this.sideOffset,
    required this.alignOffset,
    required this.textDirection,
    required this.arrow,
    required Widget super.child,
  });

  final Rect anchor;
  final NebaSide side;
  final NebaAlign align;
  final double sideOffset;
  final double alignOffset;
  final TextDirection textDirection;
  final NebaFloatingArrow? arrow;

  @override
  _RenderFloatingLayout createRenderObject(BuildContext context) {
    return _RenderFloatingLayout(
      anchor: anchor,
      side: side,
      align: align,
      sideOffset: sideOffset,
      alignOffset: alignOffset,
      textDirection: textDirection,
      arrow: arrow,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderFloatingLayout renderObject) {
    renderObject
      ..anchor = anchor
      ..side = side
      ..align = align
      ..sideOffset = sideOffset
      ..alignOffset = alignOffset
      ..textDirection = textDirection
      ..arrow = arrow;
  }
}

class _RenderFloatingLayout extends RenderShiftedBox {
  _RenderFloatingLayout({
    required Rect anchor,
    required NebaSide side,
    required NebaAlign align,
    required double sideOffset,
    required double alignOffset,
    required TextDirection textDirection,
    required NebaFloatingArrow? arrow,
  }) : _anchor = anchor,
       _side = side,
       _align = align,
       _sideOffset = sideOffset,
       _alignOffset = alignOffset,
       _textDirection = textDirection,
       _arrow = arrow,
       super(null);

  Rect _anchor;
  set anchor(Rect value) {
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

  double _sideOffset;
  set sideOffset(double value) {
    if (value != _sideOffset) {
      _sideOffset = value;
      markNeedsLayout();
    }
  }

  double _alignOffset;
  set alignOffset(double value) {
    if (value != _alignOffset) {
      _alignOffset = value;
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

  NebaFloatingArrow? _arrow;
  set arrow(NebaFloatingArrow? value) {
    if (value != _arrow) {
      _arrow = value;
      markNeedsLayout();
    }
  }

  List<Offset>? _wedge;

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
      BoxConstraints(maxWidth: math.max(0, size.width - 2 * nebaCollisionPadding)),
      parentUsesSize: true,
    );

    final NebaFloatingPlacement placement = nebaPlaceFloating(
      anchor: _anchor,
      popup: child.size,
      bounds: size,
      side: _side,
      align: _align,
      textDirection: _textDirection,
      sideOffset: _sideOffset,
      alignOffset: _alignOffset,
      arrow: _arrow,
    );

    (child.parentData! as BoxParentData).offset = placement.rect.topLeft;
    _wedge = placement.arrow;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final RenderBox? child = this.child;
    final List<Offset>? wedge = _wedge;
    final NebaFloatingArrow? arrow = _arrow;

    if (child == null || wedge == null || arrow == null) {
      return;
    }

    final Offset origin = offset + (child.parentData! as BoxParentData).offset;
    final Path triangle = Path()
      ..moveTo(origin.dx + wedge[0].dx, origin.dy + wedge[0].dy)
      ..lineTo(origin.dx + wedge[1].dx, origin.dy + wedge[1].dy)
      ..lineTo(origin.dx + wedge[2].dx, origin.dy + wedge[2].dy)
      ..close();
    final Canvas canvas = context.canvas;

    canvas.drawPath(triangle, Paint()..color = arrow.fill);

    final Color? edge = arrow.edge;

    if (edge != null) {
      // Only the two slanted sides, so the wedge carries the sheet's
      // hairline on rather than ruling a line across the edge it grows from.
      final Path sides = Path()
        ..moveTo(origin.dx + wedge[0].dx, origin.dy + wedge[0].dy)
        ..lineTo(origin.dx + wedge[1].dx, origin.dy + wedge[1].dy)
        ..lineTo(origin.dx + wedge[2].dx, origin.dy + wedge[2].dy);

      canvas.drawPath(
        sides,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
}

/// The frosted panel a Popover and a HoverCard draw: the sheet the page sits
/// under, at elevation 3, with a hairline in [color]'s family, the size's
/// corners and padding, and the sheet type ladder.
///
/// A heading of [title] over [description] comes first, with [headerEnd]
/// pinned to its end, then [child], with a section gap between them. The
/// sheet is as wide as what is on it, up to [maxWidth], as a CSS box that
/// shrinks to fit its content is. [corner] is laid over the top end corner,
/// eight pixels in.
class NebaFloatingSheet extends StatelessWidget {
  /// A sheet with [child] on it.
  const NebaFloatingSheet({
    required this.size,
    required this.color,
    required this.density,
    required this.maxWidth,
    this.title,
    this.description,
    this.headerEnd,
    this.corner,
    this.child,
    super.key,
  });

  /// The type, the corners and the padding.
  final NebaSize size;

  /// The family of the hairline.
  final NebaColor color;

  /// How much padding the sheet has at its [size].
  final NebaDensity density;

  /// The widest the sheet gets.
  final double maxWidth;

  /// The heading, one step above the body in semibold.
  final Widget? title;

  /// A line under the heading, one step below the body and muted.
  final Widget? description;

  /// Pinned to the heading's end: a close button.
  final Widget? headerEnd;

  /// Laid over the top end corner.
  final Widget? corner;

  /// The body.
  final Widget? child;

  /// The wedge a sheet of each size draws when it draws one.
  static const Map<NebaSize, double> arrowSizes = <NebaSize, double>{
    NebaSize.xs: 8,
    NebaSize.sm: 9,
    NebaSize.md: 10,
    NebaSize.lg: 11,
    NebaSize.xl: 12,
  };

  /// The wedge itself, in the sheet's colours: its fill, and its hairline
  /// along the two slanted sides.
  static NebaFloatingArrow arrowOf(NebaTokens tokens, NebaColor color, NebaSize size) {
    return NebaFloatingArrow(
      size: arrowSizes[size]!,
      fill: tokens.panelPress,
      edge: tokens.roles(color).line,
      border: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double inset = NebaBox.padding[density]![size]!;
    final double body = NebaScale.sheetBodyText[size]!;
    final double leading = NebaScale.sheetBodyLeading[size]!;
    final double titleSize = NebaScale.sheetTitleText[size]!;
    final double meta = NebaScale.metaText[size]!;
    final Widget? title = this.title;
    final Widget? description = this.description;
    final Widget? headerEnd = this.headerEnd;
    final Widget? child = this.child;
    final Widget? corner = this.corner;

    final Widget? header = title == null && description == null && headerEnd == null
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
                        child: title,
                      ),
                    if (description != null)
                      // The sheet's line height is a length in CSS, so the
                      // smaller line keeps it rather than scaling it down.
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: meta,
                          height: leading / meta,
                          color: tokens.mutedFg,
                        ),
                        child: description,
                      ),
                  ],
                ),
              ),
              ?headerEnd,
            ],
          );

    Widget content = Padding(
      padding: EdgeInsets.all(inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: NebaScale.sheetSectionGap[size]!,
        children: <Widget>[?header, ?child],
      ),
    );

    content = DefaultTextStyle.merge(
      style: TextStyle(fontSize: body, height: leading / body, color: tokens.fg),
      child: content,
    );

    if (corner != null) {
      content = Stack(
        children: <Widget>[
          content,
          PositionedDirectional(top: 8, end: 8, child: corner),
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: IntrinsicWidth(
        child: NebaSheet(
          fill: tokens.panelPress,
          edge: tokens.roles(color).line,
          plate: NebaPlate.glass,
          elevation: 3,
          borderRadius: BorderRadius.circular(tokens.radius[size]!),
          child: content,
        ),
      ),
    );
  }
}
