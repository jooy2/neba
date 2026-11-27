/// `NebaRating`, a score given in stars.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A score given in stars, or shown in them.
///
/// The stars are a set of choices in steps of [precision], one stop in the
/// focus order whose arrow keys move along it and choose as they go, as a set
/// of radios does. A star fills by a width that travels, never by a scale,
/// and the pointer shows the score it would give before it is pressed.
/// [readOnly] makes it a picture of a score.
///
/// ```dart
/// NebaRating(value: score, onValueChange: (double value) => setState(() => score = value))
/// ```
class NebaRating extends StatefulWidget {
  /// A rating out of [count].
  const NebaRating({
    this.value,
    this.defaultValue = 0,
    this.onValueChange,
    this.count = 5,
    this.precision = 1,
    this.icon,
    this.emptyIcon,
    this.clearable = true,
    this.readOnly = false,
    this.disabled = false,
    this.size,
    this.color = NebaColor.warning,
    this.locale,
    this.semanticLabel,
    this.valueLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The score, when the caller holds it. `0` is no score.
  final double? value;

  /// The score to start from, when the rating holds its own.
  final double defaultValue;

  /// Called with the score chosen, `0` when a chosen score is pressed again
  /// to clear it.
  final ValueChanged<double>? onValueChange;

  /// How many stars there are.
  final int count;

  /// The step a score moves in: `1` for whole stars, `0.5` for halves.
  final double precision;

  /// A glyph of the caller's own for a given point, drawn in the fill colour.
  final Widget? icon;

  /// A glyph of the caller's own for a point not given.
  final Widget? emptyIcon;

  /// Whether pressing the chosen score again clears it.
  final bool clearable;

  /// Whether the stars only show the score.
  final bool readOnly;

  /// Whether the rating takes no input.
  final bool disabled;

  /// The stars' size. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of a given point.
  final NebaColor color;

  /// The language of what a screen reader hears.
  final Locale? locale;

  /// The rating's name for a screen reader, in place of "Rating".
  final String? semanticLabel;

  /// What a screen reader hears for a score, in place of "4 out of 5".
  final String Function(double value, int count)? valueLabel;

  /// The rating's focus node.
  final FocusNode? focusNode;

  /// Whether the rating takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaRating> createState() => _NebaRatingState();
}

class _NebaRatingState extends State<NebaRating> {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late double _own = widget.defaultValue;
  double? _hovered;
  bool _focused = false;
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'NebaRating'));

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  double get _value => widget.value ?? _own;
  int get _stars => math.max(1, widget.count);
  double get _step => widget.precision > 0 && widget.precision <= 1 ? widget.precision : 1;

  /// Every score the rating can give, in order.
  List<double> get _scores {
    final int steps = (1 / _step).round();

    return <double>[
      for (int k = 1; k <= _stars * steps; k++) double.parse((k * _step).toStringAsFixed(4)),
    ];
  }

  bool get _interactive => !widget.readOnly && !_disabled;

  void _change(double next) {
    if (widget.value == null) {
      setState(() => _own = next);
    }

    widget.onValueChange?.call(next);
  }

  void _choose(double score) {
    _change(widget.clearable && _value == score ? 0 : score);
  }

  String _describe(BuildContext context, double score) {
    final String Function(double value, int count)? custom = widget.valueLabel;

    if (custom != null) {
      return custom(score, _stars);
    }

    final Map<String, String> messages = nebaMessages(context, 'rating', locale: widget.locale);

    if (score <= 0) {
      return messages['empty']!;
    }

    final double rounded = (score * 10).round() / 10;
    final String written = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();

    return fillNebaMessage(messages['value']!, <String, String>{
      'value': written,
      'max': '$_stars',
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final List<double> scores = _scores;
    final int current = scores.indexOf(_value);
    // With nothing chosen the first radio holds the focus, as a browser's do.
    final int at = current < 0 ? 0 : current;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    int? next;

    if (key == LogicalKeyboardKey.arrowUp ||
        key == (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)) {
      next = (at + 1) % scores.length;
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)) {
      next = (at - 1 + scores.length) % scores.length;
    } else if (key == LogicalKeyboardKey.space && current < 0) {
      next = 0;
    }

    if (next == null) {
      return KeyEventResult.ignored;
    }

    _change(scores[next]);

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final double side = NebaScale.iconSize[size]!;
    final double gap = NebaScale.gap[size]!;
    final int stars = _stars;
    final double step = _step;
    final int steps = (1 / step).round();
    final double value = _value;
    final double shown = math.max(0, math.min(stars.toDouble(), _hovered ?? value));
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly;
    final Color fill = disabled ? tokens.disabledFg : roles.fill;
    final Color empty = disabled
        ? tokens.disabledFg
        : tokens.mutedFg.withValues(alpha: tokens.mutedFg.a * (readOnly ? 0.4 : 0.8));
    final Duration duration = nebaDuration(context, NebaScale.duration);
    final List<double> scores = _scores;
    final int chosen = scores.indexOf(value);
    // The star whose radio holds the focus: the chosen one's, or the first.
    final int ringed = chosen < 0 ? 0 : (scores[chosen] - 0.0001).floor();

    Widget glyph(Widget? own, List<NebaGlyphPart> parts, Color colour) {
      return IconTheme.merge(
        data: IconThemeData(size: side, color: colour),
        child: SizedBox.square(
          dimension: side,
          child: own ?? NebaGlyph(parts, color: colour),
        ),
      );
    }

    Widget star(int index) {
      final double part = math.max(0, math.min(1, shown - index)).toDouble();

      Widget drawn = SizedBox.square(
        dimension: side,
        child: Stack(
          children: <Widget>[
            glyph(widget.emptyIcon, NebaGlyphs.starOutline, empty),
            // The filled copy, cropped to the fraction from the start edge
            // by a width that travels: the glyph keeps its own width.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: part),
              duration: duration,
              curve: NebaScale.ease,
              builder: (BuildContext context, double width, Widget? child) {
                return ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: width,
                    child: child,
                  ),
                );
              },
              child: glyph(widget.icon, NebaGlyphs.star, fill),
            ),
          ],
        ),
      );

      drawn = ExcludeSemantics(child: drawn);

      if (!readOnly) {
        drawn = NebaFocusRing(
          visible: _focused && ringed == index,
          color: roles.ring,
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.xs]!),
          child: drawn,
        );
      }

      // Each step of the star is a press target, and the targets meet across
      // the gap, so there is nowhere between two stars a press is lost.
      final Widget padded = Padding(
        padding: EdgeInsetsDirectional.only(
          start: index == 0 ? 0 : gap / 2,
          end: index == stars - 1 ? 0 : gap / 2,
        ),
        child: drawn,
      );

      return readOnly
          ? padded
          : Stack(
              children: <Widget>[
                padded,
                Positioned.fill(
                  child: Row(
                    children: <Widget>[
                      for (int p = 0; p < steps; p++)
                        Expanded(child: _segment(context, scores[index * steps + p], value)),
                    ],
                  ),
                ),
              ],
            );
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[for (int i = 0; i < stars; i++) star(i)],
    );

    if (readOnly) {
      return Semantics(
        container: true,
        image: true,
        label: _describe(context, math.max(0, math.min(stars.toDouble(), value))),
        child: ExcludeSemantics(child: row),
      );
    }

    row = MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : MouseCursor.defer,
      onExit: (PointerExitEvent event) => setState(() => _hovered = null),
      child: row,
    );

    return Semantics(
      container: true,
      role: SemanticsRole.radioGroup,
      label:
          widget.semanticLabel ?? nebaMessages(context, 'rating', locale: widget.locale)['label'],
      enabled: !disabled,
      child: Focus(
        focusNode: _focus,
        autofocus: widget.autofocus,
        canRequestFocus: _interactive,
        skipTraversal: !_interactive,
        includeSemantics: false,
        onKeyEvent: _onKey,
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        child: row,
      ),
    );
  }

  Widget _segment(BuildContext context, double score, double value) {
    final bool interactive = _interactive;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: value == score,
      enabled: interactive,
      label: _describe(context, score),
      onTap: interactive ? () => _choose(score) : null,
      child: MouseRegion(
        cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: interactive ? (PointerEnterEvent event) => setState(() => _hovered = score) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // The tap a screen reader sends is the radio's above; a second one
          // here would split off a node of its own with no name.
          excludeFromSemantics: true,
          onTap: interactive
              ? () {
                  _focus.requestFocus();
                  _choose(score);
                }
              : null,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
