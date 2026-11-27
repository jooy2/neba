/// `NebaTabs`, `NebaTab` and `NebaTabPanel`: one of several panels shown in
/// the same place, chosen from a bar of tabs.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/scroll_fade.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';
import 'package:neba/src/internal/wheel.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// What a [NebaTabs] bar with more tabs than room does about it.
enum NebaTabsOverflow {
  /// Stays one line and scrolls along it. The ends fade while there is more
  /// bar in that direction, which is the only cue: the scrollbar is hidden.
  scroll,

  /// Takes as many lines as it needs, and the indicator rides the line its
  /// tab is on. For a bar whose tabs all have to be visible at once.
  wrap,
}

/// The gap between the bar and the panel, CSS `gap-4`.
const double _gap = 16;

/// The solid trough's padding around the tabs, CSS `p-1`.
const double _troughPadding = 4;

/// How far the fade reaches in from an edge with more bar beyond it, CSS
/// `2rem`.
const double _fade = 32;

/// One of several panels shown in the same place, chosen from a bar of tabs.
///
/// The [children] are `NebaTab`s and `NebaTabPanel`s side by side, sorted
/// into the bar and the panel area by their type, so there is no list wrapper
/// to remember. A tab picks out the panel with the same `value`.
///
/// The bar is one stop in the focus order: the arrow keys along it move the
/// focus between the tabs, Home and End go to the ends, and Enter or Space
/// chooses the focused tab, or the arrows choose as they go with
/// [activateOnFocus]. The indicator slides to the chosen tab by its
/// rectangle, never by a transform. A screen reader hears a tab bar of tabs,
/// the chosen one selected, and each panel named after its tab.
///
/// Controlled with [value] and [onValueChange], or left to keep its own state
/// from [defaultValue].
///
/// ```dart
/// const NebaTabs<String>(
///   defaultValue: 'overview',
///   children: <Widget>[
///     NebaTab<String>(value: 'overview', child: Text('Overview')),
///     NebaTab<String>(value: 'usage', child: Text('Usage')),
///     NebaTabPanel<String>(value: 'overview', child: Text('Three deploys today.')),
///     NebaTabPanel<String>(value: 'usage', child: Text('1,284 build minutes.')),
///   ],
/// )
/// ```
class NebaTabs<T> extends StatefulWidget {
  /// A set of [children]: `NebaTab`s and `NebaTabPanel`s.
  const NebaTabs({
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.orientation = NebaOrientation.horizontal,
    this.activateOnFocus = false,
    this.loopFocus = true,
    this.overflow = NebaTabsOverflow.scroll,
    this.lines,
    this.wheel = true,
    this.fullWidth = false,
    this.align = NebaAlign.center,
    this.keepMounted = false,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.semanticLabel,
    super.key,
  }) : assert(lines == null || lines > 0);

  /// The tabs and the panels. A `NebaTabPanel` goes to the panel area, and
  /// everything else to the bar.
  final List<Widget> children;

  /// The chosen tab's value, for a controlled set. Leave it `null` and the
  /// set keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which tab starts chosen, for an uncontrolled set.
  final T? defaultValue;

  /// Called with the value of the tab that was chosen.
  final ValueChanged<T?>? onValueChange;

  /// Which way the bar runs. `vertical` puts the tabs down the start side
  /// with the panel beside them, and moves the arrow keys onto that axis.
  final NebaOrientation orientation;

  /// Whether moving the focus with the arrow keys also chooses the tab it
  /// lands on. Off, Enter or Space chooses, so a panel that fetches does not
  /// fire a request for every tab walked past.
  final bool activateOnFocus;

  /// Whether the arrow keys wrap from the last tab back to the first.
  final bool loopFocus;

  /// What a bar with more tabs than room does about it.
  final NebaTabsOverflow overflow;

  /// The most tab rows a wrapping bar may take before it scrolls: the lines
  /// it wraps onto across a horizontal bar, the tabs in a column before it
  /// starts another down a vertical one. Read only when [overflow] is
  /// [NebaTabsOverflow.wrap].
  final int? lines;

  /// Turns a mouse wheel rolled over a bar that scrolls sideways into travel
  /// along it, and holds it there, at the ends too, while the pointer is over
  /// it. A bar that fits takes nothing.
  final bool wheel;

  /// Stretches a horizontal bar's tabs to share its width evenly, unless a
  /// label needs more than its share.
  final bool fullWidth;

  /// Where a tab's label sits once the tab is wider than it: down a vertical
  /// bar, where every tab is as wide as the longest, or with [fullWidth].
  final NebaAlign align;

  /// Whether a panel whose tab is not chosen stays built, hidden, with its
  /// state. A panel's own `keepMounted` wins over this.
  final bool keepMounted;

  /// The weight of the bar, not of the panels: `solid` a frosted trough with
  /// a tile that slides between the tabs, `outline` a rule along the bar with
  /// the indicator riding on it, `text` the same without the rule. Defaults
  /// to `NebaProvider`'s, then [NebaVariant.outline].
  final NebaVariant? variant;

  /// The tabs' height and type, on `NebaButton`'s ladder. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the indicator, the chosen tab's ink, the bar's rule and
  /// the focus ring. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The tabs' inline padding, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// What a screen reader calls the tab bar.
  final String? semanticLabel;

  @override
  State<NebaTabs<T>> createState() => _NebaTabsState<T>();
}

class _NebaTabsState<T> extends State<NebaTabs<T>> {
  late T? _value = widget.defaultValue;

  final ScrollController _scroll = ScrollController();

  /// One focus node per place in the bar, made as a tab first needs one and
  /// kept until the set goes.
  final List<FocusNode> _nodes = <FocusNode>[];

  /// What is in the bar, as of the last build.
  List<Widget> _tabs = const <Widget>[];

  /// The tab holding the focus, which is the bar's stop in the focus order
  /// while the focus is inside it.
  int? _active;
  bool _focusCheckScheduled = false;

  /// Whether there is more bar before and after what is showing, along the
  /// axis it scrolls.
  (bool, bool) _edges = (false, false);

  T? get _current => widget.value ?? _value;

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.removeListener(_handleFocus);
      node.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  FocusNode _nodeAt(int index) {
    while (_nodes.length <= index) {
      _nodes.add(FocusNode(debugLabel: 'NebaTab')..addListener(_handleFocus));
    }

    return _nodes[index];
  }

  /// The tab at [index], or `null` for something in the bar that is not one.
  NebaTab<Object?>? _tabAt(int index) {
    final Widget? tab = index < _tabs.length ? _tabs[index] : null;

    return tab is NebaTab ? tab as NebaTab<Object?> : null;
  }

  bool _off(int index) => _tabAt(index)?.disabled ?? true;

  void _choose(int index) {
    final NebaTab<Object?>? tab = _tabAt(index);

    if (tab == null || tab.disabled) {
      return;
    }

    final Object? value = tab.value;

    if (value is! T || value == _current) {
      return;
    }

    if (widget.value == null) {
      setState(() => _value = value);
    }

    widget.onValueChange?.call(value);
  }

  /// A press on a tab: the focus goes to it, as a browser focuses a pressed
  /// button, so the arrow keys carry on from there.
  void _press(int index) {
    _nodeAt(index).requestFocus();
    _choose(index);
  }

  /// Moves the bar's stop to the tab that took the focus, and back to the
  /// chosen one once the focus has left. A focus change can land during a
  /// build, so the stop moves after the frame.
  void _handleFocus() {
    if (_focusCheckScheduled) {
      return;
    }

    _focusCheckScheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((Duration _) {
        _focusCheckScheduled = false;

        if (!mounted) {
          return;
        }

        final int? focused = _focused;

        if (focused != _active) {
          setState(() => _active = focused);
        }
      })
      ..ensureVisualUpdate();
  }

  int? get _focused {
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].hasPrimaryFocus) {
        return i;
      }
    }

    return null;
  }

  /// The bar's one stop in the focus order: the tab holding the focus, then
  /// the chosen one, then the first that is not disabled.
  int? _tabStop(int? chosen) {
    final int count = _tabs.length;
    final int? active = _active;

    if (active != null && active < count && _tabAt(active) != null) {
      return active;
    }

    if (chosen != null && !_off(chosen)) {
      return chosen;
    }

    for (int i = 0; i < count; i++) {
      if (!_off(i)) {
        return i;
      }
    }

    return null;
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    final int? current = _focused;

    if (current == null || current >= _tabs.length) {
      return KeyEventResult.ignored;
    }

    final int? target = nebaRovingTarget(
      event,
      current: current,
      count: _tabs.length,
      axis: widget.orientation == NebaOrientation.horizontal ? Axis.horizontal : Axis.vertical,
      textDirection: Directionality.of(context),
      loop: widget.loopFocus,
      // A disabled tab still takes the focus, so it can be found and read;
      // only choosing it is refused.
      focusable: (int index) => _tabAt(index) != null,
    );

    if (target == null) {
      return KeyEventResult.ignored;
    }

    if (target != current) {
      _nodeAt(target).requestFocus();
      _reveal(target, forward: target > current);

      if (widget.activateOnFocus) {
        _choose(target);
      }
    }

    return KeyEventResult.handled;
  }

  /// Scrolls the bar until the tab at [index] is in view, as a browser does
  /// for an element it focuses.
  void _reveal(int index, {required bool forward}) {
    final BuildContext? tab = _nodes[index].context;

    if (tab == null) {
      return;
    }

    Scrollable.ensureVisible(
      tab,
      alignmentPolicy: forward
          ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
          : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  bool _onMetrics(ScrollMetrics metrics) {
    final (bool, bool) edges = (metrics.extentBefore > 1, metrics.extentAfter > 1);

    if (edges != _edges) {
      setState(() => _edges = edges);
    }

    return false;
  }

  /// What a screen reader calls the panel for [value]: its tab's name.
  String? _labelFor(Object? value) {
    for (final Widget tab in _tabs) {
      if (tab is NebaTab && tab.value == value) {
        final Widget? child = tab.child;

        return tab.semanticLabel ?? (child is Text ? child.data : null);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(color);
    final bool horizontal = widget.orientation == NebaOrientation.horizontal;
    final Axis axis = horizontal ? Axis.horizontal : Axis.vertical;
    final bool wraps = widget.overflow == NebaTabsOverflow.wrap;
    final int? lines = wraps ? widget.lines : null;
    final bool solid = variant == NebaVariant.solid;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final T? current = _current;

    // A panel goes to the panel area, and everything else to the bar.
    final List<Widget> tabs = <Widget>[];
    final List<NebaTabPanel<Object?>> panels = <NebaTabPanel<Object?>>[];

    for (final Widget child in widget.children) {
      if (child is NebaTabPanel) {
        panels.add(child as NebaTabPanel<Object?>);
      } else {
        tabs.add(child);
      }
    }

    _tabs = tabs;

    int? chosen;

    for (int i = 0; i < tabs.length; i++) {
      final NebaTab<Object?>? tab = _tabAt(i);

      if (current != null && tab != null && tab.value == current) {
        chosen = i;
        break;
      }
    }

    final int? tabStop = _tabStop(chosen);
    final Widget tile = solid
        ? NebaSheet(
            fill: tokens.panelPress,
            plate: NebaPlate.glass,
            elevation: 1,
            borderRadius: radius,
          )
        : _Underline(axis: axis, color: roles.accent);

    Widget run = NebaTileRun(
      current: chosen,
      axis: axis,
      wrap: wraps,
      fill: widget.fullWidth && horizontal,
      tile: tile,
      children: <Widget>[
        for (int i = 0; i < tabs.length; i++)
          _TabSlot(
            // The tab's own key, one level up, so a reordered bar keeps each
            // tab's state with it; wrapped, so a GlobalKey is not used twice.
            key: tabs[i].key == null ? null : ValueKey<Key>(tabs[i].key!),
            index: i,
            chosen: i == chosen,
            off: _off(i),
            variant: variant,
            size: size,
            color: color,
            density: density,
            align: widget.align,
            focusNode: _nodeAt(i)..skipTraversal = i != tabStop,
            press: _press,
            child: tabs[i],
          ),
      ],
    );

    run = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      label: widget.semanticLabel,
      child: run,
    );
    run = Focus(canRequestFocus: false, skipTraversal: true, onKeyEvent: _handleKey, child: run);

    if (solid) {
      run = Padding(padding: const EdgeInsets.all(_troughPadding), child: run);
    }

    // The axis the bar scrolls along: its own unless it wraps, and across it
    // when a wrapping bar is capped by `lines`.
    final Axis? scrolls = !wraps
        ? axis
        : (lines != null ? (horizontal ? Axis.vertical : Axis.horizontal) : null);

    if (scrolls != null) {
      final Widget content = run;

      Widget view(double? minWidth) {
        return SingleChildScrollView(
          controller: _scroll,
          scrollDirection: scrolls,
          primary: false,
          child: minWidth == null
              ? content
              : ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minWidth),
                  child: content,
                ),
        );
      }

      // Tabs sharing the bar's width share the width of the view while they
      // fit, and scroll once they do not.
      run = widget.fullWidth && horizontal && scrolls == Axis.horizontal
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return view(constraints.hasBoundedWidth ? constraints.maxWidth : null);
              },
            )
          : view(null);

      // The scrollbar is hidden: under a tab bar it is a rail of furniture on
      // one system and invisible on another, so the fade is the cue on both.
      run = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: run,
      );
      run = NotificationListener<ScrollMetricsNotification>(
        onNotification: (ScrollMetricsNotification notification) =>
            notification.depth == 0 && _onMetrics(notification.metrics),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) =>
              notification.depth == 0 && _onMetrics(notification.metrics),
          child: run,
        ),
      );
      run = Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (_scroll.hasClients) {
            nebaStripWheel(
              event,
              _scroll.position,
              axis: scrolls,
              turn: widget.wheel,
              textDirection: Directionality.of(context),
            );
          }
        },
        child: run,
      );
    }

    Widget fade(Widget child) {
      if (scrolls == null) {
        return child;
      }

      return NebaEdgeFade(
        reach: _fade,
        vertical: scrolls == Axis.vertical ? _edges : (false, false),
        horizontal: scrolls == Axis.horizontal ? _edges : (false, false),
        child: child,
      );
    }

    final BorderSide rule = BorderSide(color: roles.line);
    Widget bar = switch (variant) {
      // The fade inside the trough: a backdrop blur under a mask has nothing
      // behind it to blur.
      NebaVariant.solid => Stack(
        children: <Widget>[
          Positioned.fill(
            child: NebaSheet(fill: tokens.panel, plate: NebaPlate.glass, borderRadius: radius),
          ),
          ClipRRect(borderRadius: radius, child: fade(run)),
        ],
      ),
      // A Container, so the rule takes its pixel as a CSS border does, and
      // fades with the tabs at an end that has more beyond it.
      NebaVariant.outline => fade(
        Container(
          decoration: BoxDecoration(
            border: horizontal ? Border(bottom: rule) : BorderDirectional(end: rule),
          ),
          child: run,
        ),
      ),
      NebaVariant.text => fade(run),
    };

    if (lines != null) {
      // A cap in rows, as the rows actually are: the trough's padding at both
      // ends, and the rule under a horizontal outline bar, are in it.
      final double extra = solid
          ? 2 * _troughPadding
          : (variant == NebaVariant.outline && horizontal ? 1 : 0);

      bar = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: NebaScale.controlHeight[size]! * lines + extra),
        child: bar,
      );
    }

    final Widget? area = panels.isEmpty
        ? null
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final NebaTabPanel<Object?> panel in panels)
                _PanelSlot(
                  key: ValueKey<Object?>(panel.value),
                  shown: current != null && panel.value == current,
                  keep: panel.keepMounted ?? widget.keepMounted,
                  label: _labelFor(panel.value),
                  child: panel,
                ),
            ],
          );

    if (horizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _gap,
        children: <Widget>[bar, ?area],
      );
    }

    return _Beside(
      gap: area == null ? 0 : _gap,
      textDirection: Directionality.of(context),
      children: <Widget>[bar, area ?? const SizedBox.shrink()],
    );
  }
}

/// One tab in a [NebaTabs] bar.
///
/// It has no `size`, `color` or `variant` of its own: all three belong to the
/// set, and a tab that could disagree with its neighbours about any of them
/// would be a bar with a hole in it.
class NebaTab<T> extends StatelessWidget {
  /// A tab named [value], labelled [child].
  const NebaTab({
    required this.value,
    this.child,
    this.startIcon,
    this.endIcon,
    this.disabled = false,
    this.semanticLabel,
    super.key,
  });

  /// What names the tab, picks out the panel with the same value, and what
  /// `onValueChange` reports when it is chosen.
  final T value;

  /// The label.
  final Widget? child;

  /// Before the label, drawn at 1.2 times the label's size.
  final Widget? startIcon;

  /// After the label: a count, a `NebaBadge`, a status dot.
  final Widget? endIcon;

  /// Unavailable, but still listed: grey, never chosen, and still reached by
  /// the arrow keys so it can be read.
  final bool disabled;

  /// What a screen reader hears in place of the label, and calls the panel
  /// the tab picks out.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final _TabSlot? slot = context.dependOnInheritedWidgetOfExactType<_TabSlot>();

    assert(() {
      if (slot == null) {
        throw FlutterError(
          'A NebaTab was built outside a NebaTabs.\n'
          'A tab draws itself from the set it is in, so it has to be one of a '
          "NebaTabs's children.",
        );
      }
      return true;
    }());

    final _TabSlot bar = slot!;
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(bar.color);
    final bool off = bar.off;
    final bool chosen = bar.chosen;
    final NebaSize size = bar.size;
    final double text = NebaScale.controlText[size]!;
    final BorderRadius radius = bar.variant == NebaVariant.solid
        ? BorderRadius.circular(tokens.radius[size]!)
        : BorderRadius.zero;
    final String? semanticLabel = this.semanticLabel;

    final Widget body = NebaInteractive(
      enabled: !off,
      // Reached by the arrow keys even while disabled.
      focusable: true,
      onTap: () => bar.press(bar.index),
      focusNode: bar.focusNode,
      cursor: off ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder:
          (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> pointer) {
            final Color ink = off
                ? tokens.disabledFg
                : chosen
                ? roles.accent
                : interaction.hovered
                ? tokens.fg
                : tokens.mutedFg;

            final Widget label = NebaInk(
              color: ink,
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: text, height: 1, fontWeight: FontWeight.w500),
                softWrap: false,
                child: IconTheme.merge(
                  data: IconThemeData(size: text * 1.2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: NebaScale.gap[size]!,
                    children: <Widget>[?startIcon, ?child, ?endIcon],
                  ),
                ),
              ),
            );

            // Inside the tab rather than off it: a ring standing off a tab in
            // a trough would be drawn over its neighbours.
            return NebaFocusRing(
              visible: interaction.focusVisible,
              color: roles.ring,
              borderRadius: radius,
              offset: -focusRingWidth,
              child: SizedBox(
                height: NebaScale.controlHeight[size],
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: NebaScale.paddingX[bar.density]![size]!,
                      ),
                      child: Align(
                        alignment: switch (bar.align) {
                          NebaAlign.start => AlignmentDirectional.centerStart,
                          NebaAlign.center => AlignmentDirectional.center,
                          NebaAlign.end => AlignmentDirectional.centerEnd,
                        },
                        child: ExcludeSemantics(excluding: semanticLabel != null, child: label),
                      ),
                    ),
                    // The spotlight alone: a chosen tab's panel is already
                    // being read, and a flash draining under it would be a
                    // second thing happening.
                    if (!off)
                      Positioned.fill(
                        child: NebaGlow(
                          interaction: interaction,
                          pointer: pointer,
                          colors: NebaGlowColors(glow: roles.soft, flash: edgeless),
                          afterglow: false,
                          borderRadius: radius,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
    );

    return Semantics(
      container: true,
      role: SemanticsRole.tab,
      selected: chosen,
      enabled: !off,
      label: semanticLabel,
      child: body,
    );
  }
}

/// The content behind one tab of a [NebaTabs].
class NebaTabPanel<T> extends StatelessWidget {
  /// The panel the tab named [value] shows.
  const NebaTabPanel({required this.value, this.child, this.keepMounted, super.key});

  /// Which tab shows this panel.
  final T value;

  /// Whether the panel stays built, hidden, with its state, while its tab is
  /// not chosen. Left `null`, it is whatever the `NebaTabs` says.
  final bool? keepMounted;

  /// The content.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: NebaTheme.of(context).fg),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// What the bar tells one tab: where it is, whether it is chosen, and the
/// set's own axes.
class _TabSlot extends InheritedWidget {
  const _TabSlot({
    required this.index,
    required this.chosen,
    required this.off,
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.align,
    required this.focusNode,
    required this.press,
    required super.child,
    super.key,
  });

  final int index;
  final bool chosen;
  final bool off;
  final NebaVariant variant;
  final NebaSize size;
  final NebaColor color;
  final NebaDensity density;
  final NebaAlign align;
  final FocusNode focusNode;
  final void Function(int index) press;

  @override
  bool updateShouldNotify(_TabSlot oldWidget) {
    return index != oldWidget.index ||
        chosen != oldWidget.chosen ||
        off != oldWidget.off ||
        variant != oldWidget.variant ||
        size != oldWidget.size ||
        color != oldWidget.color ||
        density != oldWidget.density ||
        align != oldWidget.align ||
        focusNode != oldWidget.focusNode ||
        press != oldWidget.press;
  }
}

/// The indicator of an `outline` or a `text` bar: a 2-pixel line along the
/// edge of the chosen tab that faces the panel, its bottom across a
/// horizontal bar and its end down a vertical one.
class _Underline extends StatelessWidget {
  const _Underline({required this.axis, required this.color});

  final Axis axis;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool horizontal = axis == Axis.horizontal;

    return Align(
      alignment: horizontal ? Alignment.bottomCenter : AlignmentDirectional.centerEnd,
      child: SizedBox(
        width: horizontal ? double.infinity : 2,
        height: horizontal ? 2 : double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(9999)),
          ),
        ),
      ),
    );
  }
}

/// One panel in the panel area: shown, hidden and kept, or not built, and
/// faded up when it arrives.
class _PanelSlot extends StatefulWidget {
  const _PanelSlot({
    required this.shown,
    required this.keep,
    required this.label,
    required this.child,
    super.key,
  });

  final bool shown;
  final bool keep;
  final String? label;
  final Widget child;

  @override
  State<_PanelSlot> createState() => _PanelSlotState();
}

class _PanelSlotState extends State<_PanelSlot> with SingleTickerProviderStateMixin {
  /// The arriving panel's fade, at rest at its end: a panel on the first
  /// frame is simply there.
  late final AnimationController _fade = AnimationController(vsync: this, value: 1);
  late final Animation<double> _opacity = _fade.drive(CurveTween(curve: NebaScale.ease));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fade.duration = nebaDuration(context, NebaScale.duration);
  }

  @override
  void didUpdateWidget(_PanelSlot oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only the arriving panel fades. The leaving one goes on the frame the
    // new one arrives, so the two are never in the layout together.
    if (widget.shown && !oldWidget.shown) {
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.shown,
      maintainState: widget.keep,
      child: FadeTransition(
        opacity: _opacity,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          role: SemanticsRole.tabPanel,
          label: widget.label,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A vertical bar beside its panel: the bar as wide as its tabs and as tall
/// as the two together, as a CSS row stretches it, and the panel in the rest
/// of the width. Under a right-to-left direction the bar is at the right.
class _Beside extends MultiChildRenderObjectWidget {
  const _Beside({required this.gap, required this.textDirection, required super.children});

  final double gap;
  final TextDirection textDirection;

  @override
  _RenderBeside createRenderObject(BuildContext context) {
    return _RenderBeside(gap: gap, textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderBeside renderObject) {
    renderObject
      ..gap = gap
      ..textDirection = textDirection;
  }
}

class _BesideParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderBeside extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BesideParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BesideParentData> {
  _RenderBeside({required double gap, required TextDirection textDirection})
    : _gap = gap,
      _textDirection = textDirection;

  double _gap;
  set gap(double value) {
    if (_gap != value) {
      _gap = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BesideParentData) {
      child.parentData = _BesideParentData();
    }
  }

  RenderBox get _bar => firstChild!;
  RenderBox get _panel => lastChild!;

  /// The bar's width, the panel's constraints and the height of the two,
  /// measured with [measure].
  (double, BoxConstraints, double) _measure(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) measure,
  ) {
    final Size bar = measure(
      _bar,
      BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight),
    );
    final double rest = math.max(0, constraints.maxWidth - bar.width - _gap);
    final BoxConstraints panel = constraints.hasBoundedWidth
        ? BoxConstraints(minWidth: rest, maxWidth: rest, maxHeight: constraints.maxHeight)
        : BoxConstraints(maxHeight: constraints.maxHeight);
    final double height = math.min(
      math.max(bar.height, measure(_panel, panel).height),
      constraints.maxHeight,
    );

    return (bar.width, panel, height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final (double bar, BoxConstraints panel, double height) = _measure(
      constraints,
      (RenderBox child, BoxConstraints c) => child.getDryLayout(c),
    );
    final double panelWidth = panel.hasBoundedWidth
        ? panel.maxWidth
        : _panel.getDryLayout(panel).width;

    return constraints.constrain(Size(bar + _gap + panelWidth, height));
  }

  @override
  void performLayout() {
    final RenderBox bar = _bar;
    final RenderBox panel = _panel;
    final (double barWidth, BoxConstraints _, double height) = _measure(constraints, (
      RenderBox child,
      BoxConstraints c,
    ) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });

    // Again at the height of the two, so the bar's rule or trough runs the
    // whole way down beside a taller panel.
    bar.layout(BoxConstraints.tightFor(width: barWidth, height: height), parentUsesSize: true);

    final double width = barWidth + _gap + panel.size.width;
    size = constraints.constrain(Size(width, height));

    final bool rtl = _textDirection == TextDirection.rtl;
    (bar.parentData! as _BesideParentData).offset = Offset(rtl ? size.width - barWidth : 0, 0);
    (panel.parentData! as _BesideParentData).offset = Offset(
      rtl ? size.width - barWidth - _gap - panel.size.width : barWidth + _gap,
      0,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _bar.getMinIntrinsicWidth(height) + _gap + _panel.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _bar.getMaxIntrinsicWidth(height) + _gap + _panel.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      _bar.getMinIntrinsicHeight(double.infinity),
      _panel.getMinIntrinsicHeight(double.infinity),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return math.max(
      _bar.getMaxIntrinsicHeight(double.infinity),
      _panel.getMaxIntrinsicHeight(double.infinity),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
