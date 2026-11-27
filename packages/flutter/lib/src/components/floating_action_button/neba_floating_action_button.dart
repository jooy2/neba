/// `NebaFloatingActionButton` and `NebaFloatingAction`, the one action a
/// screen is about, floating over it, and the actions that fan out of it.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/icon_button/neba_icon_button.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/pin.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Where a floating button sits: [NebaPosition]'s three values and the
/// fourth CSS one, [absolute], which makes it belong to a region rather than
/// to the screen.
///
/// Flutter has no positioning against the window, so every value but
/// [static] floats the same way: the button takes the whole of the space it
/// is laid out in and sits in its corner. Put it in a `Stack` over the screen
/// or the region it floats over. What differs is whether it keeps clear of the
/// system insets.
enum NebaFloatingActionButtonPosition {
  /// In the flow, as any other button: in a toolbar or a row.
  static,

  /// Over the region it is in, clear of the system insets on the edges of its
  /// corner, as [fixed] is.
  sticky,

  /// Over the screen it is in, in its corner and clear of the system insets
  /// on the two edges the corner is against.
  fixed,

  /// Over the region it is in, in its corner: a card, a map, a preview. The
  /// region is not against the edge of the screen, so the insets are left
  /// alone.
  absolute,
}

/// Which way a floating button's actions fan out from it. Physical rather
/// than logical, because above is above in every writing direction, and never
/// sideways, which out of a corner is into the edge of the screen.
enum NebaFloatingActionButtonDirection {
  /// Up from the button.
  top,

  /// Down from the button.
  bottom,
}

/// The one action a screen is about, floating over it: a round button on a
/// shadow, two steps up the elevation ladder from everything resting on the
/// page. Given [children], it is a dial: pressing it, or resting a mouse on
/// it, fans the actions out and swaps the glyph for a ×.
///
/// The button is a `NebaButton` cut round, so the variants, the elevation
/// ladder, the light and the press are the ones every control has. Its
/// [label] is its name for a screen reader and, [extended], the word written
/// beside the glyph. The dial is not a menu: the actions are buttons in the
/// focus order right after the one that revealed them, Escape and a press
/// anywhere else put them away, and pressing one runs it and puts them away
/// too, with the focus given back to the button.
///
/// With [position] anything but static, the button takes the whole of the
/// space it is laid out in and sits in its [corner], so it goes in a `Stack`
/// over the screen or the region it belongs to:
///
/// ```dart
/// Stack(
///   children: <Widget>[
///     page,
///     NebaFloatingActionButton(label: 'Compose', icon: pencil, onPressed: compose),
///   ],
/// )
/// ```
///
/// A slot that places its child itself, such as a Material `Scaffold`'s
/// `floatingActionButton`, takes it with [NebaFloatingActionButtonPosition.static].
class NebaFloatingActionButton extends StatefulWidget {
  /// A floating button named [label].
  const NebaFloatingActionButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.openIcon,
    this.extended = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.position = NebaFloatingActionButtonPosition.fixed,
    this.corner = NebaCorner.bottomEnd,
    this.offset = 16,
    this.safeArea = true,
    this.direction,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.openOnHover = true,
    this.closeOnAction = true,
    this.showLabels = true,
    this.disabled = false,
    this.children = const <NebaFloatingAction>[],
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       ),
       assert(offset >= 0);

  /// What the button does, in words. Required, because a button whose whole
  /// label is a drawing has no name at all; with [extended] it is also the
  /// word written on the button, so the two never differ.
  final String label;

  /// Called when the button is pressed. It is still called when the button
  /// has [children], where the press also opens and closes the dial. With no
  /// [onPressed] and no [children] the button is disabled, as every Flutter
  /// button is.
  final VoidCallback? onPressed;

  /// The glyph on the button. Defaults to a plus.
  final Widget? icon;

  /// The glyph while the dial is open. Defaults to a ×; pass the same widget
  /// as [icon] to keep the glyph unchanged.
  final Widget? openIcon;

  /// Writes [label] beside the glyph, which turns the disc into a stadium:
  /// the extended floating button, for the one action a screen is about.
  final bool extended;

  /// The weight of the button, as on `NebaButton`. Defaults to
  /// `NebaProvider`'s, then [NebaVariant.solid].
  final NebaVariant? variant;

  /// The button's height. The ladder `NebaButton` is on, started a step up
  /// at [NebaSize.lg], because this is the one control on a screen that has
  /// to be found and hit with a thumb without being looked at. Defaults to
  /// `NebaProvider`'s, then [NebaSize.lg]. The actions are a step down.
  final NebaSize? size;

  /// The colour family. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The extended button's inline padding. Defaults to `NebaProvider`'s,
  /// then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `2`: the button is defined
  /// by not being part of the page, and hovers over whatever is under it.
  final NebaElevation? elevation;

  /// Where the button sits. Anything but
  /// [NebaFloatingActionButtonPosition.static] floats it in its [corner] of
  /// the space it is laid out in.
  final NebaFloatingActionButtonPosition position;

  /// Which corner it is pinned to. Logical, so the end corners flip under a
  /// right-to-left direction.
  final NebaCorner corner;

  /// How far in from both edges of its corner, in logical pixels.
  final double offset;

  /// Adds the system insets of the two edges the corner is against to
  /// [offset], so a button in the bottom corner of a phone clears its home
  /// indicator and, held sideways, its notch. Only a fixed or a sticky button
  /// is against the edge of the screen.
  final bool safeArea;

  /// Which way the actions fan out. Left out, they fan up from a bottom
  /// corner and down from a top one.
  final NebaFloatingActionButtonDirection? direction;

  /// Whether the dial is open, for a controlled dial. Leave it `null` and the
  /// button keeps its own state, starting from [defaultOpen].
  final bool? open;

  /// Whether an uncontrolled dial starts open.
  final bool defaultOpen;

  /// Called when the dial asks to open or to close.
  final ValueChanged<bool>? onOpenChange;

  /// Opens the dial when a mouse arrives on the button, and closes it when
  /// the mouse leaves. Touch and a pen are left out: there is no hovering
  /// with a finger, and a dial that opened on the first half of a tap would
  /// swallow the second.
  final bool openOnHover;

  /// Closes the dial when one of the actions is pressed.
  final bool closeOnAction;

  /// Draws each action's name on a lozenge beside it. Turned off, the names
  /// are still heard: each is its action's `label`.
  final bool showLabels;

  /// The button and every action stop answering, and the dial does not open.
  final bool disabled;

  /// The actions, if there are any.
  final List<NebaFloatingAction> children;

  /// The button's focus node, which is also where the focus goes back to when
  /// the dial closes.
  final FocusNode? focusNode;

  /// Whether the button takes the focus when it is first built.
  final bool autofocus;

  /// An action's size, one step down the ladder from the button's, so what
  /// was pressed stays the largest object in the corner. `xs` stays where it
  /// is: a dial of half-size `xs` buttons would be too small to hit.
  static const Map<NebaSize, NebaSize> actionSizes = <NebaSize, NebaSize>{
    NebaSize.xs: NebaSize.xs,
    NebaSize.sm: NebaSize.xs,
    NebaSize.md: NebaSize.sm,
    NebaSize.lg: NebaSize.md,
    NebaSize.xl: NebaSize.lg,
  };

  @override
  State<NebaFloatingActionButton> createState() => _NebaFloatingActionButtonState();
}

class _NebaFloatingActionButtonState extends State<NebaFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late bool _uncontrolled = widget.defaultOpen;

  /// The dial arriving, in opacity and nothing else: these are buttons with
  /// words beside them, and a dial that slid would move the action the finger
  /// was already travelling to.
  late final AnimationController _fade = AnimationController(vsync: this);

  /// The frame the button and the dial are drawn in: a press outside it puts
  /// the dial away.
  final GlobalKey _frame = GlobalKey();

  FocusNode? _ownFocus;

  /// Whether the dial is up because a mouse arrived rather than because the
  /// button was pressed, so the click that follows the mouse onto the button
  /// keeps the dial it was reaching for.
  bool _openedByHover = false;

  /// Whether the dial was open at the last look, which is what starts the
  /// fade and the watch for a press outside.
  bool _shown = false;
  bool _routed = false;

  FocusNode get _trigger {
    return widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'NebaFloatingActionButton'));
  }

  bool get _hasActions => widget.children.isNotEmpty;

  bool get _open => (widget.open ?? _uncontrolled) && _hasActions && !widget.disabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fade.duration = nebaDuration(context, NebaScale.duration);
    _follow();
  }

  @override
  void didUpdateWidget(NebaFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _follow();
  }

  @override
  void dispose() {
    _watch(false);
    _fade.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  /// Starts the fade when the dial has just opened, and watches for a press
  /// outside for as long as it is open.
  void _follow() {
    final bool open = _open;

    if (open && !_shown) {
      _fade.forward(from: 0);
    }

    if (!open) {
      _openedByHover = false;
    }

    _shown = open;
    _watch(open);
  }

  void _watch(bool on) {
    if (on == _routed) {
      return;
    }

    _routed = on;

    if (on) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
      HardwareKeyboard.instance.addHandler(_onKey);
    } else {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
      HardwareKeyboard.instance.removeHandler(_onKey);
    }
  }

  void _setOpen(bool next) {
    if (next == _open) {
      return;
    }

    if (widget.open == null) {
      setState(() => _uncontrolled = next);
    }

    widget.onOpenChange?.call(next);
    _follow();
  }

  /// A press anywhere else puts the dial away, on the pointer going down, so
  /// it is gone before whatever was pressed answers.
  void _onPointer(PointerEvent event) {
    if (event is! PointerDownEvent || !_open) {
      return;
    }

    final RenderObject? frame = _frame.currentContext?.findRenderObject();

    if (frame is! RenderBox || !frame.attached || !frame.hasSize) {
      return;
    }

    if (!(Offset.zero & frame.size).contains(frame.globalToLocal(event.position))) {
      _setOpen(false);
    }
  }

  void _press() {
    if (_hasActions) {
      if (_open && _openedByHover) {
        _openedByHover = false;
      } else {
        _setOpen(!_open);
      }
    }

    widget.onPressed?.call();
  }

  /// Escape puts the dial away wherever the focus is, as it does a popup's:
  /// a press does not move the focus onto a Flutter button the way a click
  /// does onto a browser's, so a dial opened with the pointer would otherwise
  /// be deaf to it. The focus goes back to the button only from inside the
  /// dial, and is left alone anywhere else.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape || !_open) {
      return false;
    }

    final bool inside = _holdsFocus();
    _setOpen(false);

    if (inside) {
      _trigger.requestFocus();
    }

    return true;
  }

  /// Whether the focus is on the button or on one of its actions.
  bool _holdsFocus() {
    final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
    final BuildContext? frame = _frame.currentContext;

    if (focused == null || frame == null) {
      return false;
    }

    bool inside = false;

    focused.visitAncestorElements((Element element) {
      inside = element == frame;
      return !inside;
    });

    return inside;
  }

  void _onEnter(PointerEnterEvent event) {
    if (widget.openOnHover &&
        _hasActions &&
        !widget.disabled &&
        event.kind == PointerDeviceKind.mouse) {
      _openedByHover = !_open;
      _setOpen(true);
    }
  }

  void _onExit(PointerExitEvent event) {
    if (widget.openOnHover && event.kind == PointerDeviceKind.mouse) {
      _openedByHover = false;
      _setOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.solid;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.lg;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaElevation elevation = widget.elevation ?? 2;
    final bool open = _open;
    final NebaCorner corner = widget.corner;
    final bool bottom = corner == NebaCorner.bottomStart || corner == NebaCorner.bottomEnd;
    final bool atEnd = corner == NebaCorner.topEnd || corner == NebaCorner.bottomEnd;
    final bool up =
        (widget.direction ??
            (bottom
                ? NebaFloatingActionButtonDirection.top
                : NebaFloatingActionButtonDirection.bottom)) ==
        NebaFloatingActionButtonDirection.top;
    final double gap = size == NebaSize.xs || size == NebaSize.sm ? 6 : 8;
    final bool enabled = !widget.disabled && (_hasActions || widget.onPressed != null);
    final VoidCallback? press = enabled ? _press : null;

    // The glyph swaps rather than turning: nothing on the control on top of
    // everything else moves.
    final Widget glyph = open
        ? (widget.openIcon ?? NebaGlyph(NebaGlyphs.close))
        : (widget.icon ?? NebaGlyph(NebaGlyphs.plus));

    Widget trigger = widget.extended
        // A stadium, through the radius ladder the button reads, as an
        // IconButton cuts its disc: the radius is only ever half the height.
        ? NebaTheme(
            tokens: tokens.copyWith(
              radius: <NebaSize, double>{for (final NebaSize step in NebaSize.values) step: 9999},
            ),
            defaults: defaults,
            child: NebaButton(
              onPressed: press,
              variant: variant,
              size: size,
              color: color,
              density: density,
              elevation: elevation,
              startIcon: glyph,
              semanticLabel: widget.label,
              focusNode: _trigger,
              autofocus: widget.autofocus,
              child: Text(widget.label),
            ),
          )
        : NebaIconButton(
            onPressed: press,
            icon: glyph,
            label: widget.label,
            variant: variant,
            size: size,
            color: color,
            density: density,
            elevation: elevation,
            focusNode: _trigger,
            autofocus: widget.autofocus,
          );

    // One node with the button's own, so the dial's state is said on the
    // button rather than on something around it.
    trigger = MergeSemantics(
      child: Semantics(expanded: _hasActions ? open : null, child: trigger),
    );

    final CrossAxisAlignment across = atEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    // The button comes first in the tree whichever way the dial fans, so the
    // focus goes from it to what came out of it; drawing the column upwards
    // is what puts the actions above it.
    final VerticalDirection fan = up ? VerticalDirection.up : VerticalDirection.down;

    Widget frame = Column(
      mainAxisSize: MainAxisSize.min,
      verticalDirection: fan,
      crossAxisAlignment: across,
      spacing: gap,
      children: <Widget>[
        trigger,
        if (open)
          FadeTransition(
            opacity: _fade,
            child: _DialScope(
              variant: variant,
              size: NebaFloatingActionButton.actionSizes[size]!,
              color: color,
              density: density,
              elevation: elevation,
              showLabels: widget.showLabels,
              atEnd: atEnd,
              closesOnAction: widget.closeOnAction,
              close: widget.closeOnAction ? () => _setOpen(false) : () {},
              focusTrigger: () => _trigger.requestFocus(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                verticalDirection: fan,
                crossAxisAlignment: across,
                spacing: gap,
                children: widget.children,
              ),
            ),
          ),
      ],
    );

    frame = MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: FocusTraversalGroup(policy: WidgetOrderTraversalPolicy(), child: frame),
    );

    frame = KeyedSubtree(key: _frame, child: frame);

    if (widget.position == NebaFloatingActionButtonPosition.static) {
      return frame;
    }

    return NebaPin(
      alignment: switch (corner) {
        NebaCorner.topStart => AlignmentDirectional.topStart,
        NebaCorner.topEnd => AlignmentDirectional.topEnd,
        NebaCorner.bottomStart => AlignmentDirectional.bottomStart,
        NebaCorner.bottomEnd => AlignmentDirectional.bottomEnd,
      },
      offset: widget.offset,
      safeArea:
          widget.safeArea &&
          (widget.position == NebaFloatingActionButtonPosition.fixed ||
              widget.position == NebaFloatingActionButtonPosition.sticky),
      child: frame,
    );
  }
}

/// One action in a `NebaFloatingActionButton`'s dial: a round button with
/// its name on a lozenge beside it, on the inside of the corner the dial hangs
/// from.
///
/// It has no `size`, `color` or `variant` of its own: all three belong to the
/// button it came out of, and the action is drawn a step down its ladder.
class NebaFloatingAction extends StatefulWidget {
  /// An action named [label].
  const NebaFloatingAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.disabled = false,
    super.key,
  });

  /// What the action does, in words: drawn beside it, and always its name for
  /// a screen reader.
  final String label;

  /// The glyph.
  final Widget? icon;

  /// Called when the action is pressed, before the dial closes.
  final VoidCallback? onPressed;

  /// Unavailable, but still part of the dial.
  final bool disabled;

  @override
  State<NebaFloatingAction> createState() => _NebaFloatingActionState();
}

class _NebaFloatingActionState extends State<NebaFloatingAction> {
  final FocusNode _focus = FocusNode(debugLabel: 'NebaFloatingAction');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _DialScope? found = context.dependOnInheritedWidgetOfExactType<_DialScope>();

    assert(() {
      if (found == null) {
        throw FlutterError(
          'A NebaFloatingAction was built outside a NebaFloatingActionButton.\n'
          'An action draws itself from the button it fans out of, so it has to be '
          "one of a NebaFloatingActionButton's children.",
        );
      }
      return true;
    }());

    final _DialScope dial = found!;
    final NebaTokens tokens = NebaTheme.of(context);

    final Widget button = NebaIconButton(
      onPressed: widget.disabled
          ? null
          : () {
              // Read before anything closes: the dial and this button leave
              // together, and a focus that went with them would land nowhere.
              final bool hadFocus = _focus.hasPrimaryFocus;

              widget.onPressed?.call();
              dial.close();

              if (hadFocus && dial.closesOnAction) {
                dial.focusTrigger();
              }
            },
      icon: widget.icon ?? const SizedBox.shrink(),
      label: widget.label,
      variant: dial.variant,
      size: dial.size,
      color: dial.color,
      density: dial.density,
      elevation: dial.elevation,
      focusNode: _focus,
    );

    if (!dial.showLabels) {
      return button;
    }

    // Not heard: the button beside it already carries the same words as its
    // name, and would be announced twice.
    final Widget name = ExcludeSemantics(
      child: IgnorePointer(
        child: NebaSheet(
          fill: tokens.panel,
          plate: NebaPlate.glass,
          elevation: 1,
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.xs]!),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                widget.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.fg,
                  fontSize: NebaScale.metaText[dial.size],
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // The name goes on the inside of the corner the dial hangs from, so it is
    // drawn over the page rather than off the edge of it.
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: dial.atEnd ? <Widget>[name, button] : <Widget>[button, name],
    );
  }
}

/// What an action takes from the button it fans out of.
class _DialScope extends InheritedWidget {
  const _DialScope({
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.elevation,
    required this.showLabels,
    required this.atEnd,
    required this.closesOnAction,
    required this.close,
    required this.focusTrigger,
    required super.child,
  });

  final NebaVariant variant;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final NebaElevation elevation;
  final bool showLabels;

  /// Whether the button is in an end corner, which puts each name before its
  /// action.
  final bool atEnd;

  /// Whether pressing an action closes the dial, and so takes the action
  /// away from under the focus.
  final bool closesOnAction;

  /// Asks the dial to close; nothing when [closesOnAction] is off.
  final VoidCallback close;

  /// Puts the focus back on the button the dial came out of.
  final VoidCallback focusTrigger;

  @override
  bool updateShouldNotify(_DialScope oldWidget) {
    return variant != oldWidget.variant ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        elevation != oldWidget.elevation ||
        showLabels != oldWidget.showLabels ||
        atEnd != oldWidget.atEnd ||
        closesOnAction != oldWidget.closesOnAction ||
        close != oldWidget.close ||
        focusTrigger != oldWidget.focusTrigger;
  }
}
