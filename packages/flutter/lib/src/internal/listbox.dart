/// The list a Select and a Combobox open: the React package's `popupClasses`,
/// `itemClasses` and `groupLabelClasses`, which the two components each
/// write out to the same values, because a combobox's list and a select's
/// list are the same list.
///
/// - [NebaListSheet], the frosted panel the rows sit on, which carries a
///   shadow by default since it is the one kind of surface meant to float,
///   and scrolls once it reaches the height the popup is given.
/// - [NebaListRow], one option: a gutter at its start for the tick or the
///   plus, the highlight the pointer and the arrow keys both move, the chosen
///   option's ink and weight, and a disabled option's grey.
/// - [NebaListHeading], the heading over a group of rows, which cannot be
///   highlighted or chosen.
/// - [NebaTypeahead], the first letters of an option typed to reach it.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The tallest a list gets before it scrolls: `20rem`, or less where the
/// window has less room beside the trigger.
const double nebaListMaxHeight = 320;

/// How far a row's text starts from its start edge, past the gutter its tick
/// is drawn in: `ps-7`.
const double _rowStart = 28;

/// A row's padding at its end and above and below its text: `pe-2`, `py-1.5`.
const double _rowEnd = 8;
const double _rowY = 6;

/// Where the tick sits in the gutter, and how big it is: `start-1.5`,
/// `size-4`.
const double _indicatorStart = 6;
const double _indicatorSize = 16;

/// The panel a list of options sits on: the sheet a page sits under, at
/// elevation 3, with a hairline in the family of [roles], the corners of
/// [size], four pixels of padding inside its edge and the control's own type.
///
/// It is as wide as its widest row, as a CSS box sized by its content is,
/// within what the popup is given, and it scrolls [child] once the popup's
/// height runs out. A screen reader hears it named by [semanticLabel].
class NebaListSheet extends StatelessWidget {
  /// A sheet holding [child], a column of rows.
  const NebaListSheet({
    required this.size,
    required this.roles,
    required this.child,
    this.controller,
    this.semanticLabel,
    super.key,
  });

  /// The type, the corners and the rows' padding.
  final NebaSize size;

  /// The family of the hairline and the highlight.
  final NebaColorRoles roles;

  /// The rows.
  final Widget child;

  /// The list's scroll position, when the caller moves it.
  final ScrollController? controller;

  /// What a screen reader calls the list.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.controlText[size]!;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: IntrinsicWidth(
        child: NebaSheet(
          fill: tokens.panelPress,
          edge: roles.line,
          plate: NebaPlate.glass,
          elevation: 3,
          borderRadius: BorderRadius.circular(tokens.radius[size]!),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: text,
              height: NebaScale.controlLeading[size]! / text,
              leadingDistribution: TextLeadingDistribution.even,
              color: tokens.fg,
            ),
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(4),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// One option in a list.
///
/// The highlight is a wash in the list's family and the ink turns to its
/// `onTint`: the row the pointer is over and the row the arrow keys reached
/// are the same row, so the two light it the same way. A chosen row takes the
/// same ink and a medium weight, and a disabled one goes grey and takes no
/// press. [indicator] stands in the gutter before the text.
///
/// A row that [reveal]s scrolls itself into the list's view when it becomes
/// highlighted, which a row the keys reached does and one under the pointer
/// does not, since the pointer is already over it.
class NebaListRow extends StatefulWidget {
  /// A row showing [child].
  const NebaListRow({
    required this.roles,
    required this.child,
    this.highlighted = false,
    this.selected = false,
    this.disabled = false,
    this.reveal = false,
    this.indicator,
    this.onHover,
    this.onExit,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  /// The family of the highlight and the chosen ink.
  final NebaColorRoles roles;

  /// The option's label, on one line, cut short with an ellipsis.
  final Widget child;

  /// Whether the pointer or the keys are on this row.
  final bool highlighted;

  /// Whether this option is chosen.
  final bool selected;

  /// Listed but not available.
  final bool disabled;

  /// Whether the row scrolls into view when it becomes highlighted.
  final bool reveal;

  /// Drawn in the gutter before the text: the tick of a chosen option.
  final Widget? indicator;

  /// Called as the pointer moves over the row.
  final VoidCallback? onHover;

  /// Called when the pointer leaves the row.
  final VoidCallback? onExit;

  /// Called when the row is pressed.
  final VoidCallback? onPressed;

  /// What a screen reader hears for the row, in place of what [child] says.
  final String? semanticLabel;

  @override
  State<NebaListRow> createState() => _NebaListRowState();
}

class _NebaListRowState extends State<NebaListRow> {
  @override
  void initState() {
    super.initState();

    if (widget.highlighted && widget.reveal) {
      _revealLater();
    }
  }

  @override
  void didUpdateWidget(NebaListRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.highlighted && widget.reveal && (!oldWidget.highlighted || !oldWidget.reveal)) {
      _revealLater();
    }
  }

  void _revealLater() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      // The nearest edge: down to show a row below the view, up for one
      // above it, and nothing for one already in it.
      for (final ScrollPositionAlignmentPolicy policy in <ScrollPositionAlignmentPolicy>[
        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      ]) {
        Scrollable.ensureVisible(context, alignmentPolicy: policy);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = widget.roles;
    final bool disabled = widget.disabled;
    final bool highlighted = widget.highlighted && !disabled;
    final Color ink = disabled
        ? tokens.disabledFg
        : highlighted || widget.selected
        ? roles.onTint
        : tokens.fg;
    final Widget? indicator = widget.indicator;

    Widget row = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(_rowStart, _rowY, _rowEnd, _rowY),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontWeight: widget.selected ? FontWeight.w500 : FontWeight.w400),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: widget.child,
      ),
    );

    if (indicator != null) {
      row = Stack(
        children: <Widget>[
          row,
          PositionedDirectional(
            start: _indicatorStart,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconTheme.merge(
                data: const IconThemeData(size: _indicatorSize),
                child: SizedBox.square(
                  dimension: _indicatorSize,
                  child: Center(child: indicator),
                ),
              ),
            ),
          ),
        ],
      );
    }

    row = TweenAnimationBuilder<Color?>(
      // The wash drains at the fill's pace, as every highlight in the library
      // does; it never lands in zero time, since a row is entered, not pressed.
      tween: ColorTween(end: highlighted ? roles.softHover : roles.softHover.withValues(alpha: 0)),
      duration: nebaDuration(context, NebaScale.durationFill),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? wash, Widget? child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: wash,
            borderRadius: BorderRadius.circular(tokens.radius[NebaSize.xs]!),
          ),
          child: child,
        );
      },
      child: NebaInk(color: ink, child: row),
    );

    final String? semanticLabel = widget.semanticLabel;

    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      enabled: !disabled,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      onTap: disabled ? null : widget.onPressed,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onHover: disabled ? null : (PointerHoverEvent _) => widget.onHover?.call(),
        onExit: (PointerExitEvent _) => widget.onExit?.call(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: disabled ? null : widget.onPressed,
          child: row,
        ),
      ),
    );
  }
}

/// The heading over a group of options: the row's own padding, so the
/// heading and the options under it share a start edge and the gutter stays
/// empty, in the label type, semibold, spaced out a little and in capitals,
/// and muted. It is a heading to a screen reader, in the words as written.
class NebaListHeading extends StatelessWidget {
  /// A heading saying [label].
  const NebaListHeading({required this.label, required this.size, super.key});

  /// The group's name.
  final String label;

  /// The list's size, which sets the type.
  final NebaSize size;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double meta = NebaScale.metaText[size]!;

    return Semantics(
      header: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(_rowStart, _rowY, _rowEnd, _rowY),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: meta,
            // The list's line box, which CSS carries down as a length.
            height: NebaScale.controlLeading[size]! / meta,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025 * meta,
            color: tokens.mutedFg,
          ),
        ),
      ),
    );
  }
}

/// The first letters of an option, typed to reach it, as floating-ui's
/// typeahead under Base UI's Select reads them.
///
/// The letters typed within [resetAfter] of each other make one string, and
/// the option reached is the first after where the search started whose
/// words begin with it, wrapping round. Typing one letter again and again
/// steps through the options that begin with it, unless an option begins
/// with the same letter twice, as `Llama` does.
class NebaTypeahead {
  /// A typeahead that forgets what was typed after [resetAfter], floating-ui's
  /// 750 milliseconds, which Base UI's Select keeps.
  NebaTypeahead({this.resetAfter = const Duration(milliseconds: 750)});

  /// How long after the last letter the string starts again.
  final Duration resetAfter;

  String _typed = '';
  int _origin = -1;
  int? _match;
  Timer? _timer;

  /// Whether letters are being typed, which makes a space part of the string
  /// rather than a key that chooses.
  bool get typing => _typed.isNotEmpty;

  /// The option [character] reaches among [labels], or `null` for none.
  ///
  /// A `null` label is an option that cannot be reached, a disabled one.
  /// [current] is where a new string starts searching from: the highlighted
  /// option, or the chosen one.
  int? type(String character, {required List<String?> labels, int? current}) {
    if (_typed.isEmpty) {
      _origin = current ?? -1;
    }

    final bool cycles = labels.every((String? label) {
      return label == null || label.length < 2 || label[0].toLowerCase() != label[1].toLowerCase();
    });

    if (cycles && _typed == character) {
      _typed = '';
      _origin = _match ?? _origin;
    }

    _typed += character;
    _timer?.cancel();
    _timer = Timer(resetAfter, () {
      _typed = '';
      _origin = _match ?? _origin;
    });

    final String needle = _typed.toLowerCase();
    final int count = labels.length;

    for (int step = 1; step <= count; step++) {
      final int index = (_origin + step) % count;
      final String? label = labels[index];

      if (label != null && label.toLowerCase().startsWith(needle)) {
        _match = index;

        return index;
      }
    }

    if (character != ' ') {
      _typed = '';
    }

    return null;
  }

  /// Forgets what was typed.
  void reset() {
    _timer?.cancel();
    _timer = null;
    _typed = '';
    _match = null;
    _origin = -1;
  }

  /// Stops the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
