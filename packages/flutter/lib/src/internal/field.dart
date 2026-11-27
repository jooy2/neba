/// What every field-shaped widget is drawn from: the React package's field
/// tables in `internal/styles.ts` and the parts of its `TextField` that a
/// NumberField, a Select, a Combobox and the pickers draw the same way.
///
/// - [NebaFieldColumn], the label, the field, the description and the error,
///   one under the other.
/// - [NebaFieldShell], the box the control sits in: its sheet in each variant
///   and state ([NebaFieldLook]), the ring flush with its edge, half the
///   pointer spotlight and never the press flash, the light put out while the
///   reader types ([NebaFieldTypingMark]), and the label on its edge when
///   there is one ([NebaFieldNotch]).
/// - [NebaFieldAdornment], an icon at the shell's start or end, muted until
///   the field holds the focus.
/// - [NebaFieldWidth], how wide a field is when it is not told to stretch.
/// - [NebaFieldSemantics], what a screen reader hears of the column.
///
/// A field's height is a floor rather than a fixed row: a control the library
/// draws the contents of is exactly as tall as the ladder says, but a field
/// holds a caller's own text, and text set larger than the step grows the
/// shell instead of being cut off by it.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A multiline field's padding above and below its text:
/// `(height - border - line height) / 2`, which makes one row exactly as tall
/// as a single-line field of the same size. Keyed by size and never by
/// density, which is inline padding only.
const Map<NebaSize, double> nebaFieldMultilinePad = <NebaSize, double>{
  NebaSize.xs: 3,
  NebaSize.sm: 4,
  NebaSize.md: 5,
  NebaSize.lg: 8,
  NebaSize.xl: 10,
};

/// How wide a field is when it is not told to stretch: room for twenty
/// characters of about half an em each, which is what a browser gives an
/// `<input>` it was told nothing about, and the shell's padding around them.
double nebaFieldWidth(NebaSize size, NebaDensity density) {
  return 11 * NebaScale.controlText[size]! + 2 * NebaScale.paddingX[density]![size]!;
}

/// The words of a `Text`, or `null` for any other widget or an empty one.
String? nebaPlainText(Widget? widget) {
  if (widget is! Text) {
    return null;
  }

  final String? text = widget.semanticsLabel ?? widget.data ?? widget.textSpan?.toPlainText();

  return text == null || text.trim().isEmpty ? null : text;
}

/// What a screen reader hears of a field's column: the label as the field's
/// name, and the description and the error after it, as the React package
/// wires `aria-describedby`.
///
/// A part is only taken when it is a `Text`, whose words can be read; any
/// other widget is left where it is and read as part of the field.
@immutable
class NebaFieldSemantics {
  const NebaFieldSemantics._({
    required this.label,
    required this.hint,
    required this.labelTaken,
    required this.descriptionTaken,
    required this.errorTaken,
  });

  /// What is heard of a field with these parts.
  ///
  /// [semanticLabel] names the field in place of [label]. A field with
  /// neither is named by its [placeholder], as a browser names an input that
  /// has nothing else; one with a name hears the placeholder after it, unless
  /// a description or an error is already there.
  factory NebaFieldSemantics.of({
    String? semanticLabel,
    Widget? label,
    Widget? description,
    Widget? error,
    String? placeholder,
  }) {
    final String? labelText = nebaPlainText(label);
    final String? descriptionText = nebaPlainText(description);
    final String? errorText = nebaPlainText(error);
    final String? hint = placeholder == null || placeholder.trim().isEmpty ? null : placeholder;
    final String? name = semanticLabel ?? labelText;
    final List<String> described = <String>[?descriptionText, ?errorText];

    return NebaFieldSemantics._(
      label: name ?? hint,
      hint: described.isNotEmpty
          ? described.join('\n')
          : name == null
          ? null
          : hint,
      labelTaken: labelText != null,
      descriptionTaken: descriptionText != null,
      errorTaken: errorText != null,
    );
  }

  /// The field's name.
  final String? label;

  /// What is read after the name.
  final String? hint;

  /// Whether the label's words are in [label], so the label itself is left
  /// out of what is read.
  final bool labelTaken;

  /// Whether the description's words are in [hint].
  final bool descriptionTaken;

  /// Whether the error's words are in [hint].
  final bool errorTaken;
}

/// What a field's shell looks like in one state.
///
/// The variants say what they say on a button, filled, hairline and bare,
/// with one difference: `solid` does not flood the field with its colour.
/// What a field holds is user data, and a caret, a selection and a placeholder
/// have to stay legible on it. So the sheet is the undyed panel, `solid` a
/// step up its ladder from `outline`, and the colour family shows in the edge,
/// the ring and the caret instead.
@immutable
class NebaFieldLook {
  /// A shell's look, written out.
  const NebaFieldLook({
    required this.fill,
    required this.edge,
    required this.plate,
    required this.elevation,
    required this.textured,
    required this.ink,
  });

  /// The React package's `fieldRestClasses`, `fieldReadOnlyClasses` and
  /// `disabledClasses`, and with [notched] their `fieldSheet` counterparts,
  /// decided in one place so the states cannot stack.
  ///
  /// A notched shell keeps its sheet and gives its edge to the notch: no
  /// plate, and an outline's hairline kept transparent, so the box is the
  /// same size whether the label stands on it or not.
  factory NebaFieldLook.of({
    required NebaTokens tokens,
    required NebaColorRoles roles,
    required NebaVariant variant,
    required NebaElevation elevation,
    required bool disabled,
    required bool readOnly,
    required bool hovered,
    required bool focused,
    bool notched = false,
  }) {
    if (disabled) {
      return switch (variant) {
        NebaVariant.solid => NebaFieldLook(
          fill: tokens.disabledBg,
          edge: null,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
          ink: tokens.disabledFg,
        ),
        NebaVariant.outline => NebaFieldLook(
          fill: transparent,
          edge: notched ? transparent : tokens.disabledBorder,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
          ink: tokens.disabledFg,
        ),
        NebaVariant.text => NebaFieldLook(
          fill: transparent,
          edge: null,
          plate: NebaPlate.none,
          elevation: 0,
          textured: false,
          ink: tokens.disabledFg,
        ),
      };
    }

    // Read-only goes flat and answers neither the pointer nor the focus; the
    // desaturation is the shell's, over everything in it.
    final bool raised = !readOnly && (hovered || focused);

    return switch (variant) {
      NebaVariant.solid => NebaFieldLook(
        fill: raised ? tokens.panelPress : tokens.panelHover,
        edge: null,
        plate: notched ? NebaPlate.none : NebaPlate.solid,
        elevation: readOnly ? 0 : elevation,
        textured: true,
        ink: tokens.fg,
      ),
      NebaVariant.outline => NebaFieldLook(
        fill: raised ? tokens.panelHover : tokens.panel,
        edge: notched
            ? transparent
            : readOnly
            ? roles.line
            : focused
            ? roles.ring
            : hovered
            ? roles.lineHover
            : roles.line,
        plate: notched ? NebaPlate.none : NebaPlate.glass,
        elevation: readOnly ? 0 : elevation,
        textured: true,
        ink: tokens.fg,
      ),
      // No surface until it is wanted: the field in a table cell that only
      // looks like a field once you go near it.
      NebaVariant.text => NebaFieldLook(
        fill: readOnly
            ? transparent
            : focused
            ? roles.softHover
            : hovered
            ? roles.soft
            : transparent,
        edge: null,
        plate: NebaPlate.none,
        elevation: 0,
        textured: false,
        ink: tokens.fg,
      ),
    };
  }

  /// The sheet's colour.
  final Color fill;

  /// The hairline, or `null` for none at all. An outline shell always has
  /// one, transparent when there is nothing to draw, so it never changes size.
  final Color? edge;

  /// The light on the sheet's edge.
  final NebaPlate plate;

  /// The drop shadow.
  final int elevation;

  /// Whether the sheet is frosted: blurred behind, with the grain and the sheen.
  final bool textured;

  /// The text colour inside.
  final Color ink;
}

/// A label on a field's top edge, for [NebaFieldShell.notch].
@immutable
class NebaFieldNotch {
  /// [label] on the edge.
  const NebaFieldNotch({
    required this.label,
    this.rests = false,
    this.empty = false,
    this.firstLine,
    this.restEnd = 0,
  });

  /// The label.
  final Widget label;

  /// Whether the label comes down into the field while the field is [empty]
  /// and nothing in it has the focus: `float`, with nothing drawn where the
  /// label would rest.
  final bool rests;

  /// Whether the field holds no value.
  final bool empty;

  /// For a field whose text starts at the top: how far below the shell's
  /// inner edge its first line sits, where a resting label rests.
  final double? firstLine;

  /// What is drawn at the shell's end, from `nebaNotchRestEnd`, which a
  /// resting label stops short of.
  final double restEnd;
}

/// Builds what sits in a field's shell, given whether anything in it has the
/// focus.
typedef NebaFieldContentBuilder = Widget Function(BuildContext context, bool focused);

/// The box a field's control sits in.
///
/// Its height is a floor of the control height at [size]; its inline padding
/// is [density]'s, and a [multiline] shell pads its text top and bottom so one
/// row is exactly a single-line shell's height. It fills the width it is
/// given, which `NebaFieldWidth` decides.
///
/// The focus anywhere inside it raises the sheet a step, turns an outline's
/// hairline the ring's colour and draws the ring, flush with the edge because
/// the hairline under it is already the ring's colour. A read-only shell
/// keeps the ring for keyboard focus only, as a browser keeps `:focus-visible`
/// off a read-only input a pointer clicked into. The pointer lights the shell
/// at half a control's strength, and the light goes out while [typing] is set
/// and comes back when the pointer moves.
class NebaFieldShell extends StatefulWidget {
  /// A shell around what [builder] builds.
  const NebaFieldShell({
    required this.variant,
    required this.size,
    required this.density,
    required this.roles,
    required this.builder,
    this.elevation = 0,
    this.disabled = false,
    this.readOnly = false,
    this.multiline = false,
    this.typing,
    this.notch,
    this.cursor = MouseCursor.defer,
    super.key,
  });

  /// The weight of the sheet.
  final NebaVariant variant;

  /// The height floor, the corners and the type.
  final NebaSize size;

  /// The inline padding.
  final NebaDensity density;

  /// The colour family the edge, the ring and the light are drawn in.
  final NebaColorRoles roles;

  /// The control and its adornments.
  final NebaFieldContentBuilder builder;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Grey and unlit.
  final bool disabled;

  /// Flat, desaturated and unlit.
  final bool readOnly;

  /// Whether the text starts at the top, padded above and below, rather than
  /// in the middle.
  final bool multiline;

  /// Set while the reader is typing, which puts the light out. A
  /// [NebaFieldTypingMark] around the control sets it.
  final ValueNotifier<bool>? typing;

  /// A label on the top edge, which the edge is then drawn around.
  final NebaFieldNotch? notch;

  /// The pointer's cursor over the shell.
  final MouseCursor cursor;

  @override
  State<NebaFieldShell> createState() => _NebaFieldShellState();
}

class _NebaFieldShellState extends State<NebaFieldShell> {
  static final ValueNotifier<bool> _neverTyping = ValueNotifier<bool>(false);

  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    NebaInputModality.pointer.addListener(_handleModality);
  }

  @override
  void dispose() {
    NebaInputModality.pointer.removeListener(_handleModality);
    _pointer.dispose();
    super.dispose();
  }

  /// [change] now, or after the frame when it would land in the middle of
  /// one: a focus change can arrive while the tree is being built.
  void _later(VoidCallback change) {
    if (!mounted) {
      return;
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          setState(change);
        }
      });
    } else {
      setState(change);
    }
  }

  void _handleFocusChange(bool focused) {
    if (focused != _focused) {
      _later(() => _focused = focused);
    }
  }

  void _handleModality() {
    // Only a read-only shell's ring depends on how the focus arrived.
    if (widget.readOnly && _focused) {
      _later(() {});
    }
  }

  void _handleEnter(PointerEnterEvent event) {
    _pointer.value = event.localPosition;

    if (!_hovered) {
      setState(() => _hovered = true);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    _pointer.value = event.localPosition;
    widget.typing?.value = false;
  }

  void _handleExit(PointerExitEvent event) {
    _pointer.value = null;

    if (_hovered) {
      setState(() => _hovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size;
    final NebaColorRoles roles = widget.roles;
    final bool disabled = widget.disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool lit = !disabled && !readOnly;
    final bool hovered = _hovered && !disabled;
    final NebaFieldNotch? notch = widget.notch;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[size]!);
    final NebaFieldLook look = NebaFieldLook.of(
      tokens: tokens,
      roles: roles,
      variant: widget.variant,
      elevation: widget.elevation,
      disabled: disabled,
      readOnly: readOnly,
      hovered: hovered,
      focused: _focused,
      notched: notch != null,
    );
    // A caret is a focus, however it got there, as `:focus-within` rings a
    // field; a read-only field has none, so its ring waits for a key, as
    // `:focus-visible` waits.
    final bool ring = _focused && !disabled && (!readOnly || !NebaInputModality.pointer.value);
    final double border = look.edge == null ? 0 : 1;

    Widget shell = NebaSheet(
      fill: look.fill,
      edge: look.edge,
      plate: look.plate,
      elevation: look.elevation,
      borderRadius: radius,
      blur: look.textured,
      texture: look.textured,
      fillDuration: _focused ? NebaScale.duration : null,
      child: NebaInk(
        color: look.ink,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            ConstrainedBox(
              // The whole box's height, hairline included, as a CSS
              // `border-box` is: an outline field is as tall as a solid one.
              constraints: BoxConstraints(minHeight: NebaScale.controlHeight[size]! - 2 * border),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: NebaScale.paddingX[widget.density]![size]!,
                  vertical: widget.multiline ? nebaFieldMultilinePad[size]! : 0,
                ),
                child: Align(
                  alignment: widget.multiline
                      ? AlignmentDirectional.topStart
                      : AlignmentDirectional.centerStart,
                  heightFactor: 1,
                  child: widget.builder(context, _focused),
                ),
              ),
            ),
            if (lit)
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: widget.typing ?? _neverTyping,
                  builder: (BuildContext context, bool typing, Widget? _) {
                    return NebaGlow(
                      interaction: NebaInteraction(hovered: hovered),
                      pointer: _pointer,
                      colors: NebaGlowColors.field(roles),
                      borderRadius: radius,
                      spotlight: !typing,
                      afterglow: false,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );

    if (notch != null) {
      shell = NebaNotch(
        label: notch.label,
        geometry: NebaNotchGeometry.of(
          tokens: tokens,
          size: size,
          density: widget.density,
          variant: widget.variant,
          firstLine: notch.firstLine,
          restEnd: notch.restEnd,
        ),
        look: NebaNotchLook.of(
          tokens: tokens,
          roles: roles,
          variant: widget.variant,
          disabled: disabled,
          readOnly: readOnly,
          hovered: hovered,
          focused: _focused,
        ),
        resting: notch.rests && notch.empty && !_focused,
        ring: ring ? roles.ring : roles.ring.withValues(alpha: 0),
        ink: disabled ? tokens.disabledFg : tokens.fg,
        restInk: disabled ? tokens.disabledFg : tokens.mutedFg,
        child: shell,
      );
    } else {
      shell = NebaFocusRing(
        visible: ring,
        color: roles.ring,
        borderRadius: radius,
        offset: 0,
        // How the focus arrived is already in `ring`.
        keyboardOnly: false,
        child: shell,
      );
    }

    if (readOnly) {
      shell = ColorFiltered(colorFilter: ColorFilter.matrix(saturationMatrix(0.55)), child: shell);
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _handleFocusChange,
      child: MouseRegion(
        cursor: widget.cursor,
        onEnter: disabled ? null : _handleEnter,
        onHover: disabled ? null : _handleHover,
        onExit: disabled ? null : _handleExit,
        child: shell,
      ),
    );
  }
}

/// Marks [typing] on every key pressed in [child], which puts a field's light
/// out until the pointer next moves.
///
/// Any key, not only the ones that type: a reader walking the caret with the
/// arrows is reading the field just as closely. It lets every key through, so
/// it goes between the control and anything that binds keys, which then still
/// sees them all.
class NebaFieldTypingMark extends StatelessWidget {
  /// Marks [typing] on a key pressed in [child].
  const NebaFieldTypingMark({required this.typing, required this.child, super.key});

  /// What is set.
  final ValueNotifier<bool> typing;

  /// The control.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyUpEvent) {
          typing.value = true;
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// An icon at a field's start or end, muted until the field holds the focus
/// and in [accent] while it does.
///
/// It is drawn at 1.2 times the control's text and stands in a box one line
/// tall, so in a multiline field it stays on the first line rather than in
/// the middle of five.
class NebaFieldAdornment extends StatelessWidget {
  /// [child] beside a field's control.
  const NebaFieldAdornment({
    required this.size,
    required this.focused,
    required this.accent,
    required this.child,
    super.key,
  });

  /// The field's size.
  final NebaSize size;

  /// Whether the field holds the focus.
  final bool focused;

  /// The colour while it does.
  final Color accent;

  /// The icon.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return SizedBox(
      height: NebaScale.controlLeading[size],
      child: Center(
        widthFactor: 1,
        child: NebaInk(
          color: focused ? accent : tokens.mutedFg,
          child: IconTheme.merge(
            data: IconThemeData(size: NebaScale.controlText[size]! * 1.2),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A field's label, the field, its description and its error, one under the
/// other, each a step below the control's text.
///
/// A set of options, a radio group or a checkbox group, puts its description
/// between the label and the options instead ([descriptionFirst]), because
/// it describes the question and not one answer, and stands its parts at a
/// gap of its own.
///
/// The parts [semantics] took the words of are left out of what a screen
/// reader hears, since the field says them itself.
class NebaFieldColumn extends StatelessWidget {
  /// The column around [field].
  const NebaFieldColumn({
    required this.size,
    required this.field,
    required this.errorColor,
    required this.semantics,
    this.label,
    this.description,
    this.error,
    this.disabled = false,
    this.onLabelTap,
    this.descriptionFirst = false,
    this.spacing,
    super.key,
  });

  /// The field's size, which sets the type and the gaps.
  final NebaSize size;

  /// The shell.
  final Widget field;

  /// The error's colour: the field's accent, `danger`'s while it is invalid.
  final Color errorColor;

  /// What the field reads itself.
  final NebaFieldSemantics semantics;

  /// Above the field, or `null` when the label is on its edge or absent.
  final Widget? label;

  /// Helper text under the field.
  final Widget? description;

  /// The error under the field.
  final Widget? error;

  /// Whether the field is disabled, which greys the label.
  final bool disabled;

  /// Called on a tap on the label, which puts the focus in the field as a
  /// `<label>` does.
  final VoidCallback? onLabelTap;

  /// Whether the description stands between the label and the field.
  final bool descriptionFirst;

  /// Between the parts, [NebaScale.stackGap] at [size] when left out.
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double meta = NebaScale.metaText[size]!;

    Widget part(Widget child, Color color, {required bool taken, FontWeight? weight}) {
      return ExcludeSemantics(
        excluding: taken,
        child: DefaultTextStyle.merge(
          style: TextStyle(fontSize: meta, color: color, fontWeight: weight),
          child: child,
        ),
      );
    }

    final Widget? label = this.label;
    final Widget? description = this.description;
    final Widget? error = this.error;
    final Widget? describing = description == null
        ? null
        : part(description, tokens.mutedFg, taken: semantics.descriptionTaken);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing ?? NebaScale.stackGap[size]!,
      children: <Widget>[
        if (label != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The field's own node already takes a tap to focus it.
            excludeFromSemantics: true,
            onTap: disabled ? null : onLabelTap,
            child: part(
              label,
              disabled ? tokens.disabledFg : tokens.fg,
              taken: semantics.labelTaken,
              weight: FontWeight.w500,
            ),
          ),
        if (descriptionFirst) ?describing,
        field,
        if (!descriptionFirst) ?describing,
        if (error != null) part(error, errorColor, taken: semantics.errorTaken),
      ],
    );
  }
}

/// How wide a field is.
///
/// [fullWidth] takes the width it is given. Otherwise the field is [width]
/// across, never narrower than [sizer] needs, which is what keeps a field as
/// wide as a label on its edge, and never wider than it is given. The sizer
/// is measured and never drawn.
class NebaFieldWidth extends MultiChildRenderObjectWidget {
  /// [child] at a field's width.
  NebaFieldWidth({
    required this.width,
    required Widget child,
    this.fullWidth = false,
    Widget? sizer,
    super.key,
  }) : super(children: <Widget>[child, ?sizer]);

  /// The width when nothing else decides it.
  final double width;

  /// Whether the field takes the width it is given.
  final bool fullWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderNebaFieldWidth(width: width, fullWidth: fullWidth);
  }

  @override
  void updateRenderObject(BuildContext context, RenderNebaFieldWidth renderObject) {
    renderObject
      ..width = width
      ..fullWidth = fullWidth;
  }
}

class _FieldWidthParentData extends ContainerBoxParentData<RenderBox> {}

/// The render object of [NebaFieldWidth].
class RenderNebaFieldWidth extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FieldWidthParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FieldWidthParentData> {
  /// A field [width] across, or the width it is given when [fullWidth].
  RenderNebaFieldWidth({required double width, required bool fullWidth})
    : _width = width,
      _fullWidth = fullWidth;

  double _width;

  /// The width when nothing else decides it.
  set width(double value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  bool _fullWidth;

  /// Whether the field takes the width it is given.
  set fullWidth(bool value) {
    if (_fullWidth != value) {
      _fullWidth = value;
      markNeedsLayout();
    }
  }

  RenderBox? get _field => firstChild;

  RenderBox? get _sizer {
    final RenderBox? field = firstChild;

    return field == null ? null : childAfter(field);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FieldWidthParentData) {
      child.parentData = _FieldWidthParentData();
    }
  }

  double get _natural {
    return math.max(_width, _sizer?.getMaxIntrinsicWidth(double.infinity) ?? 0);
  }

  double _widthFor(BoxConstraints constraints) {
    if (_fullWidth && constraints.hasBoundedWidth) {
      return constraints.maxWidth;
    }

    return constraints.constrainWidth(_natural);
  }

  BoxConstraints _fieldConstraints(BoxConstraints constraints, double width) {
    return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: constraints.maxHeight);
  }

  @override
  double computeMinIntrinsicWidth(double height) => _natural;

  @override
  double computeMaxIntrinsicWidth(double height) => _natural;

  @override
  double computeMinIntrinsicHeight(double width) => _field?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) => _field?.getMaxIntrinsicHeight(width) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double width = _widthFor(constraints);
    final double height = _field?.getDryLayout(_fieldConstraints(constraints, width)).height ?? 0;

    return constraints.constrain(Size(width, height));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _field?.getDistanceToActualBaseline(baseline);
  }

  @override
  void performLayout() {
    final double width = _widthFor(constraints);
    final RenderBox? field = _field;

    // Laid out at its own size, so it is never anything but measured.
    _sizer?.layout(const BoxConstraints());

    if (field == null) {
      size = constraints.constrain(Size(width, 0));
      return;
    }

    field.layout(_fieldConstraints(constraints, width), parentUsesSize: true);
    size = constraints.constrain(Size(width, field.size.height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? field = _field;

    if (field != null) {
      context.paintChild(field, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return _field?.hitTest(result, position: position) ?? false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final RenderBox? field = _field;

    if (field != null) {
      visitor(field);
    }
  }
}
