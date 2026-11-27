/// `NebaSwitch`, an on/off that takes effect the moment it moves.
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/choice.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which side of a [NebaSwitch]'s track its label sits on.
enum NebaSwitchLabelSide {
  /// Before the track, with the track at the end of the row: a settings
  /// list, where the labels form a column and the switches line up.
  start,

  /// After the track, as a caption for it.
  end,
}

/// The track's width and height at each size.
const Map<NebaSize, Size> _track = <NebaSize, Size>{
  NebaSize.xs: Size(24, 14),
  NebaSize.sm: Size(28, 16),
  NebaSize.md: Size(36, 20),
  NebaSize.lg: Size(44, 24),
  NebaSize.xl: Size(52, 28),
};

/// How far the thumb stands inside the track's hairline, CSS `inset-0.5`.
const double _thumbInset = 2;

/// Between the track and its text, CSS `gap-2.5`.
const double _gap = 10;

/// An on/off that takes effect the moment it moves.
///
/// What sets it apart from a checkbox is when the change lands rather than
/// how it looks: a checkbox is a value submitted with a form, and a switch
/// applies itself at once. If there is a Save button under it, it should
/// have been a `NebaCheckbox`.
///
/// Off it is a groove with a hairline in the colour family; on it fills with
/// the family. The thumb is the light on the track, white in both states, and
/// travels to the end of the line by its offset, never by a transform. The
/// label sits after the track, or before it with [labelSide], and a press on
/// it flips the switch.
///
/// Controlled with [checked] and [onCheckedChange], or left to keep its own
/// state from [defaultChecked].
///
/// ```dart
/// NebaSwitch(
///   label: const Text('Email alerts'),
///   checked: alerts,
///   onCheckedChange: (bool on) => setState(() => alerts = on),
/// )
/// ```
class NebaSwitch extends StatefulWidget {
  /// A switch labelled [label].
  const NebaSwitch({
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.checked,
    this.defaultChecked = false,
    this.onCheckedChange,
    this.labelSide = NebaSwitchLabelSide.end,
    this.size,
    this.color,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The text beside the track, usually a [Text]. A press on it flips the
  /// switch, and a screen reader hears it as the switch's name.
  final Widget? label;

  /// Helper text under the label.
  final Widget? description;

  /// The error under the switch. Given, it also turns the switch invalid.
  final Widget? error;

  /// Whether the switch is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Whether it is on, for a controlled switch. Leave it out and the switch
  /// keeps its own state.
  final bool? checked;

  /// Whether an uncontrolled switch starts on.
  final bool defaultChecked;

  /// Called with the new state when the switch is turned on or off.
  final ValueChanged<bool>? onCheckedChange;

  /// Which side of the track the label sits on.
  final NebaSwitchLabelSide labelSide;

  /// The track's size and the type scale. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The colour family the track fills with. Defaults to
  /// [NebaColor.primary]; an invalid switch is [NebaColor.danger].
  final NebaColor? color;

  /// Drops the colour family for neutral grey and takes the switch out of
  /// the focus order.
  final bool disabled;

  /// Shows the state without letting it change, with the saturation drained.
  final bool readOnly;

  /// What a screen reader calls a switch with no label.
  final String? semanticLabel;

  /// The track's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the switch takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaSwitch> createState() => _NebaSwitchState();
}

class _NebaSwitchState extends State<NebaSwitch> {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  late bool _checked = widget.defaultChecked;

  bool get _on => widget.checked ?? _checked;

  void _toggle() {
    if (_disabled || widget.readOnly) {
      return;
    }

    final bool next = !_on;

    widget.onCheckedChange?.call(next);

    if (widget.checked == null) {
      setState(() => _checked = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool invalid = widget.invalid ?? widget.error != null;
    // Invalid repoints the whole family at danger, so the track, the ring and
    // the message turn over together.
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final bool on = _on;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );

    final Widget track = _Track(
      size: size,
      roles: roles,
      on: on,
      disabled: disabled,
      readOnly: readOnly,
      onToggle: _toggle,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
    );

    return Semantics(
      container: true,
      toggled: on,
      enabled: !disabled,
      readOnly: readOnly,
      label: semantics.label,
      hint: semantics.hint,
      validationResult: invalid
          ? ui.SemanticsValidationResult.invalid
          : ui.SemanticsValidationResult.none,
      child: NebaChoiceField(
        size: size,
        control: track,
        controlHeight: _track[size]!.height,
        semantics: semantics,
        errorColor: roles.accent,
        label: widget.label,
        description: widget.description,
        error: widget.error,
        gap: _gap,
        labelFirst: widget.labelSide == NebaSwitchLabelSide.start,
        disabled: disabled,
        onLabelTap: _toggle,
      ),
    );
  }
}

/// The track and the thumb that travels along it.
///
/// No plate on the track, for the reason a checkbox has none: a white
/// hairline around a 20-pixel groove is a bevel, and a bevelled groove with a
/// domed thumb in it is the skeuomorphic switch this design language is not.
/// The acrylic stays.
///
/// Off, the track is the groove rather than the panel, the one place a
/// control turns the surface ladder over: a white thumb on a white track is an
/// empty pill, so the groove darkens and the thumb has something to be the
/// light on. Under reduced transparency the groove is laid on the page's
/// surface, so a switch on a picture does not show it through.
class _Track extends StatelessWidget {
  const _Track({
    required this.size,
    required this.roles,
    required this.on,
    required this.disabled,
    required this.readOnly,
    required this.onToggle,
    this.focusNode,
    this.autofocus = false,
  });

  final NebaSize size;
  final NebaColorRoles roles;
  final bool on;
  final bool disabled;
  final bool readOnly;
  final VoidCallback onToggle;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Size extent = _track[size]!;
    // Inside the hairline, which takes a pixel on each side whether it is
    // drawn or not, and inset from it on every side.
    final double inner = extent.height - 2;
    final double thumb = inner - 2 * _thumbInset;
    final double travel = extent.width - 2 - 2 * _thumbInset - thumb;
    // A pill, the one place in the library a full radius is right: a track
    // with corners is a track the thumb would have to climb out of.
    final BorderRadius radius = BorderRadius.circular(extent.height / 2);

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
        final bool lit = interaction.hovered && !readOnly;
        final Color fill;
        final Color edge;

        if (disabled) {
          fill = on ? tokens.disabledBg : edgeless;
          edge = tokens.disabledBorder;
        } else if (on) {
          fill = lit ? roles.fillHover : roles.fill;
          edge = edgeless;
        } else {
          fill = Color.alphaBlend(lit ? tokens.grooveHover : tokens.groove, tokens.backing);
          edge = lit ? roles.lineHover : roles.line;
        }

        Widget track = NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: radius,
          child: NebaSheet(
            fill: fill,
            edge: edge,
            plate: NebaPlate.none,
            borderRadius: radius,
            blur: !disabled,
            texture: !disabled,
            child: SizedBox(
              width: extent.width - 2,
              height: inner,
              child: Stack(
                children: <Widget>[
                  // The thumb's inline start, so on is the end of the line in
                  // either direction.
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: on ? 1 : 0),
                    duration: nebaDuration(context, NebaScale.duration),
                    curve: NebaScale.ease,
                    builder: (BuildContext context, double along, Widget? thumbChild) {
                      return PositionedDirectional(
                        top: _thumbInset,
                        start: _thumbInset + travel * along,
                        child: thumbChild!,
                      );
                    },
                    child: _Thumb(diameter: thumb),
                  ),
                ],
              ),
            ),
          ),
        );

        if (readOnly) {
          track = ColorFiltered(
            colorFilter: ColorFilter.matrix(saturationMatrix(0.55)),
            child: track,
          );
        }

        return track;
      },
    );
  }
}

/// The thumb: the page's surface, white in both states rather than the
/// accent, because it is the light on the track and not a second coloured
/// object, raised one level.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return SizedBox.square(
      dimension: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          shape: BoxShape.circle,
          boxShadow: tokens.elevation(1),
        ),
      ),
    );
  }
}
