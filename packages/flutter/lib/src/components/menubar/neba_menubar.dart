/// `NebaMenubar`, the strip of words at the top of an application, each of
/// which opens a menu, and `NebaMenubarMenu`, one of them.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/menu.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The strip of words at the top of an application — File, Edit, View — each
/// a [NebaMenubarMenu] that opens a menu.
///
/// What makes it a bar rather than a row of separate menus is what happens
/// once one is open: the pointer moving along the strip walks through the
/// others instead of closing the one it left, and the arrow keys move between
/// the menus as well as inside them. The whole bar is one stop in the focus
/// order; the arrow keys along it move between the words, letters move to the
/// word that starts with them, and the arrow across it opens the menu.
///
/// It draws no surface of its own: a menu bar sits on something that already
/// has one, a toolbar, a window's title bar or a page's header.
///
/// ```dart
/// NebaMenubar(
///   children: <Widget>[
///     NebaMenubarMenu(
///       label: const Text('File'),
///       children: <Widget>[NebaMenuItem(onPressed: create, child: const Text('New file'))],
///     ),
///   ],
/// )
/// ```
class NebaMenubar extends StatefulWidget {
  /// A bar of [children].
  const NebaMenubar({
    required this.children,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.orientation = NebaOrientation.horizontal,
    this.modal = true,
    this.loopFocus = true,
    this.disabled = false,
    this.semanticLabel,
    super.key,
  });

  /// The menus, each a [NebaMenubarMenu].
  final List<Widget> children;

  /// The height and type scale of the words, on a ladder of their own one rung
  /// below the controls', and the size of every menu's rows. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family the word of an open menu, the rows' tint and the focus ring
  /// are drawn in.
  final NebaColor color;

  /// The rows' padding. The words keep the compact padding at either.
  /// Defaults to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which way the bar runs. A vertical bar opens its menus beside it, at its
  /// inline end, and the arrow keys follow it either way.
  final NebaOrientation orientation;

  /// Whether an open menu takes the page away: a press on it only closes the
  /// menu. The bar itself is left out, so the pointer can still cross it.
  final bool modal;

  /// Whether the arrow keys wrap around at the ends of the bar.
  final bool loopFocus;

  /// Disables every menu on the bar at once.
  final bool disabled;

  /// What a screen reader calls the bar, for a page that holds more than one.
  final String? semanticLabel;

  /// The height of a word at each size, one rung below the control ladder: a
  /// menu bar is a strip of words, and it usually sits inside something that
  /// already has a height of its own.
  static const Map<NebaSize, double> triggerHeight = <NebaSize, double>{
    NebaSize.xs: 18,
    NebaSize.sm: 22,
    NebaSize.md: 26,
    NebaSize.lg: 32,
    NebaSize.xl: 40,
  };

  @override
  State<NebaMenubar> createState() => _NebaMenubarState();
}

class _NebaMenubarState extends State<NebaMenubar> {
  final GlobalKey _bar = GlobalKey();
  final List<_NebaMenubarMenuState> _menus = <_NebaMenubarMenuState>[];
  final NebaTypeahead _typeahead = NebaTypeahead(resetAfter: nebaTypeaheadReset);
  _NebaMenubarMenuState? _open;
  _NebaMenubarMenuState? _stop;
  // Whether the menu that opens next replaces one that is open, and so lands
  // at once rather than fading: Base UI's `instant` for a menubar.
  bool _instant = false;

  bool get _vertical => widget.orientation == NebaOrientation.vertical;

  @override
  void dispose() {
    _typeahead.dispose();
    super.dispose();
  }

  void _register(_NebaMenubarMenuState menu) {
    if (!_menus.contains(menu)) {
      _menus.add(menu);
    }
  }

  void _unregister(_NebaMenubarMenuState menu) {
    _menus.remove(menu);

    if (identical(_open, menu)) {
      _open = null;
    }

    if (identical(_stop, menu)) {
      _stop = null;
    }
  }

  // The menus in reading order.
  List<_NebaMenubarMenuState> _ordered() {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final List<(double, _NebaMenubarMenuState)> placed = <(double, _NebaMenubarMenuState)>[];

    for (final _NebaMenubarMenuState menu in _menus) {
      final RenderObject? box = menu.context.findRenderObject();

      if (box is RenderBox && box.attached && box.hasSize) {
        final Offset at = box.localToGlobal(Offset.zero);
        placed.add((_vertical ? at.dy : (rtl ? -at.dx : at.dx), menu));
      }
    }

    placed.sort(
      ((double, _NebaMenubarMenuState) a, (double, _NebaMenubarMenuState) b) =>
          a.$1.compareTo(b.$1),
    );

    return <_NebaMenubarMenuState>[
      for (final (double _, _NebaMenubarMenuState menu) in placed) menu,
    ];
  }

  bool _isStop(_NebaMenubarMenuState menu) {
    final _NebaMenubarMenuState? stop = _stop;

    if (stop != null && !stop._disabled) {
      return identical(stop, menu);
    }

    // Before anything has had the focus, the first word that can take it.
    for (final _NebaMenubarMenuState candidate in _menus) {
      if (!candidate._disabled) {
        return identical(candidate, menu);
      }
    }

    return false;
  }

  void _setStop(_NebaMenubarMenuState menu) {
    if (!identical(_stop, menu)) {
      setState(() => _stop = menu);
    }
  }

  void _show(_NebaMenubarMenuState menu, NebaMenuFocus focus) {
    if (menu._disabled) {
      return;
    }

    menu._focus.request(focus);

    if (identical(_open, menu)) {
      return;
    }

    setState(() {
      _instant = _open != null;
      _open = menu;
      _stop = menu;
    });
  }

  void _hide(_NebaMenubarMenuState menu) {
    if (identical(_open, menu)) {
      setState(() {
        _instant = false;
        _open = null;
      });
    }
  }

  // The arrow along the bar from inside an open menu: the menu before it or
  // after it opens in its place, at its first row.
  void _cross(_NebaMenubarMenuState from, int direction) {
    final List<_NebaMenubarMenuState> menus = _ordered();
    final int index = menus.indexOf(from);

    if (index < 0) {
      return;
    }

    for (int step = 1; step < menus.length; step++) {
      int next = index + direction * step;

      if (next < 0 || next >= menus.length) {
        if (!widget.loopFocus) {
          return;
        }

        next = (next + menus.length) % menus.length;
      }

      if (!menus[next]._disabled) {
        _show(menus[next], NebaMenuFocus.first);

        return;
      }
    }
  }

  KeyEventResult _onTriggerKey(_NebaMenubarMenuState menu, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final List<_NebaMenubarMenuState> menus = _ordered();
    final int current = menus.indexOf(menu);
    final TextDirection direction = Directionality.of(context);
    final LogicalKeyboardKey key = event.logicalKey;

    final int? target = nebaRovingTarget(
      event,
      current: current,
      count: menus.length,
      axis: _vertical ? Axis.vertical : Axis.horizontal,
      textDirection: direction,
      loop: widget.loopFocus,
      focusable: (int index) => !menus[index]._disabled,
    );

    if (target != null) {
      menus[target]._node.requestFocus();

      return KeyEventResult.handled;
    }

    // The arrow across the bar opens the menu: down under a horizontal bar,
    // and towards the inline end beside a vertical one.
    final bool rtl = direction == TextDirection.rtl;
    final LogicalKeyboardKey opens = _vertical
        ? (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowDown;

    if (key == opens) {
      _show(menu, NebaMenuFocus.first);

      return KeyEventResult.handled;
    }

    if (!_vertical && key == LogicalKeyboardKey.arrowUp) {
      _show(menu, NebaMenuFocus.last);

      return KeyEventResult.handled;
    }

    final String? character = nebaTypeaheadCharacter(event);

    if (character != null) {
      final int? index = _typeahead.type(
        character,
        labels: <String?>[
          for (final _NebaMenubarMenuState other in menus)
            other._disabled ? null : nebaMenuTextOf(other.widget.label),
        ],
        current: current,
      );

      if (index != null) {
        menus[index]._node.requestFocus();
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;

    Widget bar = Flex(
      direction: _vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _vertical ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      spacing: NebaScale.gap[size]!,
      children: widget.children,
    );

    if (_vertical) {
      // As wide as the widest word, or the width it is given.
      bar = IntrinsicWidth(child: bar);
    }

    return _NebaMenubarScope(
      bar: this,
      size: size,
      color: widget.color,
      density: density,
      vertical: _vertical,
      modal: widget.modal,
      loop: widget.loopFocus,
      disabled: widget.disabled,
      open: _open,
      stop: _stop,
      instant: _instant,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        // A menu bar cannot be empty for a screen reader, which says so.
        role: widget.children.isEmpty ? null : SemanticsRole.menuBar,
        label: widget.semanticLabel,
        child: KeyedSubtree(key: _bar, child: bar),
      ),
    );
  }
}

/// What a menu on the bar takes from the bar.
class _NebaMenubarScope extends InheritedWidget {
  const _NebaMenubarScope({
    required this.bar,
    required this.size,
    required this.color,
    required this.density,
    required this.vertical,
    required this.modal,
    required this.loop,
    required this.disabled,
    required this.open,
    required this.stop,
    required this.instant,
    required super.child,
  });

  final _NebaMenubarState bar;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final bool vertical;
  final bool modal;
  final bool loop;
  final bool disabled;
  final _NebaMenubarMenuState? open;
  final _NebaMenubarMenuState? stop;
  final bool instant;

  static _NebaMenubarScope of(BuildContext context) {
    final _NebaMenubarScope? scope = context
        .dependOnInheritedWidgetOfExactType<_NebaMenubarScope>();

    if (scope == null) {
      throw FlutterError('A NebaMenubarMenu goes inside a NebaMenubar, and is in none.');
    }

    return scope;
  }

  @override
  bool updateShouldNotify(_NebaMenubarScope oldWidget) {
    return bar != oldWidget.bar ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        vertical != oldWidget.vertical ||
        modal != oldWidget.modal ||
        loop != oldWidget.loop ||
        disabled != oldWidget.disabled ||
        !identical(open, oldWidget.open) ||
        !identical(stop, oldWidget.stop) ||
        instant != oldWidget.instant;
  }
}

/// One menu on a [NebaMenubar]: the word, and the rows behind it.
///
/// It has no size, colour or density of its own: all three belong to the bar.
/// The rows are the same [NebaMenuItem], [NebaMenuSeparator], [NebaMenuGroup],
/// [NebaMenuCheckboxItem], [NebaMenuRadioGroup] and [NebaMenuSubmenu] a
/// [NebaMenu] takes, because it is the same menu.
class NebaMenubarMenu extends StatefulWidget {
  /// The word [label] on the bar, opening [children].
  const NebaMenubarMenu({
    required this.label,
    this.startIcon,
    this.disabled = false,
    this.children = const <Widget>[],
    super.key,
  });

  /// The word on the bar, usually a [Text].
  final Widget label;

  /// What goes before the word, at 1.2 times its size.
  final Widget? startIcon;

  /// Whether the word opens nothing. It stays on the bar, and the arrow keys
  /// pass over it.
  final bool disabled;

  /// The rows, written exactly as they are inside a [NebaMenu].
  final List<Widget> children;

  @override
  State<NebaMenubarMenu> createState() => _NebaMenubarMenuState();
}

class _NebaMenubarMenuState extends State<NebaMenubarMenu> implements NebaMenuRoot {
  final FocusNode _node = FocusNode(debugLabel: 'NebaMenubarMenu trigger');
  final NebaMenuFocusRequest _focus = NebaMenuFocusRequest();
  _NebaMenubarState? _bar;
  bool _barDisabled = false;

  bool get _disabled => widget.disabled || _barDisabled;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final _NebaMenubarState bar = _NebaMenubarScope.of(context).bar;

    if (!identical(bar, _bar)) {
      _bar?._unregister(this);
      _bar = bar;
      bar._register(this);
    }
  }

  @override
  void dispose() {
    _bar?._unregister(this);
    _node.removeListener(_onFocus);
    _node.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    // The word that last had the focus is the bar's one stop in the order.
    if (_node.hasFocus) {
      _bar?._setStop(this);
    }
  }

  void _toggle() {
    final _NebaMenubarState? bar = _bar;

    if (bar == null) {
      return;
    }

    if (identical(bar._open, this)) {
      bar._hide(this);
    } else {
      bar._show(this, NebaInputModality.pointer.value ? NebaMenuFocus.popup : NebaMenuFocus.first);
    }
  }

  void _onEnter(PointerEnterEvent event) {
    final _NebaMenubarState? bar = _bar;

    // Once a menu is open, the pointer walks the bar through the others.
    if (bar != null && bar._open != null && !identical(bar._open, this) && !_disabled) {
      bar._show(this, NebaMenuFocus.popup);
    }
  }

  void _onFocusOut(FocusNode focus) {
    // Walking to another word on the bar is the bar's business.
    for (final _NebaMenubarMenuState menu in _bar?._menus ?? <_NebaMenubarMenuState>[]) {
      if (focus == menu._node) {
        return;
      }
    }

    _bar?._hide(this);
  }

  @override
  void closeAll() => _bar?._hide(this);

  @override
  void tab({required bool forward}) {
    _bar?._hide(this);
    nebaMenuMoveOn(_node, forward: forward);
  }

  @override
  Widget build(BuildContext context) {
    final _NebaMenubarScope scope = _NebaMenubarScope.of(context);
    final _NebaMenubarState bar = scope.bar;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(scope.color);
    final NebaSize size = scope.size;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    _barDisabled = scope.disabled;
    final bool disabled = _disabled;
    final bool open = identical(scope.open, this) && !disabled;
    final double text = NebaScale.controlText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);

    // One stop for the whole bar, the word that last had the focus.
    _node.skipTraversal = !bar._isStop(this);

    final Widget? startIcon = widget.startIcon;
    final Widget word = Row(
      mainAxisSize: scope.vertical ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: NebaScale.gap[size]!,
      children: <Widget>[
        if (startIcon != null)
          IconTheme.merge(
            data: IconThemeData(size: text * 1.2),
            child: startIcon,
          ),
        Flexible(child: widget.label),
      ],
    );

    final Widget trigger = Semantics(
      container: true,
      role: SemanticsRole.menuItem,
      enabled: !disabled,
      expanded: open,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (FocusNode node, KeyEvent event) => bar._onTriggerKey(this, event),
        child: MouseRegion(
          opaque: false,
          onEnter: _onEnter,
          child: NebaInteractive(
            focusNode: _node,
            enabled: !disabled,
            onTap: _toggle,
            builder: (BuildContext context, NebaInteraction interaction, _) {
              const Color clear = Color(0x00000000);
              // Open is legible from across the bar, in colour and nothing
              // else: the word does not move and the strip keeps its height.
              final Color fill = disabled
                  ? clear
                  : open
                  ? roles.softHover
                  : interaction.hovered || interaction.pressed
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
                // Inside the word, which sits flush against its neighbours.
                offset: -focusRingWidth,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: fill),
                  duration: nebaDuration(
                    context,
                    NebaScale.durationFill,
                    instant: interaction.pressed,
                  ),
                  curve: NebaScale.ease,
                  builder: (BuildContext context, Color? tint, Widget? child) {
                    return DecoratedBox(
                      decoration: BoxDecoration(color: tint, borderRadius: radius),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    height: NebaMenubar.triggerHeight[size],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: NebaScale.paddingX[NebaDensity.compact]![size]!,
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
          ),
        ),
      ),
    );

    return NebaMenuScope(
      size: size,
      color: scope.color,
      density: scope.density,
      root: this,
      loop: scope.loop,
      child: NebaFloating(
        open: open,
        onOpenChange: (bool next, NebaFloatingReason reason) {
          if (!next) {
            bar._hide(this);
          }
        },
        // A vertical bar's menus open beside it, rather than over the word
        // below the one that opened them.
        side: scope.vertical ? (rtl ? NebaSide.left : NebaSide.right) : NebaSide.bottom,
        align: NebaAlign.start,
        sideOffset: 4,
        modal: scope.modal ? NebaModal.on : NebaModal.off,
        barrierCutout: bar._bar,
        instant: scope.instant,
        enabled: !disabled,
        popup: NebaMenuSheet(
          open: open,
          focus: _focus,
          returnFocus: () => _node,
          onFocusOut: _onFocusOut,
          // Along a horizontal bar the arrows walk to the menu beside this
          // one; beside a vertical one, back towards the bar closes it.
          onBack: scope.vertical ? () => bar._hide(this) : () => bar._cross(this, -1),
          onForward: scope.vertical ? null : () => bar._cross(this, 1),
          children: widget.children,
        ),
        child: trigger,
      ),
    );
  }
}
