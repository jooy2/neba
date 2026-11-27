/// `NebaTimeline` and `NebaTimelineItem`, steps in the order they happen in.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How far along one [NebaTimelineItem] is.
enum NebaTimelineStatus {
  /// Done: a filled bullet.
  complete,

  /// The one being worked on now: a filled bullet with a halo round it.
  current,

  /// Still to come: an empty ring.
  upcoming,
}

/// How the line from one [NebaTimelineItem] to the next is drawn.
enum NebaTimelineConnector {
  /// A continuous line.
  solid,

  /// Dashes.
  dashed,

  /// Dots.
  dotted,

  /// No line: the gap is left open, which groups the items around it.
  none,
}

/// What a [NebaTimelineItem] takes from the [NebaTimeline] around it,
/// including where in the sequence it is: an item is never told its index,
/// the timeline counts its children.
class _NebaTimelineScope extends InheritedWidget {
  const _NebaTimelineScope({
    required this.size,
    required this.density,
    required this.orientation,
    required this.color,
    required this.active,
    required this.labels,
    required this.index,
    required this.last,
    required super.child,
    super.key,
  });

  final NebaSize size;
  final NebaDensity density;
  final NebaOrientation orientation;
  final NebaColor color;
  final int? active;
  final Map<NebaTimelineStatus, String> labels;
  final int index;
  final bool last;

  static _NebaTimelineScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NebaTimelineScope>();
  }

  @override
  bool updateShouldNotify(_NebaTimelineScope oldWidget) {
    return size != oldWidget.size ||
        density != oldWidget.density ||
        orientation != oldWidget.orientation ||
        color != oldWidget.color ||
        active != oldWidget.active ||
        index != oldWidget.index ||
        last != oldWidget.last ||
        !_sameLabels(labels, oldWidget.labels);
  }

  static bool _sameLabels(Map<NebaTimelineStatus, String> a, Map<NebaTimelineStatus, String> b) {
    return a.length == b.length &&
        a.entries.every((MapEntry<NebaTimelineStatus, String> e) => b[e.key] == e.value);
  }
}

/// A sequence of steps, in the order they happen in: an order on its way, a
/// deployment's history, a checkout's stages.
///
/// The order is the content, so a screen reader hears a list of the steps in
/// order. [active] is how far the sequence has got, counted against the
/// children, which the timeline numbers itself: every step before it is
/// complete, it is current, and every step after it is still to come.
///
/// ```dart
/// NebaTimeline(
///   active: 1,
///   children: <Widget>[
///     NebaTimelineItem(title: Text('Ordered'), meta: Text('12 Jul')),
///     NebaTimelineItem(title: Text('In transit')),
///     NebaTimelineItem(title: Text('Delivered')),
///   ],
/// )
/// ```
class NebaTimeline extends StatelessWidget {
  /// A timeline of [children], usually [NebaTimelineItem]s.
  const NebaTimeline({
    required this.children,
    this.active,
    this.size,
    this.color,
    this.density,
    this.orientation = NebaOrientation.vertical,
    this.locale,
    this.labels,
    super.key,
  }) : assert(active == null || active >= 0);

  /// The steps, usually [NebaTimelineItem]s.
  final List<Widget> children;

  /// The index of the step being worked on now. Left out, every step is
  /// upcoming unless it says otherwise; the number of steps marks them all
  /// complete.
  final int? active;

  /// The bullet and the type scale. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family a bullet is filled with and the current title is drawn in.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The space between the steps, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// Which way the sequence runs: [NebaOrientation.vertical] takes any number
  /// of steps with any amount to say about each, and
  /// [NebaOrientation.horizontal] is the stepper across the top of a
  /// checkout, which only works while every label is short.
  final NebaOrientation orientation;

  /// The language a step's status is said in to a screen reader. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Those words written out, by status, over the [locale]'s:
  /// [NebaTimelineStatus.complete] and [NebaTimelineStatus.upcoming]. The
  /// current step says nothing; it is selected instead.
  final Map<NebaTimelineStatus, String>? labels;

  /// Between one step and the next, per density, down the timeline or, when
  /// it runs across, along it.
  static const Map<NebaDensity, Map<NebaSize, double>> itemGap =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 20,
          NebaSize.sm: 24,
          NebaSize.md: 28,
          NebaSize.lg: 32,
          NebaSize.xl: 40,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 12,
          NebaSize.sm: 14,
          NebaSize.md: 16,
          NebaSize.lg: 20,
          NebaSize.xl: 24,
        },
      };

  @override
  Widget build(BuildContext context) {
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = this.color ?? NebaColor.primary;
    final Map<String, String> messages = nebaMessages(context, 'timeline', locale: locale);
    final Map<NebaTimelineStatus, String> words = <NebaTimelineStatus, String>{
      NebaTimelineStatus.complete: labels?[NebaTimelineStatus.complete] ?? messages['complete']!,
      NebaTimelineStatus.upcoming: labels?[NebaTimelineStatus.upcoming] ?? messages['upcoming']!,
    };
    final List<Widget> steps = nebaPresentChildren(context, children);
    final List<Widget> scoped = <Widget>[
      for (int i = 0; i < steps.length; i++)
        _NebaTimelineScope(
          // After the step's own key, so a step put in front of the others
          // leaves their state where it was.
          key: steps[i].key == null ? null : ValueKey<Key>(steps[i].key!),
          size: size,
          density: density,
          orientation: orientation,
          color: color,
          active: active,
          labels: words,
          index: i,
          last: i == steps.length - 1,
          child: steps[i],
        ),
    ];

    final Widget sequence = orientation == NebaOrientation.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: scoped,
          )
        : _across(scoped, itemGap[density]![size]!);

    return Semantics(
      container: true,
      role: SemanticsRole.list,
      explicitChildNodes: true,
      child: sequence,
    );
  }

  /// The steps across: each an equal share of what the gaps between them
  /// leave, as CSS shares a row of `flex: 1` items, with the gap after a step
  /// counted as its own, since its line runs through it.
  Widget _across(List<Widget> steps, double gap) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedWidth || steps.isEmpty) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps,
          );
        }

        final double share = math.max(
          0,
          (constraints.maxWidth - gap * (steps.length - 1)) / steps.length,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < steps.length; i++)
              SizedBox(width: i == steps.length - 1 ? share : share + gap, child: steps[i]),
          ],
        );
      },
    );
  }
}

/// One step of a [NebaTimeline]: a bullet, a [title] with its [meta], and a
/// body under them.
///
/// Its place in the sequence is the timeline's to count, and its status
/// follows from the timeline's `active` unless [status] says otherwise. The
/// line to the next step belongs to this one, so it is coloured by whether
/// this step has been reached.
///
/// ```dart
/// NebaTimelineItem(
///   title: Text('Ordered'),
///   meta: Text('12 Jul'),
///   child: Text('Payment taken.'),
/// )
/// ```
class NebaTimelineItem extends StatelessWidget {
  /// A step with a [title], a [meta] and a body.
  const NebaTimelineItem({
    this.title,
    this.meta,
    this.bullet,
    this.status,
    this.color,
    this.connector = NebaTimelineConnector.solid,
    this.child,
    super.key,
  });

  /// The step's heading, usually a [Text].
  final Widget? title;

  /// When it happened, a date, a duration or a name: beside the title, and
  /// under it when the two do not fit on one line.
  final Widget? meta;

  /// What goes inside the bullet: a number, an icon. Text is set at half the
  /// bullet's size and an icon at six tenths of it. Left out, the bullet is a
  /// plain disc.
  final Widget? bullet;

  /// Overrides what the timeline's `active` would have made of this step: a
  /// step that failed and stopped the sequence, one that was skipped.
  final NebaTimelineStatus? status;

  /// Overrides the timeline's colour family for this step alone.
  final NebaColor? color;

  /// How the line to the next step is drawn. The last step draws none.
  final NebaTimelineConnector connector;

  /// The body of the step, under the title, muted.
  final Widget? child;

  /// The bullet's diameter at each size: a mark beside the title, sized
  /// against it rather than against a control.
  static const Map<NebaSize, double> bulletSize = <NebaSize, double>{
    NebaSize.xs: 14,
    NebaSize.sm: 16,
    NebaSize.md: 20,
    NebaSize.lg: 24,
    NebaSize.xl: 30,
  };

  /// Between the bullet and the content beside it.
  static const Map<NebaSize, double> bulletGap = <NebaSize, double>{
    NebaSize.xs: 8,
    NebaSize.sm: 10,
    NebaSize.md: 12,
    NebaSize.lg: 14,
    NebaSize.xl: 16,
  };

  /// The connector's width.
  static const double lineWidth = 2;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final _NebaTimelineScope? timeline = _NebaTimelineScope.maybeOf(context);
    // A step on its own still draws: one step with nothing before or after
    // it, in the timeline's own defaults.
    final NebaSize size = timeline?.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = timeline?.density ?? defaults.density ?? NebaDensity.standard;
    final bool horizontal = timeline?.orientation == NebaOrientation.horizontal;
    final NebaColorRoles roles = tokens.roles(color ?? timeline?.color ?? NebaColor.primary);
    final int index = timeline?.index ?? 0;
    final bool last = timeline?.last ?? true;
    final int? active = timeline?.active;
    final NebaTimelineStatus resolved =
        status ??
        (active == null || index > active
            ? NebaTimelineStatus.upcoming
            : index < active
            ? NebaTimelineStatus.complete
            : NebaTimelineStatus.current);
    final double diameter = bulletSize[size]!;
    final bool lined = connector != NebaTimelineConnector.none && !last;
    final double gap = NebaTimeline.itemGap[density]![size]!;
    final String? said = resolved == NebaTimelineStatus.current
        ? null
        : timeline?.labels[resolved] ??
              nebaMessages(context, 'timeline')[resolved == NebaTimelineStatus.complete
                  ? 'complete'
                  : 'upcoming'];

    final Widget body = _Body(
      size: size,
      tokens: tokens,
      roles: roles,
      status: resolved,
      title: title,
      meta: meta,
      child: child,
    );
    final Widget mark = _Bullet(
      diameter: diameter,
      status: resolved,
      tokens: tokens,
      roles: roles,
      child: bullet,
    );

    Widget step;

    if (horizontal) {
      step = Padding(
        padding: EdgeInsetsDirectional.only(end: last ? 0 : gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            mark,
            Padding(padding: const EdgeInsets.only(top: 8), child: body),
          ],
        ),
      );
    } else {
      step = Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : gap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: bulletGap[size]!,
          children: <Widget>[
            mark,
            Expanded(child: body),
          ],
        ),
      );
    }

    // From the far edge of the bullet to the edge of the step, which is
    // where the next bullet begins, centred on the bullet. It is painted
    // under the step, so a current bullet's halo lies over its start. The
    // stack is there with or without a line, so a step that gains one when
    // another is added after it keeps what is inside it.
    final Widget line = lined
        ? _Connector(
            style: connector,
            axis: horizontal ? Axis.horizontal : Axis.vertical,
            color: resolved == NebaTimelineStatus.complete ? roles.lineHover : tokens.border,
          )
        : const SizedBox.shrink();

    step = Stack(
      children: <Widget>[
        PositionedDirectional(
          start: horizontal ? diameter : diameter / 2 - lineWidth / 2,
          end: horizontal ? 0 : null,
          top: horizontal ? diameter / 2 - lineWidth / 2 : diameter,
          bottom: horizontal ? null : 0,
          width: horizontal ? null : lineWidth,
          height: horizontal ? lineWidth : null,
          child: line,
        ),
        step,
      ],
    );

    // The bullet's shape is the only other place the status is said, and a
    // shape is not read: a finished or a waiting step says it in words
    // first, and the current one is selected.
    return Semantics(
      container: true,
      role: timeline != null ? SemanticsRole.listItem : null,
      selected: resolved == NebaTimelineStatus.current ? true : null,
      child: Semantics(label: said, child: step),
    );
  }
}

/// The title with its meta beside it, and the body under them.
class _Body extends StatelessWidget {
  const _Body({
    required this.size,
    required this.tokens,
    required this.roles,
    required this.status,
    this.title,
    this.meta,
    this.child,
  });

  final NebaSize size;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final NebaTimelineStatus status;
  final Widget? title;
  final Widget? meta;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double titleText = NebaScale.sheetTitleText[size]!;
    final double titleLeading = NebaScale.sheetTitleLeading[size]!;
    final double metaText = NebaScale.metaText[size]!;
    final double bodyText = NebaScale.sheetBodyText[size]!;
    final Widget? title = this.title;
    final Widget? meta = this.meta;
    final Widget? child = this.child;

    Widget? heading;

    if (title != null || meta != null) {
      // Each set on the line's baseline, the meta moving under the title
      // when the two do not fit on one line, as a wrapping flex row with
      // `align-items: baseline` does.
      heading = Text.rich(
        TextSpan(
          children: <InlineSpan>[
            if (title != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: meta != null ? 8 : 0),
                  child: NebaInk(
                    color: switch (status) {
                      NebaTimelineStatus.complete => tokens.fg,
                      NebaTimelineStatus.current => roles.accent,
                      NebaTimelineStatus.upcoming => tokens.mutedFg,
                    },
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: titleText,
                        height: titleLeading / titleText,
                        // CSS shares a line's leading evenly above and below it.
                        leadingDistribution: TextLeadingDistribution.even,
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                  ),
                ),
              ),
            if (meta != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: metaText,
                    height: titleLeading / metaText,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: tokens.mutedFg,
                    fontWeight: FontWeight.w400,
                  ),
                  child: meta,
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        ?heading,
        if (child != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: bodyText,
              height: NebaScale.sheetBodyLeading[size]! / bodyText,
              leadingDistribution: TextLeadingDistribution.even,
              color: tokens.mutedFg,
            ),
            child: child,
          ),
      ],
    );
  }
}

/// The bullet: a filled disc for a finished step, the same with a halo for
/// the current one, and an empty ring for one still to come. Three shapes
/// rather than three shades, so the status reads without its colour.
class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.diameter,
    required this.status,
    required this.tokens,
    required this.roles,
    this.child,
  });

  final double diameter;
  final NebaTimelineStatus status;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final Widget? child;

  /// How far the current step's halo reaches past the bullet.
  static const double halo = 4;

  /// The width of a waiting step's ring.
  static const double ring = 2;

  @override
  Widget build(BuildContext context) {
    const Color clear = Color(0x00000000);
    final bool filled = status != NebaTimelineStatus.upcoming;
    final Color ink = filled ? roles.family.onSolid : tokens.mutedFg;
    final Widget? child = this.child;
    final Duration duration = nebaDuration(context, NebaScale.duration);

    Widget? content;

    if (child != null) {
      content = Center(
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: diameter * 0.5,
            height: 1,
            fontWeight: FontWeight.w600,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          child: IconTheme.merge(
            data: IconThemeData(size: diameter * 0.6),
            child: NebaInk(color: ink, child: child),
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: duration,
        curve: NebaScale.ease,
        width: diameter,
        height: diameter,
        // The halo lies outside the disc, as a spread shadow does, and never
        // under its translucent fill.
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: status == NebaTimelineStatus.current ? roles.soft : clear,
            width: halo,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        // A ring is a CSS border, drawn over the fill inside the edge.
        foregroundDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: filled ? clear : roles.line, width: ring),
        ),
        child: NebaSheet(
          fill: filled ? roles.fill : tokens.panel,
          plate: filled ? NebaPlate.solid : NebaPlate.none,
          borderRadius: BorderRadius.circular(diameter / 2),
          blur: false,
          child: SizedBox.square(dimension: diameter, child: content),
        ),
      ),
    );
  }
}

/// The line from one step to the next, solid, dashed or dotted, in a colour
/// that eases as the step it leaves is reached.
class _Connector extends StatelessWidget {
  const _Connector({required this.style, required this.axis, required this.color});

  final NebaTimelineConnector style;
  final Axis axis;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? color, Widget? _) {
        return CustomPaint(
          painter: _ConnectorPainter(style: style, axis: axis, color: color ?? this.color),
        );
      },
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.style, required this.axis, required this.color});

  final NebaTimelineConnector style;
  final Axis axis;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bool vertical = axis == Axis.vertical;
    final double length = vertical ? size.height : size.width;
    final double thickness = vertical ? size.width : size.height;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    Offset at(double along) {
      return vertical ? Offset(size.width / 2, along) : Offset(along, size.height / 2);
    }

    if (length <= 0 || style == NebaTimelineConnector.none) {
      return;
    }

    if (style == NebaTimelineConnector.solid) {
      canvas.drawLine(at(0), at(length), paint);

      return;
    }

    // A browser draws a thin dashed border as dashes three widths long with
    // two widths between them, and a dotted one as squares a width apart,
    // and spreads the gaps so the line starts and ends on a mark.
    final bool dashed = style == NebaTimelineConnector.dashed;
    final double mark = thickness * (dashed ? 3 : 1);
    final double space = thickness * (dashed ? 2 : 1);
    final int marks = math.max(1, ((length + space) / (mark + space)).round());
    final double spread = marks > 1 ? (length - marks * mark) / (marks - 1) : 0;

    for (int i = 0; i < marks; i++) {
      final double start = i * (mark + spread);
      canvas.drawLine(at(start), at(math.min(start + mark, length)), paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.axis != axis || oldDelegate.color != color;
  }
}
