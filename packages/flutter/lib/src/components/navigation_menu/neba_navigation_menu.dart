/// `NebaNavigationMenu`, a site's navigation: a row of destinations, some of
/// which open a panel of more of them, with `NebaNavigationMenuItem`, one word
/// in the row, and `NebaNavigationMenuLink`, one row in a panel.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/menu.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What opened the panel, which decides what may close it again.
enum _Opened {
  /// The pointer resting on the word: leaving both it and the panel closes it.
  hover,

  /// A press, Enter or Space: only another press, Escape, a press outside or
  /// the focus leaving closes it.
  press,

  /// The arrow across the row.
  keyboard,
}

/// How long a panel the pointer opened counts as just opened, so that a press
/// arriving with the pointer keeps it rather than closing it: Base UI's
/// `PATIENT_CLICK_THRESHOLD`.
const Duration _patientPress = Duration(milliseconds: 500);

/// How much room a panel keeps around its links, at each size.
const Map<NebaSize, double> _panelPadding = <NebaSize, double>{
  NebaSize.xs: 4,
  NebaSize.sm: 6,
  NebaSize.md: 8,
  NebaSize.lg: 10,
  NebaSize.xl: 12,
};

/// The gap between the links in a panel, both ways.
const double _panelGap = 4;

/// A site's navigation: a row of destinations, some of which open a panel of
/// more of them.
///
/// The difference from a [NebaMenu] is what the rows are. A menu holds
/// actions; this holds destinations, so every word that goes somewhere is a
/// link with an `href` a screen reader announces, every one is a stop of its
/// own in the focus order, and the whole row is a navigation region. Reach
/// for a menu when a row does something and for this when it goes somewhere.
///
/// One panel is open at a time, and it hangs off its word on one sheet that
/// changes size as the pointer crosses the row rather than closing and
/// opening again.
///
/// ```dart
/// NebaNavigationMenu(
///   semanticLabel: 'Main',
///   children: <Widget>[
///     NebaNavigationMenuItem(
///       label: const Text('Product'),
///       children: <Widget>[
///         NebaNavigationMenuLink(
///           title: const Text('Analytics'),
///           href: Uri.parse('/analytics'),
///           onPressed: openAnalytics,
///         ),
///       ],
///     ),
///     NebaNavigationMenuItem(
///       label: const Text('Pricing'),
///       href: Uri.parse('/pricing'),
///       onPressed: openPricing,
///     ),
///   ],
/// )
/// ```
class NebaNavigationMenu extends StatefulWidget {
  /// A navigation of [children].
  const NebaNavigationMenu({
    required this.children,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.orientation = NebaOrientation.horizontal,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.delay = const Duration(milliseconds: 50),
    this.closeDelay = const Duration(milliseconds: 50),
    this.sideOffset = 8,
    this.semanticLabel,
    super.key,
  });

  /// The items, each a [NebaNavigationMenuItem].
  final List<Widget> children;

  /// The height and type scale of the items, and of the links in the panels.
  /// Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the open item, the panel's edge and the focus ring are drawn
  /// in.
  final NebaColor color;

  /// The horizontal padding of the items and the links. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which way the row runs. A vertical one is a rail whose panels open
  /// beside it, at its inline end; the arrow keys follow either way.
  final NebaOrientation orientation;

  /// Which item's panel is open, by its `value`, for a controlled menu. Leave
  /// it `null` and the menu keeps its own state, starting from
  /// [defaultValue]; a controlled menu whose value turns `null` closes.
  final String? value;

  /// Which item starts open, for an uncontrolled menu.
  final String? defaultValue;

  /// Called whenever the open item changes, with its `value`, or `null` once
  /// the panel closes.
  final ValueChanged<String?>? onValueChange;

  /// How long the pointer rests on an item before its panel opens.
  final Duration delay;

  /// How long a panel stays after the pointer has left it and its item.
  final Duration closeDelay;

  /// How far the panel stands off the row, in logical pixels.
  final double sideOffset;

  /// What a screen reader calls the navigation, for a page that holds more
  /// than one: React's `aria-label`.
  final String? semanticLabel;

  @override
  State<NebaNavigationMenu> createState() => _NebaNavigationMenuState();
}

class _NebaNavigationMenuState extends State<NebaNavigationMenu> {
  final GlobalKey _panelKey = GlobalKey();
  // Holds the row and, through the overlay child that is built under it, the
  // panel: whether the focus is anywhere in the navigation.
  final FocusNode _navFocus = FocusNode(
    debugLabel: 'NebaNavigationMenu',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final FocusNode _panelFocus = FocusNode(
    debugLabel: 'NebaNavigationMenu panel',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final List<_NebaNavigationMenuItemState> _items = <_NebaNavigationMenuItemState>[];

  late String? _value = widget.defaultValue;
  _Opened _openedBy = _Opened.press;
  // The item whose panel is drawn: the open one, and the last one while the
  // panel fades out.
  _NebaNavigationMenuItemState? _shown;
  _NebaNavigationMenuItemState? _pending;
  Timer? _openTimer;
  Timer? _closeTimer;
  Timer? _patient;
  bool _routing = false;
  bool _focusInside = false;
  // Whether the open item arrived after the menu was first built, as a
  // controlled or a default value names one: its panel is there at once
  // rather than fading in, as Base UI skips the transition on mount.
  bool _arrivedOpen = false;

  String? get _current => widget.value ?? _value;

  bool get _vertical => widget.orientation == NebaOrientation.vertical;

  _NebaNavigationMenuItemState? get _open {
    final String? current = _current;

    if (current == null) {
      return null;
    }

    for (final _NebaNavigationMenuItemState item in _items) {
      if (item._id == current) {
        return item._hasPanel && !item.widget.disabled ? item : null;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NebaNavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != null && widget.value == null) {
      _value = null;
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChange);
    _cancelTimers();
    _patient?.cancel();
    _route(false);
    _navFocus.dispose();
    _panelFocus.dispose();
    super.dispose();
  }

  void _register(_NebaNavigationMenuItemState item) {
    if (!_items.contains(item)) {
      _items.add(item);

      // The items register after the menu has built, so a value that names
      // one of them is only seen now.
      if (item._id == _current && item._hasPanel && _open == item) {
        _arrivedOpen = true;
        _refresh();
      }
    }
  }

  void _unregister(_NebaNavigationMenuItemState item) {
    final bool wasOpen = identical(_open, item);

    _items.remove(item);

    if (wasOpen) {
      _refresh();
    }

    if (identical(_shown, item)) {
      _shown = null;
    }

    if (identical(_pending, item)) {
      _openTimer?.cancel();
      _openTimer = null;
      _pending = null;
    }
  }

  // An item's panel changed under it, outside a build of the menu: the panel
  // is drawn in the overlay and is built again with the next frame.
  void _refresh() {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        setState(() {});
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _openTimer = null;
    _pending = null;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _set(String? next, _Opened reason) {
    if (!mounted) {
      return;
    }

    _cancelTimers();

    if (next == _current) {
      return;
    }

    if (next != null) {
      _openedBy = reason;
      _patient?.cancel();
      _patient = reason == _Opened.hover ? Timer(_patientPress, () => _patient = null) : null;
    }

    setState(() {
      if (widget.value == null) {
        _value = next;
      }
    });
    widget.onValueChange?.call(next);
  }

  void _close(NebaFloatingReason reason) {
    final _NebaNavigationMenuItemState? open = _open;

    // The focus a panel held goes back to its word, unless something else has
    // already taken it.
    if (open != null &&
        _panelFocus.hasFocus &&
        reason != NebaFloatingReason.outsidePress &&
        reason != NebaFloatingReason.focusOut) {
      open._node.requestFocus();
    }

    _set(null, _Opened.press);
  }

  // ----- The pointer --------------------------------------------------------

  void _enter(_NebaNavigationMenuItemState item) {
    if (item.widget.disabled || !item._hasPanel) {
      // A word that opens nothing takes the wait over from one that would.
      if (_pending != null) {
        _openTimer?.cancel();
        _openTimer = null;
        _pending = null;
      }

      return;
    }

    final _NebaNavigationMenuItemState? open = _open;

    if (open == null) {
      _schedule(item);
    } else if (!identical(open, item)) {
      // Crossing the row walks through the panels at once.
      _set(item._id, _Opened.hover);
    }
  }

  // The wait starts again on every movement, so a panel opens once the
  // pointer comes to rest rather than as it passes over: Base UI's `restMs`.
  void _hoverItem(_NebaNavigationMenuItemState item) {
    if (identical(_pending, item)) {
      _schedule(item);
    }
  }

  void _exit(_NebaNavigationMenuItemState item, Offset position) {
    if (identical(_pending, item)) {
      _openTimer?.cancel();
      _openTimer = null;
      _pending = null;
    }

    _follow(position);
  }

  void _schedule(_NebaNavigationMenuItemState item) {
    _openTimer?.cancel();
    _pending = item;

    if (widget.delay == Duration.zero) {
      _pending = null;
      _set(item._id, _Opened.hover);

      return;
    }

    _openTimer = Timer(widget.delay, () {
      _openTimer = null;
      _pending = null;

      if (mounted && item.mounted && !item.widget.disabled) {
        _set(item._id, _Opened.hover);
      }
    });
  }

  void _route(bool on) {
    if (on == _routing) {
      return;
    }

    _routing = on;

    if (on) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    } else {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    }
  }

  void _onPointer(PointerEvent event) {
    if (event is PointerHoverEvent) {
      _follow(event.position);
    }
  }

  Rect? _rect(GlobalKey key) {
    final RenderObject? box = key.currentContext?.findRenderObject();

    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return null;
    }

    return MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
  }

  // Whether the pointer is on the open word, on its panel, or crossing the
  // gap between them: Base UI's safe polygon, as the strip the pointer has
  // to cross.
  bool _holds(_NebaNavigationMenuItemState item, Offset position) {
    final Rect? trigger = _rect(item._box);
    final Rect? panel = _rect(_panelKey);

    if (trigger == null || panel == null) {
      return true;
    }

    if (trigger.contains(position) || panel.contains(position)) {
      return true;
    }

    final Rect gap;

    if (panel.top >= trigger.bottom) {
      gap = Rect.fromLTRB(panel.left, trigger.bottom, panel.right, panel.top);
    } else if (panel.bottom <= trigger.top) {
      gap = Rect.fromLTRB(panel.left, panel.bottom, panel.right, trigger.top);
    } else if (panel.left >= trigger.right) {
      gap = Rect.fromLTRB(trigger.right, panel.top, panel.left, panel.bottom);
    } else {
      gap = Rect.fromLTRB(panel.right, panel.top, trigger.left, panel.bottom);
    }

    return gap.contains(position);
  }

  void _follow(Offset position) {
    final _NebaNavigationMenuItemState? open = _open;

    // A panel a press or a key opened stays until it is closed on purpose.
    if (open == null || _openedBy != _Opened.hover) {
      return;
    }

    if (_holds(open, position)) {
      _closeTimer?.cancel();
      _closeTimer = null;

      return;
    }

    if (_closeTimer != null) {
      return;
    }

    if (widget.closeDelay == Duration.zero) {
      _set(null, _Opened.hover);

      return;
    }

    _closeTimer = Timer(widget.closeDelay, () {
      _closeTimer = null;

      if (mounted && identical(_open, open) && _openedBy == _Opened.hover) {
        _set(null, _Opened.hover);
      }
    });
  }

  // ----- A press ------------------------------------------------------------

  void _press(_NebaNavigationMenuItemState item) {
    if (item.widget.disabled) {
      return;
    }

    if (identical(_open, item)) {
      // A press that arrives with the pointer that has just opened the panel
      // keeps it, and holds it open from now on.
      if (_openedBy == _Opened.hover && _patient != null) {
        _cancelTimers();
        _openedBy = _Opened.press;

        return;
      }

      _set(null, _Opened.press);
    } else {
      _set(item._id, _Opened.press);
    }
  }

  // ----- The focus and the keys ---------------------------------------------

  void _onFocusChange() {
    final bool inside = _navFocus.hasFocus || _panelFocus.hasFocus;

    // Only the focus leaving closes a panel: focus moving between two things
    // elsewhere on the page has nothing to do with it.
    if (_focusInside &&
        !inside &&
        FocusManager.instance.primaryFocus != null &&
        _open != null &&
        mounted) {
      _set(null, _Opened.press);
    }

    _focusInside = inside;
  }

  // The items in the order they are read in.
  List<_NebaNavigationMenuItemState> _ordered() {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final List<(Offset, _NebaNavigationMenuItemState)> placed =
        <(Offset, _NebaNavigationMenuItemState)>[];

    for (final _NebaNavigationMenuItemState item in _items) {
      final RenderObject? box = item.context.findRenderObject();

      if (box is RenderBox && box.attached && box.hasSize) {
        final Offset at = box.localToGlobal(Offset.zero);
        placed.add((Offset(rtl ? -at.dx - box.size.width : at.dx, at.dy), item));
      }
    }

    placed.sort((
      (Offset, _NebaNavigationMenuItemState) a,
      (Offset, _NebaNavigationMenuItemState) b,
    ) {
      // A wrapped row is read a line at a time.
      if (!_vertical && (a.$1.dy - b.$1.dy).abs() > 0.5) {
        return a.$1.dy.compareTo(b.$1.dy);
      }

      return _vertical ? a.$1.dy.compareTo(b.$1.dy) : a.$1.dx.compareTo(b.$1.dx);
    });

    return <_NebaNavigationMenuItemState>[
      for (final (Offset _, _NebaNavigationMenuItemState item) in placed) item,
    ];
  }

  // The panel's stops, in the order they were built, which is the order they
  // are laid out in.
  List<FocusNode> _panelStops() {
    return <FocusNode>[
      for (final FocusNode node in _panelFocus.traversalDescendants)
        if (node is! FocusScopeNode) node,
    ];
  }

  KeyEventResult _onItemKey(_NebaNavigationMenuItemState item, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final TextDirection direction = Directionality.of(context);
    final List<_NebaNavigationMenuItemState> items = _ordered();
    final int current = items.indexOf(item);

    // The row's own arrows, which stop at its ends; Home and End are left to
    // the page.
    if (current >= 0 && key != LogicalKeyboardKey.home && key != LogicalKeyboardKey.end) {
      final int? target = nebaRovingTarget(
        event,
        current: current,
        count: items.length,
        axis: _vertical ? Axis.vertical : Axis.horizontal,
        textDirection: direction,
        loop: false,
        focusable: (int index) => items[index]._arrowStop,
      );

      if (target != null) {
        if (target != current) {
          items[target]._node.requestFocus();
        }

        return KeyEventResult.handled;
      }
    }

    // The arrow across the row opens the panel: down under a horizontal row,
    // towards the inline end beside a vertical one.
    final LogicalKeyboardKey opens = _vertical
        ? (direction == TextDirection.rtl
              ? LogicalKeyboardKey.arrowLeft
              : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowDown;

    if (key == opens && item._hasPanel && !item.widget.disabled) {
      if (!identical(_open, item)) {
        _set(item._id, _Opened.keyboard);
      }

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.tab) {
      final _NebaNavigationMenuItemState? open = _open;
      final List<FocusNode> stops = open == null ? <FocusNode>[] : _panelStops();

      if (open == null || stops.isEmpty) {
        return KeyEventResult.ignored;
      }

      final bool back = HardwareKeyboard.instance.isShiftPressed;

      // Tab from an open word goes into its panel, and Shift+Tab from the
      // stop after it comes back out of the panel's end, as if the panel
      // were laid out right after its word.
      if (!back && identical(open, item)) {
        stops.first.requestFocus();

        return KeyEventResult.handled;
      }

      if (back && identical(_stopAfter(open), item)) {
        stops.last.requestFocus();

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  _NebaNavigationMenuItemState? _stopAfter(_NebaNavigationMenuItemState item) {
    final List<_NebaNavigationMenuItemState> items = _ordered();

    for (int index = items.indexOf(item) + 1; index < items.length; index++) {
      if (items[index]._focusable) {
        return items[index];
      }
    }

    return null;
  }

  KeyEventResult _onPanelKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final List<FocusNode> stops = _panelStops();
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    final int index = primary == null ? -1 : stops.indexOf(primary);
    final _NebaNavigationMenuItemState? item = _open ?? _shown;

    if (index < 0 || item == null) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.tab) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        (index == 0 ? item._node : stops[index - 1]).requestFocus();
      } else if (index == stops.length - 1) {
        // Out of the panel's end to whatever follows its word.
        nebaMenuMoveOn(item._node, forward: true);
      } else {
        stops[index + 1].requestFocus();
      }

      return KeyEventResult.handled;
    }

    // Either pair of arrows walks the links, round from one end to the other.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final int? step = switch (key) {
      LogicalKeyboardKey.arrowDown => 1,
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      _ => null,
    };

    if (step == null) {
      return KeyEventResult.ignored;
    }

    stops[(index + step + stops.length) % stops.length].requestFocus();

    return KeyEventResult.handled;
  }

  // ----- Building -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final _NebaNavigationMenuItemState? open = _open;

    if (open != null) {
      _shown = open;
    }

    _route(open != null);

    final bool instant = _arrivedOpen;

    if (open != null) {
      _arrivedOpen = false;
    }

    final double gap = NebaScale.gap[size]!;
    final List<Widget> children = widget.children;

    Widget row = _vertical
        ? IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: children,
            ),
          )
        // A row too long for its line wraps onto the next rather than
        // running off it.
        : Wrap(
            spacing: gap,
            runSpacing: gap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          );

    row = Semantics(
      container: true,
      explicitChildNodes: true,
      role: children.isEmpty ? null : SemanticsRole.list,
      child: row,
    );

    final _NebaNavigationMenuScope scope = _NebaNavigationMenuScope(
      menu: this,
      size: size,
      color: widget.color,
      density: density,
      vertical: _vertical,
      open: open,
      child: const SizedBox.shrink(),
    );

    row = NebaFloating(
      open: open != null,
      onOpenChange: (bool next, NebaFloatingReason reason) {
        if (!next) {
          _close(reason);
        }
      },
      side: _vertical ? (rtl ? NebaSide.left : NebaSide.right) : NebaSide.bottom,
      sideOffset: widget.sideOffset,
      padding: 12,
      anchor: (open ?? _shown)?._box,
      intentionalOutsidePress: true,
      inTabOrder: false,
      instant: instant,
      popup: _NebaNavigationMenuPanel(menu: this, scope: scope),
      child: row,
    );

    return _NebaNavigationMenuScope(
      menu: this,
      size: size,
      color: widget.color,
      density: density,
      vertical: _vertical,
      open: open,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.navigation,
        label: widget.semanticLabel,
        child: Focus(
          focusNode: _navFocus,
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          child: row,
        ),
      ),
    );
  }
}

/// What an item and a link take from the menu around them.
class _NebaNavigationMenuScope extends InheritedWidget {
  const _NebaNavigationMenuScope({
    required this.menu,
    required this.size,
    required this.color,
    required this.density,
    required this.vertical,
    required this.open,
    required super.child,
  });

  final _NebaNavigationMenuState menu;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final bool vertical;
  final _NebaNavigationMenuItemState? open;

  static _NebaNavigationMenuScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaNavigationMenuScope>();
  }

  _NebaNavigationMenuScope around(Widget child) {
    return _NebaNavigationMenuScope(
      menu: menu,
      size: size,
      color: color,
      density: density,
      vertical: vertical,
      open: open,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(_NebaNavigationMenuScope oldWidget) {
    return menu != oldWidget.menu ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        vertical != oldWidget.vertical ||
        !identical(open, oldWidget.open);
  }
}

/// The one panel, drawn with whichever item it belongs to: a frosted sheet
/// that eases to the size of each item's links as the pointer crosses the
/// row, rather than closing and opening again.
class _NebaNavigationMenuPanel extends StatelessWidget {
  const _NebaNavigationMenuPanel({required this.menu, required this.scope});

  final _NebaNavigationMenuState menu;
  final _NebaNavigationMenuScope scope;

  @override
  Widget build(BuildContext context) {
    final _NebaNavigationMenuItemState? item = menu._shown;

    if (item == null || !item.mounted) {
      return const SizedBox.shrink();
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = scope.size;
    final NebaNavigationMenuItem widget = item.widget;

    Widget panel = Padding(
      padding: EdgeInsets.all(_panelPadding[size]!),
      child: _PanelGrid(
        columns: math.max(1, widget.columns),
        gap: _panelGap,
        children: widget.children,
      ),
    );

    // Opacity and its own size only: a panel that slid in would drag a page's
    // worth of links across the screen.
    panel = AnimatedSize(
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      alignment: AlignmentDirectional.topStart,
      child: KeyedSubtree(key: ObjectKey(item), child: panel),
    );

    return KeyedSubtree(
      key: menu._panelKey,
      child: Focus(
        focusNode: menu._panelFocus,
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: menu._onPanelKey,
        child: scope.around(
          NebaSheet(
            fill: tokens.panelPress,
            edge: tokens.roles(scope.color).line,
            plate: NebaPlate.glass,
            elevation: 3,
            borderRadius: BorderRadius.circular(tokens.radius[size]!),
            child: panel,
          ),
        ),
      ),
    );
  }
}

/// One word in the row of a [NebaNavigationMenu], and what opens under it.
///
/// With [children] it opens a panel of them, usually
/// [NebaNavigationMenuLink]s, and a screen reader hears a button that
/// expands; without any it is a link of its own, and is heard as one. The
/// difference is not cosmetic, which is why an item cannot be both: with
/// [children], [href] and [onPressed] are not used, and a debug build says
/// so.
///
/// The package opens nothing itself, so a link is a callback: [onPressed]
/// calls the router or a URL launcher, and [href] tells a screen reader, and
/// on the web the browser, where it goes.
class NebaNavigationMenuItem extends StatefulWidget {
  /// The word [label] in the row, opening [children], or going to [href]
  /// through [onPressed] when there are none.
  const NebaNavigationMenuItem({
    required this.label,
    this.href,
    this.onPressed,
    this.newTab = false,
    this.startIcon,
    this.value,
    this.disabled = false,
    this.columns = 1,
    this.children = const <Widget>[],
    this.focusNode,
    super.key,
  }) : assert(columns >= 1, 'A panel has at least one column.');

  /// The word in the row, usually a [Text].
  final Widget label;

  /// Where an item with no [children] goes, for a screen reader and, on the
  /// web, the browser. A scheme other than `http`, `https`, `mailto` or `tel`
  /// is not written.
  final Uri? href;

  /// What an item with no [children] does when it is pressed. `null` leaves
  /// it drawn as a link that does nothing and takes no focus.
  final VoidCallback? onPressed;

  /// Whether a link item leaves the app. It is announced with "(opens in a
  /// new tab)"; opening the tab is [onPressed]'s.
  final bool newTab;

  /// What goes before the word, at 1.2 times its size.
  final Widget? startIcon;

  /// Identifies the item, for a controlled menu. Left out, the item has an
  /// identity of its own, which is what [NebaNavigationMenu.onValueChange]
  /// reports for it.
  final String? value;

  /// Whether the item is unavailable. The word stays in the row and opens
  /// nothing; one that opens a panel keeps its place in the focus order, and
  /// a link item is not a link at all.
  final bool disabled;

  /// How many columns the panel lays its links out in.
  final int columns;

  /// The panel's contents, usually [NebaNavigationMenuLink]s.
  final List<Widget> children;

  /// The item's focus node.
  final FocusNode? focusNode;

  @override
  State<NebaNavigationMenuItem> createState() => _NebaNavigationMenuItemState();
}

class _NebaNavigationMenuItemState extends State<NebaNavigationMenuItem> {
  static int _count = 0;

  final String _generated = 'neba-navigation-menu-item-${_count++}';
  final GlobalKey _box = GlobalKey();
  FocusNode? _ownNode;
  _NebaNavigationMenuState? _menu;
  bool _warned = false;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());

  String get _id => widget.value ?? _generated;

  bool get _hasPanel => widget.children.isNotEmpty;

  bool get _enabledLink => !widget.disabled && widget.onPressed != null;

  // In the focus order: a word that opens a panel even while it is disabled,
  // as a disabled Base UI trigger stays focusable, and a link that does
  // something.
  bool get _focusable => _hasPanel || _enabledLink;

  // Where the arrow keys stop: what can be used.
  bool get _arrowStop => _hasPanel ? !widget.disabled : _enabledLink;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final _NebaNavigationMenuState? menu = _NebaNavigationMenuScope.maybeOf(context)?.menu;

    if (menu == null) {
      throw FlutterError(
        'A NebaNavigationMenuItem goes inside a NebaNavigationMenu, and is in none.',
      );
    }

    if (!identical(menu, _menu)) {
      _menu?._unregister(this);
      _menu = menu;
      menu._register(this);
    }
  }

  @override
  void didUpdateWidget(NebaNavigationMenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (identical(_menu?._shown, this) &&
        (!listEquals(oldWidget.children, widget.children) || oldWidget.columns != widget.columns)) {
      _menu?._refresh();
    }
  }

  @override
  void dispose() {
    _menu?._unregister(this);
    _ownNode?.dispose();
    super.dispose();
  }

  void _warn() {
    if (_warned || !kDebugMode || !_hasPanel) {
      return;
    }

    if (widget.href == null && widget.onPressed == null) {
      return;
    }

    _warned = true;
    debugPrint(
      'Neba: a NebaNavigationMenuItem has both children and '
      '${widget.href != null ? 'href: ${widget.href}' : 'onPressed'}. An item with children opens '
      'a panel and is a button, so the href and onPressed are not used. Put the destination in '
      'the panel as a NebaNavigationMenuLink, or drop the children to make the item a link.',
    );
  }

  @override
  Widget build(BuildContext context) {
    _warn();

    final _NebaNavigationMenuScope scope = _NebaNavigationMenuScope.maybeOf(context)!;
    final _NebaNavigationMenuState menu = scope.menu;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(scope.color);
    final NebaSize size = scope.size;
    final bool disabled = widget.disabled;
    final bool hasPanel = _hasPanel;
    final bool open = hasPanel && identical(scope.open, this);
    final bool enabled = hasPanel ? !disabled : _enabledLink;
    final double text = NebaScale.controlText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final Widget? startIcon = widget.startIcon;
    final double gap = NebaScale.gap[size]!;

    final Widget word = Row(
      mainAxisSize: scope.vertical ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: gap,
      children: <Widget>[
        if (startIcon != null)
          IconTheme.merge(
            data: IconThemeData(size: text * 1.2),
            child: startIcon,
          ),
        Flexible(child: widget.label),
        // Drawn pointing down and turned while the panel is open: a glyph
        // turning is not a control moving.
        if (hasPanel) NebaDisclosureChevron(open: open, size: text * 1.2),
      ],
    );

    Widget body = NebaInteractive(
      focusNode: _node,
      enabled: enabled,
      focusable: _focusable,
      activatesOnSpace: hasPanel,
      onTap: hasPanel ? () => menu._press(this) : widget.onPressed,
      cursor: disabled ? SystemMouseCursors.forbidden : null,
      builder: (BuildContext context, NebaInteraction interaction, _) {
        const Color clear = Color(0x00000000);
        final Color fill = disabled
            ? clear
            : open
            ? roles.softHover
            : interaction.hovered
            ? roles.soft
            : clear;
        final Color ink = disabled
            ? tokens.disabledFg
            : open
            ? roles.onTint
            : tokens.fg;

        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: radius,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: fill),
            duration: nebaDuration(context, NebaScale.durationFill, instant: interaction.pressed),
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? tint, Widget? child) {
              return DecoratedBox(
                decoration: BoxDecoration(color: tint, borderRadius: radius),
                child: child,
              );
            },
            child: SizedBox(
              height: NebaScale.controlHeight[size],
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: NebaScale.paddingX[scope.density]![size]!,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: text,
                    height: 1,
                    leadingDistribution: TextLeadingDistribution.even,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: NebaInk(color: ink, child: word),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!hasPanel && widget.newTab && !disabled) {
      // Read to everybody and drawn for nobody, after the word.
      body = Stack(
        children: <Widget>[
          body,
          Semantics(label: nebaMessages(context, 'link')['newTab'], child: const SizedBox.shrink()),
        ],
      );
    }

    body = Semantics(
      container: true,
      button: hasPanel,
      link: !hasPanel && enabled,
      linkUrl: !hasPanel && enabled ? nebaSafeHref(widget.href) : null,
      enabled: hasPanel || disabled ? enabled : null,
      expanded: hasPanel ? open : null,
      child: body,
    );

    body = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: (FocusNode node, KeyEvent event) => menu._onItemKey(this, event),
      child: MouseRegion(
        opaque: false,
        onEnter: (PointerEnterEvent event) => menu._enter(this),
        onHover: (PointerHoverEvent event) => menu._hoverItem(this),
        onExit: (PointerExitEvent event) => menu._exit(this, event.position),
        child: body,
      ),
    );

    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      explicitChildNodes: true,
      child: KeyedSubtree(key: _box, child: body),
    );
  }
}

/// One row inside a panel of a [NebaNavigationMenu]: where it goes, what it
/// is called, and a line saying what is there.
///
/// It is a link, heard as one with its [href], and a stop of its own in the
/// focus order. The package opens nothing itself, so [onPressed] calls the
/// router or a URL launcher.
class NebaNavigationMenuLink extends StatelessWidget {
  /// A link called [title] that runs [onPressed].
  const NebaNavigationMenuLink({
    required this.title,
    required this.onPressed,
    this.href,
    this.description,
    this.startIcon,
    this.newTab = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The row's name, usually a [Text].
  final Widget title;

  /// What the link does. `null` leaves it drawn as a link that does nothing
  /// and takes no focus.
  final VoidCallback? onPressed;

  /// Where it goes, for a screen reader and, on the web, the browser. A
  /// scheme other than `http`, `https`, `mailto` or `tel` is not written.
  final Uri? href;

  /// A second line under the title, one step down the scale and muted.
  final Widget? description;

  /// A glyph before the title.
  final Widget? startIcon;

  /// Whether the link leaves the app. It is announced with "(opens in a new
  /// tab)"; opening the tab is [onPressed]'s.
  final bool newTab;

  /// The link's focus node.
  final FocusNode? focusNode;

  /// Whether the link takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final _NebaNavigationMenuScope? scope = _NebaNavigationMenuScope.maybeOf(context);
    final NebaSize size = scope?.size ?? NebaSize.md;
    final NebaDensity density = scope?.density ?? NebaDensity.standard;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(scope?.color ?? NebaColor.primary);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final bool enabled = onPressed != null;
    final double ambient = DefaultTextStyle.of(context).style.fontSize ?? 16;
    final double text = NebaScale.controlText[size]!;
    final double meta = NebaScale.metaText[size]!;
    final Widget? startIcon = this.startIcon;
    final Widget? description = this.description;

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: NebaScale.gap[size]!,
      children: <Widget>[
        if (startIcon != null)
          // On the first line of the link's own text, at 1.2 times its size.
          SizedBox(
            height: ambient * 1.5,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(size: ambient * 1.2),
                child: startIcon,
              ),
            ),
          ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: <Widget>[
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: text,
                  height: NebaScale.controlLeading[size]! / text,
                  fontWeight: FontWeight.w500,
                ),
                child: title,
              ),
              if (description != null)
                DefaultTextStyle.merge(
                  style: TextStyle(fontSize: meta, height: 1.5, color: tokens.mutedFg),
                  child: description,
                ),
            ],
          ),
        ),
      ],
    );

    if (newTab) {
      content = Stack(
        children: <Widget>[
          content,
          Semantics(label: nebaMessages(context, 'link')['newTab'], child: const SizedBox.shrink()),
        ],
      );
    }

    return Semantics(
      container: true,
      link: enabled,
      linkUrl: enabled ? nebaSafeHref(href) : null,
      child: NebaInteractive(
        enabled: enabled,
        onTap: onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        activatesOnSpace: false,
        builder: (BuildContext context, NebaInteraction interaction, _) {
          const Color clear = Color(0x00000000);

          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: roles.ring,
            borderRadius: radius,
            // Inside the row, which sits flush against its neighbours.
            offset: -focusRingWidth,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: interaction.hovered ? roles.soft : clear),
              duration: nebaDuration(context, NebaScale.durationFill, instant: interaction.pressed),
              curve: NebaScale.ease,
              builder: (BuildContext context, Color? tint, Widget? child) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: tint, borderRadius: radius),
                  child: child,
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: NebaScale.paddingX[density]![size]!,
                  vertical: 8,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.fg),
                  child: content,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A panel's links in [columns] columns of one width, the widest link's, and
/// rows as tall as their tallest link, each link stretched to its row: CSS's
/// `repeat(columns, minmax(0, 1fr))` in a box that shrinks to fit.
class _PanelGrid extends MultiChildRenderObjectWidget {
  const _PanelGrid({required this.columns, required this.gap, required super.children});

  final int columns;
  final double gap;

  @override
  _RenderPanelGrid createRenderObject(BuildContext context) {
    return _RenderPanelGrid(columns: columns, gap: gap, textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPanelGrid renderObject) {
    renderObject
      ..columns = columns
      ..gap = gap
      ..textDirection = Directionality.of(context);
  }
}

class _PanelGridParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderPanelGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PanelGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PanelGridParentData> {
  _RenderPanelGrid({
    required int columns,
    required double gap,
    required TextDirection textDirection,
  }) : _columns = columns,
       _gap = gap,
       _textDirection = textDirection;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  int _columns;
  set columns(int value) {
    if (value != _columns) {
      _columns = value;
      markNeedsLayout();
    }
  }

  double _gap;
  set gap(double value) {
    if (value != _gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PanelGridParentData) {
      child.parentData = _PanelGridParentData();
    }
  }

  List<RenderBox> get _children {
    final List<RenderBox> children = <RenderBox>[];
    RenderBox? child = firstChild;

    while (child != null) {
      children.add(child);
      child = childAfter(child);
    }

    return children;
  }

  double get _gaps => (_columns - 1) * _gap;

  double _widest(double Function(RenderBox child) measure) {
    double widest = 0;

    for (final RenderBox child in _children) {
      widest = math.max(widest, measure(child));
    }

    return widest;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _columns * _widest((RenderBox child) => child.getMinIntrinsicWidth(double.infinity)) +
        _gaps;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _columns * _widest((RenderBox child) => child.getMaxIntrinsicWidth(double.infinity)) +
        _gaps;
  }

  double _cell(double width) => math.max(0, (width - _gaps) / _columns);

  double _height(double cell, double Function(RenderBox child, double cell) measure) {
    final List<RenderBox> children = _children;
    double height = 0;

    for (int start = 0; start < children.length; start += _columns) {
      double row = 0;

      for (int index = start; index < math.min(start + _columns, children.length); index++) {
        row = math.max(row, measure(children[index], cell));
      }

      height += row + (start == 0 ? 0 : _gap);
    }

    return height;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _height(_cell(width), (RenderBox child, double cell) {
      return child.getMinIntrinsicHeight(cell);
    });
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _height(_cell(width), (RenderBox child, double cell) {
      return child.getMaxIntrinsicHeight(cell);
    });
  }

  double _width(BoxConstraints constraints) {
    final double natural =
        _columns * _widest((RenderBox child) => child.getMaxIntrinsicWidth(double.infinity)) +
        _gaps;

    return constraints.constrainWidth(natural);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double width = _width(constraints);
    final double height = _height(_cell(width), (RenderBox child, double cell) {
      return child.getDryLayout(BoxConstraints(minWidth: cell, maxWidth: cell)).height;
    });

    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    final double width = _width(constraints);
    final double cell = _cell(width);
    final List<RenderBox> children = _children;
    final bool rtl = _textDirection == TextDirection.rtl;
    double y = 0;

    for (int start = 0; start < children.length; start += _columns) {
      final int end = math.min(start + _columns, children.length);
      double row = 0;

      for (int index = start; index < end; index++) {
        children[index].layout(
          BoxConstraints(minWidth: cell, maxWidth: cell),
          parentUsesSize: true,
        );
        row = math.max(row, children[index].size.height);
      }

      for (int index = start; index < end; index++) {
        final RenderBox child = children[index];

        // Every link in a row as tall as the row, as a grid stretches them.
        if (child.size.height != row) {
          child.layout(BoxConstraints.tightFor(width: cell, height: row), parentUsesSize: true);
        }

        final int column = index - start;
        final double x = rtl ? width - (column + 1) * cell - column * _gap : column * (cell + _gap);
        (child.parentData! as _PanelGridParentData).offset = Offset(x, y);
      }

      y += row + (end < children.length ? _gap : 0);
    }

    size = constraints.constrain(Size(width, y));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
