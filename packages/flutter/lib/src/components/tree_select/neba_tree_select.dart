/// `NebaTreeSelect`, a value chosen from a tree rather than from a list.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/tree_view/neba_tree_view.dart';
import 'package:neba/src/internal/calendar.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/fieldset.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/picker.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/sizer.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One node of the tree a [NebaTreeSelect] chooses from.
@immutable
class NebaTreeSelectItem<T> {
  /// A node standing for [value], holding [children].
  const NebaTreeSelectItem({
    required this.value,
    this.label,
    this.searchLabel,
    this.startIcon,
    this.disabled = false,
    this.selectable,
    this.children = const <Never>[],
  });

  /// What is held when this node is chosen. Unique across the whole tree,
  /// not only among its siblings: it is what a node is looked up by.
  final T value;

  /// What the row and the trigger show, usually a [Text]. Defaults to the
  /// value's own text.
  final Widget? label;

  /// What a search matches against. Falls back to the [label]'s words when
  /// it is a `Text`, then to the value's text.
  final String? searchLabel;

  /// A glyph before the label.
  final Widget? startIcon;

  /// Listed, but not available to choose.
  final bool disabled;

  /// Whether this node may itself be chosen. `false` makes it a heading
  /// with children under it, a "Europe" that groups countries without being
  /// one. Defaults to `true` for a leaf and to the tree select's
  /// `selectableBranches` for a node with children.
  final bool? selectable;

  /// The nodes under this one.
  final List<NebaTreeSelectItem<T>> children;
}

/// A value chosen from a tree rather than from a list, generic over the type
/// of the values.
///
/// The gap between a `NebaSelect`, a flat list behind a field, and a
/// `NebaTreeView`, a hierarchy with no field: a category, a folder, an org
/// chart node and a region are all chosen from a shape a flat list flattens
/// away. The trigger is a field's shell that writes what is held, and it
/// opens a `NebaTreeView` under it on a press, Enter or Space; the tree takes
/// the focus, or the search field above it does when [searchable]. Escape, a
/// press outside and, unless [multiple], the choice itself close it and give
/// the focus back.
///
/// A branch is a heading by default, which opens and shuts without being
/// chosen, because in most of these trees the branches are the taxonomy and
/// the leaves are the answers; [selectableBranches] and an item's own
/// `selectable` say otherwise. The value is a list whether or not the tree
/// select is [multiple].
///
/// ```dart
/// NebaTreeSelect<String>(
///   label: const Text('Category'),
///   placeholder: const Text('Pick a category'),
///   items: const <NebaTreeSelectItem<String>>[
///     NebaTreeSelectItem<String>(
///       value: 'hardware',
///       label: Text('Hardware'),
///       children: <NebaTreeSelectItem<String>>[
///         NebaTreeSelectItem<String>(value: 'laptops', label: Text('Laptops')),
///       ],
///     ),
///   ],
/// )
/// ```
class NebaTreeSelect<T> extends StatefulWidget {
  /// A tree select over [items].
  const NebaTreeSelect({
    this.items = const <Never>[],
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.multiple = false,
    this.selectableBranches = false,
    this.expanded,
    this.defaultExpanded,
    this.onExpandedChange,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placeholder,
    this.clearable = false,
    this.clearLabel,
    this.closeOnSelect,
    this.searchable = false,
    this.searchPlaceholder,
    this.locale,
    this.format,
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
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The tree, as nested items.
  final List<NebaTreeSelectItem<T>> items;

  /// The values held, for a controlled tree select: a list even when only
  /// one may be held, and empty for none. Leave it `null` and the tree select
  /// keeps its own state, starting from [defaultValue].
  final List<T>? value;

  /// What starts held, for an uncontrolled tree select.
  final List<T>? defaultValue;

  /// Called with the values held after a node is chosen or the value is
  /// cleared.
  final ValueChanged<List<T>>? onValueChange;

  /// Whether more than one node may be held.
  final bool multiple;

  /// Whether a node that has children may itself be chosen. An item's own
  /// `selectable` overrides it either way.
  final bool selectableBranches;

  /// Which branches are open, by their values, for a controlled tree.
  final List<T>? expanded;

  /// Which branches start open.
  final List<T>? defaultExpanded;

  /// Called with the values of the open branches after one opens or shuts.
  final ValueChanged<List<T>>? onExpandedChange;

  /// Whether the popup is open. With [onOpenChange] the caller owns the
  /// state; without it the tree select keeps its own.
  final bool? open;

  /// Whether a tree select that keeps its own state starts open.
  final bool defaultOpen;

  /// Called whenever the popup opens or closes.
  final ValueChanged<bool>? onOpenChange;

  /// What the trigger shows while nothing is held, usually a [Text], muted
  /// as a field's placeholder is.
  final Widget? placeholder;

  /// Offers the × that empties the control.
  final bool clearable;

  /// What a screen reader names the ×. Defaults to the [locale]'s "Clear".
  final String? clearLabel;

  /// Whether the popup closes as soon as a node is chosen. Defaults to
  /// whether only one may be held.
  final bool? closeOnSelect;

  /// Offers a field above the tree that filters it. A match keeps its
  /// ancestors, and every branch the filter kept is open, so a match is
  /// never cut off from its place or folded out of sight.
  final bool searchable;

  /// The search field's placeholder, and its name for a screen reader.
  /// Defaults to the [locale]'s word for searching.
  final String? searchPlaceholder;

  /// Which language the words this draws on its own behalf are in. Defaults
  /// to `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// How the trigger writes what is held. Defaults to the labels,
  /// comma-joined.
  final Widget Function(List<NebaTreeSelectItem<T>> chosen)? format;

  /// The control's name, usually a [Text]. A screen reader hears it as the
  /// trigger's name.
  final Widget? label;

  /// Where [label] is drawn: above the trigger, in a notch cut into its top
  /// edge, or inside it while nothing is held, the trigger does not hold the
  /// focus and the popup is closed. A [startIcon] keeps a `float` label in
  /// the notch. Defaults to `NebaProvider`'s, then [NebaLabelPlacement.top].
  final NebaLabelPlacement? labelPlacement;

  /// Helper text under the trigger, usually a [Text].
  final Widget? description;

  /// An error under the trigger, usually a [Text]. Giving one turns the
  /// control invalid.
  final Widget? error;

  /// Whether the control is invalid, for when something else owns the
  /// validity. Defaults to whether there is an [error].
  final bool? invalid;

  /// Before the value, drawn at 1.2 times its size and muted.
  final Widget? startIcon;

  /// The weight of the trigger's sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The height floor, the type scale and the tree's rows. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The colour family of the edge, the ring and the tree's tint. Defaults
  /// to [NebaColor.primary]; an invalid control is [NebaColor.danger].
  final NebaColor? color;

  /// The trigger's inline padding, and nothing else. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The trigger's drop shadow, from `0`, which is none, to `3`. The popup
  /// has its own, fixed at `3`: it floats above the page.
  final NebaElevation? elevation;

  /// Stretches to the width it is given. Otherwise the trigger is as wide as
  /// what it is writing.
  final bool fullWidth;

  /// Grey, out of the focus order, and closed.
  final bool disabled;

  /// Shows what it holds and does not open: what it holds is something to
  /// read. The trigger keeps the focus and goes flat.
  final bool readOnly;

  /// What a screen reader names the trigger, in place of [label].
  final String? semanticLabel;

  /// The trigger's focus node, when the caller drives the focus.
  final FocusNode? focusNode;

  /// Whether the trigger takes the focus when it is first built.
  final bool autofocus;

  @override
  State<NebaTreeSelect<T>> createState() => _NebaTreeSelectState<T>();
}

/// The width of what the popup holds, and the tallest it gets: `w-64`,
/// `max-h-80`.
const double _panelWidth = 256;
const double _panelHeight = 320;

/// Between the search field and the tree: `gap-2`.
const double _panelGap = 8;

class _NebaTreeSelectState<T> extends State<NebaTreeSelect<T>> {
  /// Its own `disabled`, or a disabled `NebaFieldset` around it.
  bool get _disabled => nebaFieldsetDisabled(context, widget.disabled);

  final TextEditingController _search = TextEditingController();
  FocusNode? _ownNode;
  late List<T> _held = <T>[...?widget.defaultValue];
  late bool _open = widget.defaultOpen;
  late List<T> _expandedOwn = <T>[...?widget.defaultExpanded];
  // What is typed at the search field.
  String _query = '';
  // Whether the pointer went down on the ×, so the shell under it does not
  // open the popup on the same press.

  // What the tree is worked out from, kept while nothing it depends on
  // changes, so a keystroke at the search field folds the tree's labels
  // once rather than once per node per character.
  List<NebaTreeSelectItem<T>>? _indexed;
  Map<T, NebaTreeSelectItem<T>> _byValue = <T, NebaTreeSelectItem<T>>{};
  Map<NebaTreeSelectItem<T>, String> _haystacks = Map<NebaTreeSelectItem<T>, String>.identity();
  String? _filteredFor;
  List<NebaTreeSelectItem<T>> _shown = <NebaTreeSelectItem<T>>[];
  List<NebaTreeItem<T>>? _rows;
  bool? _rowsBranches;

  FocusNode get _triggerNode {
    return widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'NebaTreeSelect'));
  }

  List<T> get _current => widget.value ?? _held;

  bool get _isOpen => widget.open ?? _open;

  bool get _inert => _disabled || widget.readOnly;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearch);
    _search.dispose();
    _ownNode?.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_search.text != _query) {
      setState(() => _query = _search.text);
    }
  }

  // ----- What the tree holds -----------------------------------------------

  void _index() {
    final List<NebaTreeSelectItem<T>> items = widget.items;

    if (identical(items, _indexed)) {
      return;
    }

    final Map<T, NebaTreeSelectItem<T>> byValue = <T, NebaTreeSelectItem<T>>{};
    final Map<NebaTreeSelectItem<T>, String> haystacks =
        Map<NebaTreeSelectItem<T>, String>.identity();

    void walk(List<NebaTreeSelectItem<T>> list) {
      for (final NebaTreeSelectItem<T> item in list) {
        byValue[item.value] = item;
        haystacks[item] = nebaSearchText(
          item.searchLabel ?? nebaPlainText(item.label) ?? '${item.value}',
        );
        walk(item.children);
      }
    }

    walk(items);
    _indexed = items;
    _byValue = byValue;
    _haystacks = haystacks;
    _filteredFor = null;
  }

  /// Keeps the nodes that match and every ancestor of one, since a node with
  /// its parents cut away is a node the reader cannot place.
  List<NebaTreeSelectItem<T>> _filter(List<NebaTreeSelectItem<T>> items, String needle) {
    if (needle.isEmpty) {
      return items;
    }

    final List<NebaTreeSelectItem<T>> kept = <NebaTreeSelectItem<T>>[];

    for (final NebaTreeSelectItem<T> item in items) {
      final List<NebaTreeSelectItem<T>> children = _filter(item.children, needle);
      final bool hit = (_haystacks[item] ?? '').contains(needle);

      if (hit) {
        kept.add(item);
      } else if (children.isNotEmpty) {
        kept.add(
          NebaTreeSelectItem<T>(
            value: item.value,
            label: item.label,
            searchLabel: item.searchLabel,
            startIcon: item.startIcon,
            disabled: item.disabled,
            selectable: item.selectable,
            children: children,
          ),
        );
      }
    }

    return kept;
  }

  List<T> _branchValues(List<NebaTreeSelectItem<T>> items) {
    return <T>[
      for (final NebaTreeSelectItem<T> item in items)
        if (item.children.isNotEmpty) ...<T>[item.value, ..._branchValues(item.children)],
    ];
  }

  bool _selectable(NebaTreeSelectItem<T> item) {
    return item.selectable ?? (item.children.isNotEmpty ? widget.selectableBranches : true);
  }

  Widget _labelOf(NebaTreeSelectItem<T> item) => item.label ?? Text('${item.value}');

  String _wordsOf(NebaTreeSelectItem<T> item) => nebaPlainText(item.label) ?? '${item.value}';

  List<NebaTreeItem<T>> _rowsOf(List<NebaTreeSelectItem<T>> items) {
    return <NebaTreeItem<T>>[
      for (final NebaTreeSelectItem<T> item in items)
        NebaTreeItem<T>(
          value: item.value,
          label: _labelOf(item),
          startIcon: item.startIcon,
          disabled: item.disabled,
          selectable: _selectable(item),
          children: _rowsOf(item.children),
        ),
    ];
  }

  // ----- Changing it -------------------------------------------------------

  void _setOpen(bool open) {
    // A read-only tree select does not open: what it holds is something to
    // read.
    if (open == _isOpen || (open && _inert)) {
      return;
    }

    setState(() {
      if (widget.open == null) {
        _open = open;
      }
    });

    if (!open) {
      _search.clear();
    }

    widget.onOpenChange?.call(open);
  }

  void _commit(List<T> next) {
    if (widget.value == null) {
      setState(() => _held = next);
    }

    widget.onValueChange?.call(next);
  }

  void _onSelectedChange(List<T> next) {
    // A branch that cannot be chosen still opens and shuts, so what comes
    // back is filtered rather than trusted.
    final List<T> allowed = <T>[
      for (final T entry in next)
        if (_byValue[entry] case final NebaTreeSelectItem<T> item
            when _selectable(item) && !item.disabled)
          entry,
    ];

    _commit(widget.multiple ? allowed : <T>[if (allowed.isNotEmpty) allowed.last]);

    if (widget.closeOnSelect ?? !widget.multiple) {
      _setOpen(false);
    }
  }

  void _onExpandedChange(List<T> next) {
    if (widget.expanded == null) {
      setState(() => _expandedOwn = next);
    }

    widget.onExpandedChange?.call(next);
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
    final bool disabled = _disabled;
    final bool invalid = widget.invalid ?? widget.error != null;
    final NebaColor family = invalid ? NebaColor.danger : widget.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(family);

    _index();

    final List<NebaTreeSelectItem<T>> chosen = <NebaTreeSelectItem<T>>[
      for (final T entry in _current) ?_byValue[entry],
    ];
    final bool empty = chosen.isEmpty;
    final Widget? label = widget.label;
    final Widget? placeholder = widget.placeholder;
    final Widget? startIcon = widget.startIcon;
    final String? words = empty ? null : chosen.map(_wordsOf).join(', ');
    final String clearLabel =
        widget.clearLabel ?? nebaMessages(context, 'action', locale: locale)['clear']!;

    // What the trigger writes, and the same thing as the sizer lays it out.
    Widget? written;
    Widget? measured;

    if (!empty) {
      final Widget Function(List<NebaTreeSelectItem<T>> chosen)? format = widget.format;

      if (format != null) {
        written = format(chosen);
        measured = written;
      } else if (chosen.every(
        (NebaTreeSelectItem<T> item) => item.label == null || item.label is Text,
      )) {
        written = Text(words!);
        measured = written;
      } else {
        final List<Widget> parts = <Widget>[
          for (int i = 0; i < chosen.length; i++) ...<Widget>[
            if (i > 0) const Text(', '),
            _labelOf(chosen[i]),
          ],
        ];

        written = Text.rich(
          TextSpan(
            children: <InlineSpan>[
              for (final Widget part in parts)
                WidgetSpan(alignment: PlaceholderAlignment.middle, child: part),
            ],
          ),
        );
        measured = Row(mainAxisSize: MainAxisSize.min, children: parts);
      }
    }

    // The picker shell every picker wears. A label of the caller's own, or a
    // format, is drawn as it is and measured as it is.
    final bool plain = widget.format == null && (written == null || written is Text);

    return NebaPickerField(
      variant: variant,
      size: size,
      color: widget.color ?? NebaColor.primary,
      density: density,
      elevation: widget.elevation ?? 0,
      value: (plain ? null : nebaPlainText(written)) ?? words,
      samples: <String>[?words],
      placeholder: placeholder,
      display: switch (written) {
        final Widget shown when !plain => DefaultTextStyle.merge(
          style: TextStyle(color: tokens.fg),
          child: shown,
        ),
        _ => null,
      },
      // Measured as a sizer measures, so the words are not drawn twice for
      // a reader or a test to find.
      sizer: switch (measured) {
        final Widget sample when !plain => NebaWidthSizer(
          style: TextStyle(fontSize: NebaScale.controlText[size]),
          samples: <Widget>[sample, ?placeholder],
        ),
        _ => null,
      },
      startIcon: startIcon,
      label: label,
      labelPlacement: placement,
      description: widget.description,
      error: widget.error,
      invalid: widget.invalid,
      clearable: widget.clearable,
      clearLabel: clearLabel,
      onClear: () => _commit(<T>[]),
      open: _isOpen,
      onOpenChange: _setOpen,
      maxHeight: _panelHeight + 2 * nebaPickerPadding[size]! + 2,
      popup: _buildPanel(context, size: size, roles: roles, family: family, locale: locale),
      fullWidth: widget.fullWidth,
      disabled: disabled,
      readOnly: widget.readOnly,
      semanticLabel: widget.semanticLabel,
      focusNode: _triggerNode,
      autofocus: widget.autofocus,
    );
  }

  Widget _buildPanel(
    BuildContext context, {
    required NebaSize size,
    required NebaColorRoles roles,
    required NebaColor family,
    required Locale? locale,
  }) {
    final NebaTokens tokens = NebaTheme.of(context);
    final double text = NebaScale.controlText[size]!;
    final String needle = nebaSearchText(_query);

    if (_filteredFor != needle) {
      _shown = _filter(widget.items, needle);
      _filteredFor = needle;
      _rows = null;
    }

    if (_rows == null || _rowsBranches != widget.selectableBranches) {
      _rows = _rowsOf(_shown);
      _rowsBranches = widget.selectableBranches;
    }

    // A search opens every branch it kept: a match folded inside a closed
    // parent is a match the reader was not shown.
    final bool searching = needle.isNotEmpty;
    final List<T> expanded = searching ? _branchValues(_shown) : widget.expanded ?? _expandedOwn;
    final String searchWords =
        widget.searchPlaceholder ?? nebaMessages(context, 'command', locale: locale)['search']!;

    final Widget tree = _shown.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg),
              child: Text(nebaMessages(context, 'combobox', locale: locale)['empty']!),
            ),
          )
        : NebaTreeView<T>(
            size: size,
            color: family,
            multiple: widget.multiple,
            selected: _current,
            onSelectedChange: _onSelectedChange,
            expanded: expanded,
            onExpandedChange: searching ? (List<T> _) {} : _onExpandedChange,
            children: _rows!,
          );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: text,
          height: NebaScale.controlLeading[size]! / text,
          leadingDistribution: TextLeadingDistribution.even,
          color: tokens.fg,
        ),
        child: SizedBox(
          width: _panelWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _panelHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _panelGap,
              children: <Widget>[
                if (widget.searchable)
                  _SearchField(
                    controller: _search,
                    roles: roles,
                    size: size,
                    placeholder: searchWords,
                  ),
                Flexible(child: SingleChildScrollView(child: tree)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The field above the tree that filters it: a bare line of text with its
/// placeholder, named by it for a screen reader.
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.roles,
    required this.size,
    required this.placeholder,
  });

  final TextEditingController controller;
  final NebaColorRoles roles;
  final NebaSize size;
  final String placeholder;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  final FocusNode _node = FocusNode(debugLabel: 'NebaTreeSelect search');
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(_SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _node.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Semantics(
      container: true,
      label: widget.placeholder,
      child: _gestures.wrap(
        Padding(
          padding: const EdgeInsets.all(4),
          child: NebaFieldEditable(
            editableKey: _editableKey,
            controller: widget.controller,
            focusNode: _node,
            style: nebaFieldTextStyle(context, tokens: tokens, size: widget.size, disabled: false),
            roles: widget.roles,
            empty: widget.controller.text.isEmpty,
            autofillHints: null,
            suggestions: false,
            placeholder: widget.placeholder,
          ),
        ),
        disabled: false,
      ),
    );
  }
}
