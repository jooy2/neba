/// `NebaAnchor`, the headings of the page being read, with the reader's
/// marked.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One heading a [NebaAnchor] lists.
@immutable
class NebaAnchorItem {
  /// A row for the heading [target] is on.
  const NebaAnchorItem({required this.target, required this.label, this.depth = 0})
    : assert(depth >= 0);

  /// The key of the heading's widget: what a row scrolls to and what the
  /// tracking measures. A heading that is not built has no row to mark.
  final GlobalKey target;

  /// What the row says, usually the heading's own words in a [Text].
  final Widget label;

  /// How far the row is indented: `0` for a section, `1` for one inside it.
  final int depth;
}

/// The list of headings on the page being read, with the one the reader is in
/// marked, and a row that scrolls to its heading when pressed.
///
/// The headings are found by their [NebaAnchorItem.target] keys, in the
/// scroll view they are in, which is the one the list follows: the marked row
/// is the last heading whose top has passed [offset] below the top of that
/// view, the first while there is nothing to scroll, and the last once the
/// scroll reaches the end.
///
/// ```dart
/// NebaAnchor(items: <NebaAnchorItem>[
///   NebaAnchorItem(target: installKey, label: const Text('Install')),
///   NebaAnchorItem(target: setupKey, label: const Text('Setup'), depth: 1),
/// ])
/// ```
class NebaAnchor extends StatefulWidget {
  /// A list of [items].
  const NebaAnchor({
    required this.items,
    this.activeTarget,
    this.onActiveChange,
    this.offset = 0,
    this.rail = true,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.locale,
    this.semanticLabel,
    super.key,
  });

  /// The headings, in the order they come on the page.
  final List<NebaAnchorItem> items;

  /// The heading whose row is marked, when the caller decides it. The tracking
  /// keeps running, so [onActiveChange] still reports where the reader is.
  final GlobalKey? activeTarget;

  /// Called with the heading the reader has scrolled into, or `null` above the
  /// first.
  final ValueChanged<GlobalKey?>? onActiveChange;

  /// How far below the top of the scroll view a heading counts as reached:
  /// the height of a bar pinned over it.
  final double offset;

  /// Whether a line runs down the leading edge, lit beside the marked row.
  final bool rail;

  /// The rows' type. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the marked row and the focus ring.
  final NebaColor color;

  /// How much room a row has above and below. Defaults to `NebaProvider`'s,
  /// then [NebaDensity.standard].
  final NebaDensity? density;

  /// The language of the list's name. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// The list's name for a screen reader, in place of "On this page".
  final String? semanticLabel;

  /// How far a row is indented per level of depth, at each size.
  static const Map<NebaSize, double> indent = <NebaSize, double>{
    NebaSize.xs: 8,
    NebaSize.sm: 10,
    NebaSize.md: 12,
    NebaSize.lg: 14,
    NebaSize.xl: 16,
  };

  /// The room above and below a row, by density and size.
  static const Map<NebaDensity, Map<NebaSize, double>> rowPadding =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 4,
          NebaSize.md: 6,
          NebaSize.lg: 6,
          NebaSize.xl: 8,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 2,
          NebaSize.md: 4,
          NebaSize.lg: 4,
          NebaSize.xl: 4,
        },
      };

  @override
  State<NebaAnchor> createState() => _NebaAnchorState();
}

class _NebaAnchorState extends State<NebaAnchor> {
  GlobalKey? _tracked;
  ScrollPosition? _position;
  bool _scheduled = false;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _later();
  }

  @override
  void didUpdateWidget(NebaAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _later();
  }

  @override
  void dispose() {
    _position?.removeListener(_later);
    super.dispose();
  }

  /// The scroll view the headings are in: the nearest one around the first
  /// heading that is built.
  ScrollableState? get _scrollable {
    for (final NebaAnchorItem item in widget.items) {
      final BuildContext? context = item.target.currentContext;

      if (context != null) {
        return Scrollable.maybeOf(context);
      }
    }

    return null;
  }

  /// Reads where the reader is after the frame, once, however many scrolls
  /// asked: the headings are measured where they were painted.
  void _later() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _scheduled = false;

      if (mounted) {
        _follow();
        _read();
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  /// Listens to the scroll view the headings are in now.
  void _follow() {
    final ScrollPosition? position = _scrollable?.position;

    if (position != _position) {
      _position?.removeListener(_later);
      _position = position?..addListener(_later);
    }
  }

  /// How far below the top of the scroll view [target]'s top is, or `null`
  /// for a heading that is not laid out.
  double? _topOf(GlobalKey target, RenderObject viewport) {
    final RenderObject? heading = target.currentContext?.findRenderObject();

    if (heading is! RenderBox || !heading.hasSize || !heading.attached) {
      return null;
    }

    return heading.localToGlobal(Offset.zero, ancestor: viewport).dy;
  }

  void _read() {
    final ScrollableState? scrollable = _scrollable;
    final ScrollPosition? position = scrollable?.position;
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    final List<NebaAnchorItem> items = widget.items;
    GlobalKey? next;

    if (position != null && viewport != null && position.hasContentDimensions) {
      final double line = widget.offset + 1;

      for (final NebaAnchorItem item in items) {
        final double? top = _topOf(item.target, viewport);

        if (top != null && top <= line) {
          next = item.target;
        }
      }

      final double range = position.maxScrollExtent - position.minScrollExtent;

      if (range <= 2) {
        // Nothing to scroll: the first heading is where the reader is.
        final NebaAnchorItem? first = items.isEmpty ? null : items.first;
        next = first != null && _topOf(first.target, viewport) != null ? first.target : next;
      } else if (position.pixels >= position.maxScrollExtent - 2 && items.isNotEmpty) {
        // At the end the last heading is marked, though its top may never
        // reach the line.
        next = items.last.target;
      }
    }

    if (next != _tracked || !_reported) {
      final bool changed = next != _tracked;
      _reported = true;
      setState(() => _tracked = next);

      if (changed) {
        widget.onActiveChange?.call(next);
      }
    }
  }

  void _go(NebaAnchorItem item) {
    final ScrollableState? scrollable = _scrollable;
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    final double? top = viewport == null ? null : _topOf(item.target, viewport);

    if (scrollable == null || top == null) {
      return;
    }

    final ScrollPosition position = scrollable.position;
    final double to = (position.pixels + top - widget.offset).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    position.jumpTo(to.roundToDouble());
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final GlobalKey? active = widget.activeTarget ?? _tracked;
    final double text = NebaScale.controlText[size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final double padY = NebaAnchor.rowPadding[density]![size]!;
    final double step = NebaAnchor.indent[size]!;
    final bool rail = widget.rail;
    final Duration duration = nebaDuration(context, NebaScale.duration);

    Widget row(NebaAnchorItem item) {
      final bool current = item.target == active;
      final double indent = item.depth * step;

      return NebaInteractive(
        onTap: () => _go(item),
        activatesOnSpace: false,
        builder: (BuildContext context, NebaInteraction interaction, _) {
          final Color ink = current
              ? roles.accent
              : interaction.hovered
              ? tokens.fg
              : tokens.mutedFg;

          Widget link = AnimatedDefaultTextStyle(
            duration: duration,
            curve: NebaScale.ease,
            style: DefaultTextStyle.of(context).style.merge(
              TextStyle(
                fontSize: text,
                height: leading / text,
                color: ink,
                fontWeight: current ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: rail ? 12 + indent : 0,
                top: padY,
                bottom: padY,
              ),
              child: item.label,
            ),
          );

          if (rail) {
            // The row's own pixel of the rail, lit beside the marked row.
            link = AnimatedContainer(
              duration: duration,
              curve: NebaScale.ease,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: current ? roles.accent : const Color(0x00000000)),
                ),
              ),
              child: link,
            );
          }

          return Padding(
            padding: EdgeInsetsDirectional.only(start: rail ? 0 : indent),
            child: Semantics(
              link: true,
              selected: current,
              child: NebaFocusRing(
                visible: interaction.focusVisible,
                color: roles.ring,
                borderRadius: BorderRadius.circular(4),
                child: link,
              ),
            ),
          );
        },
      );
    }

    Widget list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[for (final NebaAnchorItem item in widget.items) row(item)],
    );

    if (rail) {
      // The rail is the list's own start border; each row's lies over it, as
      // a row pulled back a pixel over it does in CSS.
      list = CustomPaint(
        painter: _RailPainter(tokens.border, Directionality.of(context)),
        child: list,
      );
    }

    // As wide as its widest row where the width is open, as a nav in an
    // `auto` column is, and the width it is given where that is fixed.
    list = IntrinsicWidth(child: list);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          widget.semanticLabel ?? nebaMessages(context, 'anchor', locale: widget.locale)['label'],
      child: list,
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter(this.color, this.direction);

  final Color color;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final double x = direction == TextDirection.ltr ? 0 : size.width - 1;

    canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.direction != direction;
  }
}
