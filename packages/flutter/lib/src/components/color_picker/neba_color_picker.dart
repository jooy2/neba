/// `NebaColorPicker`, a colour chosen by eye.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/color.dart' show NebaColorFormat;

/// The names a [NebaColorPicker] gives the parts of its panel that have no
/// text on them, each one in place of the locale's word for it.
@immutable
class NebaColorPickerLabels {
  /// Overrides for any of the names; the rest stay the locale's.
  const NebaColorPickerLabels({
    this.area,
    this.areaValue,
    this.hue,
    this.alpha,
    this.value,
    this.swatches,
    this.clear,
    this.empty,
  });

  /// The saturation and brightness square.
  final String? area;

  /// What the square's position is read as, with `{saturation}` and
  /// `{brightness}` in it.
  final String? areaValue;

  /// The hue rail.
  final String? hue;

  /// The opacity rail, when the picker has one.
  final String? alpha;

  /// The field the value can be typed into.
  final String? value;

  /// The grid of ready-made colours.
  final String? swatches;

  /// The × that empties the picker.
  final String? clear;

  /// What the trigger reads before anything has been chosen.
  final String? empty;
}

/// The names, resolved: the locale's words with the caller's laid over them.
class _Labels {
  _Labels(Map<String, String> words, NebaColorPickerLabels? overrides)
    : area = overrides?.area ?? words['area']!,
      areaValue = overrides?.areaValue ?? words['areaValue']!,
      hue = overrides?.hue ?? words['hue']!,
      alpha = overrides?.alpha ?? words['alpha']!,
      value = overrides?.value ?? words['value']!,
      swatches = overrides?.swatches ?? words['swatches']!,
      clear = overrides?.clear ?? words['clear']!,
      empty = overrides?.empty ?? words['empty']!;

  final String area;
  final String areaValue;
  final String hue;
  final String alpha;
  final String value;
  final String swatches;
  final String clear;
  final String empty;
}

/// A colour, chosen by eye: a saturation and brightness square with a hue
/// rail under it, an opacity rail when [alpha] is on, a field the value can be
/// typed into, and a grid of ready-made swatches.
///
/// By default the panel hangs off a field-shaped trigger, the same box a
/// `NebaTextField` is drawn in, which shows the colour and its value; a press
/// on it, Enter or Space open the panel with the focus on the square, and
/// Escape, a press outside or the focus leaving close it. [inline] draws the
/// panel in the page instead, with no trigger.
///
/// The value is a CSS colour string, read in hex, `rgb()` or `hsl()` and
/// written back in [format]. The panel keeps its own state in HSV and never
/// derives it from the string again while the string means the same colour,
/// which is what keeps the hue rail still when the square reaches black.
/// Controlled with [value] and [onValueChange], or left to keep its own state
/// from [defaultValue].
///
/// ```dart
/// NebaColorPicker(value: color, onValueChange: (String next) => setState(() => color = next))
/// ```
class NebaColorPicker extends StatefulWidget {
  /// A colour picker.
  const NebaColorPicker({
    this.value,
    this.defaultValue = '#1a58d1',
    this.onValueChange,
    this.format = NebaColorFormat.hex,
    this.alpha = false,
    this.swatches,
    this.inline = false,
    this.editable = true,
    this.label,
    this.labelPlacement,
    this.description,
    this.error,
    this.invalid,
    this.required = false,
    this.disabled = false,
    this.readOnly = false,
    this.fullWidth = false,
    this.clearable = false,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.locale,
    this.labels,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The colour, as a CSS string, for a controlled picker. Leave it `null`
  /// and the picker keeps its own, starting from [defaultValue]. An empty
  /// string is a picker with nothing chosen.
  final String? value;

  /// Where a picker that keeps its own state starts.
  final String defaultValue;

  /// Called with the new colour, written in [format], or with an empty string
  /// when the × empties the picker.
  final ValueChanged<String>? onValueChange;

  /// The notation the value is written in on the way out. A [value] in any of
  /// the three is read whatever this says.
  final NebaColorFormat format;

  /// Whether the panel offers an opacity rail and the value carries a fourth
  /// channel.
  final bool alpha;

  /// The ready-made colours under the panel, as CSS colour strings, in place
  /// of the built-in set. An empty list draws none.
  final List<String>? swatches;

  /// Whether the panel is drawn in the page, with no trigger and no popup.
  final bool inline;

  /// Whether the panel has the field the value can be typed into.
  final bool editable;

  /// The picker's name, usually a [Text]. A screen reader hears it as the
  /// trigger's name, or as the name of an inline panel.
  final Widget? label;

  /// Where [label] is drawn: above the trigger or in a notch cut into its top
  /// edge. The swatch at the trigger's start is where a `float` label would
  /// rest, so `float` keeps it in the notch as well, and an [inline] picker,
  /// with no trigger to notch, keeps it on top. Defaults to `NebaProvider`'s,
  /// then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the picker, usually a [Text].
  final Widget? description;

  /// An error under the picker, usually a [Text]. Giving one turns the picker
  /// invalid.
  final Widget? error;

  /// Whether the picker is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Whether a screen reader hears that a colour is required.
  final bool required;

  /// Grey, out of the focus order, and closed: the trigger, the square, the
  /// rails, the swatches and the field all take nothing.
  final bool disabled;

  /// Shows the colour but does not change it. The panel still opens; the
  /// square, the rails and the swatches leave the focus order and take no
  /// input, and the field stays in it, read-only, so its value can still be
  /// selected and copied.
  final bool readOnly;

  /// Stretches the trigger to the width it is given. Otherwise it is as wide
  /// as the longest value its [format] writes.
  final bool fullWidth;

  /// Whether the trigger offers the × that empties the picker.
  final bool clearable;

  /// Whether the popup is open. With [onOpenChange] the caller owns the
  /// state; without it the picker keeps its own.
  final bool? open;

  /// Whether a picker that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the popup opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// The language of the names a screen reader hears. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// The names of the parts with no text on them, one at a time, in place of
  /// the locale's words.
  final NebaColorPickerLabels? labels;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The trigger's height floor and type scale, a field's, and the width of
  /// the panel and the height of the square with it. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the trigger's edge, the focus rings and the popup's
  /// hairline: nothing to do with the colour being chosen. Defaults to
  /// [NebaColor.primary]; an invalid picker is [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0`, which is none, to `3`. The popup has
  /// its own, fixed at `3`.
  final NebaElevation? elevation;

  /// What a screen reader names the trigger, in place of [label].
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  /// How wide the panel is at each size: a ladder of its own, because the
  /// square is a space to aim at rather than a row to read.
  static const Map<NebaSize, double> panelWidth = <NebaSize, double>{
    NebaSize.xs: 160,
    NebaSize.sm: 176,
    NebaSize.md: 208,
    NebaSize.lg: 240,
    NebaSize.xl: 288,
  };

  /// How tall the saturation and brightness square is at each size.
  static const Map<NebaSize, double> areaHeight = <NebaSize, double>{
    NebaSize.xs: 96,
    NebaSize.sm: 112,
    NebaSize.md: 128,
    NebaSize.lg: 160,
    NebaSize.xl: 192,
  };

  /// How thick a rail is at each size.
  static const Map<NebaSize, double> railHeight = <NebaSize, double>{
    NebaSize.xs: 10,
    NebaSize.sm: 12,
    NebaSize.md: 14,
    NebaSize.lg: 16,
    NebaSize.xl: 20,
  };

  /// The gap between the parts of the panel, one track tighter than a form's.
  static const Map<NebaSize, double> panelGap = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 10,
    NebaSize.lg: 12,
    NebaSize.xl: 14,
  };

  /// The diameter of the thumb on the square and on each rail.
  static const Map<NebaSize, double> thumbSize = <NebaSize, double>{
    NebaSize.xs: 10,
    NebaSize.sm: 12,
    NebaSize.md: 14,
    NebaSize.lg: 16,
    NebaSize.xl: 18,
  };

  /// The popup's own padding, one track tighter than a control's.
  static const Map<NebaSize, double> popupPadding = <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 10,
    NebaSize.lg: 12,
    NebaSize.xl: 14,
  };

  @override
  State<NebaColorPicker> createState() => _NebaColorPickerState();
}

/// One ready-made colour, read once per list rather than on every move of a
/// drag.
class _Swatch {
  _Swatch(this.source)
    : parsed = parseCssColor(source),
      hex = switch (parseCssColor(source)) {
        final NebaColorValue value => formatCssColor(value.hsv, value.alpha, NebaColorFormat.hex),
        null => null,
      };

  final String source;
  final NebaColorValue? parsed;
  final String? hex;
}

/// The widest string each notation writes, so the trigger stops resizing.
String _widthSample(NebaColorFormat format, bool alpha) {
  return switch (format) {
    NebaColorFormat.hex => alpha ? '#ffffffff' : '#ffffff',
    NebaColorFormat.rgb => alpha ? 'rgba(255, 255, 255, 0.55)' : 'rgb(255, 255, 255)',
    NebaColorFormat.hsl => alpha ? 'hsla(360, 100%, 100%, 0.55)' : 'hsl(360, 100%, 100%)',
  };
}

const NebaColorValue _fallback = NebaColorValue(NebaHsv(217, 87, 82));

class _NebaColorPickerState extends State<NebaColorPicker> {
  late String _value = widget.defaultValue;
  late bool _open = widget.defaultOpen;
  late NebaColorValue _model = parseCssColor(_current) ?? _fallback;
  late final TextEditingController _text = TextEditingController(text: _current);
  FocusNode? _ownNode;
  List<String>? _swatchSource;
  List<_Swatch> _swatchList = <_Swatch>[];
  // What the model was last held against: the value, what the model writes,
  // and the two props that decide how it writes it. The React package keys
  // its effect on the same four.
  (String, String, bool, NebaColorFormat)? _held;
  bool _holdScheduled = false;

  String get _current => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  FocusNode get _triggerNode {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaColorPicker'));
  }

  String get _written {
    return formatCssColor(_model.hsv, widget.alpha ? _model.alpha : 1, widget.format);
  }

  @override
  void initState() {
    super.initState();
    _held = (_current, _written, widget.alpha, widget.format);
  }

  @override
  void didUpdateWidget(NebaColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hold();
  }

  @override
  void dispose() {
    _text.dispose();
    _ownNode?.dispose();
    super.dispose();
  }

  /// The model brought back to the value, when the value says something
  /// different from what the model already means.
  ///
  /// The value is compared with the model as colours rather than as strings:
  /// `#FF0000` and `#ff0000` are one colour, and `#000000` is every hue at
  /// once, so re-reading a value the model has just written would turn the
  /// hue rail back to red at the bottom of the square. A value this does not
  /// read, an empty one after a clear, is shown in the field and leaves the
  /// panel where it was.
  void _hold() {
    final String current = _current;
    final (String, String, bool, NebaColorFormat) key = (
      current,
      _written,
      widget.alpha,
      widget.format,
    );

    if (key == _held) {
      return;
    }

    final NebaColorValue? parsed = parseCssColor(current);

    if (parsed == null) {
      _setText(current);
    } else if (formatCssColor(parsed.hsv, widget.alpha ? parsed.alpha : 1, widget.format) !=
        _written) {
      _model = parsed;
      _setText(current);
    }

    _held = (current, _written, widget.alpha, widget.format);
  }

  /// [_hold] once the frame is drawn, by when a caller who controls the value
  /// has handed the new one down; one who did not gets the old one back.
  void _scheduleHold() {
    if (_holdScheduled) {
      return;
    }

    _holdScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _holdScheduled = false;

      if (mounted) {
        setState(_hold);
      }
    });
  }

  void _setText(String text) {
    if (_text.text != text) {
      _text.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _commit(NebaColorValue next, {String? typed}) {
    final String output = formatCssColor(next.hsv, widget.alpha ? next.alpha : 1, widget.format);

    setState(() {
      _model = next;

      if (widget.value == null) {
        _value = output;
      }
    });

    if (typed == null) {
      _setText(output);
    }

    widget.onValueChange?.call(output);
    _scheduleHold();
  }

  void _typed(String text) {
    final NebaColorValue? parsed = parseCssColor(text);

    if (parsed != null) {
      _commit(parsed, typed: text);
    }
  }

  void _clear() {
    if (widget.value == null) {
      setState(() => _value = '');
    }

    _setText('');
    widget.onValueChange?.call('');
    _scheduleHold();
  }

  void _setOpen(bool open) {
    if (open == _isOpen || (open && widget.disabled)) {
      return;
    }

    if (widget.open == null) {
      setState(() => _open = open);
    }

    widget.onOpenChange?.call(open);
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    final LogicalKeyboardKey key = event.logicalKey;
    final bool activates =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space;

    if (!activates || widget.disabled) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      _setOpen(!_isOpen);
    }

    return event is KeyUpEvent ? KeyEventResult.ignored : KeyEventResult.handled;
  }

  List<_Swatch> _swatches() {
    final List<String> source = widget.swatches ?? defaultSwatches;

    if (!identical(source, _swatchSource)) {
      _swatchSource = source;
      _swatchList = <_Swatch>[for (final String swatch in source) _Swatch(swatch)];
    }

    return _swatchList;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaLabelPlacement placement =
        widget.labelPlacement ?? defaults.labelPlacement ?? NebaLabelPlacement.top;
    final bool disabled = widget.disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool inert = disabled || readOnly;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final _Labels labels = _Labels(
      nebaMessages(context, 'color', locale: widget.locale),
      widget.labels,
    );

    final Widget panel = _Panel(
      model: _model,
      onChanged: _commit,
      text: _text,
      onTyped: _typed,
      withAlpha: widget.alpha,
      swatches: _swatches(),
      editable: widget.editable,
      size: size,
      roles: roles,
      inert: inert,
      disabled: disabled,
      labels: labels,
    );

    if (widget.inline) {
      return _buildInline(
        context,
        panel: panel,
        size: size,
        roles: roles,
        disabled: disabled,
        invalid: invalid,
      );
    }

    return _buildField(
      context,
      tokens: tokens,
      panel: panel,
      variant: variant,
      size: size,
      density: density,
      placement: placement,
      roles: roles,
      disabled: disabled,
      readOnly: readOnly,
      invalid: invalid,
      labels: labels,
    );
  }

  Widget _buildInline(
    BuildContext context, {
    required Widget panel,
    required NebaSize size,
    required NebaColorRoles roles,
    required bool disabled,
    required bool invalid,
  }) {
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: widget.label,
      description: widget.description,
      error: widget.error,
    );

    // One group, named by the label and described by the lines under it, so
    // the square, the rails and the field are heard as one picker.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semantics.label,
      hint: semantics.hint,
      isRequired: widget.required ? true : null,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: SizedBox(
        width: NebaColorPicker.panelWidth[size],
        child: NebaFieldColumn(
          size: size,
          semantics: semantics,
          errorColor: roles.accent,
          disabled: disabled,
          label: widget.label,
          description: widget.description,
          error: widget.error,
          field: panel,
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required NebaTokens tokens,
    required Widget panel,
    required NebaVariant variant,
    required NebaSize size,
    required NebaDensity density,
    required NebaLabelPlacement placement,
    required NebaColorRoles roles,
    required bool disabled,
    required bool readOnly,
    required bool invalid,
    required _Labels labels,
  }) {
    final bool open = _isOpen && !disabled;
    final bool empty = _current.isEmpty;
    final String display = empty ? labels.empty : _written;
    final Widget? label = widget.label;
    // The swatch at the start is where a float label would rest, so a label
    // off the top always stands in the notch.
    final bool notched = label != null && placement != NebaLabelPlacement.top;
    final bool clears = widget.clearable && !disabled && !readOnly;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: label,
      description: widget.description,
      error: widget.error,
    );
    final double text = NebaScale.controlText[size]!;
    final double gap = NebaScale.gap[size]!;
    final double swatch = text * 1.15;
    final TextStyle valueStyle = TextStyle(
      fontSize: text,
      height: NebaScale.controlLeading[size]! / text,
      leadingDistribution: TextLeadingDistribution.even,
    );

    Widget content(BuildContext context, bool focused) {
      return Row(
        spacing: gap,
        children: <Widget>[
          Expanded(
            child: Focus(
              focusNode: _triggerNode,
              autofocus: widget.autofocus,
              canRequestFocus: !disabled,
              onKeyEvent: _onTriggerKey,
              child: Row(
                spacing: gap,
                children: <Widget>[
                  _ColorDot(
                    diameter: swatch,
                    edge: mixOklab(tokens.fg, 0.18, transparent),
                    color: empty ? null : hsvColor(_model.hsv, widget.alpha ? _model.alpha : 1),
                  ),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        display,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: valueStyle.copyWith(
                          color: disabled
                              ? tokens.disabledFg
                              : empty
                              ? tokens.mutedFg
                              : tokens.fg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (clears && !empty)
            _ClearButton(
              extent: swatch,
              glyph: text * 1.2,
              ring: roles.ring,
              label: labels.clear,
              onPressed: _clear,
            ),
        ],
      );
    }

    Widget trigger = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation ?? 0,
      disabled: disabled,
      readOnly: readOnly,
      keyboardRing: true,
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : readOnly
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      notch: notched
          ? NebaFieldNotch(
              label: ExcludeSemantics(excluding: semantics.labelTaken, child: label),
              empty: empty && !open,
            )
          : null,
      builder: content,
    );

    if (disabled) {
      trigger = ExcludeFocus(child: trigger);
    } else {
      trigger = GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => _setOpen(!_isOpen),
        child: trigger,
      );
    }

    final Widget popup = NebaSheet(
      fill: tokens.panelPress,
      edge: roles.line,
      plate: NebaPlate.glass,
      elevation: 3,
      borderRadius: BorderRadius.circular(tokens.radius[size]!),
      child: Padding(
        padding: EdgeInsets.all(NebaColorPicker.popupPadding[size]!),
        child: DefaultTextStyle.merge(style: valueStyle, child: panel),
      ),
    );

    final Widget field = NebaFloating(
      open: open,
      onOpenChange: (bool next, NebaFloatingReason reason) => _setOpen(next),
      align: NebaAlign.start,
      sideOffset: 6,
      moveFocus: true,
      enabled: !disabled,
      popup: popup,
      child: trigger,
    );

    final double border = variant == NebaVariant.outline ? 1 : 0;
    final double padX = NebaScale.paddingX[density]![size]!;
    final Widget sizer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The trigger at the width of the longest value its notation writes,
        // or of what it says while it is empty, with room kept for the × so
        // the trigger does not widen when a colour arrives.
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: padX + border + swatch + gap,
            end: padX + border + (clears ? swatch + gap : 0),
          ),
          child: NebaWidthSizer(
            style: valueStyle,
            samples: <Widget>[Text(_widthSample(widget.format, widget.alpha)), Text(display)],
          ),
        ),
        if (notched)
          NebaNotchSizer(label: label, size: size, density: density, variant: variant)
        else if (label != null)
          NebaWidthSizer(
            style: TextStyle(fontSize: NebaScale.metaText[size], fontWeight: FontWeight.w500),
            samples: <Widget>[label],
          ),
      ],
    );

    // One node for the column: a button named by the label that says the
    // colour, and that it opens a panel by being expanded or collapsed. The ×
    // is a button of its own inside it.
    final String? name = semantics.label;

    return Semantics(
      container: true,
      button: true,
      label: name ?? display,
      value: name == null ? null : display,
      hint: semantics.hint,
      enabled: !disabled,
      expanded: open,
      readOnly: readOnly,
      isRequired: widget.required ? true : null,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: disabled ? null : () => _setOpen(!_isOpen),
      child: NebaFieldWidth(
        width: 0,
        fullWidth: widget.fullWidth,
        sizer: sizer,
        child: NebaFieldColumn(
          size: size,
          semantics: semantics,
          errorColor: roles.accent,
          disabled: disabled,
          label: notched ? null : label,
          description: widget.description,
          error: widget.error,
          onLabelTap: _triggerNode.requestFocus,
          field: field,
        ),
      ),
    );
  }
}

/// The panel: the square, the rails, the field and the swatches, the same in
/// the popup and in the page.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.model,
    required this.onChanged,
    required this.text,
    required this.onTyped,
    required this.withAlpha,
    required this.swatches,
    required this.editable,
    required this.size,
    required this.roles,
    required this.inert,
    required this.disabled,
    required this.labels,
  });

  final NebaColorValue model;

  /// One callback for the colour and the opacity together: a swatch changes
  /// both, and two updates in one press would build the second from the state
  /// the first had just replaced.
  final void Function(NebaColorValue next) onChanged;
  final TextEditingController text;
  final ValueChanged<String> onTyped;
  final bool withAlpha;
  final List<_Swatch> swatches;
  final bool editable;
  final NebaSize size;
  final NebaColorRoles roles;
  final bool inert;
  final bool disabled;
  final _Labels labels;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaHsv hsv = model.hsv;
    final double alpha = model.alpha;
    final double thumb = NebaColorPicker.thumbSize[size]!;
    final double rail = NebaColorPicker.railHeight[size]!;
    final BorderRadius areaRadius = BorderRadius.circular(tokens.radius[size]!);
    final BorderRadius railRadius = BorderRadius.circular(rail / 2);
    final Color pure = hsvColor(NebaHsv(hsv.h, 100, 100));
    final Color solid = hsvColor(hsv);

    String areaText(NebaHsv at) {
      return fillNebaMessage(labels.areaValue, <String, String>{
        'saturation': nebaFormatPercent(at.s / 100),
        'brightness': nebaFormatPercent(at.v / 100),
      });
    }

    String hueText(double hue) => '${hue.round()}°';

    void area(NebaHsv next) {
      onChanged(NebaColorValue(next, alpha));
    }

    void hue(double next) {
      onChanged(NebaColorValue(NebaHsv(next, hsv.s, hsv.v), alpha));
    }

    void opacity(double next) {
      onChanged(NebaColorValue(hsv, next));
    }

    final NebaHsv? moreSaturated = hsv.s < 100
        ? NebaHsv(hsv.h, (hsv.s + 1).clamp(0, 100).toDouble(), hsv.v)
        : null;
    final NebaHsv? lessSaturated = hsv.s > 0
        ? NebaHsv(hsv.h, (hsv.s - 1).clamp(0, 100).toDouble(), hsv.v)
        : null;
    final double moreHue = _railStep(hsv.h, 2, 360, wrap: true);
    final double lessHue = _railStep(hsv.h, -2, 360, wrap: true);
    final double share = alpha * 100;

    final List<Widget> children = <Widget>[
      _PanelSlider(
        height: NebaColorPicker.areaHeight[size]!,
        radius: areaRadius,
        ring: roles.ring,
        inert: inert,
        cursor: SystemMouseCursors.precise,
        label: labels.area,
        value: areaText(hsv),
        increasedValue: moreSaturated == null ? null : areaText(moreSaturated),
        decreasedValue: lessSaturated == null ? null : areaText(lessSaturated),
        onIncrease: moreSaturated == null ? null : () => area(moreSaturated),
        onDecrease: lessSaturated == null ? null : () => area(lessSaturated),
        onKey: (KeyEvent event) {
          final NebaHsv? next = _areaKey(event, hsv);

          if (next == null) {
            return false;
          }

          area(next);

          return true;
        },
        onPoint: (Offset fraction) {
          area(NebaHsv(hsv.h, fraction.dx * 100, (1 - fraction.dy) * 100));
        },
        painter: _AreaPainter(
          tokens: tokens,
          radius: areaRadius,
          thumb: thumb,
          pure: pure,
          solid: solid,
          s: hsv.s,
          v: hsv.v,
        ),
      ),
      _PanelSlider(
        height: rail,
        radius: railRadius,
        ring: roles.ring,
        inert: inert,
        cursor: SystemMouseCursors.click,
        label: labels.hue,
        value: hueText(hsv.h),
        increasedValue: hueText(moreHue),
        decreasedValue: hueText(lessHue),
        onIncrease: () => hue(moreHue),
        onDecrease: () => hue(lessHue),
        onKey: (KeyEvent event) {
          final double? next = _railKey(event, hsv.h, max: 360, unit: 2, wrap: true);

          if (next == null) {
            return false;
          }

          hue(next);

          return true;
        },
        onPoint: (Offset fraction) => hue(fraction.dx * 360),
        painter: _HuePainter(
          tokens: tokens,
          radius: railRadius,
          thumb: thumb,
          pure: pure,
          hue: hsv.h,
        ),
      ),
      if (withAlpha)
        _PanelSlider(
          height: rail,
          radius: railRadius,
          ring: roles.ring,
          inert: inert,
          cursor: SystemMouseCursors.click,
          label: labels.alpha,
          value: nebaFormatPercent(alpha),
          increasedValue: share < 100
              ? nebaFormatPercent(_railStep(share, 1, 100, wrap: false) / 100)
              : null,
          decreasedValue: share > 0
              ? nebaFormatPercent(_railStep(share, -1, 100, wrap: false) / 100)
              : null,
          onIncrease: share < 100
              ? () => opacity(_railStep(share, 1, 100, wrap: false) / 100)
              : null,
          onDecrease: share > 0
              ? () => opacity(_railStep(share, -1, 100, wrap: false) / 100)
              : null,
          onKey: (KeyEvent event) {
            final double? next = _railKey(event, share, max: 100, unit: 1, wrap: false);

            if (next == null) {
              return false;
            }

            opacity(next / 100);

            return true;
          },
          onPoint: (Offset fraction) => opacity(fraction.dx),
          painter: _AlphaPainter(
            tokens: tokens,
            radius: railRadius,
            thumb: thumb,
            solid: solid,
            alpha: alpha,
          ),
        ),
      if (editable)
        _ValueField(
          controller: text,
          onTyped: onTyped,
          size: size,
          roles: roles,
          inert: inert,
          disabled: disabled,
          label: labels.value,
          preview: _ColorDot(diameter: thumb + 6, edge: tokens.border, color: hsvColor(hsv, alpha)),
        ),
      if (swatches.isNotEmpty)
        _SwatchGrid(
          swatches: swatches,
          current: formatCssColor(hsv, alpha, NebaColorFormat.hex),
          width: NebaColorPicker.panelWidth[size]!,
          tokens: tokens,
          roles: roles,
          inert: inert,
          label: labels.swatches,
          onChosen: onChanged,
        ),
    ];

    return SizedBox(
      width: NebaColorPicker.panelWidth[size],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: NebaColorPicker.panelGap[size]!,
        children: children,
      ),
    );
  }
}

/// A rail's value moved [by], held to the ends or wrapped round them.
double _railStep(double now, double by, double max, {required bool wrap}) {
  final double next = now + by;

  return wrap ? ((next % max) + max) % max : next.clamp(0, max).toDouble();
}

/// The square's keys: the arrows a step at a time, ten with Shift, Page Up and
/// Page Down ten steps of brightness, and Home and End the ends of
/// saturation. `null` for a key it does not answer, so Tab still leaves.
NebaHsv? _areaKey(KeyEvent event, NebaHsv hsv) {
  final double step = HardwareKeyboard.instance.isShiftPressed ? 10 : 1;
  final double s = hsv.s;
  final double v = hsv.v;

  final (double, double)? next = switch (event.logicalKey) {
    LogicalKeyboardKey.arrowLeft => (s - step, v),
    LogicalKeyboardKey.arrowRight => (s + step, v),
    LogicalKeyboardKey.arrowUp => (s, v + step),
    LogicalKeyboardKey.arrowDown => (s, v - step),
    LogicalKeyboardKey.pageUp => (s, v + 10),
    LogicalKeyboardKey.pageDown => (s, v - 10),
    LogicalKeyboardKey.home => (0, v),
    LogicalKeyboardKey.end => (100, v),
    _ => null,
  };

  if (next == null) {
    return null;
  }

  return NebaHsv(hsv.h, next.$1.clamp(0, 100).toDouble(), next.$2.clamp(0, 100).toDouble());
}

/// A rail's keys, which are a slider's: either arrow pair a [unit] at a time,
/// ten with Shift, Page Up and Page Down ten units, Home and End the ends. A
/// hue wraps round rather than stopping.
double? _railKey(
  KeyEvent event,
  double now, {
  required double max,
  required double unit,
  required bool wrap,
}) {
  final double step = (HardwareKeyboard.instance.isShiftPressed ? 10 : 1) * unit;

  return switch (event.logicalKey) {
    LogicalKeyboardKey.arrowRight ||
    LogicalKeyboardKey.arrowUp => _railStep(now, step, max, wrap: wrap),
    LogicalKeyboardKey.arrowLeft ||
    LogicalKeyboardKey.arrowDown => _railStep(now, -step, max, wrap: wrap),
    LogicalKeyboardKey.pageUp => _railStep(now, 10 * unit, max, wrap: wrap),
    LogicalKeyboardKey.pageDown => _railStep(now, -10 * unit, max, wrap: wrap),
    LogicalKeyboardKey.home => 0,
    LogicalKeyboardKey.end => max,
    _ => null,
  };
}

/// The square or a rail: a slider of its own in the focus order, dragged
/// anywhere on its well, with the keys a slider answers.
///
/// The thumb is drawn by [painter] and takes no press of its own, so the well
/// takes the whole of it, and a thumb at an end is clipped by the well as the
/// React package's `overflow: hidden` clips it. That is why this lays nothing
/// out along the well, as the slider's `_Along` does for a thumb that is a
/// control.
class _PanelSlider extends StatefulWidget {
  const _PanelSlider({
    required this.height,
    required this.radius,
    required this.ring,
    required this.inert,
    required this.cursor,
    required this.label,
    required this.value,
    required this.increasedValue,
    required this.decreasedValue,
    required this.onIncrease,
    required this.onDecrease,
    required this.onKey,
    required this.onPoint,
    required this.painter,
  });

  final double height;
  final BorderRadius radius;
  final Color ring;
  final bool inert;
  final MouseCursor cursor;
  final String label;
  final String value;
  final String? increasedValue;
  final String? decreasedValue;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  /// Answers a key, and says whether it did.
  final bool Function(KeyEvent event) onKey;

  /// Called with where the pointer is, as a share of each axis.
  final ValueChanged<Offset> onPoint;
  final CustomPainter painter;

  @override
  State<_PanelSlider> createState() => _PanelSliderState();
}

class _PanelSliderState extends State<_PanelSlider> {
  final FocusNode _node = FocusNode(debugLabel: 'NebaColorPicker slider');
  bool _focused = false;
  Offset _origin = Offset.zero;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  void _point(Offset position) {
    final Size? size = context.size;

    if (size == null || widget.inert) {
      return;
    }

    widget.onPoint(
      Offset(
        size.width == 0 ? 0 : (position.dx / size.width).clamp(0, 1).toDouble(),
        size.height == 0 ? 0 : (position.dy / size.height).clamp(0, 1).toDouble(),
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.inert) {
      return KeyEventResult.ignored;
    }

    return widget.onKey(event) ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final bool inert = widget.inert;

    return Semantics(
      container: true,
      slider: true,
      enabled: !inert,
      label: widget.label,
      value: widget.value,
      increasedValue: inert ? null : widget.increasedValue,
      decreasedValue: inert ? null : widget.decreasedValue,
      onIncrease: inert ? null : widget.onIncrease,
      onDecrease: inert ? null : widget.onDecrease,
      child: Focus(
        focusNode: _node,
        canRequestFocus: !inert,
        skipTraversal: inert,
        onKeyEvent: _onKey,
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        child: NebaFocusRing(
          visible: _focused && !inert,
          color: widget.ring,
          borderRadius: widget.radius,
          child: NebaDragRegion(
            enabled: !inert,
            cursor: widget.cursor,
            onStart: (Offset position) {
              // As a browser focuses a focusable element under a press; the
              // ring waits for a key.
              _node.requestFocus();
              _origin = position;
              _point(position);

              return true;
            },
            onMove: (Offset travelled) => _point(_origin + travelled),
            builder: (BuildContext context, bool dragging) {
              return SizedBox(
                height: widget.height,
                width: double.infinity,
                child: CustomPaint(painter: widget.painter),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A well the pointer aims into: a fill of the caller's colour behind the
/// page's hairline and top light, with a thumb on it clipped by its edge.
abstract class _WellPainter extends CustomPainter {
  const _WellPainter({required this.tokens, required this.radius, required this.thumb});

  final NebaTokens tokens;
  final BorderRadius radius;
  final double thumb;

  /// The fill, across [rect].
  void paintFill(Canvas canvas, Rect rect);

  /// Where the thumb's centre is, as a share of each axis.
  Offset get thumbAt;

  /// The thumb's fill.
  Color get thumbColor;

  /// Whatever decides what is drawn, for [shouldRepaint].
  List<Object?> get props;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect outer = radius.toRRect(rect);
    final RRect inner = outer.deflate(1);

    canvas.save();
    canvas.clipRRect(outer);
    paintFill(canvas, rect);
    canvas.restore();

    paintPlate(canvas, inner, tokens, NebaPlate.glass);

    // The thumb, clipped by the well: a white ring so it shows on black, a
    // dark hairline round it so the ring shows on white, and a soft drop.
    // None of them is tinted with the colour under it.
    final Rect box = inner.outerRect;
    final Offset centre = Offset(
      box.left + thumbAt.dx * box.width,
      box.top + thumbAt.dy * box.height,
    );
    final double r = thumb / 2;

    canvas.save();
    canvas.clipRRect(inner);
    canvas.drawCircle(
      centre.translate(0, 1),
      r,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    canvas.drawCircle(
      centre,
      r + 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x59000000),
    );
    canvas.drawCircle(centre, r, Paint()..color = thumbColor);
    canvas.drawCircle(
      centre,
      r - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFFFFF),
    );
    canvas.restore();

    strokeInside(canvas, outer, tokens.border);
  }

  @override
  bool shouldRepaint(_WellPainter oldDelegate) {
    return oldDelegate.runtimeType != runtimeType ||
        oldDelegate.tokens != tokens ||
        oldDelegate.radius != radius ||
        oldDelegate.thumb != thumb ||
        !listEquals(oldDelegate.props, props);
  }
}

/// The square: the hue at full strength, white across it from the start and
/// black up it from the bottom, black on top so its foot reaches black.
class _AreaPainter extends _WellPainter {
  const _AreaPainter({
    required super.tokens,
    required super.radius,
    required super.thumb,
    required this.pure,
    required this.solid,
    required this.s,
    required this.v,
  });

  final Color pure;
  final Color solid;
  final double s;
  final double v;

  @override
  void paintFill(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = pure);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFFFFFFFF), Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[Color(0xFF000000), Color(0x00000000)],
        ).createShader(rect),
    );
  }

  @override
  Offset get thumbAt => Offset(s / 100, 1 - v / 100);

  @override
  Color get thumbColor => solid;

  @override
  List<Object?> get props => <Object?>[pure, solid, s, v];
}

/// The hue rail: the spectrum, red at both ends.
class _HuePainter extends _WellPainter {
  const _HuePainter({
    required super.tokens,
    required super.radius,
    required super.thumb,
    required this.pure,
    required this.hue,
  });

  final Color pure;
  final double hue;

  @override
  void paintFill(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: hueSpectrum,
          stops: hueSpectrumStops,
        ).createShader(rect),
    );
  }

  @override
  Offset get thumbAt => Offset(hue / 360, 0.5);

  @override
  Color get thumbColor => pure;

  @override
  List<Object?> get props => <Object?>[pure, hue];
}

/// The opacity rail: the colour from none of it to all of it, over a chequer
/// that shows how much of the page comes through.
class _AlphaPainter extends _WellPainter {
  const _AlphaPainter({
    required super.tokens,
    required super.radius,
    required super.thumb,
    required this.solid,
    required this.alpha,
  });

  final Color solid;
  final double alpha;

  @override
  void paintFill(Canvas canvas, Rect rect) {
    _paintChecker(canvas, rect, tokens.border);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[solid.withValues(alpha: 0), solid],
        ).createShader(rect),
    );
  }

  @override
  Offset get thumbAt => Offset(alpha, 0.5);

  @override
  Color get thumbColor => solid.withValues(alpha: alpha);

  @override
  List<Object?> get props => <Object?>[solid, alpha];
}

/// The chequer behind a translucent colour: squares of four pixels in
/// [color], every other one, from the top start corner of [rect].
void _paintChecker(Canvas canvas, Rect rect, Color color) {
  const double cell = 4;
  final Paint paint = Paint()..color = color;

  for (double y = rect.top; y < rect.bottom; y += cell) {
    final int row = ((y - rect.top) / cell).round();

    for (double x = rect.left; x < rect.right; x += cell) {
      final int column = ((x - rect.left) / cell).round();

      if ((row + column).isEven) {
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), paint);
      }
    }
  }
}

/// A round swatch of [color] over the chequer with a hairline round it, or an
/// empty one when there is no colour: the trigger's and the field's preview.
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.diameter, required this.edge, required this.color});

  final double diameter;
  final Color edge;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: diameter,
        child: CustomPaint(
          painter: _DotPainter(checker: tokens.border, edge: edge, color: color),
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter({required this.checker, required this.edge, required this.color});

  final Color checker;
  final Color edge;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path round = Path()..addOval(rect);

    canvas.save();
    canvas.clipPath(round);
    _paintChecker(canvas, rect, checker);

    final Color? color = this.color;

    if (color != null) {
      canvas.drawRect(rect, Paint()..color = color);
    }

    canvas.restore();
    canvas.drawOval(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = edge,
    );
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) {
    return oldDelegate.checker != checker || oldDelegate.edge != edge || oldDelegate.color != color;
  }
}

/// Lower case as it is typed, as the React field's `text-transform`: a value
/// is the same colour in either case.
class _LowerCase extends TextInputFormatter {
  const _LowerCase();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String lower = newValue.text.toLowerCase();

    // Only where lowering keeps every offset where it was.
    if (lower == newValue.text || lower.length != newValue.text.length) {
      return newValue;
    }

    return newValue.copyWith(text: lower);
  }
}

/// The field the value can be typed into, with a preview of the colour
/// beside it. What is typed reaches the panel the moment it reads as a
/// colour, and half a colour leaves the panel where it was.
class _ValueField extends StatefulWidget {
  const _ValueField({
    required this.controller,
    required this.onTyped,
    required this.size,
    required this.roles,
    required this.inert,
    required this.disabled,
    required this.label,
    required this.preview,
  });

  final TextEditingController controller;
  final ValueChanged<String> onTyped;
  final NebaSize size;
  final NebaColorRoles roles;
  final bool inert;
  final bool disabled;
  final String label;
  final Widget preview;

  @override
  State<_ValueField> createState() => _ValueFieldState();
}

class _ValueFieldState extends State<_ValueField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final FocusNode _node = FocusNode(debugLabel: 'NebaColorPicker value');
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);
  bool _focused = false;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !widget.disabled;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    _node.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_node.hasFocus != _focused) {
      setState(() => _focused = _node.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size;
    final double meta = NebaScale.metaText[size]!;
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.xs]!);
    final TextStyle style = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        fontFamily: NebaScale.monoFonts.first,
        fontFamilyFallback: NebaScale.monoFonts.sublist(1),
        fontSize: meta,
        height: 1.5,
        leadingDistribution: TextLeadingDistribution.even,
        color: widget.disabled ? tokens.disabledFg : tokens.fg,
      ),
    );

    Widget box = NebaFocusRing(
      // A text field rings on any focus, as `:focus-visible` matches every
      // focused input.
      visible: _focused && !widget.disabled,
      keyboardOnly: false,
      color: widget.roles.ring,
      borderRadius: radius,
      offset: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: tokens.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: NebaFieldEditable(
            editableKey: _editableKey,
            controller: widget.controller,
            focusNode: _node,
            style: style,
            roles: widget.roles,
            empty: widget.controller.text.isEmpty,
            readOnly: widget.inert,
            suggestions: false,
            autofillHints: null,
            inputFormatters: const <TextInputFormatter>[_LowerCase()],
            onChanged: widget.onTyped,
            selectionEnabled: selectionEnabled,
          ),
        ),
      ),
    );

    box = MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      child: _gestures.wrap(box, disabled: widget.disabled),
    );

    return Row(
      spacing: NebaColorPicker.panelGap[size]!,
      children: <Widget>[
        widget.preview,
        Expanded(
          // The editable's own flags and actions merge into this node, so
          // nothing here repeats them.
          child: Semantics(
            container: true,
            label: widget.label,
            enabled: !widget.disabled,
            onTap: widget.disabled ? null : () => _editableKey.currentState?.requestKeyboard(),
            child: box,
          ),
        ),
      ],
    );
  }
}

/// The ready-made colours, eight to a row, each a round button named by its
/// own colour and heard as pressed while it is the one chosen.
class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid({
    required this.swatches,
    required this.current,
    required this.width,
    required this.tokens,
    required this.roles,
    required this.inert,
    required this.label,
    required this.onChosen,
  });

  final List<_Swatch> swatches;

  /// The chosen colour as hex, which a swatch is compared with.
  final String current;
  final double width;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final bool inert;
  final String label;
  final void Function(NebaColorValue value) onChosen;

  static const int _columns = 8;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final double cell = (width - _gap * (_columns - 1)) / _columns;
    final Color edge = mixOklab(tokens.fg, 0.18, transparent);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: <Widget>[
          for (final _Swatch swatch in swatches)
            SizedBox.square(
              dimension: cell,
              child: _SwatchButton(
                swatch: swatch,
                chosen: swatch.hex != null && swatch.hex == current,
                edge: edge,
                ring: roles.ring,
                inert: inert,
                onChosen: onChosen,
              ),
            ),
        ],
      ),
    );
  }
}

class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.swatch,
    required this.chosen,
    required this.edge,
    required this.ring,
    required this.inert,
    required this.onChosen,
  });

  final _Swatch swatch;
  final bool chosen;
  final Color edge;
  final Color ring;
  final bool inert;
  final void Function(NebaColorValue value) onChosen;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorValue? parsed = swatch.parsed;
    final Color fill = parsed == null ? transparent : hsvColor(parsed.hsv, parsed.alpha);

    void choose() {
      if (parsed != null) {
        onChosen(parsed);
      }
    }

    // The press is the control's own, which a screen reader's tap reaches; a
    // second tap action here would split the node in two.
    return Semantics(
      container: true,
      button: true,
      selected: chosen,
      enabled: !inert,
      label: swatch.source,
      child: NebaInteractive(
        enabled: !inert,
        onTap: choose,
        cursor: inert ? SystemMouseCursors.basic : SystemMouseCursors.click,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: nebaDuration(context, NebaScale.duration),
              curve: NebaScale.ease,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: edge),
                boxShadow: interaction.hovered ? tokens.elevation(1) : const <BoxShadow>[],
              ),
              child: chosen && parsed != null
                  ? Center(
                      child: NebaGlyph(NebaGlyphs.check, size: 12, color: readableInk(parsed.hsv)),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// The × that empties the picker: drawn at the size of the text beside it,
/// muted, and a button of its own in the focus order.
class _ClearButton extends StatelessWidget {
  const _ClearButton({
    required this.extent,
    required this.glyph,
    required this.ring,
    required this.label,
    required this.onPressed,
  });

  final double extent;
  final double glyph;
  final Color ring;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Semantics(
      container: true,
      button: true,
      label: label,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            borderRadius: BorderRadius.circular(extent),
            offset: 1,
            // The React package's `chipRemoveClasses`, as a Chip's × is.
            child: AnimatedOpacity(
              opacity: interaction.hovered || interaction.focusVisible ? 1 : 0.7,
              duration: nebaDuration(context, NebaScale.duration),
              curve: NebaScale.ease,
              child: SizedBox.square(
                dimension: extent,
                child: OverflowBox(
                  maxWidth: glyph,
                  maxHeight: glyph,
                  child: NebaGlyph(NebaGlyphs.close, size: glyph, color: tokens.mutedFg),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
