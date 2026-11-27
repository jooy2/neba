/// What the choice controls are drawn from: a checkbox's square, a radio's
/// ring and a switch's track, each beside its label.
///
/// - [NebaChoiceField], the control beside its label and its description,
///   centred on the label's first line however many lines the label wraps
///   to, with the error under the whole row.
/// - [NebaTick], the square or the ring a checkbox and a radio draw, with
///   what it holds drawn by the caller, and [NebaTickLook], its fill, edge and
///   ink in each state.
/// - [NebaTickMark], the tick or the dash a checkbox draws along its own
///   length, and [NebaTickDot], the dot a chosen radio grows from nothing.
///   These are the one thing in a choice control allowed to move, by a stroke
///   and a size and never by a transform.
/// - [NebaChoiceOptions], the options of a radio group or a checkbox group, in
///   a column or a row that wraps, at the gaps the two share.
///
/// None of them carries a plate. A one-pixel line of light along the edge of
/// a 32-pixel button reads as a cut edge; on an 18-pixel square it is a bevel
/// a quarter of the object's size. The acrylic stays, the grain, the sheen
/// and the blur, and only the highlight goes.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/breakpoint.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/svg_path.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The line height a choice's label and description are set at, as a
/// multiple of their size: the React package's `tickRowLeadingClasses`. The
/// control is centred on one line of it.
const double nebaChoiceLeading = 1.4;

/// Between a checkbox's or a radio's control and its text, CSS `gap-2`.
const double nebaChoiceGap = 8;

/// Between a choice's row and the error under it, CSS `gap-1`.
const double _errorGap = 4;

/// Between a choice's label and its description, CSS `gap-0.5`.
const double _descriptionGap = 2;

/// Between the options along a row, CSS `gap-x-5`: wider than a column's
/// step, because a label has to end visibly before the next box starts.
const double _optionRowGap = 20;

/// The options of a radio group or a checkbox group: a column, or a row that
/// wraps onto more lines.
///
/// Left without a [spacing], a column stands its options on
/// [NebaScale.sheetSectionGap], the step a form stands its fields on, and a
/// row puts 20 pixels along it and the column's step between its lines.
/// [spacing] counts on the spacing scale and is one length on both axes, so a
/// row that wraps puts its lines as far apart as its options.
class NebaChoiceOptions extends StatelessWidget {
  /// [children] in a column or a row.
  const NebaChoiceOptions({
    required this.size,
    required this.orientation,
    required this.children,
    this.spacing,
    super.key,
  });

  /// The set's size, which sets the gaps when [spacing] does not.
  final NebaSize size;

  /// A column or a row.
  final NebaOrientation orientation;

  /// The gap on the spacing scale, `3` being 12 logical pixels.
  final double? spacing;

  /// The options.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> present = nebaPresentChildren(context, children);
    final double? spacing = this.spacing;
    final double? gap = spacing == null ? null : spacing * NebaScale.spacingUnit;
    final double step = gap ?? NebaScale.sheetSectionGap[size]!;

    if (orientation == NebaOrientation.horizontal) {
      return Wrap(spacing: gap ?? _optionRowGap, runSpacing: step, children: present);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: step,
      children: present,
    );
  }
}

/// A choice control beside its label and its description, and the error
/// under the whole row.
///
/// The control is centred on the label's first line, so it stays put when
/// the label wraps to three. A control taller than that line, a switch's
/// track from `md` up, gets room above and below the row instead of being
/// drawn outside it, half its overflow on each side, so it stays centred on
/// the line.
///
/// A press on the label, or on the gap between it and the control, calls
/// [onLabelTap], as a `<label>` hands its click to the control it names. The
/// description takes no press. With no label and no description the row is
/// the control alone, with no gap.
///
/// The parts [semantics] took the words of are left out of what a screen
/// reader hears, since the control says them itself.
class NebaChoiceField extends StatelessWidget {
  /// [control] beside its text.
  const NebaChoiceField({
    required this.size,
    required this.control,
    required this.controlHeight,
    required this.semantics,
    required this.errorColor,
    this.label,
    this.description,
    this.error,
    this.gap = nebaChoiceGap,
    this.labelFirst = false,
    this.disabled = false,
    this.onLabelTap,
    super.key,
  });

  /// The size, which sets the type and the line the control is centred on.
  final NebaSize size;

  /// The tick, the ring or the track.
  final Widget control;

  /// How tall [control] is, which decides whether the row makes room for it.
  final double controlHeight;

  /// What the control reads itself.
  final NebaFieldSemantics semantics;

  /// The error's colour: the control's accent, `danger`'s while it is invalid.
  final Color errorColor;

  /// The text beside the control, at the control's type size.
  final Widget? label;

  /// Helper text under the label, a step smaller and muted.
  final Widget? description;

  /// The error under the row.
  final Widget? error;

  /// Between the control and its text.
  final double gap;

  /// Whether the text comes first and the control after it, at the row's
  /// end when the row is given more width than it needs.
  final bool labelFirst;

  /// Greys the label.
  final bool disabled;

  /// Called on a press on the label or on the gap beside the control.
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.controlText[size]!;
    final double meta = NebaScale.metaText[size]!;
    final double line = text * nebaChoiceLeading;
    final double room = math.max(0, (controlHeight - line) / 2);
    final VoidCallback? onLabelTap = disabled ? null : this.onLabelTap;
    final Widget? label = this.label;
    final Widget? description = this.description;
    final Widget? error = this.error;

    Widget pressable(Widget child) {
      if (onLabelTap == null) {
        return child;
      }

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // The control's own node takes the tap a screen reader sends.
          excludeFromSemantics: true,
          onTap: onLabelTap,
          child: child,
        ),
      );
    }

    final Widget box = SizedBox(
      height: line + 2 * room,
      child: Center(widthFactor: 1, child: control),
    );

    Widget row;

    if (label == null && description == null) {
      row = box;
    } else {
      // The gap is the control's side of the row: a finger that lands between
      // the two still counts, as the 24-pixel target around a tick reaches
      // into it.
      final Widget slop = pressable(
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: labelFirst ? gap : 0,
            end: labelFirst ? 0 : gap,
          ),
          child: box,
        ),
      );
      final Widget words = Padding(
        padding: EdgeInsets.symmetric(vertical: room),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _descriptionGap,
          children: <Widget>[
            if (label != null)
              pressable(
                ExcludeSemantics(
                  excluding: semantics.labelTaken,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: text,
                      height: nebaChoiceLeading,
                      leadingDistribution: TextLeadingDistribution.even,
                      color: disabled ? tokens.disabledFg : tokens.fg,
                    ),
                    child: label,
                  ),
                ),
              ),
            if (description != null)
              ExcludeSemantics(
                excluding: semantics.descriptionTaken,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: meta,
                    height: nebaChoiceLeading,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: tokens.mutedFg,
                  ),
                  child: description,
                ),
              ),
          ],
        ),
      );

      row = Row(
        mainAxisSize: MainAxisSize.min,
        // Given more width than it needs, a row with its label first puts the
        // control at the end, as a settings list lines its switches up.
        mainAxisAlignment: labelFirst ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labelFirst
            ? <Widget>[Flexible(child: words), slop]
            : <Widget>[slop, Flexible(child: words)],
      );
    }

    if (error == null) {
      return row;
    }

    // As wide as the wider of the row and the error, and the row stretched
    // to it, as an inline flex column is.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _errorGap,
        children: <Widget>[
          row,
          ExcludeSemantics(
            excluding: semantics.errorTaken,
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: meta, color: errorColor),
              child: error,
            ),
          ),
        ],
      ),
    );
  }
}

/// What a checkbox's square or a radio's ring looks like in one state: the
/// React package's rest, read-only and disabled classes for both, decided in
/// one place so the states cannot stack.
///
/// Unmarked it is the undyed panel with a hairline in the family's line.
/// Marked it fills with the family and the hairline goes, which is the one
/// place the library says a state by swapping the surface rather than moving
/// it a step: on and off are not two strengths of the same thing. Disabled
/// drops the family for neutral grey and the acrylic with it.
@immutable
class NebaTickLook {
  /// A look, written out.
  const NebaTickLook({
    required this.fill,
    required this.edge,
    required this.ink,
    required this.textured,
  });

  /// The look of a tick that is [marked] or not, in [roles]' family.
  ///
  /// A read-only tick answers no pointer. [hoverMarked] is whether a marked
  /// tick deepens under the pointer, which a checkbox's dash does not.
  factory NebaTickLook.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required bool marked,
    required bool disabled,
    required bool readOnly,
    required bool hovered,
    bool hoverMarked = true,
  }) {
    if (disabled) {
      return NebaTickLook(
        fill: marked ? tokens.disabledBg : edgeless,
        edge: tokens.disabledBorder,
        ink: tokens.disabledFg,
        textured: false,
      );
    }

    final bool lit = hovered && !readOnly;

    if (marked) {
      return NebaTickLook(
        fill: lit && hoverMarked ? roles.fillHover : roles.fill,
        edge: edgeless,
        ink: roles.onSolid,
        textured: true,
      );
    }

    return NebaTickLook(
      fill: lit ? tokens.panelHover : tokens.panel,
      edge: lit ? roles.lineHover : roles.line,
      ink: tokens.fg,
      textured: true,
    );
  }

  /// The sheet's colour.
  final Color fill;

  /// The hairline, transparent rather than absent when there is none, so it
  /// keeps its pixel and fades rather than snaps.
  final Color edge;

  /// The mark's colour: the ink on the family's fill while marked.
  final Color ink;

  /// Whether the sheet is frosted: blurred behind, with the grain and the
  /// sheen.
  final bool textured;
}

/// A checkbox's square or a radio's ring: [NebaScale.tickSize] across, in
/// [roles]' family, with [mark] drawn inside it in the tick's ink, which the
/// [IconTheme] and the [DefaultTextStyle] carry and which eases with the fill.
///
/// A press on it calls [onToggle]; so do Enter and Space while it holds the
/// focus. A read-only tick keeps its place in the focus order and takes no
/// input, and its saturation is drained.
class NebaTick extends StatelessWidget {
  /// A tick of [size] with [borderRadius] corners.
  const NebaTick({
    required this.size,
    required this.borderRadius,
    required this.roles,
    required this.marked,
    required this.mark,
    this.onToggle,
    this.disabled = false,
    this.readOnly = false,
    this.hoverMarked = true,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The tick's size.
  final NebaSize size;

  /// Its corners: a checkbox's are on [NebaScale.tickRadius], a radio's
  /// round.
  final BorderRadius borderRadius;

  /// The colour family it fills with and is ringed in.
  final NebaColorRoles roles;

  /// Whether it is filled.
  final bool marked;

  /// What is inside: the tick's drawn stroke, the radio's dot.
  final Widget mark;

  /// Called when it is pressed.
  final VoidCallback? onToggle;

  /// Neutral grey, unlit and out of the focus order.
  final bool disabled;

  /// In the focus order, but taking no input.
  final bool readOnly;

  /// Whether a marked tick deepens under the pointer.
  final bool hoverMarked;

  /// The focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether it takes the focus when it is first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double extent = NebaScale.tickSize[size]!;

    return NebaInteractive(
      enabled: !disabled && !readOnly,
      focusable: !disabled,
      onTap: onToggle,
      focusNode: focusNode,
      autofocus: autofocus,
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : readOnly
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        final NebaTickLook look = NebaTickLook.of(
          tokens: tokens,
          roles: roles,
          marked: marked,
          disabled: disabled,
          readOnly: readOnly,
          hovered: interaction.hovered,
          hoverMarked: hoverMarked,
        );

        Widget tick = NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: borderRadius,
          child: NebaSheet(
            fill: look.fill,
            edge: look.edge,
            plate: NebaPlate.none,
            borderRadius: borderRadius,
            pressed: interaction.pressed,
            blur: look.textured,
            texture: look.textured,
            child: SizedBox.square(
              // Inside the hairline, which takes a pixel on each side whether
              // it is drawn or not, as a CSS border does.
              dimension: extent - 2,
              child: NebaInk(color: look.ink, instant: interaction.pressed, child: mark),
            ),
          ),
        );

        if (readOnly && !disabled) {
          tick = ColorFiltered(
            colorFilter: ColorFilter.matrix(saturationMatrix(0.55)),
            child: tick,
          );
        }

        return tick;
      },
    );
  }
}

/// The two marks a checkbox draws.
enum NebaTickMarkShape {
  /// The tick of a checked box.
  check,

  /// The dash of a box that is neither checked nor clear.
  dash,
}

/// The mark inside a checkbox's square, in the ambient icon colour: drawn
/// along its own length as it arrives and taken back the same way as it goes,
/// fading with it, over [NebaScale.duration]. Nothing moves and nothing is
/// resampled; the stroke simply is not finished yet.
///
/// Built with a shape, it is there at once. A tick that turns into a dash is
/// redrawn as a dash on the spot, and a mark on its way out keeps its shape.
class NebaTickMark extends StatefulWidget {
  /// [shape], or nothing when it is `null`.
  const NebaTickMark({required this.shape, super.key});

  /// What is drawn.
  final NebaTickMarkShape? shape;

  @override
  State<NebaTickMark> createState() => _NebaTickMarkState();
}

class _NebaTickMarkState extends State<NebaTickMark> {
  late NebaTickMarkShape _last = widget.shape ?? NebaTickMarkShape.check;

  @override
  void didUpdateWidget(NebaTickMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _last = widget.shape ?? _last;
  }

  @override
  Widget build(BuildContext context) {
    final Color ink = IconTheme.of(context).color ?? const Color(0xFF000000);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.shape == null ? 0 : 1),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, double drawn, Widget? _) {
        return CustomPaint(
          painter: NebaTickMarkPainter(shape: _last, drawn: drawn, color: ink),
        );
      },
    );
  }
}

/// Paints a [NebaTickMark].
class NebaTickMarkPainter extends CustomPainter {
  /// [drawn] of [shape], in [color].
  NebaTickMarkPainter({required this.shape, required this.drawn, required this.color});

  /// The React package's `CheckMark` and `DashMark`, in their 12-unit box.
  static final Map<NebaTickMarkShape, ui.Path> _paths = <NebaTickMarkShape, ui.Path>{
    NebaTickMarkShape.check: parseSvgPath('M2 6.2 4.6 8.8 10 3.4'),
    NebaTickMarkShape.dash: parseSvgPath('M2.5 6h7'),
  };

  /// What is drawn.
  final NebaTickMarkShape shape;

  /// How much of the stroke is drawn, from 0 to 1, which is also how much of
  /// its colour it takes.
  final double drawn;

  /// The stroke's colour.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double drawn = this.drawn.clamp(0, 1);

    if (drawn == 0) {
      return;
    }

    // At 70% of the square, so the mark never reaches its corners.
    final double extent = size.shortestSide * 0.7;
    final Offset origin = size.center(Offset.zero) - Offset(extent / 2, extent / 2);
    final ui.Path path = ui.Path();

    for (final ui.PathMetric metric in _paths[shape]!.computeMetrics()) {
      path.addPath(metric.extractPath(0, metric.length * drawn), Offset.zero);
    }

    canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..scale(extent / 12)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color.withValues(alpha: color.a * drawn),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(NebaTickMarkPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.drawn != drawn || oldDelegate.color != color;
  }
}

/// The dot inside a chosen radio's ring, in the ambient icon colour: it grows
/// from nothing at the centre to [NebaScale.tickDot] as the radio is chosen
/// and shrinks back as it is left, by its width and height over
/// [NebaScale.duration] rather than by a scale.
class NebaTickDot extends StatelessWidget {
  /// A dot of [size] while [shown].
  const NebaTickDot({required this.size, required this.shown, super.key});

  /// The radio's size, which sets the dot's diameter.
  final NebaSize size;

  /// Whether the dot is there.
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final Color ink = IconTheme.of(context).color ?? const Color(0xFF000000);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: shown ? NebaScale.tickDot[size]! : 0),
        duration: nebaDuration(context, NebaScale.duration),
        curve: NebaScale.ease,
        builder: (BuildContext context, double diameter, Widget? _) {
          return SizedBox.square(
            dimension: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
            ),
          );
        },
      ),
    );
  }
}
