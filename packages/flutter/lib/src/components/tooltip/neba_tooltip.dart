/// `NebaTooltip`, a short label that appears when the pointer rests on
/// something, and `NebaTooltipProvider`, which shares one delay across a group
/// of them.
library;

import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A short label that appears when the pointer rests on something, or when
/// it takes the keyboard focus.
///
/// It wraps the widget it describes and adds nothing to the layout. It opens
/// after [delay] under a mouse, at once on keyboard focus, never on a touch,
/// and closes when the pointer leaves both the trigger and the label, on a
/// press on the trigger, on Escape and on a press elsewhere. A screen reader
/// hears a [Text] [content] after the trigger's own name, as
/// `aria-describedby` reads it.
///
/// A tooltip is a description, never a name, and never the only way to
/// something: a touch screen cannot reach it, and nothing inside it can be
/// pressed. Content that needs either is a `NebaPopover`'s.
///
/// ```dart
/// NebaTooltip(
///   content: const Text('Copy the deploy URL'),
///   child: NebaIconButton(onPressed: copy, icon: linkIcon, label: 'Copy'),
/// )
/// ```
class NebaTooltip extends StatefulWidget {
  /// A tooltip saying [content] about [child].
  const NebaTooltip({
    required this.content,
    required this.child,
    this.size,
    this.color = NebaColor.secondary,
    this.density,
    this.side = NebaSide.top,
    this.align = NebaAlign.center,
    this.sideOffset = 6,
    this.delay,
    this.closeDelay,
    this.arrow = true,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.disabled = false,
    super.key,
  });

  /// What the tooltip says: a short phrase, usually a [Text].
  final Widget content;

  /// The widget the tooltip describes.
  final Widget child;

  /// The type, the corners, the padding and the wedge. Defaults to
  /// `NebaProvider`'s, then [NebaSize.sm].
  final NebaSize? size;

  /// The plate's family. Neutral by default: a tooltip is a note about
  /// something else, never the thing itself.
  final NebaColor color;

  /// How much inline padding the plate has at its [size]. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which edge of the trigger it appears on. It flips to the opposite side
  /// when there is no room.
  final NebaSide side;

  /// Where it sits along that edge.
  final NebaAlign align;

  /// The distance from the trigger, in logical pixels.
  final double sideOffset;

  /// How long the pointer has to rest before the tooltip opens. Defaults to
  /// the [NebaTooltipProvider]'s, then 600 milliseconds.
  final Duration? delay;

  /// How long it waits before closing once the pointer has left. Defaults to
  /// the [NebaTooltipProvider]'s, then none.
  final Duration? closeDelay;

  /// Draws the little wedge pointing at the trigger.
  final bool arrow;

  /// Whether the tooltip is open. With [onOpenChange] the caller owns the
  /// state; without it the tooltip keeps its own.
  final bool? open;

  /// Whether a tooltip that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the tooltip opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// Stops the tooltip from opening at all, without disabling the trigger:
  /// for the tooltip that only exists while a label is cut short.
  final bool disabled;

  /// The wait before a tooltip opens when nothing says otherwise.
  static const Duration defaultDelay = Duration(milliseconds: 600);

  /// The widest a tooltip gets.
  static const double maxWidth = 256;

  /// The plate's block padding at each size, against the inline track of the
  /// control ladder.
  static const Map<NebaSize, double> paddingY = <NebaSize, double>{
    NebaSize.xs: 2,
    NebaSize.sm: 2,
    NebaSize.md: 4,
    NebaSize.lg: 6,
    NebaSize.xl: 8,
  };

  /// The wedge at each size, about a third of the plate's corner radius.
  static const Map<NebaSize, double> arrowSizes = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 7,
    NebaSize.md: 8,
    NebaSize.lg: 9,
    NebaSize.xl: 10,
  };

  @override
  State<NebaTooltip> createState() => _NebaTooltipState();
}

class _NebaTooltipState extends State<NebaTooltip> {
  late bool _open = widget.defaultOpen;
  // Whether the change being drawn lands at once: a tooltip opened while its
  // group is warm, or closed because the next one opened.
  bool _instant = false;
  _NebaTooltipGroup? _group;
  bool _told = false;

  bool get _isOpen => !widget.disabled && (widget.open ?? _open);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = context.dependOnInheritedWidgetOfExactType<_NebaTooltipGroupScope>()?.group;

    // One that starts open is the group's open one from the first frame.
    if (_isOpen && !_told) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => _tell(true));
    }
  }

  @override
  void didUpdateWidget(NebaTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);

    // An `open` the caller changed, or a `disabled` that closed it.
    if (_isOpen != _told) {
      final bool open = _isOpen;
      SchedulerBinding.instance.addPostFrameCallback((Duration _) => _tell(open));
    }
  }

  @override
  void dispose() {
    if (_told) {
      _group?.closed(this);
    }

    super.dispose();
  }

  // What the group needs to know: who is open.
  void _tell(bool open) {
    if (!mounted || open == _told) {
      return;
    }

    _told = open;
    open ? _group?.opened(this) : _group?.closed(this);
  }

  void _change(bool open, NebaFloatingReason reason) {
    if ((open && widget.disabled) || open == _isOpen) {
      return;
    }

    final bool instant = open ? (_group?.warm ?? false) : reason == NebaFloatingReason.replaced;

    setState(() {
      _instant = instant;

      if (widget.open == null) {
        _open = open;
      }
    });

    if (widget.open == null) {
      _tell(open);
    }

    widget.onOpenChange?.call(open);
  }

  void _replace() => _change(false, NebaFloatingReason.replaced);

  Duration _openDelay() {
    final _NebaTooltipGroup? group = _group;

    // Once one in the group has opened, its neighbours open at once.
    if (group != null && group.warm) {
      return Duration.zero;
    }

    return widget.delay ?? group?.delay ?? NebaTooltip.defaultDelay;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.sm;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final Widget content = widget.content;
    final String? described = content is Text
        ? (content.data ?? content.textSpan?.toPlainText())
        : null;

    final Widget popup = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: NebaTooltip.maxWidth),
      child: NebaSheet(
        fill: roles.fill,
        elevation: 3,
        borderRadius: BorderRadius.circular(tokens.radius[size]!),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: NebaScale.paddingX[density]![size]!,
            vertical: NebaTooltip.paddingY[size]!,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: NebaScale.metaText[size], height: 1.5, color: roles.onSolid),
            child: content,
          ),
        ),
      ),
    );

    // The trigger carries the words, as `aria-describedby` points at them, so
    // the label itself is not read a second time; a label that is not a Text
    // has no words to lend and is read where it is drawn.
    final Widget trigger = described == null
        ? widget.child
        : MergeSemantics(
            child: Semantics(tooltip: described, child: widget.child),
          );

    return NebaFloating(
      open: _isOpen,
      onOpenChange: _change,
      side: widget.side,
      align: widget.align,
      sideOffset: widget.sideOffset,
      arrow: widget.arrow
          ? NebaFloatingArrow(size: NebaTooltip.arrowSizes[size]!, fill: roles.fill)
          : null,
      hover: NebaFloatingHover(
        delay: _openDelay,
        closeDelay: widget.closeDelay ?? _group?.closeDelay ?? Duration.zero,
        rest: true,
      ),
      focusDelay: Duration.zero,
      closeOnTriggerPress: true,
      instant: _instant,
      enabled: !widget.disabled,
      popup: ExcludeSemantics(excluding: described != null, child: popup),
      child: trigger,
    );
  }
}

/// Shares one delay across the tooltips below it: once any of them has
/// opened, its neighbours open at once and without a fade, and the wait comes
/// back [timeout] after the last one closed.
///
/// Worth wrapping a toolbar in. Without it, moving along a row of icon
/// buttons means waiting out the whole delay at every stop.
class NebaTooltipProvider extends StatefulWidget {
  /// A group of the tooltips in [child].
  const NebaTooltipProvider({
    required this.child,
    this.delay,
    this.closeDelay,
    this.timeout = const Duration(milliseconds: 400),
    super.key,
  });

  /// The tooltips.
  final Widget child;

  /// The wait before the first tooltip opens, for every tooltip without a
  /// `delay` of its own.
  final Duration? delay;

  /// The wait before one closes, for every tooltip without a `closeDelay`
  /// of its own.
  final Duration? closeDelay;

  /// How long after the last tooltip closed its neighbours still open at
  /// once.
  final Duration timeout;

  @override
  State<NebaTooltipProvider> createState() => _NebaTooltipProviderState();
}

class _NebaTooltipProviderState extends State<NebaTooltipProvider> {
  late final _NebaTooltipGroup _group = _NebaTooltipGroup()..configure(widget);

  @override
  void didUpdateWidget(NebaTooltipProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _group.configure(widget);
  }

  @override
  void dispose() {
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NebaTooltipGroupScope(group: _group, child: widget.child);
  }
}

/// Floating UI's delay group: which tooltip is open, and whether the group
/// is still warm from the last one.
class _NebaTooltipGroup {
  Duration? delay;
  Duration? closeDelay;
  Duration timeout = Duration.zero;

  _NebaTooltipState? _current;
  Timer? _cooling;
  bool warm = false;

  void configure(NebaTooltipProvider provider) {
    delay = provider.delay;
    closeDelay = provider.closeDelay;
    timeout = provider.timeout;
  }

  void opened(_NebaTooltipState tooltip) {
    _cooling?.cancel();
    _cooling = null;
    final _NebaTooltipState? previous = _current;
    _current = tooltip;
    warm = true;

    // The one it replaces goes at once rather than fading under it.
    if (previous != null && previous != tooltip && previous.mounted) {
      previous._replace();
    }
  }

  void closed(_NebaTooltipState tooltip) {
    if (_current != tooltip) {
      return;
    }

    _current = null;
    _cooling?.cancel();
    _cooling = Timer(timeout, () {
      _cooling = null;
      warm = false;
    });
  }

  void dispose() {
    _cooling?.cancel();
  }
}

class _NebaTooltipGroupScope extends InheritedWidget {
  const _NebaTooltipGroupScope({required this.group, required super.child});

  final _NebaTooltipGroup group;

  @override
  bool updateShouldNotify(_NebaTooltipGroupScope oldWidget) => group != oldWidget.group;
}
