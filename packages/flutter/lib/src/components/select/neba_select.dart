/// `NebaSelect`, one value chosen from a list of them.
library;

import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One option of a [NebaSelect].
@immutable
class NebaSelectOption<T> {
  /// An option standing for [value].
  const NebaSelectOption({required this.value, this.label, this.disabled = false, this.group});

  /// What choosing the option makes the select's value.
  final T value;

  /// What the list and the trigger show, usually a [Text]. Defaults to the
  /// value's own text. A `Text` is also what typeahead matches and what a
  /// screen reader reads; any other widget is matched and read by its value.
  final Widget? label;

  /// Listed, but not available to choose.
  final bool disabled;

  /// A heading over this option and the ones next to it that name the same
  /// group. A group is a run of adjacent options, so the list's order is the
  /// order given, and two runs naming one group draw two headings. The
  /// heading cannot be highlighted, chosen or reached by typeahead.
  final String? group;
}

/// One value chosen from a list of them, generic over the type of the value.
///
/// The trigger is a `NebaTextField`'s shell wearing a chevron, so a select
/// and the fields around it share their height, corners and edge. A press on
/// it, the arrow keys, Enter or Space open the list under it; the arrow keys,
/// Home and End move the highlight there, typing the first letters of an
/// option reaches it, and Enter, Space or a press chooses. Typing at a closed
/// trigger chooses the option it reaches, as a native select does. Escape,
/// Tab, a press outside and the choice itself close the list and give the
/// focus back to the trigger.
///
/// It is as wide as its widest option, so choosing a shorter one never moves
/// it under the pointer, unless it is [fullWidth]. Controlled with [value]
/// and [onValueChange], or left to keep its own state from [defaultValue].
///
/// ```dart
/// NebaSelect<String>(
///   label: const Text('Region'),
///   placeholder: const Text('Pick a region'),
///   items: const <NebaSelectOption<String>>[
///     NebaSelectOption<String>(value: 'icn', label: Text('Seoul')),
///     NebaSelectOption<String>(value: 'nrt', label: Text('Tokyo')),
///   ],
/// )
/// ```
class NebaSelect<T> extends StatefulWidget {
  /// A select over [items].
  const NebaSelect({
    required this.items,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.placeholder,
    this.label,
    this.labelPlacement,
    this.description,
    this.error,
    this.invalid,
    this.startIcon,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.fullWidth = false,
    this.disabled = false,
    this.readOnly = false,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The options, in the order the list shows them.
  final List<NebaSelectOption<T>> items;

  /// The chosen option's value, for a controlled select. Leave it `null` and
  /// the select keeps its own state, starting from [defaultValue].
  final T? value;

  /// Which option starts chosen, for an uncontrolled select.
  final T? defaultValue;

  /// Called with the value of the option that was chosen.
  final ValueChanged<T>? onValueChange;

  /// What the trigger shows while nothing is chosen, usually a [Text], muted
  /// as a field's placeholder is.
  final Widget? placeholder;

  /// The select's name, usually a [Text]. A screen reader hears it as the
  /// trigger's name.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it while nothing is chosen, the trigger does not hold
  /// the focus and the list is closed. A [startIcon] keeps a `float` label in
  /// the notch. Defaults to `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the trigger, usually a [Text].
  final Widget? description;

  /// An error under the trigger, usually a [Text]. Giving one turns the
  /// select invalid.
  final Widget? error;

  /// Whether the select is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Before the value, drawn at 1.2 times its size and muted.
  final Widget? startIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type scale, a field's. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the list's highlight.
  /// Defaults to [NebaColor.primary]; an invalid select is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0`, which is none, to `3`. The list has
  /// its own, fixed at `3`: it floats above the page.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the select is as wide as
  /// its widest option, its placeholder or a floating label at rest.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows its value but does not change it. The list still opens, so the
  /// options can be read, and nothing in it can be chosen; the trigger keeps
  /// the focus and goes flat.
  final bool readOnly;

  /// Whether the list is open. With [onOpenChange] the caller owns the
  /// state; without it the select keeps its own.
  final bool? open;

  /// Whether a select that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the list opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// What a screen reader names the trigger, in place of [label]: for a
  /// select with no label of its own, one in a table cell, say.
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaSelect<T>> createState() => _NebaSelectState<T>();
}

class _NebaSelectState<T> extends State<NebaSelect<T>> {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  final NebaTypeahead _typeahead = NebaTypeahead();
  final FocusNode _listNode = FocusNode(debugLabel: 'NebaSelect list');
  FocusNode? _ownNode;
  late T? _value = widget.defaultValue;
  late bool _open = widget.defaultOpen;
  // The option the pointer or the keys are on, by its index in `items`.
  int? _highlight;
  // Whether the keys put it there, so the list scrolls to show it.
  bool _reveal = false;
  // Whether the select asked to open and set the highlight it opens on, so a
  // caller's `open` arriving after does not set it again.
  bool _prepared = false;

  FocusNode get _triggerNode {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaSelect'));
  }

  T? get _current => widget.value ?? _value;

  bool get _isOpen => widget.open ?? _open;

  // A read-only select still opens, so its options can be read; it is the
  // value that is locked, as Base UI's is.
  bool get _readOnly => widget.readOnly && !_disabled;

  @override
  void initState() {
    super.initState();

    if (_isOpen) {
      _highlight = _selectedIndex;
      _reveal = true;
    }
  }

  @override
  void didUpdateWidget(NebaSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasOpen = oldWidget.open ?? _open;

    // Opened from outside: the list starts on the chosen option, as it does
    // when the select opens itself.
    if (_isOpen && !wasOpen && !_prepared) {
      _highlight = _selectedIndex;
      _reveal = true;
      _typeahead.reset();
    }

    if (_isOpen != wasOpen || !_isOpen) {
      _prepared = false;
    }

    if (_highlight != null && _highlight! >= widget.items.length) {
      _highlight = null;
    }
  }

  @override
  void dispose() {
    _typeahead.dispose();
    _listNode.dispose();
    _ownNode?.dispose();
    super.dispose();
  }

  int? get _selectedIndex {
    final T? current = _current;

    if (current == null) {
      return null;
    }

    final int index = widget.items.indexWhere(
      (NebaSelectOption<T> option) => option.value == current,
    );

    return index < 0 ? null : index;
  }

  bool _enabledAt(int index) => !widget.items[index].disabled;

  int? _firstEnabled({bool last = false}) {
    final int count = widget.items.length;

    for (int i = 0; i < count; i++) {
      final int index = last ? count - 1 - i : i;

      if (_enabledAt(index)) {
        return index;
      }
    }

    return null;
  }

  /// The words of each option, or `null` for one that cannot be reached.
  List<String?> get _typeaheadLabels {
    return <String?>[
      for (final NebaSelectOption<T> option in widget.items)
        option.disabled ? null : _wordsOf(option),
    ];
  }

  void _setOpen(bool open, {int? highlight}) {
    if (open == _isOpen || (open && _disabled)) {
      return;
    }

    setState(() {
      if (widget.open == null) {
        _open = open;
      }

      if (open) {
        _highlight = highlight;
        _reveal = true;
        _typeahead.reset();
      }

      _prepared = open && widget.open != null;
    });

    widget.onOpenChange?.call(open);
  }

  void _choose(int index) {
    final NebaSelectOption<T> option = widget.items[index];

    if (option.disabled || _disabled || _readOnly) {
      return;
    }

    final bool changed = option.value != _current;

    if (widget.value == null) {
      setState(() => _value = option.value);
    }

    if (changed) {
      widget.onValueChange?.call(option.value);
    }
  }

  void _togglePointer() {
    if (_isOpen) {
      _setOpen(false);
    } else {
      // A press opens on the chosen option and leaves the rest unlit until
      // the pointer moves over them.
      _setOpen(true, highlight: _selectedIndex);
    }
  }

  void _highlightFromPointer(int index) {
    if (_highlight != index || _reveal) {
      setState(() {
        _highlight = index;
        _reveal = false;
      });
    }
  }

  void _leaveFromPointer(int index) {
    if (_highlight == index && !_reveal) {
      setState(() => _highlight = null);
    }
  }

  void _moveHighlight(int? index) {
    if (index != null && (index != _highlight || !_reveal)) {
      setState(() {
        _highlight = index;
        _reveal = true;
      });
    }
  }

  /// Closes the list and moves the focus on from the trigger, as Tab out of
  /// an open native select does.
  void _tabOut({required bool backwards}) {
    _setOpen(false);
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) {
        return;
      }

      // The list gave the focus back as it closed, and that lands first, so
      // the focus moves on from the trigger.
      FocusManager.instance.applyFocusChangesIfNeeded();

      final FocusNode node = _triggerNode;

      if (node.hasFocus) {
        backwards ? node.previousFocus() : node.nextFocus();
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _disabled) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final bool open = _isOpen;
    final bool enter = key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter;
    final bool space = key == LogicalKeyboardKey.space;

    if (!open) {
      if (event is KeyRepeatEvent && (enter || space)) {
        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.arrowDown || enter || (space && !_typeahead.typing)) {
        _setOpen(true, highlight: _selectedIndex ?? _firstEnabled());

        return KeyEventResult.handled;
      }

      if (key == LogicalKeyboardKey.arrowUp) {
        _setOpen(true, highlight: _selectedIndex ?? _firstEnabled(last: true));

        return KeyEventResult.handled;
      }
    } else {
      if (key == LogicalKeyboardKey.tab) {
        _tabOut(backwards: HardwareKeyboard.instance.isShiftPressed);

        return KeyEventResult.handled;
      }

      if (enter || (space && !_typeahead.typing)) {
        if (event is KeyDownEvent) {
          final int? highlight = _highlight;

          // A read-only list is read, and nothing in it is chosen.
          if (highlight != null && _enabledAt(highlight) && !_readOnly) {
            _choose(highlight);
            _setOpen(false);
          }
        }

        return KeyEventResult.handled;
      }

      final int? current = _highlight;
      final int? moved = current == null
          ? switch (key) {
              LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.home => _firstEnabled(),
              LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.end => _firstEnabled(last: true),
              _ => null,
            }
          : nebaRovingTarget(
              event,
              current: current,
              count: widget.items.length,
              axis: Axis.vertical,
              textDirection: Directionality.of(context),
              loop: true,
              focusable: _enabledAt,
            );

      if (moved != null) {
        _moveHighlight(moved);

        return KeyEventResult.handled;
      }
    }

    final String? character = event.character;
    final bool modified =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed;

    // Typing at a closed trigger chooses, which a read-only one does not.
    if (character != null &&
        (open || !_readOnly) &&
        character.length == 1 &&
        character.codeUnitAt(0) >= 0x20 &&
        character.codeUnitAt(0) != 0x7F &&
        !modified) {
      final int? match = _typeahead.type(
        character,
        labels: _typeaheadLabels,
        current: open ? _highlight ?? _selectedIndex : _selectedIndex,
      );

      if (match != null) {
        if (open) {
          _moveHighlight(match);
        } else {
          _choose(match);
        }
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _wordsOf(NebaSelectOption<T> option) => nebaPlainText(option.label) ?? '${option.value}';

  Widget _labelOf(NebaSelectOption<T> option) => option.label ?? Text('${option.value}');

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaLabelPlacement placement =
        widget.labelPlacement ?? defaults.labelPlacement ?? NebaLabelPlacement.top;
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColorRoles roles = tokens.roles(
      invalid ? NebaColor.danger : widget.color ?? NebaColor.primary,
    );
    final bool open = _isOpen && !disabled;
    final int? selected = _selectedIndex;
    final NebaSelectOption<T>? chosen = selected == null ? null : widget.items[selected];
    final Widget? label = widget.label;
    final Widget? placeholder = widget.placeholder;
    final Widget? startIcon = widget.startIcon;
    // The trigger is a button, so its label stands on the edge beside it
    // rather than inside it; with no label there is nothing to cut a notch
    // for.
    final bool notched = label != null && placement != NebaLabelPlacement.top;
    final bool rests = notched && placement == NebaLabelPlacement.float && startIcon == null;
    final double chevron = nebaNotchRestEnd(size, const <double>[1.2]);
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

    Widget content(BuildContext context, bool focused) {
      Widget value;

      if (chosen != null) {
        value = _labelOf(chosen);
      } else if (placeholder != null) {
        // A resting label stands where the placeholder would be, so the
        // placeholder shows only once the label has risen.
        final bool hidden = rests && !focused && !open;

        value = TweenAnimationBuilder<Color?>(
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
        value = const SizedBox.shrink();
      }

      return Focus(
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
                focused: false,
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
                  child: Align(alignment: AlignmentDirectional.centerStart, child: value),
                ),
              ),
            ),
            NebaFieldAdornment(
              size: size,
              focused: false,
              accent: roles.accent,
              child: NebaDisclosureChevron(open: open),
            ),
          ],
        ),
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
              rests: rests,
              empty: chosen == null && !open,
              restEnd: chevron,
            )
          : null,
      builder: content,
    );

    if (disabled) {
      trigger = ExcludeFocus(child: trigger);
    } else {
      // A mouse opens it on the press going down, as Base UI's trigger does,
      // and a finger on the tap, so a scroll that starts on it opens nothing.
      trigger = Listener(
        onPointerDown: (PointerDownEvent event) {
          if (event.kind != PointerDeviceKind.touch && event.buttons == kPrimaryButton) {
            _togglePointer();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: (TapUpDetails details) {
            if (details.kind == PointerDeviceKind.touch) {
              _togglePointer();
            }
          },
          child: trigger,
        ),
      );
    }

    final Widget field = NebaFloating(
      open: open,
      onOpenChange: (bool next, NebaFloatingReason reason) => _setOpen(next),
      side: NebaSide.bottom,
      sideOffset: 6,
      moveFocus: true,
      width: NebaFloatingWidth.atLeastAnchor,
      maxHeight: nebaListMaxHeight,
      popup: _buildList(context, size: size, roles: roles, name: semantics.label),
      child: trigger,
    );

    final Widget sizer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The trigger at the width of the longest thing it could say.
        Padding(
          padding: EdgeInsetsDirectional.only(
            start:
                NebaScale.paddingX[density]![size]! +
                (variant == NebaVariant.outline ? 1 : 0) +
                (startIcon == null ? 0 : text * 1.2 + gap),
            end:
                NebaScale.paddingX[density]![size]! +
                (variant == NebaVariant.outline ? 1 : 0) +
                chevron,
          ),
          child: NebaWidthSizer(
            style: valueStyle,
            samples: <Widget>[
              for (final NebaSelectOption<T> option in widget.items) _labelOf(option),
              ?placeholder,
              if (rests) label,
            ],
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

    // One node for the whole column: a button that says its value, and that
    // it opens a list by being expanded or collapsed.
    return Semantics(
      container: true,
      button: true,
      label: semantics.label,
      value: chosen == null ? null : _wordsOf(chosen),
      hint: semantics.hint,
      enabled: !disabled,
      expanded: open,
      readOnly: readOnly,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: disabled ? null : _togglePointer,
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

  Widget _buildList(
    BuildContext context, {
    required NebaSize size,
    required NebaColorRoles roles,
    required String? name,
  }) {
    final List<NebaSelectOption<T>> items = widget.items;
    final int? selected = _selectedIndex;
    final List<Widget> children = <Widget>[];
    int index = 0;

    while (index < items.length) {
      final String? group = items[index].group;
      final List<Widget> run = <Widget>[];

      // A group is a run of adjacent options naming it.
      while (index < items.length && items[index].group == group) {
        final int at = index;
        final NebaSelectOption<T> option = items[at];
        final bool chosen = at == selected;

        run.add(
          NebaListRow(
            roles: roles,
            highlighted: at == _highlight,
            reveal: _reveal,
            selected: chosen,
            disabled: option.disabled,
            indicator: chosen ? NebaGlyph(NebaGlyphs.check) : null,
            semanticLabel: _wordsOf(option),
            onHover: () => _highlightFromPointer(at),
            onExit: () => _leaveFromPointer(at),
            onPressed: _readOnly
                ? null
                : () {
                    _choose(at);
                    _setOpen(false);
                  },
            child: _labelOf(option),
          ),
        );
        index++;
      }

      if (group == null) {
        children.addAll(run);
      } else {
        children.add(
          Semantics(
            container: true,
            explicitChildNodes: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NebaListHeading(label: group, size: size),
                ...run,
              ],
            ),
          ),
        );
      }
    }

    return Focus(
      focusNode: _listNode,
      onKeyEvent: _onKey,
      child: NebaListSheet(
        size: size,
        roles: roles,
        semanticLabel: name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
