/// `NebaCombobox`, a field you can type into and also choose from.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/chip/neba_chip.dart';
import 'package:neba/src/internal/button_group.dart';
import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/listbox.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One option of a [NebaCombobox].
@immutable
class NebaComboboxOption<T> {
  /// An option standing for [value].
  const NebaComboboxOption({required this.value, this.label, this.disabled = false});

  /// What choosing the option makes the combobox's value.
  final T value;

  /// What the list, the field and a chip show, and what typing is matched
  /// against. A string rather than a widget, because it is typed against and
  /// written into the field. Defaults to the value's own text.
  final String? label;

  /// Listed, but not available to choose.
  final bool disabled;
}

/// Decides whether an option stays in the list for what was typed.
typedef NebaComboboxFilter<T> = bool Function(NebaComboboxOption<T> option, String query);

/// A field you can type into and also choose from, generic over the type of
/// the value.
///
/// The shell is a `NebaTextField`'s wearing a chevron, as a `NebaSelect`'s
/// trigger is. What is typed narrows the list, with the accents and the case
/// folded away, and the first match lights up, so Enter chooses it. Unless
/// [allowCustom] is off, what was typed is also offered as the list's last
/// row, so a value the list does not have is chosen on purpose rather than on
/// the way out.
///
/// [NebaCombobox.multiple] holds a list of values instead: each one chosen
/// becomes a chip inside the field, with a × that takes it out, and the field
/// goes on filtering after each, so a set of tags is built without it
/// closing. Backspace in an empty field takes the last chip out.
///
/// ```dart
/// NebaCombobox<String>(
///   label: const Text('Framework'),
///   placeholder: 'Search or type your own',
///   items: const <NebaComboboxOption<String>>[
///     NebaComboboxOption<String>(value: 'react', label: 'React'),
///     NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
///   ],
/// )
/// ```
class NebaCombobox<T> extends StatefulWidget {
  /// A combobox holding one value.
  const NebaCombobox({
    required this.items,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.filter,
    this.onInputValueChange,
    this.allowCustom = true,
    this.customLabel,
    this.clearable = false,
    this.locale,
    this.emptyMessage,
    this.limit = -1,
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
    this.clearLabel,
    this.openLabel,
    this.removeLabel,
    this.shortcuts,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : multiple = false,
       values = null,
       defaultValues = null,
       onValuesChange = null,
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// A combobox holding a list of values, each drawn as a chip in the field.
  ///
  /// [value], [defaultValue] and [onValueChange] speak in lists here, which
  /// is why this is a constructor of its own rather than a flag.
  const NebaCombobox.multiple({
    required this.items,
    List<T>? value,
    List<T>? defaultValue,
    ValueChanged<List<T>>? onValueChange,
    this.filter,
    this.onInputValueChange,
    this.allowCustom = true,
    this.customLabel,
    this.clearable = false,
    this.locale,
    this.emptyMessage,
    this.limit = -1,
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
    this.clearLabel,
    this.openLabel,
    this.removeLabel,
    this.shortcuts,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : multiple = true,
       values = value,
       defaultValues = defaultValue,
       onValuesChange = onValueChange,
       value = null,
       defaultValue = null,
       onValueChange = null,
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The options, in the order the list shows them.
  final List<NebaComboboxOption<T>> items;

  /// Whether the combobox holds a list of values, as [NebaCombobox.multiple]
  /// makes it.
  final bool multiple;

  /// The chosen value of a single combobox, for a controlled one. Leave it
  /// `null` and the combobox keeps its own state, starting from
  /// [defaultValue].
  final T? value;

  /// The value a single combobox that keeps its own state starts with.
  final T? defaultValue;

  /// Called with the value a single combobox now holds, `null` once it is
  /// cleared.
  final ValueChanged<T?>? onValueChange;

  /// The chosen values of a multiple combobox, for a controlled one, which
  /// [NebaCombobox.multiple] takes as `value`.
  final List<T>? values;

  /// The values a multiple combobox that keeps its own state starts with,
  /// which [NebaCombobox.multiple] takes as `defaultValue`.
  final List<T>? defaultValues;

  /// Called with the values a multiple combobox now holds, which
  /// [NebaCombobox.multiple] takes as `onValueChange`.
  final ValueChanged<List<T>>? onValuesChange;

  /// Decides whether an option stays in the list for what was typed. Left
  /// out, an option stays when its label holds the typed text, with the
  /// accents and the case folded away. A filter that keeps everything turns
  /// filtering off, for a list a server has already narrowed. The row that
  /// offers what was typed is never filtered out.
  final NebaComboboxFilter<T>? filter;

  /// Called as the text in the field changes: the query, not the value.
  final ValueChanged<String>? onInputValueChange;

  /// Whether a value the list does not have may be chosen, offered as the
  /// list's last row. Only a combobox whose values a `String` can be, one
  /// over `String` or `Object?`, holds what was typed; over any other type
  /// the row is never offered.
  final bool allowCustom;

  /// What the row offering what was typed says, given the trimmed query.
  /// Defaults to the [locale]'s "Add “{label}”".
  final Widget Function(String query)? customLabel;

  /// Shows a × that empties the field while it holds something. Off by
  /// default: a field that empties in one press empties by accident.
  final bool clearable;

  /// The language the combobox's own words are in. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// Shown in the list when nothing matches and no value may be added.
  /// Defaults to the [locale]'s "No matches".
  final Widget? emptyMessage;

  /// The most options the list shows at once, `-1` for all of them. The row
  /// that offers what was typed is drawn after them, so a full list can still
  /// take a new value.
  final int limit;

  /// What the field shows while nothing is typed. Under a `float` label it
  /// shows only once the label has moved up.
  final String? placeholder;

  /// The field's name, usually a [Text]. A screen reader hears it as the
  /// field's name.
  final Widget? label;

  /// Where [label] is drawn: above the field, in a notch cut into its top
  /// edge, or inside it until the field takes the focus, holds text or has a
  /// chip in it. A [startIcon] keeps a `float` label in the notch. Defaults to
  /// `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the field, usually a [Text].
  final Widget? description;

  /// An error under the field, usually a [Text]. Giving one turns the field
  /// invalid.
  final Widget? error;

  /// Whether the field is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Before the text, drawn at 1.2 times its size and muted.
  final Widget? startIcon;

  /// The weight of the field's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor and the type scale, a field's. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring, the caret and the list's
  /// highlight. Defaults to [NebaColor.primary]; an invalid combobox is
  /// [NebaColor.danger].
  final NebaColor? color;

  /// The inline padding, and nothing else. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The field's drop shadow, from `0`, which is none, to `3`. The list has
  /// its own, fixed at `3`.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the field is about twenty
  /// characters wide, as a text field is.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows its value but takes no text and does not change it. The list
  /// still opens, so the options can be read, and nothing in it can be
  /// chosen; the field keeps the focus and goes flat, and its chips lose
  /// their ×.
  final bool readOnly;

  /// Whether the list is open. With [onOpenChange] the caller owns the
  /// state; without it the combobox keeps its own.
  final bool? open;

  /// Whether a combobox that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the list opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// What a screen reader hears for the ×. Defaults to the [locale]'s
  /// "Clear".
  final String? clearLabel;

  /// What a screen reader hears for the chevron when [label] is not a `Text`
  /// to name it by. Defaults to the [locale]'s "Open".
  final String? openLabel;

  /// What a screen reader hears for a chip's ×, given the chip's label.
  /// Defaults to the [locale]'s "Remove {label}".
  final String Function(String label)? removeLabel;

  /// Key combinations to act on while the field holds the focus, with what
  /// each does. They run before the list acts on a key and do not replace
  /// it, so a binding on Enter runs alongside the choice.
  final Map<ShortcutActivator, VoidCallback>? shortcuts;

  /// What a screen reader names the field, in place of [label].
  final String? semanticLabel;

  /// The field's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the field takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaCombobox<T>> createState() => _NebaComboboxState<T>();
}

/// A row of the list: an option, or the row offering what was typed.
class _Entry<T> {
  const _Entry({required this.label, this.option, this.custom = false});

  final NebaComboboxOption<T>? option;
  final String label;
  final bool custom;

  bool get disabled => option?.disabled ?? false;
}

class _NebaComboboxState<T> extends State<NebaCombobox<T>>
    implements TextSelectionGestureDetectorBuilderDelegate {
  /// Its own `disabled`, or that of a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final ValueNotifier<bool> _typing = ValueNotifier<bool>(false);
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this, onTap: _openFromTap);
  late final TextEditingController _controller = TextEditingController();

  /// One focus node per chip of a multiple combobox, by its value: a chip is
  /// reached with the arrow keys from the field, never with Tab.
  final Map<T, FocusNode> _chipNodes = <T, FocusNode>{};
  FocusNode? _ownNode;
  late List<T> _selection = <T>[
    if (widget.multiple) ...?widget.defaultValues else ?widget.defaultValue,
  ];
  late bool _open = widget.defaultOpen;
  // The text last seen, to tell typing from the caret moving.
  String _text = '';
  // Whether the text was written by the combobox rather than typed.
  bool _writing = false;
  // Whether anything was typed since the list opened, which is what narrows
  // a single combobox's list once its chosen label is in the field.
  bool _typedSinceOpen = false;
  // The row the pointer or the keys are on, by its index in the list shown.
  int? _highlight;
  bool _reveal = false;
  // Whether Escape has just closed the list, so the same key does not go on
  // to empty the field.
  bool _escapeClosed = false;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaCombobox'));

  bool get _isOpen => widget.open ?? _open;

  bool get _locked => _disabled || widget.readOnly;

  List<T> get _chosen {
    if (widget.multiple) {
      return widget.values ?? _selection;
    }

    final T? value = widget.value;

    return value == null ? _selection : <T>[value];
  }

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !_disabled;

  @override
  void initState() {
    super.initState();
    _write(widget.multiple ? '' : _labelOfValue(_chosen.firstOrNull), report: false);
    _controller.addListener(_handleText);
    _node.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(NebaCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final FocusNode? previous = oldWidget.focusNode ?? _ownNode;

    if (previous != _node) {
      previous?.removeListener(_handleFocus);
      _node.addListener(_handleFocus);
    }

    // A single combobox's field says the chosen option's label whenever the
    // choice changes, from inside or from the caller.
    if (!widget.multiple) {
      final T? before = oldWidget.value;
      final T? after = widget.value;

      if (after != null && after != before) {
        _later(() => _write(_labelOfValue(after)));
      }
    }

    final bool wasOpen = oldWidget.open ?? _open;

    if (_isOpen != wasOpen && !_isOpen) {
      _afterClose();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleText);
    _controller.dispose();
    _node.removeListener(_handleFocus);
    _ownNode?.dispose();
    for (final FocusNode node in _chipNodes.values) {
      node.dispose();
    }
    _typing.dispose();
    super.dispose();
  }

  /// [change] now, or after the frame when it would land in the middle of
  /// one: a controller written to while the tree builds tells its listeners
  /// at once.
  void _later(VoidCallback change) {
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

  /// Puts [text] in the field as the combobox's own writing, the caret at its
  /// end, and reports it as `onInputValueChange` reports what is typed.
  void _write(String text, {bool report = true}) {
    if (report && text != _controller.text) {
      widget.onInputValueChange?.call(text);
    }

    _writing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _text = text;
    _writing = false;
  }

  String _labelOf(NebaComboboxOption<T> option) => option.label ?? '${option.value}';

  String _labelOfValue(T? value) {
    if (value == null) {
      return '';
    }

    for (final NebaComboboxOption<T> option in widget.items) {
      if (option.value == value) {
        return _labelOf(option);
      }
    }

    return '$value';
  }

  /// Whether what was typed can be a value: a `String` has to be a `T`.
  bool get _takesText => '' is T;

  void _handleText() {
    final String text = _controller.text;

    if (text == _text) {
      return;
    }

    _text = text;

    if (_writing) {
      return;
    }

    widget.onInputValueChange?.call(text);

    // Typing opens the list, and the first match lights up so Enter takes it.
    if (!_isOpen) {
      _setOpen(true, keepHighlight: true);
    }

    _later(() {
      _typedSinceOpen = true;
      _highlight = text.trim().isEmpty ? null : _firstEnabled(_entries());
      _reveal = true;
    });
  }

  void _handleFocus() {
    if (!_node.hasFocus && _isOpen) {
      _setOpen(false);
    }
  }

  // The chevron opens the list with the focus in the field, so the keys and
  // the focus leaving work as they do after a tap on the field.
  void _toggleFromChevron() {
    if (_isOpen) {
      _setOpen(false);
    } else {
      _requestFocus();
      _setOpen(true);
    }
  }

  void _openFromTap() {
    if (!_isOpen) {
      _setOpen(true);
    }
  }

  void _setOpen(bool open, {int? highlight, bool keepHighlight = false}) {
    // A read-only combobox still opens, so its options can be read; it is the
    // value that is locked, as Base UI's is.
    if (open == _isOpen || (open && _disabled)) {
      return;
    }

    _later(() {
      if (widget.open == null) {
        _open = open;
      }

      if (open) {
        _typedSinceOpen = false;

        if (!keepHighlight) {
          _highlight = highlight;
          _reveal = true;
        }
      }
    });

    if (!open && widget.open == null) {
      _afterClose();
    }

    widget.onOpenChange?.call(open);
  }

  /// A multiple combobox empties its field as the list closes; a single one
  /// keeps what was typed.
  void _afterClose() {
    _highlight = null;

    if (widget.multiple && _controller.text.isNotEmpty) {
      _write('');
      _later(() {});
    }
  }

  void _commit(List<T> next) {
    if (widget.multiple ? widget.values == null : widget.value == null) {
      _later(() => _selection = next);
    }

    if (widget.multiple) {
      widget.onValuesChange?.call(next);
    } else {
      widget.onValueChange?.call(next.firstOrNull);
    }
  }

  void _choose(_Entry<T> entry) {
    if (entry.disabled || _locked) {
      return;
    }

    final T value = entry.custom ? entry.label as T : entry.option!.value;

    if (widget.multiple) {
      final List<T> chosen = _chosen;
      final bool had = chosen.contains(value);

      _commit(<T>[
        for (final T item in chosen)
          if (item != value) item,
        if (!had) value,
      ]);
      _write('');
      _later(() {
        _typedSinceOpen = false;
        _highlight = null;
      });

      return;
    }

    if (_chosen.firstOrNull != value) {
      _commit(<T>[value]);
    }

    _write(entry.label);
    _setOpen(false);
  }

  FocusNode _chipNode(T value) {
    return _chipNodes.putIfAbsent(
      value,
      () => FocusNode(debugLabel: 'NebaCombobox chip', skipTraversal: true),
    );
  }

  /// Forgets the nodes of chips that are gone, after the frame that stopped
  /// drawing them.
  void _pruneChipNodes(List<T> chosen) {
    final List<T> gone = <T>[
      for (final T value in _chipNodes.keys)
        if (!chosen.contains(value)) value,
    ];

    if (gone.isEmpty) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      for (final T value in gone) {
        if (!_chosen.contains(value)) {
          _chipNodes.remove(value)?.dispose();
        }
      }
    });
  }

  /// The keys a chip answers, as Base UI's chips do: the arrows walk the chips
  /// and step off either end into the field, Backspace and Delete take the
  /// chip out and move to the one that takes its place, and anything typed,
  /// Enter, Space and the arrows down the list go back to the field.
  KeyEventResult _onChipKey(T value, KeyEvent event) {
    if (event is KeyUpEvent || _locked) {
      return KeyEventResult.ignored;
    }

    final List<T> chosen = _chosen;
    final int index = chosen.indexOf(value);

    if (index < 0) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final LogicalKeyboardKey on = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;

    void focusAt(int? at) {
      if (at == null || at < 0 || at >= _chosen.length) {
        _node.requestFocus();
      } else {
        _chipNode(_chosen[at]).requestFocus();
      }
    }

    if (key == back) {
      focusAt(index > 0 ? index - 1 : null);

      return KeyEventResult.handled;
    }

    if (key == on) {
      focusAt(index < chosen.length - 1 ? index + 1 : null);

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      final int count = chosen.length;
      final int next = index >= count - 1 ? count - 2 : index;

      _remove(value);
      // After the frame, when the chip that takes this one's place is drawn.
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          focusAt(next >= 0 ? next : null);
        }
      });

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      _node.requestFocus();
      _setOpen(true);

      return KeyEventResult.handled;
    }

    final String? character = event.character;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space ||
        (character != null &&
            character.length == 1 &&
            character.codeUnitAt(0) >= 0x20 &&
            !HardwareKeyboard.instance.isControlPressed &&
            !HardwareKeyboard.instance.isMetaPressed &&
            !HardwareKeyboard.instance.isAltPressed)) {
      _node.requestFocus();

      // A character typed at a chip is typed into the field, which only
      // hears it from here: the keyboard's text goes to whatever held the
      // focus when the key went down.
      if (character != null && key != LogicalKeyboardKey.enter && key != LogicalKeyboardKey.space) {
        final String text = _controller.text + character;
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _remove(T value) {
    if (_locked) {
      return;
    }

    _commit(<T>[
      for (final T item in _chosen)
        if (item != value) item,
    ]);
  }

  void _clear() {
    if (_locked) {
      return;
    }

    _write('');
    _commit(<T>[]);
    _later(() => _highlight = null);
    _node.requestFocus();
  }

  /// The rows the list shows for what is in the field now.
  List<_Entry<T>> _entries() {
    final List<NebaComboboxOption<T>> items = widget.items;
    final List<T> chosen = _chosen;
    final String query = _controller.text.trim();
    final String folded = nebaSearchText(query);

    // A single combobox showing its chosen option's label shows every option
    // until something else is typed, rather than the one it already holds.
    final bool bypass =
        !widget.multiple &&
        !_typedSinceOpen &&
        chosen.isNotEmpty &&
        nebaSearchText(_labelOfValue(chosen.first)) == folded;
    final String filterQuery = bypass ? '' : query;
    final NebaComboboxFilter<T>? filter = widget.filter;

    Iterable<NebaComboboxOption<T>> matching = filterQuery.isEmpty
        ? items
        : items.where((NebaComboboxOption<T> option) {
            return filter != null
                ? filter(option, filterQuery)
                : nebaSearchText(_labelOf(option)).contains(nebaSearchText(filterQuery));
          });

    if (widget.limit > -1) {
      matching = matching.take(widget.limit);
    }

    final List<_Entry<T>> entries = <_Entry<T>>[
      for (final NebaComboboxOption<T> option in matching)
        _Entry<T>(option: option, label: _labelOf(option)),
    ];

    if (widget.allowCustom && !_locked && _takesText && query.isNotEmpty) {
      final String lower = query.toLowerCase();
      final bool known =
          items.any((NebaComboboxOption<T> option) {
            return _labelOf(option).toLowerCase() == lower ||
                '${option.value}'.toLowerCase() == lower;
          }) ||
          chosen.any((T item) => '$item'.toLowerCase() == lower);

      if (!known) {
        entries.add(_Entry<T>(label: query, custom: true));
      }
    }

    return entries;
  }

  int? _firstEnabled(List<_Entry<T>> entries, {bool last = false}) {
    for (int i = 0; i < entries.length; i++) {
      final int index = last ? entries.length - 1 - i : i;

      if (!entries[index].disabled) {
        return index;
      }
    }

    return null;
  }

  int? _selectedIn(List<_Entry<T>> entries) {
    final T? first = _chosen.firstOrNull;

    if (first == null) {
      return null;
    }

    for (int i = 0; i < entries.length; i++) {
      final NebaComboboxOption<T>? option = entries[i].option;

      if (option != null && option.value == first && !option.disabled) {
        return i;
      }
    }

    return null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final Map<ShortcutActivator, VoidCallback>? shortcuts = widget.shortcuts;

    if (shortcuts != null) {
      for (final MapEntry<ShortcutActivator, VoidCallback> binding in shortcuts.entries) {
        if (binding.key.accepts(event, HardwareKeyboard.instance)) {
          binding.value();
        }
      }
    }

    final HardwareKeyboard keyboard = HardwareKeyboard.instance;

    if (_disabled ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;
    final List<_Entry<T>> entries = _entries();
    final bool open = _isOpen;

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      final bool down = key == LogicalKeyboardKey.arrowDown;

      if (!open) {
        _setOpen(true, highlight: _selectedIn(entries) ?? _firstEnabled(entries, last: !down));

        return KeyEventResult.handled;
      }

      final int? current = _highlight;
      final int? moved = current == null || current >= entries.length
          ? _firstEnabled(entries, last: !down)
          : nebaRovingTarget(
              event,
              current: current,
              count: entries.length,
              axis: Axis.vertical,
              textDirection: Directionality.of(context),
              loop: true,
              focusable: (int index) => !entries[index].disabled,
            );

      setState(() {
        _highlight = moved;
        _reveal = true;
      });

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (!open) {
        return KeyEventResult.ignored;
      }

      final int? highlight = _highlight;

      if (highlight == null || highlight >= entries.length) {
        _setOpen(false);
      } else if (event is KeyDownEvent && !_locked) {
        _choose(entries[highlight]);
      }

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape && _escapeClosed) {
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape && !open) {
      // A closed list leaves Escape to empty the field, as Base UI's does.
      if (_controller.text.isEmpty && _chosen.isEmpty) {
        return KeyEventResult.ignored;
      }

      _clear();

      return KeyEventResult.handled;
    }

    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final TextSelection caret = _controller.selection;

    if (key == (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft) &&
        widget.multiple &&
        !_locked &&
        _chosen.isNotEmpty &&
        caret.isCollapsed &&
        caret.baseOffset <= 0) {
      _chipNode(_chosen.last).requestFocus();

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace &&
        widget.multiple &&
        _controller.text.isEmpty &&
        _chosen.isNotEmpty) {
      _remove(_chosen.last);

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.end) {
      final int offset = key == LogicalKeyboardKey.home ? 0 : _controller.text.length;

      _controller.selection = TextSelection.collapsed(offset: offset);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _requestFocus() {
    _editableKey.currentState?.requestKeyboard();
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
    final Locale? locale = widget.locale ?? defaults.locale;
    final Map<String, String> messages = nebaMessages(context, 'combobox', locale: locale);
    final bool disabled = _disabled;
    final bool readOnly = widget.readOnly && !disabled;
    final bool lit = !disabled && !readOnly;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColor family = invalid ? NebaColor.danger : widget.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(family);
    final bool open = _isOpen && !disabled;
    final bool multiple = widget.multiple;
    final List<T> chosen = _chosen;
    final Widget? label = widget.label;
    final Widget? startIcon = widget.startIcon;
    final bool clears = widget.clearable && !readOnly;
    final bool holds = multiple ? chosen.isNotEmpty : chosen.isNotEmpty || _text.isNotEmpty;
    final bool notched = label != null && placement != NebaLabelPlacement.top;
    final bool rests = notched && placement == NebaLabelPlacement.float && startIcon == null;
    final double restEnd = nebaNotchRestEnd(
      size,
      clears ? const <double>[1.2, 1.2] : <double>[1.2],
    );
    final bool empty = _text.isEmpty && (!multiple || chosen.isEmpty);
    final NebaFieldSemantics semantics = NebaFieldSemantics.of(
      semanticLabel: widget.semanticLabel,
      label: label,
      description: widget.description,
      error: widget.error,
      placeholder: widget.placeholder,
    );
    final double text = NebaScale.controlText[size]!;
    final TextStyle style = DefaultTextStyle.of(context).style.merge(
      TextStyle(
        fontSize: text,
        height: NebaScale.controlLeading[size]! / text,
        leadingDistribution: TextLeadingDistribution.even,
        color: disabled ? tokens.disabledFg : tokens.fg,
      ),
    );
    final List<_Entry<T>> entries = open ? _entries() : <_Entry<T>>[];
    final double border = variant == NebaVariant.outline ? 1 : 0;
    final double padX = NebaScale.paddingX[density]![size]!;
    final double gap = NebaScale.gap[size]!;
    final NebaSize chipStep = NebaChip.step[size]!;
    // A row of chips stands a single row at the control's height: the chip
    // one step down the ladder, and half the difference above and below it.
    final double chipInset = math.max(
      0,
      (NebaScale.controlHeight[size]! - NebaScale.controlHeight[chipStep]!) / 2 - border,
    );

    Widget input(bool focused) {
      Widget editable = EditableText(
        key: _editableKey,
        controller: _controller,
        focusNode: _node,
        style: style,
        cursorColor: roles.accent,
        backgroundCursorColor: tokens.mutedFg,
        selectionColor: roles.softPress,
        readOnly: readOnly,
        autofocus: widget.autofocus,
        maxLines: 1,
        // The browser's list of past entries would open over the combobox's.
        autofillHints: null,
        autocorrect: false,
        enableSuggestions: false,
        // Enter is the list's; the field keeps the focus after it.
        onEditingComplete: () {},
        rendererIgnoresPointer: true,
        enableInteractiveSelection: selectionEnabled,
        selectionControls: null,
      );

      final String? placeholder = widget.placeholder;

      if (placeholder != null && _text.isEmpty) {
        final bool hidden = rests && !focused && empty;

        editable = Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end: hidden ? tokens.mutedFg.withValues(alpha: 0) : tokens.mutedFg,
                    ),
                    duration: nebaDuration(context, NebaScale.duration),
                    curve: NebaScale.ease,
                    builder: (BuildContext context, Color? color, Widget? _) {
                      return Text(
                        placeholder,
                        style: style.copyWith(color: color),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ),
            ),
            editable,
          ],
        );
      }

      if (lit) {
        editable = NebaFieldTypingMark(typing: _typing, child: editable);
      }

      return Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: _onKey,
        child: editable,
      );
    }

    // A chip's × is pressed, never tabbed to, as Base UI keeps it out of the
    // tab order; Backspace in the empty field takes the last chip out, and
    // the arrow keys reach the chips themselves from the caret's start.
    //
    // A [sample] is the copy the field is measured with, its words drawn as a
    // `RichText` so a test's `find.text` does not match them twice.
    final BorderRadius chipRadius = BorderRadius.circular(tokens.radius[NebaChip.step[size]!]!);

    Widget chip(T value, {bool sample = false}) {
      final String words = _labelOfValue(value);

      final Widget drawn = ExcludeFocus(
        child: NebaChip(
          variant: NebaVariant.outline,
          size: size,
          color: family,
          density: NebaDensity.compact,
          disabled: disabled,
          locale: locale,
          deleteLabel: _locked
              ? null
              : widget.removeLabel?.call(words) ??
                    fillNebaMessage(messages['remove']!, <String, String>{'label': words}),
          onDelete: _locked ? null : () => _remove(value),
          child: sample
              ? Builder(builder: (BuildContext context) => nebaSizerSample(context, Text(words)))
              : Text(words),
        ),
      );

      if (sample) {
        return KeyedSubtree(key: ValueKey<Object?>(value), child: drawn);
      }

      final FocusNode node = _chipNode(value);

      return Focus(
        key: ValueKey<Object?>(value),
        focusNode: node,
        canRequestFocus: !_locked,
        onKeyEvent: (FocusNode node, KeyEvent event) => _onChipKey(value, event),
        child: ListenableBuilder(
          listenable: node,
          builder: (BuildContext context, Widget? child) {
            return NebaFocusRing(
              visible: node.hasFocus,
              color: roles.ring,
              borderRadius: chipRadius,
              child: child!,
            );
          },
          child: drawn,
        ),
      );
    }

    if (multiple) {
      _pruneChipNodes(chosen);
    }

    Widget content(BuildContext context, bool focused) {
      final Widget field = multiple
          ? Semantics(
              container: true,
              explicitChildNodes: true,
              child: _ChipsLayout(
                textDirection: Directionality.of(context),
                gap: chosen.isEmpty ? 0 : 6,
                children: <Widget>[for (final T value in chosen) chip(value), input(focused)],
              ),
            )
          : input(focused);

      final String? labelWords = nebaPlainText(label);

      return Row(
        spacing: NebaScale.gap[size]!,
        children: <Widget>[
          if (startIcon != null)
            NebaFieldAdornment(size: size, focused: false, accent: roles.accent, child: startIcon),
          Expanded(child: field),
          if (clears && holds)
            _FieldButton(
              size: size,
              accent: roles.accent,
              disabled: disabled,
              label: widget.clearLabel ?? nebaMessages(context, 'action', locale: locale)['clear']!,
              onPressed: _clear,
              child: NebaGlyph(NebaGlyphs.close),
            ),
          _FieldButton(
            size: size,
            accent: roles.accent,
            disabled: disabled,
            label: labelWords ?? widget.openLabel ?? messages['open']!,
            onPressed: disabled ? null : _toggleFromChevron,
            child: NebaDisclosureChevron(open: open),
          ),
        ],
      );
    }

    Widget shell = NebaFieldShell(
      variant: variant,
      size: size,
      density: density,
      roles: roles,
      elevation: widget.elevation ?? 0,
      disabled: disabled,
      readOnly: readOnly,
      typing: lit ? _typing : null,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
      // The chevron brings room of its own, so the end keeps a narrow inset.
      padding: EdgeInsetsDirectional.fromSTEB(
        padX,
        multiple ? chipInset : 0,
        6,
        multiple ? chipInset : 0,
      ),
      notch: notched
          ? NebaFieldNotch(
              label: ExcludeSemantics(excluding: semantics.labelTaken, child: label),
              rests: rests,
              empty: empty,
              restEnd: restEnd,
            )
          : null,
      builder: content,
    );

    shell = disabled
        ? ExcludeFocus(child: shell)
        : TextFieldTapRegion(
            child: _gestures.buildGestureDetector(
              behavior: HitTestBehavior.translucent,
              child: shell,
            ),
          );

    final Widget field = NebaFloating(
      open: open,
      onOpenChange: (bool next, NebaFloatingReason reason) {
        if (reason == NebaFloatingReason.escape) {
          // The same key reaches the field next, and must not empty it too.
          _escapeClosed = true;
          scheduleMicrotask(() => _escapeClosed = false);
        }

        _setOpen(next);
      },
      side: NebaSide.bottom,
      sideOffset: 6,
      width: NebaFloatingWidth.anchor,
      maxHeight: nebaListMaxHeight,
      popup: TextFieldTapRegion(
        child: _buildList(
          context,
          entries: entries,
          size: size,
          roles: roles,
          messages: messages,
          name: semantics.label,
        ),
      ),
      child: shell,
    );

    return Semantics(
      container: true,
      label: semantics.label,
      hint: semantics.hint,
      enabled: !disabled,
      expanded: open,
      validationResult: invalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: disabled ? null : _requestFocus,
      child: NebaFieldWidth(
        width: 0,
        fullWidth: widget.fullWidth,
        sizer: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The field as wide as twenty characters of text after its chips,
            // with what stands before and after them, as an input sized by
            // its content is in a row that has not had to wrap yet.
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: padX + border + (startIcon == null ? 0 : text * 1.2 + gap),
                end: 6 + border + restEnd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: _chipSpacing,
                children: <Widget>[
                  if (multiple)
                    for (final T value in chosen) chip(value, sample: true),
                  SizedBox(width: 11 * text + (multiple && chosen.isNotEmpty ? 6 : 0)),
                ],
              ),
            ),
            if (notched)
              NebaNotchSizer(
                label: label,
                size: size,
                density: density,
                variant: variant,
                rests: rests,
                restEnd: restEnd,
              ),
          ],
        ),
        child: NebaFieldColumn(
          size: size,
          semantics: semantics,
          errorColor: roles.accent,
          disabled: disabled,
          label: notched ? null : label,
          description: widget.description,
          error: widget.error,
          onLabelTap: _requestFocus,
          field: field,
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context, {
    required List<_Entry<T>> entries,
    required NebaSize size,
    required NebaColorRoles roles,
    required Map<String, String> messages,
    required String? name,
  }) {
    final NebaTokens tokens = NebaTheme.of(context);
    final List<T> chosen = _chosen;
    final Widget child;

    if (entries.isEmpty) {
      child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: tokens.mutedFg),
          child: widget.emptyMessage ?? Text(messages['empty']!),
        ),
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < entries.length; i++) _row(entries[i], i, roles, messages, chosen),
        ],
      );
    }

    return NebaListSheet(size: size, roles: roles, semanticLabel: name, child: child);
  }

  Widget _row(
    _Entry<T> entry,
    int index,
    NebaColorRoles roles,
    Map<String, String> messages,
    List<T> chosen,
  ) {
    final bool selected = !entry.custom && chosen.contains(entry.option!.value);
    final Widget label;
    final String words;

    if (entry.custom) {
      final String fallback = fillNebaMessage(messages['add']!, <String, String>{
        'label': entry.label,
      });

      label = widget.customLabel?.call(entry.label) ?? Text(fallback);
      words = nebaPlainText(label) ?? fallback;
    } else {
      label = Text(entry.label);
      words = entry.label;
    }

    return NebaListRow(
      key: ValueKey<Object?>(entry.custom ? '\u0000custom' : entry.option!.value),
      roles: roles,
      highlighted: index == _highlight,
      reveal: _reveal,
      selected: selected,
      disabled: entry.disabled,
      indicator: entry.custom
          ? NebaGlyph(NebaGlyphs.plus, color: roles.accent)
          : selected
          ? NebaGlyph(NebaGlyphs.check)
          : null,
      semanticLabel: words,
      onHover: () {
        if (_highlight != index || _reveal) {
          setState(() {
            _highlight = index;
            _reveal = false;
          });
        }
      },
      onExit: () {
        if (_highlight == index && !_reveal) {
          setState(() => _highlight = null);
        }
      },
      onPressed: _locked ? null : () => _choose(entry),
      child: label,
    );
  }
}

/// The chevron and the ×, which sit in the field rather than in the list:
/// muted, in the field's accent under the pointer, and pressed without
/// taking the focus from the field, as Base UI's are kept out of the tab
/// order.
class _FieldButton extends StatefulWidget {
  const _FieldButton({
    required this.size,
    required this.accent,
    required this.disabled,
    required this.label,
    required this.onPressed,
    required this.child,
  });

  final NebaSize size;
  final Color accent;
  final bool disabled;
  final String label;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_FieldButton> createState() => _FieldButtonState();
}

class _FieldButtonState extends State<_FieldButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool enabled = !widget.disabled && widget.onPressed != null;
    final Color ink = widget.disabled
        ? tokens.disabledFg
        : _hovered && enabled
        ? widget.accent
        : tokens.mutedFg;
    final double text = NebaScale.controlText[widget.size]!;

    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? widget.onPressed : null,
      child: MouseRegion(
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (PointerEnterEvent _) => setState(() => _hovered = true),
        onExit: (PointerExitEvent _) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: enabled ? widget.onPressed : null,
          child: SizedBox(
            height: NebaScale.controlLeading[widget.size],
            child: Center(
              widthFactor: 1,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: ink),
                duration: nebaDuration(context, NebaScale.duration),
                curve: NebaScale.ease,
                builder: (BuildContext context, Color? color, Widget? child) {
                  return IconTheme.merge(
                    data: IconThemeData(color: color, size: text * 1.2),
                    child: child!,
                  );
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chips of a multiple combobox and the field after them, wrapping onto
/// further lines as CSS wraps a `flex-wrap` row: the chips at their own
/// width, four pixels apart, and the field taking the rest of the last line,
/// or a line of its own when less than [_inputMinWidth] is left. Each line is
/// as tall as its tallest child, and a child is centred on it.
class _ChipsLayout extends MultiChildRenderObjectWidget {
  const _ChipsLayout({required this.textDirection, required this.gap, required super.children});

  final TextDirection textDirection;

  /// The extra room between the last chip and the field, so the query does
  /// not read as another chip's label.
  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChipsLayout(textDirection: textDirection, gap: gap);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChipsLayout renderObject) {
    renderObject
      ..textDirection = textDirection
      ..gap = gap;
  }
}

/// The room between two chips, and between two lines of them: `gap-1`.
const double _chipSpacing = 4;

/// The narrowest the field after the chips gets before it takes a line of its
/// own: `min-w-16`.
const double _inputMinWidth = 64;

class _ChipsParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderChipsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ChipsParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ChipsParentData> {
  _RenderChipsLayout({required TextDirection textDirection, required double gap})
    : _textDirection = textDirection,
      _gap = gap;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value != _textDirection) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  double _gap;
  set gap(double value) {
    if (value != _gap) {
      _gap = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ChipsParentData) {
      child.parentData = _ChipsParentData();
    }
  }

  /// Lays the children out in [width], with [sizeOf] giving each one's size
  /// for the constraints it is offered, and says where each goes and how
  /// tall the whole is.
  ({List<Offset> offsets, double height}) _arrange(
    double width,
    Size Function(RenderBox child, BoxConstraints constraints) sizeOf,
  ) {
    final List<RenderBox> children = getChildrenAsList();
    final List<Size> sizes = <Size>[];
    final List<double> xs = <double>[];
    final List<int> lines = <int>[];
    final List<double> heights = <double>[0];
    double x = 0;
    int line = 0;

    for (int i = 0; i < children.length; i++) {
      final RenderBox child = children[i];
      final bool last = i == children.length - 1;
      final bool lineEmpty = x == 0;

      if (last) {
        final double lead = lineEmpty ? 0 : _gap;
        double room = width - x - lead;

        if (room < _inputMinWidth && !lineEmpty) {
          line++;
          heights.add(0);
          x = 0;
          room = width;
        }

        final double start = x == 0 ? 0 : x + lead;
        final Size size = sizeOf(child, BoxConstraints.tightFor(width: math.max(0, width - start)));

        sizes.add(size);
        xs.add(start);
        lines.add(line);
        heights[line] = math.max(heights[line], size.height);
        continue;
      }

      final Size size = sizeOf(child, BoxConstraints(maxWidth: width));

      if (!lineEmpty && x + size.width > width) {
        line++;
        heights.add(0);
        x = 0;
      }

      sizes.add(size);
      xs.add(x);
      lines.add(line);
      heights[line] = math.max(heights[line], size.height);
      x += size.width + _chipSpacing;
    }

    final List<double> tops = <double>[];
    double top = 0;

    for (final double height in heights) {
      tops.add(top);
      top += height + _chipSpacing;
    }

    final double height = heights.isEmpty ? 0 : top - _chipSpacing;
    final List<Offset> offsets = <Offset>[
      for (int i = 0; i < sizes.length; i++)
        Offset(
          _textDirection == TextDirection.ltr ? xs[i] : width - xs[i] - sizes[i].width,
          tops[lines[i]] + (heights[lines[i]] - sizes[i].height) / 2,
        ),
    ];

    return (offsets: offsets, height: height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double widest = _inputMinWidth;
    RenderBox? child = firstChild;

    while (child != null && child != lastChild) {
      widest = math.max(widest, child.getMinIntrinsicWidth(double.infinity));
      child = childAfter(child);
    }

    return widest;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double total = 0;
    RenderBox? child = firstChild;

    while (child != null && child != lastChild) {
      total += child.getMaxIntrinsicWidth(double.infinity) + _chipSpacing;
      child = childAfter(child);
    }

    return total + (firstChild == lastChild ? 0 : _gap - _chipSpacing) + _inputMinWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _arrange(width, (RenderBox child, BoxConstraints constraints) {
      return child.getDryLayout(constraints);
    }).height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : computeMaxIntrinsicWidth(double.infinity);
    final double height = _arrange(width, (RenderBox child, BoxConstraints constraints) {
      return child.getDryLayout(constraints);
    }).height;

    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    final double width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : computeMaxIntrinsicWidth(double.infinity);
    final ({List<Offset> offsets, double height}) arranged = _arrange(width, (
      RenderBox child,
      BoxConstraints constraints,
    ) {
      child.layout(constraints, parentUsesSize: true);

      return child.size;
    });

    RenderBox? child = firstChild;
    int i = 0;

    while (child != null) {
      (child.parentData! as _ChipsParentData).offset = arranged.offsets[i];
      child = childAfter(child);
      i++;
    }

    size = constraints.constrain(Size(width, arranged.height));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
