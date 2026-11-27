/// `NebaMenu`, a list of actions that appears when a trigger is pressed, its
/// rows, and `NebaContextMenu`, the same rows opened by a right-click.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/menu.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/text_marks.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The control in [wrapper] that can take the focus: what a menu gives the
/// focus back to when it closes.
FocusNode? _focusableIn(FocusNode wrapper) {
  for (final FocusNode node in wrapper.descendants) {
    if (node.canRequestFocus && !node.skipTraversal && node is! FocusScopeNode) {
      return node;
    }
  }

  return null;
}

/// A list of actions that appears when a trigger is pressed.
///
/// The rows are written as widgets rather than passed as data, because each
/// carries its own handler and icon and some of them are submenus:
/// [NebaMenuItem], [NebaMenuCheckboxItem], a [NebaMenuRadioGroup] of
/// [NebaMenuRadioItem]s, [NebaMenuGroup], [NebaMenuSeparator] and
/// [NebaMenuSubmenu]. Their size, colour and density are the menu's.
///
/// A press on [trigger] opens the menu and a second press closes it, as do
/// Escape, a press outside and picking a row. The arrow keys, Home and End
/// move the highlight, letters move it to the row that starts with them,
/// Enter and Space pick the highlighted row, and Tab closes the menu and moves
/// on from the trigger. The focus comes back to the trigger when it closes.
///
/// ```dart
/// NebaMenu(
///   trigger: NebaButton(onPressed: () {}, child: const Text('Actions')),
///   children: <Widget>[
///     NebaMenuItem(onPressed: rename, child: const Text('Rename')),
///     const NebaMenuSeparator(),
///     NebaMenuItem(onPressed: delete, color: NebaColor.danger, child: const Text('Delete')),
///   ],
/// )
/// ```
class NebaMenu extends StatefulWidget {
  /// A menu of [children] opened by [trigger].
  const NebaMenu({
    this.trigger,
    this.children = const <Widget>[],
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.side = NebaSide.bottom,
    this.align = NebaAlign.start,
    this.sideOffset = 6,
    this.modal = true,
    this.openOnHover = false,
    this.loopFocus = true,
    this.disabled = false,
    super.key,
  });

  /// What opens the menu: a Neba control, such as a [NebaButton], whose press
  /// opens and closes the menu besides doing its own work. A button that is
  /// only a trigger takes `onPressed: () {}`, as a button with none is
  /// disabled. The Down and Up arrows on it open the menu at its first row and
  /// its last.
  ///
  /// Optional: a menu that is only ever opened through [open] needs none, and
  /// hangs off the point where it is written.
  final Widget? trigger;

  /// The rows.
  final List<Widget> children;

  /// The rows' type, padding and corners. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the popup's edge and of a row's tint under the pointer.
  /// The popup itself stays undyed.
  final NebaColor color;

  /// The rows' padding. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// Whether the menu is open. With [onOpenChange] the caller owns the state;
  /// without it the menu keeps its own.
  final bool? open;

  /// Whether a menu that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the menu opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// Which edge of the trigger it hangs off. It flips when there is no room.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// The distance from the trigger, in logical pixels.
  final double sideOffset;

  /// Whether the page behind is taken away while the menu is open: a press
  /// on it only closes the menu. The trigger is left pressable, so it can
  /// close what it opened.
  final bool modal;

  /// Whether the pointer resting on the trigger opens the menu as well as a
  /// press.
  final bool openOnHover;

  /// Whether the arrow keys wrap from the last row back to the first.
  final bool loopFocus;

  /// Whether the trigger stops opening the menu. The trigger is the caller's
  /// own widget, so it is drawn as it is: disable it as well.
  final bool disabled;

  @override
  State<NebaMenu> createState() => _NebaMenuState();
}

class _NebaMenuState extends State<NebaMenu> implements NebaMenuRoot {
  late bool _open = widget.defaultOpen;
  final NebaMenuFocusRequest _focus = NebaMenuFocusRequest();
  final GlobalKey _triggerKey = GlobalKey();
  final FocusNode _trigger = FocusNode(
    debugLabel: 'NebaMenu trigger',
    canRequestFocus: false,
    skipTraversal: true,
  );

  bool get _isOpen => widget.open ?? _open;

  @override
  void initState() {
    super.initState();

    // Open when it arrives: the popup takes the focus, as Base UI's does.
    if (_isOpen) {
      _focus.request(NebaMenuFocus.popup);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _trigger.dispose();
    super.dispose();
  }

  void _change(bool open, [NebaMenuFocus focus = NebaMenuFocus.popup]) {
    if (open && widget.disabled) {
      return;
    }

    if (open) {
      _focus.request(focus);
    }

    if (open == _isOpen) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
  }

  void _onFloating(bool open, NebaFloatingReason reason) {
    if (!open) {
      _change(false);

      return;
    }

    // A menu the keyboard opened starts on its first row; one a press opened
    // waits for the arrow keys; one the pointer opened by resting on the
    // trigger leaves the focus where it was.
    _change(
      true,
      reason == NebaFloatingReason.triggerHover
          ? NebaMenuFocus.none
          : NebaInputModality.pointer.value
          ? NebaMenuFocus.popup
          : NebaMenuFocus.first,
    );
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _change(true, NebaMenuFocus.first);

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _change(true, NebaMenuFocus.last);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onFocusOut(FocusNode focus) {
    if (focus == _trigger || focus.ancestors.contains(_trigger)) {
      return;
    }

    _change(false);
  }

  @override
  void closeAll() => _change(false);

  @override
  void tab({required bool forward}) {
    final FocusNode? trigger = _focusableIn(_trigger);
    _change(false);
    nebaMenuMoveOn(trigger, forward: forward);
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool open = _isOpen;

    return NebaMenuScope(
      size: size,
      color: widget.color,
      density: density,
      root: this,
      loop: widget.loopFocus,
      child: NebaFloating(
        open: open,
        onOpenChange: _onFloating,
        side: widget.side,
        align: widget.align,
        sideOffset: widget.sideOffset,
        openOnPress: true,
        hover: widget.openOnHover ? NebaFloatingHover(delay: () => nebaSubmenuDelay) : null,
        modal: widget.modal ? NebaModal.on : NebaModal.off,
        barrierCutout: _triggerKey,
        enabled: !widget.disabled,
        popup: NebaMenuSheet(
          open: open,
          focus: _focus,
          returnFocus: () => _focusableIn(_trigger),
          onFocusOut: _onFocusOut,
          children: widget.children,
        ),
        // One node, so the trigger says it is expanded as `aria-expanded`
        // does.
        child: MergeSemantics(
          child: Semantics(
            expanded: open,
            child: Focus(
              focusNode: _trigger,
              includeSemantics: false,
              onKeyEvent: _onTriggerKey,
              child: KeyedSubtree(
                key: _triggerKey,
                child: widget.trigger ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The same menu, opened by a right-click or a long press on an area of the
/// page instead of by a button.
///
/// It takes the rows as [content] and the area as [child], which it lays out
/// exactly as it would be laid out without it. The menu opens where the
/// pointer is. From the keyboard it opens with the context-menu key or
/// Shift+F10 while something inside [child] holds the focus, so an area that
/// cannot take the focus on its own goes inside a [Focus].
///
/// ```dart
/// NebaContextMenu(
///   content: <Widget>[NebaMenuItem(onPressed: copy, child: const Text('Copy'))],
///   child: const SizedBox(height: 120, child: Center(child: Text('Right-click here'))),
/// )
/// ```
class NebaContextMenu extends StatefulWidget {
  /// A menu of [content] opened on [child].
  const NebaContextMenu({
    required this.content,
    required this.child,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.loopFocus = true,
    this.disabled = false,
    super.key,
  });

  /// The rows, written exactly as they are inside a [NebaMenu].
  final List<Widget> content;

  /// The area that answers a right-click or a long press.
  final Widget child;

  /// The rows' type, padding and corners. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the popup's edge and of a row's tint under the pointer.
  final NebaColor color;

  /// The rows' padding. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// Whether the menu is open. With [onOpenChange] the caller owns the state.
  final bool? open;

  /// Whether a menu that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the menu opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// Whether the arrow keys wrap from the last row back to the first.
  final bool loopFocus;

  /// Whether the area stops answering a right-click and a long press.
  final bool disabled;

  /// Where the popup stands from the pointer: Base UI's `sideOffset` and
  /// `alignOffset` for a context menu, which put its corner just under the
  /// tip of the arrow.
  static const Offset pointerOffset = Offset(2, -5);

  @override
  State<NebaContextMenu> createState() => _NebaContextMenuState();
}

class _NebaContextMenuState extends State<NebaContextMenu> implements NebaMenuRoot {
  late bool _open = widget.defaultOpen;
  Offset _point = Offset.zero;
  final NebaMenuFocusRequest _focus = NebaMenuFocusRequest();
  final FocusNode _area = FocusNode(
    debugLabel: 'NebaContextMenu area',
    canRequestFocus: false,
    skipTraversal: true,
  );
  FocusNode? _returnTo;
  bool _hovered = false;
  bool _browserMenuHeld = false;

  bool get _isOpen => widget.open ?? _open;

  @override
  void initState() {
    super.initState();

    if (_isOpen) {
      _focus.request(NebaMenuFocus.popup);
    }
  }

  @override
  void didUpdateWidget(NebaContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncBrowserMenu();
  }

  @override
  void dispose() {
    if (_browserMenuHeld) {
      _browserMenuHeld = false;
      BrowserContextMenu.enableContextMenu();
    }

    _focus.dispose();
    _area.dispose();
    super.dispose();
  }

  // On the web the browser has a menu of its own for a right-click, which
  // would open over this one. It is held off while the pointer is over the
  // area or the menu is open, and only if the app had not held it off itself.
  void _syncBrowserMenu() {
    if (!kIsWeb) {
      return;
    }

    final bool hold = _hovered || _isOpen;

    if (hold && !_browserMenuHeld && BrowserContextMenu.enabled) {
      _browserMenuHeld = true;
      BrowserContextMenu.disableContextMenu();
    } else if (!hold && _browserMenuHeld) {
      _browserMenuHeld = false;
      BrowserContextMenu.enableContextMenu();
    }
  }

  void _change(bool open) {
    if (open == _isOpen) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
    _syncBrowserMenu();
  }

  void _openAt(Offset point, {required bool keyboard}) {
    if (widget.disabled) {
      return;
    }

    final FocusNode? primary = FocusManager.instance.primaryFocus;
    _returnTo = primary != null && primary.ancestors.contains(_area) ? primary : null;
    _focus.request(keyboard ? NebaMenuFocus.first : NebaMenuFocus.popup);
    setState(() => _point = point);
    _change(true);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse && (event.buttons & kSecondaryMouseButton) != 0) {
      _openAt(event.localPosition, keyboard: false);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final bool menuKey =
        event.logicalKey == LogicalKeyboardKey.contextMenu ||
        (event.logicalKey == LogicalKeyboardKey.f10 && HardwareKeyboard.instance.isShiftPressed);

    if (!menuKey || widget.disabled) {
      return KeyEventResult.ignored;
    }

    final Size? area = context.size;
    _openAt(area == null ? Offset.zero : area.center(Offset.zero), keyboard: true);

    return KeyEventResult.handled;
  }

  void _onFocusOut(FocusNode focus) {
    if (focus == _area || focus.ancestors.contains(_area)) {
      return;
    }

    _change(false);
  }

  @override
  void closeAll() => _change(false);

  @override
  void tab({required bool forward}) {
    final FocusNode? from = _returnTo;
    _change(false);
    nebaMenuMoveOn(from, forward: forward);
  }

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final bool open = _isOpen;

    // A point to hang the popup off, at the pointer, laid over the area
    // without taking any room in it.
    final Widget anchor = Positioned(
      left: _point.dx,
      top: _point.dy,
      child: NebaFloating(
        open: open,
        onOpenChange: (bool open, NebaFloatingReason reason) => _change(open),
        sideOffset: NebaContextMenu.pointerOffset.dy,
        alignOffset: NebaContextMenu.pointerOffset.dx,
        align: NebaAlign.start,
        modal: NebaModal.on,
        popup: NebaMenuSheet(
          open: open,
          focus: _focus,
          returnFocus: () => _returnTo,
          onFocusOut: _onFocusOut,
          children: widget.content,
        ),
        child: const SizedBox.shrink(),
      ),
    );

    return NebaMenuScope(
      size: size,
      color: widget.color,
      density: density,
      root: this,
      loop: widget.loopFocus,
      child: Stack(
        // The area is laid out exactly as it would be without the menu.
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: <Widget>[
          Focus(
            focusNode: _area,
            includeSemantics: false,
            onKeyEvent: _onKey,
            child: MouseRegion(
              opaque: false,
              onEnter: (PointerEnterEvent event) {
                _hovered = true;
                _syncBrowserMenu();
              },
              onExit: (PointerExitEvent event) {
                _hovered = false;
                _syncBrowserMenu();
              },
              // Anywhere in the area, whether or not something is drawn
              // there, and without taking the press from what is behind it.
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onPointerDown,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  supportedDevices: const <PointerDeviceKind>{
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                  },
                  onLongPressStart: widget.disabled
                      ? null
                      : (LongPressStartDetails details) =>
                            _openAt(details.localPosition, keyboard: false),
                  child: widget.child,
                ),
              ),
            ),
          ),
          anchor,
        ],
      ),
    );
  }
}

/// One row of a menu: an action, or a link.
///
/// Picking it runs [onPressed] and closes the menu, unless [closeOnPress] is
/// off. A row with no [onPressed] still closes the menu when it is picked,
/// and [disabled] is what stops it.
class NebaMenuItem extends StatelessWidget {
  /// A row labelled [child].
  const NebaMenuItem({
    this.child,
    this.onPressed,
    this.href,
    this.newTab = false,
    this.startIcon,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = true,
    this.disabled = false,
    this.label,
    super.key,
  });

  /// The label, usually a [Text], cut short with an ellipsis on one line.
  final Widget? child;

  /// What the row does. The package opens nothing itself, so a row that is a
  /// link follows its [href] here.
  final VoidCallback? onPressed;

  /// Where a row that is a link leads, for a screen reader and, on the web,
  /// the browser. Following it is [onPressed]'s. A scheme other than `http`,
  /// `https`, `mailto` or `tel` is not written, and a disabled row is not a
  /// link.
  final Uri? href;

  /// Whether the link opens somewhere other than here. A screen reader hears
  /// "(opens in a new tab)" after the label; opening it is [onPressed]'s.
  final bool newTab;

  /// What goes before the label: an icon, a swatch, muted and at 1.2 times
  /// the text's size through the [IconTheme] the row hands down.
  final Widget? startIcon;

  /// What goes after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing, set muted at the end: a [Text]
  /// or a [NebaShortcut]. Shown, never bound.
  final Widget? shortcut;

  /// A second line under the label, one step down the type scale and muted.
  final Widget? description;

  /// This row's family in place of the menu's: [NebaColor.danger] for the one
  /// that deletes. The label and the tint under the pointer turn over
  /// together.
  final NebaColor? color;

  /// Whether picking the row closes the menu.
  final bool closeOnPress;

  /// Whether the row does nothing. It stays listed, highlighted under the
  /// pointer and found by typeahead.
  final bool disabled;

  /// What typeahead matches against, when [child] is not a [Text].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final Uri? link = disabled ? null : nebaSafeHref(href);

    return NebaMenuRow(
      label: child,
      link: link,
      notice: link != null && newTab ? nebaMessages(context, 'link')['newTab'] : null,
      leading: startIcon,
      trailing: endIcon,
      shortcut: shortcut,
      description: description,
      color: color,
      disabled: disabled,
      typeahead: label,
      onActivate: () {
        onPressed?.call();

        if (closeOnPress) {
          menu.root.closeAll();
        }
      },
    );
  }
}

/// A row that ticks. The tick lands in the slot a [NebaMenuItem]'s
/// `startIcon` would, and the slot is kept while it is not ticked.
///
/// Ticking it leaves the menu open, since a list of things to tick is a list
/// you tick more than one of.
class NebaMenuCheckboxItem extends StatefulWidget {
  /// A row labelled [child] that ticks.
  const NebaMenuCheckboxItem({
    this.child,
    this.checked,
    this.defaultChecked = false,
    this.onCheckedChange,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = false,
    this.disabled = false,
    this.label,
    super.key,
  });

  /// The label.
  final Widget? child;

  /// Whether the row is ticked. With [onCheckedChange] the caller owns the
  /// state; without it the row keeps its own.
  final bool? checked;

  /// Whether a row that keeps its own state starts ticked.
  final bool defaultChecked;

  /// Called with the new state when the row is ticked or unticked.
  final ValueChanged<bool>? onCheckedChange;

  /// What goes after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing, set muted at the end.
  final Widget? shortcut;

  /// A second line under the label.
  final Widget? description;

  /// This row's family in place of the menu's.
  final NebaColor? color;

  /// Whether ticking the row closes the menu.
  final bool closeOnPress;

  /// Whether the row does nothing.
  final bool disabled;

  /// What typeahead matches against, when [child] is not a [Text].
  final String? label;

  @override
  State<NebaMenuCheckboxItem> createState() => _NebaMenuCheckboxItemState();
}

class _NebaMenuCheckboxItemState extends State<NebaMenuCheckboxItem> {
  late bool _checked = widget.defaultChecked;

  bool get _isChecked => widget.checked ?? _checked;

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final bool checked = _isChecked;

    return NebaMenuRow(
      role: SemanticsRole.menuItemCheckbox,
      checked: checked,
      label: widget.child,
      leading: checked ? NebaGlyph(NebaGlyphs.check) : null,
      leadingSlot: true,
      leadingAccent: true,
      trailing: widget.endIcon,
      shortcut: widget.shortcut,
      description: widget.description,
      color: widget.color,
      disabled: widget.disabled,
      typeahead: widget.label,
      onActivate: () {
        final bool next = !checked;

        if (widget.checked == null) {
          setState(() => _checked = next);
        }

        widget.onCheckedChange?.call(next);

        if (widget.closeOnPress) {
          menu.root.closeAll();
        }
      },
    );
  }
}

/// One choice out of a set of [NebaMenuRadioItem]s, which it holds.
///
/// Generic over the value, as [NebaRadioGroup] is: a `NebaMenuRadioGroup<String>`
/// holds `NebaMenuRadioItem<String>`s.
class NebaMenuRadioGroup<T> extends StatefulWidget {
  /// A set of [children] with one of them chosen.
  const NebaMenuRadioGroup({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.disabled = false,
    super.key,
  });

  /// The rows of the set, and anything else between them.
  final List<Widget> children;

  /// The chosen row's value. With [onValueChange] the caller owns the state;
  /// without it the group keeps its own.
  final T? value;

  /// The value a group that keeps its own state starts on.
  final T? defaultValue;

  /// Called with the value of a row when another one is chosen.
  final ValueChanged<T>? onValueChange;

  /// Whether every row of the set does nothing.
  final bool disabled;

  @override
  State<NebaMenuRadioGroup<T>> createState() => _NebaMenuRadioGroupState<T>();
}

class _NebaMenuRadioGroupState<T> extends State<NebaMenuRadioGroup<T>> {
  late T? _value = widget.defaultValue;

  T? get _current => widget.value ?? _value;

  void _choose(T value) {
    if (value == _current) {
      return;
    }

    if (widget.value == null) {
      setState(() => _value = value);
    }

    widget.onValueChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return _MenuRadioScope<T>(
      value: _current,
      disabled: widget.disabled,
      choose: _choose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
  }
}

class _MenuRadioScope<T> extends InheritedWidget {
  const _MenuRadioScope({
    required this.value,
    required this.disabled,
    required this.choose,
    required super.child,
  });

  final T? value;
  final bool disabled;
  final ValueChanged<T> choose;

  @override
  bool updateShouldNotify(_MenuRadioScope<T> oldWidget) {
    return value != oldWidget.value || disabled != oldWidget.disabled || choose != oldWidget.choose;
  }
}

/// A row inside a [NebaMenuRadioGroup], marked with a dot rather than a tick:
/// a tick says "and", a dot says "instead of".
class NebaMenuRadioItem<T> extends StatelessWidget {
  /// A row that sets the group to [value].
  const NebaMenuRadioItem({
    required this.value,
    this.child,
    this.endIcon,
    this.shortcut,
    this.description,
    this.color,
    this.closeOnPress = false,
    this.disabled = false,
    this.label,
    super.key,
  });

  /// What this row sets the group to.
  final T value;

  /// The label.
  final Widget? child;

  /// What goes after the label, before any [shortcut].
  final Widget? endIcon;

  /// The keystroke that does the same thing, set muted at the end.
  final Widget? shortcut;

  /// A second line under the label.
  final Widget? description;

  /// This row's family in place of the menu's.
  final NebaColor? color;

  /// Whether choosing the row closes the menu.
  final bool closeOnPress;

  /// Whether the row does nothing.
  final bool disabled;

  /// What typeahead matches against, when [child] is not a [Text].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final _MenuRadioScope<T>? group = context
        .dependOnInheritedWidgetOfExactType<_MenuRadioScope<T>>();

    assert(
      group != null,
      'A NebaMenuRadioItem<$T> goes inside a NebaMenuRadioGroup<$T>, and is in none.',
    );

    final bool checked = group != null && group.value == value;

    return NebaMenuRow(
      role: SemanticsRole.menuItemRadio,
      checked: checked,
      mutuallyExclusive: true,
      label: child,
      leading: checked ? NebaGlyph(NebaGlyphs.dot) : null,
      leadingSlot: true,
      leadingAccent: true,
      trailing: endIcon,
      shortcut: shortcut,
      description: description,
      color: color,
      disabled: disabled || (group?.disabled ?? false),
      typeahead: label,
      onActivate: () {
        group?.choose(value);

        if (closeOnPress) {
          menu.root.closeAll();
        }
      },
    );
  }
}

/// A named run of rows. The [label] is a heading over them, not a row, and
/// cannot be picked; a screen reader hears it as the group's name.
class NebaMenuGroup extends StatelessWidget {
  /// A group of [children] under [label].
  const NebaMenuGroup({this.label, this.children = const <Widget>[], super.key});

  /// The heading, usually a [Text], set in small capitals of its own.
  final Widget? label;

  /// The rows in the group.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final NebaTokens tokens = NebaTheme.of(context);
    final Widget? label = this.label;
    final String? name = nebaMenuTextOf(label);
    Widget? heading;

    if (label != null) {
      final double meta = NebaScale.metaText[menu.size]!;
      final double leading = NebaScale.controlLeading[menu.size]!;
      final String? text = label is Text ? label.data : null;

      heading = Padding(
        padding: NebaMenuRow.padding[menu.density]![menu.size]!,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: meta,
            height: leading / meta,
            leadingDistribution: TextLeadingDistribution.even,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025 * meta,
            color: tokens.mutedFg,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          // Upper case is how it is drawn, not what it says: the name read
          // out is the label as written.
          child: label is Text && text != null
              ? nebaRetext(label, TextSpan(text: text.toUpperCase()))
              : label,
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (heading != null) ExcludeSemantics(excluding: name != null, child: heading),
          ...children,
        ],
      ),
    );
  }
}

/// The hairline between two runs of rows, drawn across the whole popup.
class NebaMenuSeparator extends StatelessWidget {
  /// A hairline.
  const NebaMenuSeparator({super.key});

  /// The room above and below the line.
  static const double gap = 4;

  @override
  Widget build(BuildContext context) {
    final NebaMenuScope menu = NebaMenuScope.of(context);
    final Color line = NebaTheme.of(context).roles(menu.color).line;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: gap),
        child: CustomPaint(size: const Size(0, 1), painter: _SeparatorPainter(line)),
      ),
    );
  }
}

/// The line, run out over the popup's padding to its edge.
class _SeparatorPainter extends CustomPainter {
  _SeparatorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(-nebaMenuPadding, 0, size.width + 2 * nebaMenuPadding, size.height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SeparatorPainter oldDelegate) => oldDelegate.color != color;
}

/// A menu inside a menu: a row with a chevron that opens a popup of more rows
/// beside it.
///
/// It opens when the pointer rests on its row, when the row is pressed, and
/// on Enter, Space or the arrow that points at it, with its first row
/// highlighted from the keyboard; the arrow that points back, and Escape,
/// close it and give the focus back to its row. A reach from the row into
/// the popup across the rows below it leaves it open. Nesting is unlimited:
/// one of [children] can be another submenu.
class NebaMenuSubmenu extends StatefulWidget {
  /// A row labelled [label] that opens [children].
  const NebaMenuSubmenu({
    this.label,
    this.startIcon,
    this.disabled = false,
    this.side,
    this.sideOffset = 4,
    this.children = const <Widget>[],
    super.key,
  });

  /// The label on the row that opens it.
  final Widget? label;

  /// What goes before the label.
  final Widget? startIcon;

  /// Whether the row opens nothing.
  final bool disabled;

  /// Which edge of the row it opens against. Left out, the row's inline end:
  /// the right, or the left in a right-to-left layout.
  final NebaSide? side;

  /// The distance from the menu it opens from, in logical pixels.
  final double sideOffset;

  /// The nested rows.
  final List<Widget> children;

  @override
  State<NebaMenuSubmenu> createState() => _NebaMenuSubmenuState();
}

class _NebaMenuSubmenuState extends State<NebaMenuSubmenu> implements NebaMenuSubmenuHandle {
  bool _open = false;
  bool _pointerInside = false;
  // Whether the popup this one opens from is open, as last built.
  bool _levelOpen = true;
  NebaMenuLevel? _level;
  final FocusNode _node = FocusNode(debugLabel: 'NebaMenuSubmenu row', skipTraversal: true);
  final NebaMenuFocusRequest _focus = NebaMenuFocusRequest();

  @override
  FocusNode get triggerNode => _node;

  @override
  bool get pointerInside => _pointerInside;

  @override
  void dispose() {
    _level?.submenuClosed(this);
    _focus.dispose();
    _node.dispose();
    super.dispose();
  }

  @override
  void close() {
    _level?.submenuClosed(this);

    if (_open && mounted) {
      setState(() => _open = false);
    }
  }

  void _show(NebaMenuFocus focus) {
    if (widget.disabled || !_levelOpen || !mounted) {
      return;
    }

    _focus.request(focus);

    if (!_open) {
      setState(() => _open = true);
    }

    _level?.submenuOpened(this);
  }

  @override
  Widget build(BuildContext context) {
    final NebaMenuLevelScope? scope = NebaMenuLevelScope.maybeOf(context);
    _level = scope?.level;
    _levelOpen = scope?.open ?? true;

    // A submenu closes with the popup it is in.
    if (!_levelOpen) {
      _open = false;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool open = _open;

    return NebaFloating(
      open: open,
      onOpenChange: (bool open, NebaFloatingReason reason) {
        if (open) {
          _show(NebaMenuFocus.none);
        } else {
          close();
        }
      },
      side: widget.side ?? (rtl ? NebaSide.left : NebaSide.right),
      align: NebaAlign.start,
      sideOffset: widget.sideOffset,
      hover: widget.disabled ? null : NebaFloatingHover(delay: () => nebaSubmenuDelay),
      enabled: !widget.disabled,
      popup: MouseRegion(
        opaque: false,
        onEnter: (PointerEnterEvent event) => _pointerInside = true,
        onExit: (PointerExitEvent event) => _pointerInside = false,
        child: NebaMenuSheet(
          open: open,
          focus: _focus,
          // Back to the row, unless the whole menu is closing.
          returnFocus: () => _levelOpen ? _node : null,
          onBack: close,
          children: widget.children,
        ),
      ),
      child: NebaMenuRow(
        focusNode: _node,
        label: widget.label,
        leading: widget.startIcon,
        chevron: true,
        expanded: open,
        popupOpen: open,
        disabled: widget.disabled,
        onActivate: () =>
            _show(NebaInputModality.pointer.value ? NebaMenuFocus.none : NebaMenuFocus.first),
        onOpenSubmenu: () {
          if (widget.disabled) {
            return false;
          }

          _show(NebaMenuFocus.first);

          return true;
        },
      ),
    );
  }
}
