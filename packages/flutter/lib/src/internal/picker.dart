/// The shell every picker wears: a field-shaped trigger with a popup hanging
/// off it, the React package's `internal/picker.tsx`.
///
/// What it draws is not new. The trigger is a `NebaTextField`'s shell, as a
/// `NebaSelect`'s is, so a date field and the text field beside it share
/// their height, corners and edge; the popup is the sheet a bordered
/// `NebaCalendar` draws, opened through `NebaFloating`. There is no typing
/// into the trigger: reading a date out of free text depends on the language
/// in a way that cannot be done honestly without a date library, so the
/// trigger is a button and the popup is where the answer comes from.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/remove.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// A picker's trigger, its label, the two lines under it and its popup.
///
/// The caller owns [open] and [value]; the field asks for [onOpenChange] on a
/// press, Enter or Space, Escape, a press outside and the focus leaving the
/// popup, and the popup gets the focus when it opens and gives it back to
/// the trigger when it closes.
class NebaPickerField extends StatefulWidget {
  /// A trigger saying [value], or [placeholder] while it is `null`.
  const NebaPickerField({
    required this.variant,
    required this.size,
    required this.color,
    required this.density,
    required this.elevation,
    required this.value,
    required this.samples,
    required this.open,
    required this.onOpenChange,
    required this.popup,
    required this.clearLabel,
    required this.onClear,
    this.placeholder,
    this.label,
    this.labelPlacement = NebaLabelPlacement.top,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.clearable = false,
    this.fullWidth = false,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.display,
    this.sizer,
    super.key,
  });

  /// The weight of the trigger's sheet.
  final NebaVariant variant;

  /// The height floor, the type, and the popup's corners and padding.
  final NebaSize size;

  /// The family of the edge, the ring and the popup.
  final NebaColor color;

  /// The trigger's inline padding.
  final NebaDensity density;

  /// The trigger's drop shadow.
  final NebaElevation elevation;

  /// What the trigger says, or `null` while nothing is chosen.
  final String? value;

  /// Everything the trigger could say, so it keeps one width whatever it
  /// holds.
  final List<String> samples;

  /// Shown, muted, while nothing is chosen.
  final Widget? placeholder;

  /// The control's name.
  final Widget? label;

  /// Where [label] is drawn.
  final NebaLabelPlacement labelPlacement;

  /// Helper text under the trigger.
  final Widget? description;

  /// An error under the trigger, which turns it invalid.
  final Widget? error;

  /// Whether it is invalid; whether there is an [error] when left out.
  final bool? invalid;

  /// The glyph before the value, or `null` for none.
  final Widget? startIcon;

  /// Whether a × empties it while it holds something.
  final bool clearable;

  /// What the × is called.
  final String clearLabel;

  /// Empties it.
  final VoidCallback onClear;

  /// Whether the popup is open.
  final bool open;

  /// Asks for the popup to open or close.
  final ValueChanged<bool> onOpenChange;

  /// What the popup holds, drawn on the picker's sheet.
  final Widget popup;

  /// Whether it takes the width it is given.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows its value, keeps the focus, and does not open.
  final bool readOnly;

  /// What a screen reader names the trigger, in place of [label].
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  /// What the trigger draws in place of [value] and [placeholder], a range's
  /// two ends. Its text and glyphs take the placeholder's muted ink unless
  /// they set their own, and while [value] is `null` it is hidden under a
  /// resting label as a placeholder is. [value] is still what a screen
  /// reader hears and what says whether the field holds anything.
  final Widget? display;

  /// What the trigger's width is measured from in place of [samples] and
  /// [placeholder], for a [display] that holds its own widths.
  final Widget? sizer;

  @override
  State<NebaPickerField> createState() => _NebaPickerFieldState();
}

class _NebaPickerFieldState extends State<NebaPickerField> {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  FocusNode? _ownNode;

  FocusNode get _triggerNode {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaPicker'));
  }

  bool get _inert => _disabled || widget.readOnly;

  @override
  void dispose() {
    _ownNode?.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_inert || widget.open) {
      widget.onOpenChange(!widget.open);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final LogicalKeyboardKey key = event.logicalKey;
    final bool activates =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space;

    if (!activates || _disabled) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent) {
      _toggle();
    }

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaVariant variant = widget.variant;
    final NebaSize size = widget.size;
    final NebaDensity density = widget.density;
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool inert = disabled || readOnly;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColor family = invalid ? NebaColor.danger : widget.color;
    final NebaColorRoles roles = tokens.roles(family);
    final bool open = widget.open && !inert;
    final String? value = widget.value;
    final bool empty = value == null;
    final Widget? label = widget.label;
    final Widget? placeholder = widget.placeholder;
    final Widget? startIcon = widget.startIcon;
    final bool clears = widget.clearable && !empty && !inert;
    final bool notched = label != null && widget.labelPlacement != NebaLabelPlacement.top;
    final bool rests =
        notched && widget.labelPlacement == NebaLabelPlacement.float && startIcon == null;
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: label,
      description: widget.description,
      error: widget.error,
      placeholder: nebaPlainText(placeholder),
    );
    final double text = NebaScale.controlText[size]!;
    final double gap = NebaScale.gap[size]!;
    final TextStyle valueStyle = TextStyle(
      fontSize: text,
      height: NebaScale.controlLeading[size]! / text,
      leadingDistribution: TextLeadingDistribution.even,
    );
    // The ×: the size of the words beside it, two pixels off them.
    final double removeExtent = text * 1.15;
    final double removeWidth = 2 + removeExtent;

    Widget content(BuildContext context, bool focused) {
      Widget shown;
      final Widget? display = widget.display;

      if (display != null) {
        // Hidden under a resting label while it holds nothing, as a
        // placeholder is.
        final bool hidden = empty && rests && !focused && !open;

        shown = TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: hidden ? tokens.mutedFg.withValues(alpha: 0) : tokens.mutedFg),
          duration: nebaDuration(context, NebaScale.duration),
          curve: NebaScale.ease,
          builder: (BuildContext context, Color? color, Widget? child) {
            return IconTheme.merge(
              data: IconThemeData(color: color),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: color),
                child: child!,
              ),
            );
          },
          child: display,
        );
      } else if (value != null) {
        shown = Text(value, style: TextStyle(color: tokens.fg));
      } else if (placeholder != null) {
        // A resting label stands where the placeholder would be, so the
        // placeholder shows only once the label has risen.
        final bool hidden = rests && !focused && !open;

        shown = TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: hidden ? tokens.mutedFg.withValues(alpha: 0) : tokens.mutedFg),
          duration: nebaDuration(context, NebaScale.duration),
          curve: NebaScale.ease,
          builder: (BuildContext context, Color? color, Widget? child) {
            return DefaultTextStyle.merge(
              style: TextStyle(color: color),
              child: child!,
            );
          },
          child: placeholder,
        );
      } else {
        shown = const SizedBox.shrink();
      }

      return Row(
        spacing: gap,
        children: <Widget>[
          Expanded(
            child: Focus(
              focusNode: _triggerNode,
              autofocus: widget.autofocus,
              canRequestFocus: !disabled,
              onKeyEvent: _onKey,
              child: Row(
                spacing: gap,
                children: <Widget>[
                  if (startIcon != null)
                    NebaFieldAdornment(
                      size: size,
                      focused: focused,
                      accent: roles.accent,
                      child: startIcon,
                    ),
                  Expanded(
                    child: ExcludeSemantics(
                      child: DefaultTextStyle.merge(
                        style: valueStyle,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: Align(alignment: AlignmentDirectional.centerStart, child: shown),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (clears)
            NebaRemoveButton(
              onPressed: widget.onClear,
              label: widget.clearLabel,
              ring: roles.ring,
              extent: removeExtent,
              glyph: text * 1.2,
              padding: const EdgeInsetsDirectional.only(start: 2),
            ),
        ],
      );
    }

    Widget trigger = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation,
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
              rests: rests,
              // It stays on the edge while the popup is open.
              empty: empty && !open,
            )
          : null,
      builder: content,
    );

    if (disabled) {
      trigger = ExcludeFocus(child: trigger);
    } else {
      // A tap opens it, as a button's click does; the ×'s own tap wins over
      // this one, so emptying the field does not open it.
      trigger = GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _toggle,
        child: trigger,
      );
    }

    final Widget field = NebaFloating(
      open: open,
      onOpenChange: (bool next, NebaFloatingReason reason) {
        if (next != widget.open) {
          widget.onOpenChange(next);
        }
      },
      side: NebaSide.bottom,
      align: NebaAlign.start,
      sideOffset: 6,
      moveFocus: true,
      // As wide as what is on it, as a popup that shrinks to fit is.
      popup: NebaCalendarSheet(
        size: size,
        roles: roles,
        elevation: 3,
        child: IntrinsicWidth(child: widget.popup),
      ),
      child: trigger,
    );

    final double padX = NebaScale.paddingX[density]![size]!;
    final double border = variant == NebaVariant.outline ? 1 : 0;
    final Widget sizer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The trigger at the width of the longest thing it could say, and
        // the × beside it while it shows.
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: padX + border + (startIcon == null ? 0 : text * 1.2 + gap),
            end: padX + border + (clears ? gap + removeWidth : 0),
          ),
          child: switch (widget.sizer) {
            null => NebaWidthSizer(
              style: valueStyle,
              samples: <Widget>[
                for (final String sample in widget.samples) Text(sample),
                ?placeholder,
                if (rests) label,
              ],
            ),
            final Widget sizer => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle.merge(style: valueStyle, child: sizer),
                if (rests) NebaWidthSizer(style: valueStyle, samples: <Widget>[label]),
              ],
            ),
          },
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

    // One node for the whole column: a button named by its label that says
    // the value it holds, and that it opens a popup by being expanded.
    return Semantics(
      container: true,
      button: true,
      label: semantics.label,
      value: value,
      hint: semantics.hint,
      enabled: !disabled,
      expanded: open,
      readOnly: readOnly,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: inert ? null : _toggle,
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

/// The row of shortcuts under a picker's panel, after a hairline rather than
/// a gap, since the buttons act on the panel and a gap would read as a second
/// popup under the first.
class NebaPickerFooter extends StatelessWidget {
  /// A footer holding [children], at the end.
  const NebaPickerFooter({
    required this.size,
    required this.roles,
    required this.children,
    super.key,
  });

  /// The gap between the buttons.
  final NebaSize size;

  /// The family of the hairline.
  final NebaColorRoles roles;

  /// The buttons.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: roles.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: NebaScale.gap[size]!,
          children: children,
        ),
      ),
    );
  }
}
