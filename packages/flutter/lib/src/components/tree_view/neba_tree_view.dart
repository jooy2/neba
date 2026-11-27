/// `NebaTreeView` and `NebaTreeItem`, rows that belong to one another, folded
/// open and shut.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/disclosure.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/ink.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/link.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How a [NebaTreeView] draws the hierarchy between its rows.
enum NebaTreeViewLines {
  /// Indentation alone: the quietest, and usually right for a navigation
  /// sidebar two levels deep whose labels say what the structure is.
  none,

  /// One hairline rail per level, running the full height of the group.
  simple,

  /// The rail, an elbow into every row, and the rail under a last child
  /// stopped at that row: the file manager's drawing, for a deep tree.
  folder,
}

/// One row of a [NebaTreeView], and the rows under it.
///
/// A description rather than a widget: the tree draws every row itself,
/// because which rows are showing, which one the keys walk to next and which
/// one is a row's parent are questions about the whole tree.
@immutable
class NebaTreeItem<T> {
  /// A row labelled [label], holding [children].
  const NebaTreeItem({
    this.value,
    this.label,
    this.startIcon,
    this.endIcon,
    this.action,
    this.href,
    this.onPressed,
    this.expandable,
    this.disabled = false,
    this.selectable = true,
    this.children = const <Never>[],
  });

  /// What names the row to the tree's `expanded` and `selected`. Left out,
  /// the tree names it by its place, which is fine for a tree nobody drives
  /// from code; such a row opens, shuts and is chosen, and is left out of the
  /// lists the tree reports.
  final T? value;

  /// The row's text, usually a [Text]. One line, cut short with an ellipsis.
  /// A `Text` is also what typing a letter matches; any other widget is
  /// matched by the value's text.
  final Widget? label;

  /// Before the label, muted: a folder glyph, a file type, a status dot.
  final Widget? startIcon;

  /// After the label, inside the pressable area, muted: a count, a badge.
  final Widget? endIcon;

  /// A control pinned to the end of the row, outside the pressable area, so
  /// pressing it never presses the row.
  final Widget? action;

  /// Where the row leads, for a screen reader and, on the web, the browser.
  /// It makes the row a link; following it is [onPressed]'s. A scheme other
  /// than `http`, `https`, `mailto` or `tel` is not written.
  final Uri? href;

  /// Called when the row is pressed, before it opens or is chosen.
  final VoidCallback? onPressed;

  /// Draws the disclosure arrow on a row with no [children] yet: the branch
  /// that is fetched the first time it is opened. Defaults to whether there
  /// are children.
  final bool? expandable;

  /// Unavailable: the row stops answering, and its branch, if it is open,
  /// keeps working.
  final bool disabled;

  /// Whether pressing the row chooses it. A row that cannot be chosen still
  /// opens and shuts: the folder in a tree whose answers are the files.
  final bool selectable;

  /// The rows underneath this one.
  final List<NebaTreeItem<T>> children;

  /// Whether the row opens and shuts.
  bool get isBranch => expandable ?? children.isNotEmpty;
}

/// Rows that belong to one another, folded open and shut, generic over the
/// type of the rows' values.
///
/// The whole tree is one stop in the focus order. Inside it, the up and down
/// arrows walk the rows that are showing, the forward arrow opens a shut
/// branch and steps into an open one, the back arrow shuts a branch and
/// climbs out of a leaf, Home and End jump to the ends, and a typed letter
/// moves to the next row whose label starts with it. Enter and Space press
/// the row in hand, which chooses it and opens or shuts its branch, as a
/// press with the pointer does; the arrows never change what is chosen. The
/// disclosure arrow is a target of its own, which opens and shuts the branch
/// without choosing the row.
///
/// A branch opens to its rows' height and shuts to none, by layout and never
/// by a transform. Which branches are open is controlled with [expanded] and
/// [onExpandedChange], or kept from [defaultExpanded]; which rows are chosen
/// with [selected] and [onSelectedChange], or kept from [defaultSelected].
/// Both are lists whether or not the tree is [multiple].
///
/// It fills the width it is given.
///
/// ```dart
/// NebaTreeView<String>(
///   label: 'Project files',
///   lines: NebaTreeViewLines.folder,
///   defaultExpanded: const <String>['src'],
///   children: const <NebaTreeItem<String>>[
///     NebaTreeItem<String>(
///       value: 'src',
///       label: Text('src'),
///       children: <NebaTreeItem<String>>[
///         NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
///       ],
///     ),
///     NebaTreeItem<String>(value: 'readme', label: Text('README.md')),
///   ],
/// )
/// ```
class NebaTreeView<T> extends StatefulWidget {
  /// A tree of [children].
  const NebaTreeView({
    required this.children,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.lines = NebaTreeViewLines.simple,
    this.expanded,
    this.defaultExpanded,
    this.onExpandedChange,
    this.selected,
    this.defaultSelected,
    this.onSelectedChange,
    this.multiple = false,
    this.disabled = false,
    this.label,
    this.keepMounted = false,
    super.key,
  }) : assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The top-level rows.
  final List<NebaTreeItem<T>> children;

  /// The sheet's weight: `solid` a brighter sheet, `outline` a frosted one
  /// with a hairline, `text` none, for a tree in a sidebar that already has a
  /// surface. The sheet is never dyed. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The row height, the type, the sheet's corners and how far one level is
  /// set in. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the hairline, the hover wash, a chosen row's tint and the
  /// focus ring. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// A row's inline padding, and nothing else: never the row height, never
  /// the indentation. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0`, the default, to `3`.
  final NebaElevation? elevation;

  /// How the hierarchy is drawn between the rows.
  final NebaTreeViewLines lines;

  /// Which branches are open, by their rows' values, for a controlled tree.
  /// Leave it `null` and the tree keeps its own state, starting from
  /// [defaultExpanded].
  final List<T>? expanded;

  /// Which branches start open, for an uncontrolled tree.
  final List<T>? defaultExpanded;

  /// Called with the values of the open branches after one opens or shuts.
  final ValueChanged<List<T>>? onExpandedChange;

  /// Which rows are chosen, by their values, for a controlled tree. A list
  /// even when only one row may be chosen. Leave it `null` and the tree keeps
  /// its own state, starting from [defaultSelected].
  final List<T>? selected;

  /// Which rows start chosen, for an uncontrolled tree.
  final List<T>? defaultSelected;

  /// Called with the values of the chosen rows after a row is chosen.
  final ValueChanged<List<T>>? onSelectedChange;

  /// Whether more than one row may be chosen at a time. Off, choosing a row
  /// replaces the one chosen before, and pressing the chosen row again keeps
  /// it; on, a press adds a row or takes it away again.
  final bool multiple;

  /// Unavailable: every row stops answering.
  final bool disabled;

  /// The name a screen reader announces the tree by.
  final String? label;

  /// Whether a shut branch keeps its rows built, so their state survives
  /// being folded away. They stay out of the focus order, the rows the arrow
  /// keys walk and what a screen reader hears while it is shut.
  final bool keepMounted;

  @override
  State<NebaTreeView<T>> createState() => _NebaTreeViewState<T>();
}

/// How far one level is set in from the one above it: the width of the
/// column a rail is drawn down.
const Map<NebaSize, double> _indent = <NebaSize, double>{
  NebaSize.xs: 14,
  NebaSize.sm: 16,
  NebaSize.md: 20,
  NebaSize.lg: 24,
  NebaSize.xl: 28,
};

/// A row's inline padding: its own ladder, because a tree row is one line in
/// a column of dozens and a box's padding would push every label a level
/// further in than the indentation put it.
const Map<NebaDensity, Map<NebaSize, double>> _rowPaddingX = <NebaDensity, Map<NebaSize, double>>{
  NebaDensity.standard: <NebaSize, double>{
    NebaSize.xs: 6,
    NebaSize.sm: 8,
    NebaSize.md: 10,
    NebaSize.lg: 12,
    NebaSize.xl: 14,
  },
  NebaDensity.compact: <NebaSize, double>{
    NebaSize.xs: 4,
    NebaSize.sm: 4,
    NebaSize.md: 6,
    NebaSize.lg: 8,
    NebaSize.xl: 10,
  },
};

/// The corner of the tint under a row: about a quarter of the row's height,
/// which on a row one line tall is the same cut a field's corner is.
const Map<NebaSize, double> _rowRadius = <NebaSize, double>{
  NebaSize.xs: 5,
  NebaSize.sm: 6,
  NebaSize.md: 8,
  NebaSize.lg: 10,
  NebaSize.xl: 12,
};

/// What names a row with no value: its place in the tree, as the indices
/// down to it.
@immutable
class _Place {
  const _Place(this.path);

  final String path;

  @override
  bool operator ==(Object other) => other is _Place && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

/// A row as the keys walk it: what it is, what names it, and the row it is
/// under.
class _Shown<T> {
  const _Shown(this.item, this.key, this.parent);

  final NebaTreeItem<T> item;
  final Object key;
  final _Shown<T>? parent;
}

Object _keyOf<T>(NebaTreeItem<T> item, String path) => item.value ?? _Place(path);

String _childPath(String path, int index) => path.isEmpty ? '$index' : '$path/$index';

class _NebaTreeViewState<T> extends State<NebaTreeView<T>> {
  /// What is open and what is chosen in an uncontrolled tree, by the rows'
  /// values and the places of the rows that have none.
  late Set<Object?> _open = <Object?>{...?widget.defaultExpanded};
  late Set<Object?> _chosen = <Object?>{...?widget.defaultSelected};

  /// The row the reader last moved to or pressed, which holds the tree's one
  /// stop in the focus order while it is showing.
  Object? _active;

  /// The focus node of every row that is built, by the row's key.
  final Map<Object, FocusNode> _nodes = <Object, FocusNode>{};

  Set<Object?> get _expanded {
    final List<T>? expanded = widget.expanded;

    return expanded == null ? _open : <Object?>{...expanded};
  }

  Set<Object?> get _selected {
    final List<T>? selected = widget.selected;

    return selected == null ? _chosen : <Object?>{...selected};
  }

  List<T> _reported(Set<Object?> keys) {
    return <T>[
      for (final Object? key in keys)
        if (key is! _Place) key as T,
    ];
  }

  /// Every row that is showing, in reading order.
  List<_Shown<T>> _shownRows() {
    final Set<Object?> open = _expanded;
    final List<_Shown<T>> rows = <_Shown<T>>[];

    void walk(List<NebaTreeItem<T>> items, String path, _Shown<T>? parent) {
      for (int i = 0; i < items.length; i++) {
        final NebaTreeItem<T> item = items[i];
        final String place = _childPath(path, i);
        final _Shown<T> row = _Shown<T>(item, _keyOf(item, place), parent);

        rows.add(row);

        if (item.isBranch && open.contains(row.key)) {
          walk(item.children, place, row);
        }
      }
    }

    walk(widget.children, '', null);

    return rows;
  }

  /// Where the tree's stop in the focus order is: the row last moved to while
  /// it is showing, the first row of a tree nobody has touched, and otherwise
  /// the chosen row if one is showing or the first row.
  Object? _stopOf(List<_Shown<T>> rows) {
    if (rows.isEmpty) {
      return null;
    }

    final Object? active = _active;

    if (active != null && rows.any((_Shown<T> row) => row.key == active)) {
      return active;
    }

    final Set<Object?> selected = _selected;

    if (active == null && selected.isEmpty) {
      return rows.first.key;
    }

    _Shown<T> stop = rows.first;

    for (final _Shown<T> row in rows) {
      if (selected.contains(row.key)) {
        stop = row;
        break;
      }
    }

    // Kept, so a branch opening later does not move it again.
    _active = stop.key;

    return stop.key;
  }

  void _register(Object key, FocusNode node) => _nodes[key] = node;

  void _unregister(Object key, FocusNode node) {
    if (_nodes[key] == node) {
      _nodes.remove(key);
    }
  }

  bool _disabled(NebaTreeItem<T> item) => item.disabled || widget.disabled;

  void _toggle(Object key, NebaTreeItem<T> item) {
    if (_disabled(item) || !item.isBranch) {
      return;
    }

    final Set<Object?> current = _expanded;
    final Set<Object?> next = current.contains(key)
        ? (<Object?>{...current}..remove(key))
        : <Object?>{...current, key};

    if (widget.expanded == null) {
      setState(() => _open = next);
    }

    widget.onExpandedChange?.call(_reported(next));
  }

  void _select(Object key) {
    final Set<Object?> current = _selected;
    // Choosing one row never empties the tree: "nothing chosen" is a state a
    // reader cannot get back to by pointing at a row. Choosing several does
    // take a row away again, which is what it is for.
    final Set<Object?> next = widget.multiple
        ? current.contains(key)
              ? (<Object?>{...current}..remove(key))
              : <Object?>{...current, key}
        : <Object?>{key};

    if (widget.selected == null) {
      setState(() => _chosen = next);
    }

    widget.onSelectedChange?.call(_reported(next));
  }

  void _activate(Object key) {
    if (_active != key) {
      setState(() => _active = key);
    }

    _nodes[key]?.requestFocus();
  }

  /// A press on the row, with the pointer, Enter or Space.
  void _press(Object key, NebaTreeItem<T> item) {
    if (_disabled(item)) {
      return;
    }

    _activate(key);
    item.onPressed?.call();

    if (item.isBranch) {
      _toggle(key, item);
    }

    if (item.selectable) {
      _select(key);
    }
  }

  /// A press on the disclosure arrow, which opens and shuts and chooses
  /// nothing.
  void _pressArrow(Object key, NebaTreeItem<T> item) {
    _activate(key);
    _toggle(key, item);
  }

  void _moveTo(_Shown<T> row, {required bool down}) {
    _activate(row.key);

    final BuildContext? context = _nodes[row.key]?.context;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: down
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  KeyEventResult _onKey(Object key, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final List<_Shown<T>> rows = _shownRows();
    final int index = rows.indexWhere((_Shown<T> row) => row.key == key);

    if (index < 0) {
      return KeyEventResult.ignored;
    }

    final _Shown<T> row = rows[index];
    final NebaTreeItem<T> item = row.item;
    // Forward is always further in, so the two arrows swap right to left.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey forward = rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final LogicalKeyboardKey back = rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final LogicalKeyboardKey pressed = event.logicalKey;
    final bool open = item.isBranch && _expanded.contains(key);

    KeyEventResult move(int to, {required bool down}) {
      if (to < 0 || to >= rows.length) {
        return KeyEventResult.ignored;
      }

      _moveTo(rows[to], down: down);

      return KeyEventResult.handled;
    }

    if (pressed == LogicalKeyboardKey.arrowDown) {
      return move(index + 1, down: true);
    }

    if (pressed == LogicalKeyboardKey.arrowUp) {
      return move(index - 1, down: false);
    }

    if (pressed == LogicalKeyboardKey.home) {
      return move(0, down: false);
    }

    if (pressed == LogicalKeyboardKey.end) {
      return move(rows.length - 1, down: true);
    }

    if (pressed == forward) {
      if (!item.isBranch) {
        return KeyEventResult.ignored;
      }

      if (!open) {
        _toggle(key, item);

        return KeyEventResult.handled;
      }

      // The first child is the next row showing.
      return move(index + 1, down: true);
    }

    if (pressed == back) {
      if (open) {
        _toggle(key, item);

        return KeyEventResult.handled;
      }

      final _Shown<T>? parent = row.parent;

      if (parent == null) {
        return KeyEventResult.ignored;
      }

      return move(rows.indexOf(parent), down: false);
    }

    // A character moves to the next row whose label starts with it, round
    // past the end, so pressing it again steps through them. Any modifier but
    // Shift is somebody else's shortcut, and Space presses the row.
    final String? character = event.character;
    final bool modified =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed;

    if (character != null &&
        character.runes.length == 1 &&
        character != ' ' &&
        character.codeUnitAt(0) >= 0x20 &&
        character.codeUnitAt(0) != 0x7F &&
        !modified) {
      final String needle = nebaSearchText(character);

      for (int step = 1; step < rows.length; step++) {
        final _Shown<T> candidate = rows[(index + step) % rows.length];

        if (_wordsOf(candidate.item).startsWith(needle)) {
          _moveTo(candidate, down: (index + step) < rows.length);

          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _wordsOf(NebaTreeItem<T> item) {
    return nebaSearchText(nebaPlainText(item.label) ?? item.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final List<NebaTreeItem<T>> children = widget.children;

    return _TreeScope<T>(
      tree: this,
      open: _expanded,
      selected: _selected,
      stop: _stopOf(_shownRows()),
      tokens: tokens,
      roles: tokens.roles(color),
      size: size,
      density: density,
      lines: widget.lines,
      multiple: widget.multiple,
      disabled: widget.disabled,
      keepMounted: widget.keepMounted,
      child: NebaDisclosureSheet(
        variant: variant,
        color: color,
        size: size,
        elevation: widget.elevation ?? 0,
        clip: false,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            role: SemanticsRole.list,
            label: widget.label,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < children.length; i++)
                  _TreeNode<T>(
                    key: ValueKey<Object>(_keyOf(children[i], '$i')),
                    item: children[i],
                    path: '$i',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the tree tells its rows.
class _TreeScope<T> extends InheritedWidget {
  const _TreeScope({
    required this.tree,
    required this.open,
    required this.selected,
    required this.stop,
    required this.tokens,
    required this.roles,
    required this.size,
    required this.density,
    required this.lines,
    required this.multiple,
    required this.disabled,
    required this.keepMounted,
    required super.child,
  });

  final _NebaTreeViewState<T> tree;
  final Set<Object?> open;
  final Set<Object?> selected;
  final Object? stop;
  final NebaTokens tokens;
  final NebaColorRoles roles;
  final NebaSize size;
  final NebaDensity density;
  final NebaTreeViewLines lines;
  final bool multiple;
  final bool disabled;
  final bool keepMounted;

  static _TreeScope<T> of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TreeScope<T>>()!;
  }

  @override
  bool updateShouldNotify(_TreeScope<T> oldWidget) {
    return !setEquals(open, oldWidget.open) ||
        !setEquals(selected, oldWidget.selected) ||
        stop != oldWidget.stop ||
        tokens != oldWidget.tokens ||
        roles != oldWidget.roles ||
        size != oldWidget.size ||
        density != oldWidget.density ||
        lines != oldWidget.lines ||
        multiple != oldWidget.multiple ||
        disabled != oldWidget.disabled ||
        keepMounted != oldWidget.keepMounted;
  }
}

/// One row, and the branch under it.
class _TreeNode<T> extends StatefulWidget {
  const _TreeNode({required this.item, required this.path, super.key});

  final NebaTreeItem<T> item;

  /// The row's place, the indices down to it.
  final String path;

  @override
  State<_TreeNode<T>> createState() => _TreeNodeState<T>();
}

class _TreeNodeState<T> extends State<_TreeNode<T>> {
  late final FocusNode _node = FocusNode(debugLabel: 'NebaTreeItem', onKeyEvent: _onKey);
  _NebaTreeViewState<T>? _tree;
  Object? _registered;

  Object get _key => _keyOf(widget.item, widget.path);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    return _tree?._onKey(_key, event) ?? KeyEventResult.ignored;
  }

  @override
  void dispose() {
    final Object? registered = _registered;

    if (registered != null) {
      _tree?._unregister(registered, _node);
    }

    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _TreeScope<T> scope = _TreeScope.of<T>(context);
    final _NebaTreeViewState<T> tree = scope.tree;
    final NebaTreeItem<T> item = widget.item;
    final Object key = _key;
    final Object? registered = _registered;

    if (registered != null && registered != key) {
      tree._unregister(registered, _node);
    }

    _tree = tree;
    _registered = key;
    tree._register(key, _node);
    // One stop in the focus order for the whole tree; the arrow keys reach
    // the rest.
    _node.skipTraversal = scope.stop != key;

    final bool branch = item.isBranch;
    final bool expanded = branch && scope.open.contains(key);
    final List<NebaTreeItem<T>> children = item.children;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.listItem,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TreeRow<T>(item: item, rowKey: key, node: _node, expanded: expanded),
          if (branch && children.isNotEmpty)
            NebaDisclosurePanel(
              open: expanded,
              keepMounted: scope.keepMounted,
              child: _TreeGroup<T>(items: children, path: widget.path),
            ),
        ],
      ),
    );
  }
}

/// The rows under a branch, set in a level, each with its rail.
class _TreeGroup<T> extends StatelessWidget {
  const _TreeGroup({required this.items, required this.path});

  final List<NebaTreeItem<T>> items;
  final String path;

  @override
  Widget build(BuildContext context) {
    final _TreeScope<T> scope = _TreeScope.of<T>(context);
    final NebaSize size = scope.size;
    final double indent = _indent[size]!;
    final NebaTreeViewLines lines = scope.lines;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.list,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              _railed(
                _TreeNode<T>(
                  key: ValueKey<Object>(_keyOf(items[i], _childPath(path, i))),
                  item: items[i],
                  path: _childPath(path, i),
                ),
                lines: lines,
                last: i == items.length - 1,
                indent: indent,
                row: NebaScale.controlHeight[size]!,
                color: scope.tokens.border,
                rtl: rtl,
              ),
          ],
        ),
      ),
    );
  }

  Widget _railed(
    Widget child, {
    required NebaTreeViewLines lines,
    required bool last,
    required double indent,
    required double row,
    required Color color,
    required bool rtl,
  }) {
    if (lines == NebaTreeViewLines.none) {
      return child;
    }

    return CustomPaint(
      painter: _RailPainter(
        folder: lines == NebaTreeViewLines.folder,
        last: last,
        indent: indent,
        row: row,
        color: color,
        rtl: rtl,
      ),
      child: child,
    );
  }
}

/// The hairline beside a row in a group, half an indent outside the row, as
/// tall as the row and everything open under it; with the elbow into the row
/// and a last child's rail stopped at its row for [folder].
class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.folder,
    required this.last,
    required this.indent,
    required this.row,
    required this.color,
    required this.rtl,
  });

  final bool folder;
  final bool last;
  final double indent;
  final double row;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double rail = rtl ? size.width + indent / 2 - 1 : -indent / 2;
    final double height = folder && last ? row / 2 : size.height;

    canvas.drawRect(Rect.fromLTWH(rail, 0, 1, height), paint);

    if (folder) {
      // It stops two pixels short of the row, so the corner reads as a turn
      // rather than as a line running into the label.
      final double width = indent / 2 - 2;

      canvas.drawRect(Rect.fromLTWH(rtl ? size.width + 2 : -indent / 2, row / 2, width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) {
    return oldDelegate.folder != folder ||
        oldDelegate.last != last ||
        oldDelegate.indent != indent ||
        oldDelegate.row != row ||
        oldDelegate.color != color ||
        oldDelegate.rtl != rtl;
  }
}

/// The row a [_TreeNode] draws: the pressable area with its arrow, icons and
/// label, and the action beside it.
class _TreeRow<T> extends StatelessWidget {
  const _TreeRow({
    required this.item,
    required this.rowKey,
    required this.node,
    required this.expanded,
  });

  final NebaTreeItem<T> item;
  final Object rowKey;
  final FocusNode node;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final _TreeScope<T> scope = _TreeScope.of<T>(context);
    final _NebaTreeViewState<T> tree = scope.tree;
    final NebaTokens tokens = scope.tokens;
    final NebaColorRoles roles = scope.roles;
    final NebaSize size = scope.size;
    final bool branch = item.isBranch;
    final bool selected = scope.selected.contains(rowKey);
    final bool disabled = item.disabled || scope.disabled;
    final Uri? link = nebaSafeHref(item.href);
    final double text = NebaScale.controlText[size]!;
    final double line = NebaScale.controlLeading[size]!;
    final double icon = text * 1.2;
    final double padX = _rowPaddingX[scope.density]![size]!;
    final BorderRadius radius = BorderRadius.circular(_rowRadius[size]!);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    // One state at a time, grey first, then the chosen row, then the
    // pointer: a hovered row and the chosen one are one tint at two
    // strengths, and a chosen row stays at its own under the pointer.
    final Color ink = disabled
        ? tokens.disabledFg
        : selected
        ? roles.onTint
        : DefaultTextStyle.of(context).style.color ?? tokens.fg;

    Widget muted(Widget child) {
      return SizedBox(
        height: line,
        child: Center(
          widthFactor: 1,
          child: IconTheme.merge(
            data: IconThemeData(color: tokens.mutedFg),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg),
              child: child,
            ),
          ),
        ),
      );
    }

    // A leaf still draws the box, so every label in a branch starts on the
    // same column. Turned, not moved: the arrow is a glyph, so turning it is
    // the one transform allowed, pointing further in while shut.
    Widget arrow = SizedBox(
      width: text * 1.15,
      height: line,
      child: branch
          ? Center(
              child: OverflowBox(
                maxWidth: icon,
                maxHeight: icon,
                child: AnimatedRotation(
                  turns: expanded ? 0 : (rtl ? 0.25 : -0.25),
                  duration: nebaDuration(context, NebaScale.duration),
                  curve: NebaScale.ease,
                  child: NebaGlyph(NebaGlyphs.chevron, size: icon, color: tokens.mutedFg),
                ),
              ),
            )
          : null,
    );

    if (branch && !disabled) {
      arrow = GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => tree._pressArrow(rowKey, item),
        child: arrow,
      );
    }

    final Widget? startIcon = item.startIcon;
    final Widget? endIcon = item.endIcon;
    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: text,
        height: line / text,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: selected && !disabled ? FontWeight.w500 : null,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: IconTheme.merge(
        data: IconThemeData(size: icon),
        child: NebaInk(
          color: ink,
          child: Row(
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              arrow,
              if (startIcon != null) muted(startIcon),
              Expanded(child: item.label ?? const SizedBox.shrink()),
              if (endIcon != null) muted(endIcon),
            ],
          ),
        ),
      ),
    );

    final Widget pressable = NebaInteractive(
      focusNode: node,
      enabled: !disabled,
      // A row that is unavailable is still on the path the arrow keys walk.
      focusable: true,
      onTap: () => tree._press(rowKey, item),
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
        final Color fill = disabled
            ? edgeless
            : selected
            ? roles.softPress
            : interaction.hovered
            ? roles.soft
            : edgeless;

        // The ring is drawn on the row rather than around the branch under
        // it, and inside its edge, where no neighbour covers it.
        return NebaFocusRing(
          visible: interaction.focusVisible,
          color: roles.ring,
          borderRadius: radius,
          offset: -focusRingWidth,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: fill),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? tint, Widget? child) {
              return DecoratedBox(
                decoration: BoxDecoration(color: tint, borderRadius: radius),
                child: child,
              );
            },
            child: SizedBox(
              height: NebaScale.controlHeight[size],
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padX),
                child: content,
              ),
            ),
          ),
        );
      },
    );

    // In a tree that chooses several, every row that can be chosen says
    // whether it is, so "not selected" is heard rather than left out.
    final bool? heardSelected = selected
        ? true
        : scope.multiple && item.selectable
        ? false
        : null;
    final Widget? action = item.action;

    return Row(
      children: <Widget>[
        Expanded(
          child: Semantics(
            container: true,
            button: link == null,
            link: link != null,
            linkUrl: link,
            enabled: !disabled,
            selected: heardSelected,
            expanded: branch ? expanded : null,
            child: pressable,
          ),
        ),
        if (action != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padX),
            child: action,
          ),
      ],
    );
  }
}
