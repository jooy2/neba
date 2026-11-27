/// `NebaDataTable`, a table for a lot of rows: it builds only the ones on
/// screen, sorts and searches them, and lets them be chosen the way a file
/// manager does.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/components/button/neba_button.dart';
import 'package:neba/src/components/checkbox/neba_checkbox.dart';
import 'package:neba/src/components/pagination/neba_pagination.dart';
import 'package:neba/src/components/select/neba_select.dart';
import 'package:neba/src/components/text_field/neba_text_field.dart';
import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/csv.dart';
import 'package:neba/src/internal/data_table.dart';
import 'package:neba/src/internal/drag.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/glyphs.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/data_table.dart'
    show NebaDataTableSort, NebaDataTableSortDirection;

// ---------------------------------------------------------------------------
// Vocabulary
// ---------------------------------------------------------------------------

/// How many rows may be chosen at once.
enum NebaDataTableSelectionMode {
  /// None: a table that lights a row under the pointer and chooses nothing.
  none,

  /// One row at a time.
  single,

  /// Any number, by Ctrl, Shift, a drag or the keyboard.
  multiple,
}

/// Whether one column or several sort the rows at a time.
enum NebaDataTableSortMode {
  /// A press on a heading replaces the sort.
  single,

  /// A Shift-press on a heading adds its column to the sort.
  multiple,
}

/// Which rows carry the zebra tint, counted as a reader counts them.
enum NebaDataTableStripe {
  /// No tint.
  none,

  /// The first, the third and the fifth row.
  odd,

  /// The second, the fourth and the sixth row.
  even,
}

/// How the rows are handed out.
enum NebaDataTablePaging {
  /// All of them, in one scrolling body.
  scroll,

  /// A page at a time, with a footer to step through them.
  pages,
}

/// The three things the table does to the rows before drawing them, any of
/// which a caller whose server does it can take over through `manual`.
enum NebaDataTableStage {
  /// Ordering by the sort.
  sort,

  /// The search and the caller's filter.
  filter,

  /// Cutting a page out.
  pages,
}

/// The edge a pinned column is frozen against.
enum NebaDataTablePin {
  /// The leading edge, where it is drawn first.
  start,

  /// The trailing edge, where it is drawn last.
  end,
}

/// What kind of value a cell's editor takes.
enum NebaDataTableEditType {
  /// Text, handed back as a [String].
  text,

  /// A number, with the keypad on a phone, handed back as a [num].
  number,
}

/// One column of a [NebaDataTable]: its heading, its width, how to get a value
/// out of a row and how to build a cell.
///
/// [value] decides what the sort, the search and a cell without a [builder]
/// see, and [builder] decides what a reader sees. A row that is a [Map] needs
/// neither, since the cell is then `row[key]`; any other row gives each
/// column a [value], and a column that builds a chip and sorts needs both.
@immutable
class NebaDataTableColumn<T> {
  /// A column named [key].
  const NebaDataTableColumn({
    required this.key,
    this.label,
    this.group,
    this.width,
    this.minWidth,
    this.align = NebaAlign.start,
    this.headerAlign,
    this.sortable,
    this.resizable,
    this.searchable = true,
    this.hidden = false,
    this.pinned,
    this.value,
    this.compare,
    this.builder,
    this.exportValue,
    this.exportable = true,
    this.editable = false,
    this.editableWhen,
    this.editType = NebaDataTableEditType.text,
    this.aggregate,
  });

  /// Identifies the column, to the sort, the widths and the order, and names
  /// the entry a row that is a [Map] is read by.
  final String key;

  /// The heading. Defaults to [key] in a [Text]; a [Text] here also names the
  /// column in an export, an editor and a resize handle.
  final Widget? label;

  /// The heading over this column and its neighbours: adjacent columns with
  /// the same group are drawn under one merged heading in a second header
  /// row, and a column with none spans both rows.
  final String? group;

  /// The width in logical pixels. Columns without one share what is left.
  final double? width;

  /// How narrow a drag may make it. Defaults to 48.
  final double? minWidth;

  /// The edge the cells line up against. Numbers want [NebaAlign.end].
  final NebaAlign align;

  /// The heading's own alignment, when it should differ from the cells'.
  final NebaAlign? headerAlign;

  /// Whether the column sorts. Defaults to the table's `sortable`.
  final bool? sortable;

  /// Whether the column can be dragged wider. Defaults to the table's
  /// `resizable`.
  final bool? resizable;

  /// Whether the search looks in this column.
  final bool searchable;

  /// Leaves the column out without removing it from the list.
  final bool hidden;

  /// Freezes the column against an edge while the rest scroll past, and
  /// moves it there: everything pinned to the start is drawn first and
  /// everything pinned to the end last.
  final NebaDataTablePin? pinned;

  /// The value behind a cell: what is sorted, searched, written by a cell
  /// without a [builder] and edited. Defaults to `row[key]` for a [Map].
  final Object? Function(T row)? value;

  /// Orders two rows by this column, written ascending, for values the
  /// default comparison cannot rank.
  final int Function(T a, T b)? compare;

  /// Builds a cell. `index` is the row's place in the sorted, filtered order
  /// across every page, so `index + 1` is a running row number.
  final Widget Function(BuildContext context, T row, int index)? builder;

  /// What an export writes for this column. Defaults to [value].
  final Object? Function(T row)? exportValue;

  /// Whether an export writes this column at all.
  final bool exportable;

  /// Whether a cell in this column edits in place, given an `onCellEdit` on
  /// the table.
  final bool editable;

  /// Decides per row whether a cell edits, for a locked record or a computed
  /// field. Setting it makes the column [editable].
  final bool Function(T row)? editableWhen;

  /// What the editor takes.
  final NebaDataTableEditType editType;

  /// The one figure that stands for a group of rows, drawn in this column of
  /// the group's heading. Called with the rows of one group.
  final Widget Function(List<T> rows)? aggregate;
}

// ---------------------------------------------------------------------------
// The widget
// ---------------------------------------------------------------------------

/// A table for a lot of rows, a place to work rather than a grid to read.
///
/// Every row is the same height, [rowHeight] or the size and density's own,
/// which is what lets a table with a [height] or a [maxHeight] build the
/// thirty rows on screen out of two hundred thousand; cells cut their text
/// short rather than wrap. Rows are chosen the way a file manager chooses
/// them once [selectionMode] allows it: a press chooses one, Ctrl adds one,
/// Shift takes the run, a mouse drag takes the rows under it and the arrow
/// keys do the same. The search, the sort and the page are one pipeline over
/// [items], and [manual] hands any stage to a server that does it.
///
/// ```dart
/// NebaDataTable<Build>(
///   semanticLabel: 'Builds',
///   headers: <NebaDataTableColumn<Build>>[
///     NebaDataTableColumn<Build>(key: 'id', label: const Text('Build'), value: (Build b) => b.id),
///   ],
///   items: builds,
///   rowKey: (Build b, int index) => b.id,
///   height: 280,
///   selectionMode: NebaDataTableSelectionMode.multiple,
///   sortable: true,
/// )
/// ```
class NebaDataTable<T> extends StatefulWidget {
  /// A table of [items] in [headers].
  const NebaDataTable({
    required this.headers,
    required this.items,
    this.rowKey,
    this.variant,
    this.size,
    this.color,
    this.density,
    this.elevation,
    this.height,
    this.maxHeight,
    this.rowHeight,
    this.striped = NebaDataTableStripe.none,
    this.hoverable = true,
    this.stickyHeader = true,
    this.caption,
    this.semanticLabel,
    this.empty,
    this.virtual = true,
    this.overscan = 8,
    this.sortable = false,
    this.sortMode = NebaDataTableSortMode.single,
    this.sort,
    this.defaultSort,
    this.onSortChange,
    this.resizable = false,
    this.columnWidths,
    this.defaultColumnWidths,
    this.onColumnWidthsChange,
    this.columnOrder,
    this.defaultColumnOrder,
    this.onColumnOrderChange,
    this.reorderable = false,
    this.selectionMode = NebaDataTableSelectionMode.none,
    this.selected,
    this.defaultSelected,
    this.onSelectedChange,
    this.checkboxes = false,
    this.onRowPressed,
    this.onRowActivate,
    this.paging = NebaDataTablePaging.scroll,
    this.page,
    this.defaultPage = 1,
    this.onPageChange,
    this.pageSize,
    this.defaultPageSize = 25,
    this.onPageSizeChange,
    this.pageSizeOptions = const <int>[10, 25, 50, 100],
    this.footer,
    this.search,
    this.defaultSearch,
    this.onSearchChange,
    this.searchable = false,
    this.searchPlaceholder,
    this.filter,
    this.toolbar,
    this.exportable = false,
    this.onExport,
    this.exportEscapeFormulas = true,
    this.onCellEdit,
    this.groupBy,
    this.collapsibleGroups = true,
    this.defaultCollapsedGroups,
    this.manual = const <NebaDataTableStage>{},
    this.rowCount,
    this.locale,
    super.key,
  }) : assert(overscan >= 0),
       assert(
         elevation == null || (elevation >= nebaElevationMin && elevation <= nebaElevationMax),
       );

  /// The columns, in the order they are drawn.
  final List<NebaDataTableColumn<T>> headers;

  /// The rows.
  final List<T> items;

  /// A stable identity per row, and what [selected] is a list of. Defaults to
  /// the row's index in [items], which a table that sorts, filters or
  /// chooses should not rely on: an index names a position, and all three
  /// change which row is in it.
  final Object Function(T row, int index)? rowKey;

  /// The weight of the sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The cells' type, padding and default row height. Defaults to
  /// `NebaProvider`'s, then [NebaSize.sm].
  final NebaSize? size;

  /// The family of the hairline, the chosen rows and the sorted column.
  /// Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The cells' padding, and here the default row height too. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.compact].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`. Defaults to `0`.
  final NebaElevation? elevation;

  /// How tall the scrolling body is, which is what turns virtual scrolling
  /// on: rows can only be left unbuilt where something bounds their height.
  final double? height;

  /// The same as a ceiling: the body is as tall as its rows, up to this.
  final double? maxHeight;

  /// How tall a row is. Defaults to the size and density's.
  final double? rowHeight;

  /// Which rows are tinted, counted over the whole page.
  final NebaDataTableStripe striped;

  /// Whether the row under the pointer is lit.
  final bool hoverable;

  /// Whether the header stays put while the rows scroll under it.
  final bool stickyHeader;

  /// A line above the table saying what it holds, and its name when it is a
  /// [Text] and there is no [semanticLabel].
  final Widget? caption;

  /// The name a screen reader announces the table by.
  final String? semanticLabel;

  /// What a table with no rows says.
  final Widget? empty;

  /// Whether the rows off screen are left unbuilt. Needs a [height] or a
  /// [maxHeight]; without one every row is built whatever this says.
  final bool virtual;

  /// How many rows past each edge of the body are kept built.
  final int overscan;

  /// Makes every column sortable. A column says otherwise with its own.
  final bool sortable;

  /// Whether a Shift-press adds a column to the sort.
  final NebaDataTableSortMode sortMode;

  /// The sort, for a controlled table.
  final List<NebaDataTableSort>? sort;

  /// The sort an uncontrolled table starts with.
  final List<NebaDataTableSort>? defaultSort;

  /// Called with the new sort when a heading is pressed.
  final ValueChanged<List<NebaDataTableSort>>? onSortChange;

  /// Lets every boundary between headings be dragged. A double press on a
  /// handle gives the column its own width back.
  final bool resizable;

  /// The widths by column key, for a controlled table.
  final Map<String, double>? columnWidths;

  /// The widths an uncontrolled table starts with.
  final Map<String, double>? defaultColumnWidths;

  /// Called with every width when a boundary moves.
  final ValueChanged<Map<String, double>>? onColumnWidthsChange;

  /// The order the columns are drawn in, as keys, for a controlled table. A
  /// key the list leaves out keeps its place behind the ones it names.
  final List<String>? columnOrder;

  /// The order an uncontrolled table starts with.
  final List<String>? defaultColumnOrder;

  /// Called with the new order when a column is moved.
  final ValueChanged<List<String>>? onColumnOrderChange;

  /// Lets a heading be dragged along the row, or moved with Alt and an arrow,
  /// to move its column.
  final bool reorderable;

  /// How many rows may be chosen.
  final NebaDataTableSelectionMode selectionMode;

  /// The chosen rows' keys, for a controlled table.
  final List<Object>? selected;

  /// The keys an uncontrolled table starts with chosen.
  final List<Object>? defaultSelected;

  /// Called with the chosen keys and the rows behind them. A table whose
  /// caller pages it keeps a key chosen on another page and hands no row for
  /// it.
  final void Function(List<Object> selected, List<T> rows)? onSelectedChange;

  /// Adds a column of ticks, and one in the header that chooses every row on
  /// the page at once.
  final bool checkboxes;

  /// Called on every press of a row, after the press has changed the
  /// selection. A press on a control in a cell is that control's.
  final void Function(T row, int index)? onRowPressed;

  /// Called on a double press and on Enter: opening the row.
  final void Function(T row, int index)? onRowActivate;

  /// Whether the rows arrive all at once or a page at a time.
  final NebaDataTablePaging paging;

  /// The page, from 1, for a controlled table.
  final int? page;

  /// The page an uncontrolled table starts on.
  final int defaultPage;

  /// Called with the page the reader moves to.
  final ValueChanged<int>? onPageChange;

  /// How many rows a page holds, for a controlled table.
  final int? pageSize;

  /// How many an uncontrolled table starts with.
  final int defaultPageSize;

  /// Called with the size the reader picks.
  final ValueChanged<int>? onPageSizeChange;

  /// What the footer's page-size select offers. An empty list drops it.
  final List<int> pageSizeOptions;

  /// The bar under the table with the counts and the pages. Defaults to
  /// whether [paging] is [NebaDataTablePaging.pages].
  final bool? footer;

  /// The query every searchable column is matched against, for a controlled
  /// search.
  final String? search;

  /// What an uncontrolled search starts as.
  final String? defaultSearch;

  /// Called with the query as the reader types it.
  final ValueChanged<String>? onSearchChange;

  /// Draws the search field above the table.
  final bool searchable;

  /// The field's placeholder and name, in place of "Search".
  final String? searchPlaceholder;

  /// A filter of your own, applied after the search. `false` drops a row.
  final bool Function(T row, int index)? filter;

  /// What goes at the end of the bar the search field sits in.
  final Widget? toolbar;

  /// Draws a button that hands [onExport] every row the reader is looking at
  /// as CSV, with the search and the sort applied and the paging not.
  final bool exportable;

  /// Takes the CSV the export button writes. The package starts no download,
  /// so the button is drawn only with one.
  final ValueChanged<String>? onExport;

  /// Puts a `'` in front of an exported text cell a spreadsheet would run as a
  /// formula.
  final bool exportEscapeFormulas;

  /// Called with an edited cell's new value. Without it nothing edits; the
  /// table holds no copy of the rows and draws what comes back in [items].
  final void Function(T row, NebaDataTableColumn<T> column, Object value)? onCellEdit;

  /// Gathers the rows under a heading by what it returns, after the search
  /// and the sort; `null` puts a row in no group, above the rest.
  final String? Function(T row)? groupBy;

  /// Whether a group can be folded away.
  final bool collapsibleGroups;

  /// Which groups start folded, by what [groupBy] returned.
  final List<String>? defaultCollapsedGroups;

  /// The stages the caller has already done. With [NebaDataTableStage.pages]
  /// in it, [items] is one page and [rowCount] the whole count;
  /// `NebaDataTableStage.values.toSet()` is all three.
  final Set<NebaDataTableStage> manual;

  /// How many rows there are in all, when the caller does the paging.
  final int? rowCount;

  /// The language of the table's own words. Defaults to `NebaProvider`'s,
  /// then the app's.
  final Locale? locale;

  @override
  State<NebaDataTable<T>> createState() => _NebaDataTableState<T>();
}

// ---------------------------------------------------------------------------
// The pieces
// ---------------------------------------------------------------------------

/// The magnifier on the search field, drawn here alone.
final List<NebaGlyphPart> _searchGlyph = <NebaGlyphPart>[
  const NebaGlyphPart.stroke('M2.5 7.25a4.75 4.75 0 1 0 9.5 0a4.75 4.75 0 1 0 -9.5 0Z'),
  const NebaGlyphPart.stroke('m10.75 10.75 2.75 2.75', cap: StrokeCap.round),
];

/// How far one arrow key moves a column's boundary, the Sidebar's step.
const double _keyboardStep = 16;

/// How many rows a table builds in full before a debug build says that
/// virtual scrolling is not on.
const int _unwindowedRows = 500;

/// How many rows the search folds between two looks at the clock while the
/// app is idle, and how long one slice may run.
const int _foldRows = 200;
const Duration _foldBudget = Duration(milliseconds: 8);

/// How long the search waits between two slices, so a slice runs while the
/// app has nothing else to do rather than in the frame that drew the table.
/// A task at idle priority would be the closer match, and it never runs
/// while an animation does, which a table with a blinking caret beside it
/// always has.
const Duration _foldPause = Duration(milliseconds: 50);

/// How far a heading travels before it is carried.
const double _reorderSlop = 6;

/// One row of [NebaDataTable.items], with what the table says about it.
class _Entry<T> {
  _Entry(this.row, this.key, this.origin);

  final T row;

  /// The caller's key, or the index.
  final Object key;

  /// Where it sat in the items, which is what the haystacks are indexed by.
  final int origin;
}

/// A group's heading in the body, keyed apart from any row's key.
@immutable
class _GroupKey {
  const _GroupKey(this.label);

  final String label;

  @override
  bool operator ==(Object other) => other is _GroupKey && other.label == label;

  @override
  int get hashCode => Object.hash(_GroupKey, label);
}

/// One line of the body: a row, or a group's heading. Every line is a row
/// tall, so the body is a linear map from a position to a line.
class _Line<T> {
  _Line.row(_Entry<T> this.entry, this.index) : label = null, rows = null;

  _Line.group(String this.label, List<_Entry<T>> this.rows) : entry = null, index = -1;

  final _Entry<T>? entry;

  /// The row's place on the page.
  final int index;

  final String? label;
  final List<_Entry<T>>? rows;

  Key get key => entry != null ? ValueKey<Object>(entry!.key) : ValueKey<Object>(_GroupKey(label!));
}

/// Where each column sits across the table.
class _Geometry {
  _Geometry({
    required this.tick,
    required this.starts,
    required this.widths,
    required this.filler,
    required this.width,
    required this.overflow,
  });

  /// The tick column's width, or none.
  final double tick;

  /// Each drawn column's distance from the start edge.
  final List<double> starts;

  /// And its width.
  final List<double> widths;

  /// The empty column that claims the slack once every column has a width.
  final double filler;

  /// The whole table's width.
  final double width;

  /// How much wider the table is than the box it is shown in.
  final double overflow;
}

/// A cell of a strip, placed by its distance from the start edge.
class _Piece {
  const _Piece({
    required this.key,
    required this.start,
    required this.width,
    required this.child,
    this.top = 0,
    this.height,
    this.pin,
  });

  final Key key;
  final double start;
  final double width;
  final double top;
  final double? height;
  final NebaDataTablePin? pin;
  final Widget child;
}

/// Every row folded into one string for the search, once, a slice at a time.
class _Haystacks<T> {
  _Haystacks(this.entries, this.columns);

  final List<_Entry<T>> entries;
  final List<NebaDataTableColumn<T>> columns;
  final List<String> _stacks = <String>[];

  bool get complete => _stacks.length >= entries.length;

  /// Folds up to [count] more rows, and says whether any are left.
  bool fold(int count) {
    final int end = math.min(entries.length, _stacks.length + count);

    for (int index = _stacks.length; index < end; index++) {
      final T row = entries[index].row;

      _stacks.add(
        columns
            .map((NebaDataTableColumn<T> column) => nebaSearchText(_cellValue(column, row)))
            .join('\u0000'),
      );
    }

    return !complete;
  }

  /// Every row folded, finishing whatever the idle slices left.
  List<String> all() {
    fold(entries.length);

    return _stacks;
  }
}

/// A value kept until what it was worked out from changes.
class _Memo<R> {
  List<Object?>? _deps;
  R? _value;

  R of(List<Object?> deps, R Function() compute) {
    final List<Object?>? last = _deps;

    if (last != null && last.length == deps.length) {
      bool same = true;

      for (int i = 0; i < deps.length; i++) {
        if (!identical(last[i], deps[i]) && last[i] != deps[i]) {
          same = false;
          break;
        }
      }

      if (same) {
        return _value as R;
      }
    }

    _deps = deps;

    return _value = compute();
  }
}

/// The value behind a cell: the column's `value`, or a map row's entry.
Object? _cellValue<T>(NebaDataTableColumn<T> column, T row) {
  final Object? Function(T row)? value = column.value;

  if (value != null) {
    return value(row);
  }

  return row is Map ? row[column.key] : null;
}

/// A value as JavaScript's `String()` writes it, so a whole number held as a
/// double reads `18` rather than `18.0`.
String _stringOf(Object? value) {
  if (value == null) {
    return '';
  }

  if (value is double && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt().toString();
  }

  return '$value';
}

/// What a cell with no builder writes: a date as a date, anything else as
/// its text.
String _plainText(Object? value) {
  if (value is DateTime) {
    return nebaFormatDate(value);
  }

  return _stringOf(value);
}

/// A column's name as text: its label when that is a [Text], else its key.
String _labelText<T>(NebaDataTableColumn<T> column) {
  final Widget? label = column.label;

  if (label is Text && label.data != null) {
    return label.data!;
  }

  return column.key;
}

/// Whether one cell edits.
bool _cellEditable<T>(NebaDataTableColumn<T> column, T row, {required bool handled}) {
  if (!handled) {
    return false;
  }

  final bool Function(T row)? when = column.editableWhen;

  return when != null ? when(row) : column.editable;
}

AlignmentGeometry _alignmentOf(NebaAlign align) => switch (align) {
  NebaAlign.start => AlignmentDirectional.centerStart,
  NebaAlign.center => Alignment.center,
  NebaAlign.end => AlignmentDirectional.centerEnd,
};

TextAlign _textAlignOf(NebaAlign align) => switch (align) {
  NebaAlign.start => TextAlign.start,
  NebaAlign.center => TextAlign.center,
  NebaAlign.end => TextAlign.end,
};

MainAxisAlignment _mainAxisOf(NebaAlign align) => switch (align) {
  NebaAlign.start => MainAxisAlignment.start,
  NebaAlign.center => MainAxisAlignment.center,
  NebaAlign.end => MainAxisAlignment.end,
};

/// What every part of the table is drawn with, worked out once per build.
class _Look {
  _Look({
    required this.tokens,
    required this.roles,
    required this.size,
    required this.density,
    required this.color,
    required this.padX,
    required this.rowHeight,
    required this.headerHeight,
    required this.messages,
    required this.duration,
    required this.rtl,
  });

  final NebaTokens tokens;
  final NebaColorRoles roles;
  final NebaSize size;
  final NebaDensity density;
  final NebaColor color;
  final double padX;
  final double rowHeight;
  final double headerHeight;
  final Map<String, String> messages;
  final Duration duration;
  final bool rtl;

  Color get stripe => tokens.fg.withValues(alpha: 0.04);

  BorderSide get rule => BorderSide(color: roles.line);
}

// ---------------------------------------------------------------------------
// The state
// ---------------------------------------------------------------------------

class _NebaDataTableState<T> extends State<NebaDataTable<T>> with SingleTickerProviderStateMixin {
  final FocusNode _tableFocus = FocusNode(debugLabel: 'NebaDataTable');
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();
  final GlobalKey _viewportKey = GlobalKey(debugLabel: 'NebaDataTable viewport');
  final GlobalKey _rowsKey = GlobalKey(debugLabel: 'NebaDataTable rows');
  late final TextEditingController _searchField = TextEditingController(
    text: widget.search ?? widget.defaultSearch ?? '',
  );
  late final Ticker _autoScroll = createTicker(_autoScrollTick);

  // What an uncontrolled table keeps.
  late List<NebaDataTableSort> _sortState = widget.defaultSort ?? <NebaDataTableSort>[];
  late Map<String, double> _widthState = widget.defaultColumnWidths ?? <String, double>{};
  late List<String> _orderState = widget.defaultColumnOrder ?? <String>[];
  late List<Object> _selectedState = widget.defaultSelected ?? <Object>[];
  late int _pageState = widget.defaultPage;
  late int _pageSizeState = widget.defaultPageSize;
  late String _searchState = widget.defaultSearch ?? '';
  late Set<String> _collapsed = <String>{...?widget.defaultCollapsedGroups};

  Object? _activeKey;
  Object? _anchor;
  ({Object key, String column})? _editing;
  bool _editorFocused = false;
  bool _tableFocused = false;
  String? _movingKey;
  String? _dropKey;
  bool _warnedUnwindowed = false;

  // A press on a row, from the pointer going down to it coming up.
  _Entry<T>? _pressed;
  int _pressedButtons = 0;

  // The row a click last landed on, while a second one would make it double.
  Timer? _clickTimer;
  Object? _clickKey;

  // A drag through a run of rows.
  ({Offset position, double speed, Object key})? _drag;

  // A resize or a reorder in progress.
  Map<String, double>? _frozen;
  double _resizeFrom = 0;
  double _reorderOrigin = 0;
  bool _reorderArmed = false;

  // The search's idle folding.
  _Haystacks<T>? _folding;
  Timer? _foldTimer;

  // The pipeline, worked out at the top of every build.
  final _Memo<List<NebaDataTableColumn<T>>> _columnsMemo = _Memo<List<NebaDataTableColumn<T>>>();
  final _Memo<List<_Entry<T>>> _entriesMemo = _Memo<List<_Entry<T>>>();
  final _Memo<Map<Object, _Entry<T>>> _byKeyMemo = _Memo<Map<Object, _Entry<T>>>();
  final _Memo<List<NebaDataTableColumn<T>>> _searchedMemo = _Memo<List<NebaDataTableColumn<T>>>();
  final _Memo<_Haystacks<T>> _haystacksMemo = _Memo<_Haystacks<T>>();
  final _Memo<List<_Entry<T>>> _orderedMemo = _Memo<List<_Entry<T>>>();
  final _Memo<List<_Entry<T>>> _filteredMemo = _Memo<List<_Entry<T>>>();
  final _Memo<({List<String> order, Map<String, List<_Entry<T>>> byLabel})?> _groupsMemo =
      _Memo<({List<String> order, Map<String, List<_Entry<T>>> byLabel})?>();
  final _Memo<List<_Entry<T>>> _arrangedMemo = _Memo<List<_Entry<T>>>();
  final _Memo<List<_Entry<T>>> _pagedMemo = _Memo<List<_Entry<T>>>();
  final _Memo<Map<Object, int>> _pageIndexMemo = _Memo<Map<Object, int>>();
  final _Memo<Set<Object>> _selectedKeysMemo = _Memo<Set<Object>>();
  final _Memo<List<_Line<T>>> _linesMemo = _Memo<List<_Line<T>>>();
  final _Memo<Map<Key, int>> _lineIndexMemo = _Memo<Map<Key, int>>();

  late List<NebaDataTableColumn<T>> _columns;
  late List<_Entry<T>> _entries;
  late Map<Object, _Entry<T>> _byKey;
  late List<NebaDataTableColumn<T>> _searched;
  late _Haystacks<T> _haystacks;
  late List<_Entry<T>> _filtered;
  late ({List<String> order, Map<String, List<_Entry<T>>> byLabel})? _groups;
  late List<_Entry<T>> _paged;
  late List<Object> _pagedKeys;
  late Map<Object, int> _pageIndex;
  late Set<Object> _selectedKeys;
  late List<_Line<T>> _lines;
  late Map<Key, int> _lineIndex;
  late DataPageBounds _bounds;
  late int _total;
  _Geometry? _geometry;
  late _Look _look;

  @override
  void initState() {
    super.initState();
    _tableFocus.addListener(_handleTableFocus);
    NebaInputModality.pointer.addListener(_handleModality);
  }

  @override
  void didUpdateWidget(NebaDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final String? search = widget.search;

    if (search != null && search != _searchField.text) {
      _searchField.value = TextEditingValue(
        text: search,
        selection: TextSelection.collapsed(offset: search.length),
      );
    }
  }

  @override
  void dispose() {
    NebaInputModality.pointer.removeListener(_handleModality);
    _tableFocus.removeListener(_handleTableFocus);
    _tableFocus.dispose();
    _autoScroll.dispose();
    _clickTimer?.cancel();
    _vertical.dispose();
    _horizontal.dispose();
    _searchField.dispose();
    _folding = null;
    _foldTimer?.cancel();
    super.dispose();
  }

  void _handleTableFocus() {
    if (_tableFocus.hasPrimaryFocus != _tableFocused && mounted) {
      setState(() => _tableFocused = _tableFocus.hasPrimaryFocus);
    }
  }

  void _handleModality() {
    if ((_tableFocused || _editorFocused) && mounted) {
      setState(() {});
    }
  }

  // -- What the props come to -----------------------------------------------

  bool get _selects => widget.selectionMode != NebaDataTableSelectionMode.none;

  bool get _multiple => widget.selectionMode == NebaDataTableSelectionMode.multiple;

  bool get _showTicks => _selects && widget.checkboxes;

  bool get _editsCells =>
      widget.onCellEdit != null &&
      _columns.any(
        (NebaDataTableColumn<T> column) => column.editable || column.editableWhen != null,
      );

  /// A table a keyboard has something to do in: one that chooses rows, opens
  /// them, or edits a cell.
  bool get _navigable => _selects || widget.onRowActivate != null || _editsCells;

  bool get _pressable => _selects || widget.onRowPressed != null;

  bool get _bounded => widget.height != null || widget.maxHeight != null;

  bool get _virtualized => widget.virtual && _bounded && _paged.isNotEmpty;

  bool get _pagesStaged => widget.manual.contains(NebaDataTableStage.pages);

  bool get _hasGroups => _columns.any((NebaDataTableColumn<T> column) => column.group != null);

  int get _headRows => _hasGroups ? 2 : 1;

  List<NebaDataTableSort> get _sort => widget.sort ?? _sortState;

  Map<String, double> get _widths => widget.columnWidths ?? _widthState;

  int get _pageSize => widget.pageSize ?? _pageSizeState;

  int get _displayOffset => widget.paging == NebaDataTablePaging.pages ? _bounds.start : 0;

  double? _explicitWidth(NebaDataTableColumn<T> column) => _widths[column.key] ?? column.width;

  double _widthFloor(String key) {
    for (final NebaDataTableColumn<T> column in _columns) {
      if (column.key == key) {
        return column.minWidth ?? dataMinColumnWidth;
      }
    }

    return dataMinColumnWidth;
  }

  // -- The pipeline ---------------------------------------------------------

  void _derive() {
    final List<String> order = widget.columnOrder ?? _orderState;

    _columns = _columnsMemo.of(<Object?>[widget.headers, order], () {
      final List<NebaDataTableColumn<T>> visible = <NebaDataTableColumn<T>>[
        for (final NebaDataTableColumn<T> column in widget.headers)
          if (!column.hidden) column,
      ];
      final List<NebaDataTableColumn<T>> ordered;

      if (order.isEmpty) {
        ordered = visible;
      } else {
        final Map<String, NebaDataTableColumn<T>> byKey = <String, NebaDataTableColumn<T>>{
          for (final NebaDataTableColumn<T> column in visible) column.key: column,
        };
        final Set<String> named = order.toSet();

        ordered = <NebaDataTableColumn<T>>[
          for (final String key in order)
            if (byKey[key] case final NebaDataTableColumn<T> column) column,
          for (final NebaDataTableColumn<T> column in visible)
            if (!named.contains(column.key)) column,
        ];
      }

      int rank(NebaDataTableColumn<T> column) => switch (column.pinned) {
        NebaDataTablePin.start => 0,
        null => 1,
        NebaDataTablePin.end => 2,
      };

      return <NebaDataTableColumn<T>>[
        for (final NebaDataTableColumn<T> column in ordered)
          if (rank(column) == 0) column,
        for (final NebaDataTableColumn<T> column in ordered)
          if (rank(column) == 1) column,
        for (final NebaDataTableColumn<T> column in ordered)
          if (rank(column) == 2) column,
      ];
    });

    _entries = _entriesMemo.of(<Object?>[widget.items, widget.rowKey], () {
      final Object Function(T row, int index)? rowKey = widget.rowKey;

      return <_Entry<T>>[
        for (int index = 0; index < widget.items.length; index++)
          _Entry<T>(
            widget.items[index],
            rowKey == null ? index : rowKey(widget.items[index], index),
            index,
          ),
      ];
    });

    _byKey = _byKeyMemo.of(<Object?>[_entries], () {
      return <Object, _Entry<T>>{for (final _Entry<T> entry in _entries) entry.key: entry};
    });

    _searched = _searchedMemo.of(<Object?>[_columns], () {
      return <NebaDataTableColumn<T>>[
        for (final NebaDataTableColumn<T> column in _columns)
          if (column.searchable) column,
      ];
    });

    _haystacks = _haystacksMemo.of(<Object?>[_entries, _searched], () {
      return _Haystacks<T>(_entries, _searched);
    });

    final bool sortStaged = widget.manual.contains(NebaDataTableStage.sort);
    final bool filterStaged = widget.manual.contains(NebaDataTableStage.filter);
    final List<NebaDataTableSort> sort = _sort;

    final List<_Entry<T>> ordered = _orderedMemo.of(<Object?>[
      _entries,
      sort,
      _columns,
      sortStaged,
    ], () => sortStaged ? _entries : _sortEntries(sort));

    final String query = (widget.search ?? _searchState).trim();

    _filtered = _filteredMemo.of(
      <Object?>[ordered, query, widget.filter, filterStaged, _searched, _haystacks],
      () {
        if (filterStaged) {
          return ordered;
        }

        final String needle = nebaSearchText(query);
        List<_Entry<T>> result = ordered;

        if (needle.isNotEmpty && _searched.isNotEmpty) {
          final List<String> stacks = _haystacks.all();

          result = <_Entry<T>>[
            for (final _Entry<T> entry in ordered)
              if (stacks[entry.origin].contains(needle)) entry,
          ];
        }

        final bool Function(T row, int index)? filter = widget.filter;

        return filter == null
            ? result
            : <_Entry<T>>[
                for (final _Entry<T> entry in result)
                  if (filter(entry.row, entry.origin)) entry,
              ];
      },
    );

    _groups = _groupsMemo.of(<Object?>[_filtered, widget.groupBy], () {
      final String? Function(T row)? groupBy = widget.groupBy;

      if (groupBy == null) {
        return null;
      }

      final List<String> order = <String>[];
      final Map<String, List<_Entry<T>>> byLabel = <String, List<_Entry<T>>>{};

      for (final _Entry<T> entry in _filtered) {
        final String label = groupBy(entry.row) ?? '';

        byLabel
            .putIfAbsent(label, () {
              order.add(label);

              return <_Entry<T>>[];
            })
            .add(entry);
      }

      // The rows in no group go above everything, since a heading that says
      // nothing is not one a reader can be asked to interpret.
      final List<String> sorted = <String>[
        if (byLabel.containsKey('')) '',
        for (final String label in order)
          if (label != '') label,
      ];

      return (order: sorted, byLabel: byLabel);
    });

    final List<_Entry<T>> arranged = _arrangedMemo.of(
      <Object?>[_groups, _collapsed, _filtered],
      () {
        final ({List<String> order, Map<String, List<_Entry<T>>> byLabel})? groups = _groups;

        if (groups == null) {
          return _filtered;
        }

        return <_Entry<T>>[
          for (final String label in groups.order)
            if (!_collapsed.contains(label)) ...groups.byLabel[label]!,
        ];
      },
    );

    _total = _pagesStaged ? (widget.rowCount ?? arranged.length) : arranged.length;
    _bounds = dataPageBounds(_total, widget.page ?? _pageState, _pageSize);

    _paged = _pagedMemo.of(
      <Object?>[arranged, widget.paging, _pagesStaged, _bounds.start, _bounds.end],
      () => widget.paging != NebaDataTablePaging.pages || _pagesStaged
          ? arranged
          : arranged.sublist(
              math.min(_bounds.start, arranged.length),
              math.min(_bounds.end, arranged.length),
            ),
    );

    _pageIndex = _pageIndexMemo.of(<Object?>[_paged], () {
      return <Object, int>{for (int i = 0; i < _paged.length; i++) _paged[i].key: i};
    });
    _pagedKeys = <Object>[for (final _Entry<T> entry in _paged) entry.key];

    final List<Object> selected = widget.selected ?? _selectedState;

    _selectedKeys = _selectedKeysMemo.of(<Object?>[selected], () => selected.toSet());

    _lines = _linesMemo.of(<Object?>[_paged, _groups, _collapsed, _pageIndex], () {
      final ({List<String> order, Map<String, List<_Entry<T>>> byLabel})? groups = _groups;

      if (groups == null) {
        return <_Line<T>>[for (int i = 0; i < _paged.length; i++) _Line<T>.row(_paged[i], i)];
      }

      final List<_Line<T>> lines = <_Line<T>>[];

      for (final String label in groups.order) {
        final List<_Entry<T>> all = groups.byLabel[label]!;
        final List<_Entry<T>> onPage = <_Entry<T>>[
          for (final _Entry<T> entry in all)
            if (_pageIndex.containsKey(entry.key)) entry,
        ];

        // An open group whose rows are all on other pages has nothing to head
        // here. A folded one has no rows on any page, so it stays on every
        // page, or it could not be opened again.
        if (onPage.isEmpty && !_collapsed.contains(label)) {
          continue;
        }

        lines.add(_Line<T>.group(label, all));

        for (final _Entry<T> entry in onPage) {
          lines.add(_Line<T>.row(entry, _pageIndex[entry.key]!));
        }
      }

      return lines;
    });

    _lineIndex = _lineIndexMemo.of(<Object?>[_lines], () {
      return <Key, int>{for (int i = 0; i < _lines.length; i++) _lines[i].key: i};
    });
  }

  /// Every row in the order the sort puts it, each key's values read once per
  /// row rather than once per comparison.
  List<_Entry<T>> _sortEntries(List<NebaDataTableSort> sort) {
    return dataSortRows<_Entry<T>>(_entries, sort, (String key) {
      NebaDataTableColumn<T>? column;

      for (final NebaDataTableColumn<T> candidate in _columns) {
        if (candidate.key == key) {
          column = candidate;
          break;
        }
      }

      if (column == null) {
        return null;
      }

      final int Function(T a, T b)? compare = column.compare;

      if (compare != null) {
        return DataRowComparator<_Entry<T>>((_Entry<T> a, _Entry<T> b) => compare(a.row, b.row));
      }

      final NebaDataTableColumn<T> read = column;
      final List<Object?> keys = <Object?>[
        for (final _Entry<T> entry in _entries) dataSortKey(_cellValue(read, entry.row)),
      ];

      return DataRowComparator<_Entry<T>>(
        (_Entry<T> a, _Entry<T> b) => dataCompareSortKeys(keys[a.origin], keys[b.origin]),
        isEmpty: (_Entry<T> entry) => keys[entry.origin] == null,
      );
    });
  }

  /// Folds the rows a slice at a time between frames, for a table that
  /// draws its own field, so the first key typed does not wait for all of
  /// them.
  void _foldWhenIdle() {
    if (!widget.searchable ||
        widget.manual.contains(NebaDataTableStage.filter) ||
        _searched.isEmpty ||
        _haystacks.complete ||
        identical(_folding, _haystacks)) {
      return;
    }

    final _Haystacks<T> haystacks = _haystacks;

    _folding = haystacks;

    void slice() {
      if (!mounted || !identical(_folding, haystacks)) {
        return;
      }

      final Stopwatch clock = Stopwatch()..start();
      bool more = haystacks.fold(_foldRows);

      while (more && clock.elapsed < _foldBudget) {
        more = haystacks.fold(_foldRows);
      }

      if (more) {
        _foldTimer = Timer(_foldPause, slice);
      } else {
        _folding = null;
      }
    }

    _foldTimer?.cancel();
    _foldTimer = Timer(_foldPause, slice);
  }

  // -- The controlled values ------------------------------------------------

  void _setSort(List<NebaDataTableSort> next) {
    if (widget.sort == null) {
      setState(() => _sortState = next);
    }

    widget.onSortChange?.call(next);
  }

  void _applySort(String key, {required bool additive}) {
    _setSort(
      dataNextSort(
        _sort,
        key,
        additive: additive && widget.sortMode == NebaDataTableSortMode.multiple,
      ),
    );
  }

  void _setWidths(Map<String, double> next) {
    if (widget.columnWidths == null) {
      setState(() => _widthState = next);
    }

    widget.onColumnWidthsChange?.call(next);
  }

  void _setOrder(List<String> next) {
    if (widget.columnOrder == null) {
      setState(() => _orderState = next);
    }

    widget.onColumnOrderChange?.call(next);
  }

  void _goToPage(int next) {
    if (widget.page == null) {
      setState(() => _pageState = next);
    }

    widget.onPageChange?.call(next);
  }

  void _handleSearch(String next) {
    if (widget.search == null) {
      setState(() => _searchState = next);
    }

    // A query that cuts the table to three pages takes the reader with it, or
    // page 14 answers a search with nothing.
    _goToPage(1);
    widget.onSearchChange?.call(next);
  }

  void _handlePageSize(int next) {
    if (widget.pageSize == null) {
      setState(() => _pageSizeState = next);
    }

    // The reader is somewhere in the data, not on a page number: showing
    // twice as many rows should not move them twice as far down.
    _goToPage(_bounds.start ~/ next + 1);
    widget.onPageSizeChange?.call(next);
  }

  // -- Selection ------------------------------------------------------------

  /// Hands a set of keys to the caller with the rows behind them.
  void _commitSelection(Iterable<Object> keys) {
    final List<Object> chosen = <Object>[];
    final List<T> rows = <T>[];
    // A table the caller pages holds only the page it was given, so a key
    // chosen on another page has no row here, and stays chosen.
    final Set<Object>? held = _pagesStaged ? _selectedKeys : null;

    for (final Object key in keys) {
      final _Entry<T>? entry = _byKey[key];

      if (entry != null) {
        chosen.add(entry.key);
        rows.add(entry.row);
      } else if (held != null && held.contains(key)) {
        chosen.add(key);
      }
    }

    if (widget.selected == null) {
      setState(() => _selectedState = chosen);
    }

    _selectedKeys = chosen.toSet();
    widget.onSelectedChange?.call(chosen, rows);
  }

  /// A plain press: this row, and the rest dropped.
  void _selectOnly(Object key) {
    _anchor = key;
    _commitSelection(<Object>[key]);
  }

  void _toggleKey(Object key) {
    final Set<Object> next = <Object>{..._selectedKeys};

    if (!next.remove(key)) {
      next.add(key);
    }

    _anchor = key;
    _commitSelection(next);
  }

  /// Shift: the run between the anchor and here, replacing what was chosen,
  /// or added to it with Ctrl.
  void _selectRange(Object key, {required bool additive}) {
    final Object? anchor = _anchor ?? (_pagedKeys.isEmpty ? null : _pagedKeys.first);

    if (anchor == null) {
      return;
    }

    final List<Object> run = dataKeysBetween<Object>(
      _pagedKeys,
      anchor,
      key,
      positions: _pageIndex,
    );

    if (run.isEmpty) {
      // The anchor is not on screen, on another page or hidden by a search,
      // so there is no run; the row still answers as a plain press would.
      if (_pageIndex.containsKey(key)) {
        _anchor = key;
        _commitSelection(additive ? <Object>{..._selectedKeys, key} : <Object>[key]);
      }

      return;
    }

    _commitSelection(additive ? <Object>{..._selectedKeys, ...run} : run);
  }

  int get _chosenHere {
    int count = 0;

    for (final Object key in _pagedKeys) {
      if (_selectedKeys.contains(key)) {
        count++;
      }
    }

    return count;
  }

  /// The header tick: every row on the page, or none of them, leaving rows
  /// chosen on other pages chosen.
  void _toggleAll() {
    if (_pagedKeys.isNotEmpty && _chosenHere == _pagedKeys.length) {
      final Set<Object> here = _pagedKeys.toSet();

      _commitSelection(<Object>[
        for (final Object key in _selectedKeys)
          if (!here.contains(key)) key,
      ]);
    } else {
      _commitSelection(<Object>{..._selectedKeys, ..._pagedKeys});
    }
  }

  void _setActive(Object? key) {
    if (_activeKey != key) {
      setState(() => _activeKey = key);
    }
  }

  // -- Where things are -----------------------------------------------------

  /// The line under a global position, which may be past either end.
  int? _lineAt(Offset global) {
    final RenderObject? rows = _rowsKey.currentContext?.findRenderObject();

    if (rows is RenderSliver) {
      final RenderObject? viewport = _viewportKey.currentContext?.findRenderObject();

      if (viewport is! RenderBox || !viewport.hasSize || !_vertical.hasClients) {
        return null;
      }

      final double y =
          viewport.globalToLocal(global).dy +
          _vertical.offset -
          rows.constraints.precedingScrollExtent;

      return (y / _look.rowHeight).floor();
    }

    if (rows is RenderBox && rows.hasSize) {
      return (rows.globalToLocal(global).dy / _look.rowHeight).floor();
    }

    return null;
  }

  /// The row a line stands for: itself, or for a group's heading the last row
  /// above it, so a heading counts as the end of the group over it.
  _Entry<T>? _rowAtLine(int line) {
    if (_lines.isEmpty) {
      return null;
    }

    final int clamped = line.clamp(0, _lines.length - 1);

    for (int i = clamped; i >= 0; i--) {
      final _Entry<T>? entry = _lines[i].entry;

      if (entry != null) {
        return entry;
      }
    }

    for (int i = clamped + 1; i < _lines.length; i++) {
      final _Entry<T>? entry = _lines[i].entry;

      if (entry != null) {
        return entry;
      }
    }

    return null;
  }

  double get _horizontalOffset {
    if (!_horizontal.hasClients) {
      return 0;
    }

    final ScrollPosition position = _horizontal.position;

    return position.hasPixels ? position.pixels : 0;
  }

  /// How far a pinned piece is moved to stay against its edge.
  double _shift(NebaDataTablePin pin, _Geometry geometry) {
    final double offset = _horizontalOffset;

    return switch (pin) {
      NebaDataTablePin.start => offset,
      NebaDataTablePin.end => math.min(0, offset - geometry.overflow),
    };
  }

  /// The column under a position across the table, measured from the start
  /// edge, as drawn: a pinned column where it is held rather than where it
  /// would be.
  NebaDataTableColumn<T>? _columnAt(double start) {
    final _Geometry? geometry = _geometry;

    if (geometry == null) {
      return null;
    }

    for (int pass = 0; pass < 2; pass++) {
      for (int i = 0; i < _columns.length; i++) {
        final NebaDataTablePin? pin = _columns[i].pinned;

        if ((pass == 0) != (pin != null)) {
          continue;
        }

        final double x = geometry.starts[i] + (pin == null ? 0 : _shift(pin, geometry));

        if (start >= x && start < x + geometry.widths[i]) {
          return _columns[i];
        }
      }
    }

    return null;
  }

  /// Puts a row on screen by arithmetic, since a virtual body may not have
  /// built it and a sticky header lies over the top of the rows.
  void _revealRow(Object key) {
    final int? line = _lineIndex[ValueKey<Object>(key)];

    if (line == null) {
      return;
    }

    final RenderObject? rows = _rowsKey.currentContext?.findRenderObject();
    final double rowHeight = _look.rowHeight;

    if (rows is RenderSliver && _vertical.hasClients) {
      final ScrollPosition position = _vertical.position;
      final double top = rows.constraints.precedingScrollExtent + line * rowHeight;
      final double bottom = top + rowHeight;
      final double covered = widget.stickyHeader ? _headRows * _look.headerHeight : 0;
      double next = position.pixels;

      if (top < position.pixels + covered) {
        next = top - covered;
      } else if (bottom > position.pixels + position.viewportDimension) {
        next = bottom - position.viewportDimension;
      }

      next = next.clamp(position.minScrollExtent, position.maxScrollExtent);

      if (next != position.pixels) {
        position.jumpTo(next);
      }

      return;
    }

    if (rows is RenderBox && rows.hasSize) {
      rows.showOnScreen(
        rect: Rect.fromLTWH(0, line * rowHeight, rows.size.width, rowHeight),
        duration: Duration.zero,
      );
    }
  }

  // -- The keyboard ---------------------------------------------------------

  bool get _ctrl => HardwareKeyboard.instance.isControlPressed;

  bool get _meta => HardwareKeyboard.instance.isMetaPressed;

  bool get _shiftHeld => HardwareKeyboard.instance.isShiftPressed;

  void _moveActive(int index, {bool choose = true}) {
    if (_paged.isEmpty) {
      return;
    }

    final _Entry<T> entry = _paged[index.clamp(0, _paged.length - 1)];

    _setActive(entry.key);
    _revealRow(entry.key);

    if (!_selects) {
      return;
    }

    if (_shiftHeld && _multiple) {
      _selectRange(entry.key, additive: false);
    } else if (choose && !_ctrl && !_meta) {
      _selectOnly(entry.key);
    }
  }

  /// Home, End and the Page keys move the body and the active row with it,
  /// and choose nothing: they read as "take me somewhere". A table that is not
  /// bounded scrolls with the page, so they are left to it.
  KeyEventResult _scrollBody(double? to, int index, {bool end = false}) {
    if (!_bounded || !_vertical.hasClients) {
      return KeyEventResult.ignored;
    }

    final ScrollPosition position = _vertical.position;
    final double furthest = position.maxScrollExtent;
    final double next = to == null ? (end ? furthest : 0) : position.pixels + to;

    position.jumpTo(next.clamp(position.minScrollExtent, furthest));
    _moveActive(index, choose: false);

    return KeyEventResult.handled;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    // Only when the table itself holds the focus: a heading's button inside it
    // answers its own Enter and Space.
    if (!_navigable || !node.hasPrimaryFocus || event is KeyUpEvent || _paged.isEmpty) {
      return KeyEventResult.ignored;
    }

    final int index = _activeKey == null ? -1 : (_pageIndex[_activeKey] ?? -1);
    final double rowHeight = _look.rowHeight;
    final double covered = widget.stickyHeader ? _headRows * _look.headerHeight : 0;
    final double room = _vertical.hasClients ? _vertical.position.viewportDimension - covered : 0;
    final int perScreen = math.max(1, ((room > 0 ? room : rowHeight * 10) / rowHeight).floor() - 1);
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveActive(index + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveActive(index == -1 ? 0 : index - 1);
    } else if (key == LogicalKeyboardKey.home) {
      return _scrollBody(null, 0);
    } else if (key == LogicalKeyboardKey.end) {
      return _scrollBody(null, _paged.length - 1, end: true);
    } else if (key == LogicalKeyboardKey.pageDown) {
      return _scrollBody(perScreen * rowHeight, math.max(index, 0) + perScreen);
    } else if (key == LogicalKeyboardKey.pageUp) {
      return _scrollBody(-perScreen * rowHeight, math.max(index, 0) - perScreen);
    } else if (key == LogicalKeyboardKey.space) {
      // The one key that chooses without moving.
      if (!_selects || index == -1) {
        return KeyEventResult.ignored;
      }

      if ((_ctrl || _meta) && _multiple) {
        _toggleKey(_paged[index].key);
      } else {
        _selectOnly(_paged[index].key);
      }
    } else if (key == LogicalKeyboardKey.keyA) {
      if (!_selects || !(_ctrl || _meta) || !_multiple) {
        return KeyEventResult.ignored;
      }

      _commitSelection(_pagedKeys);
    } else if (key == LogicalKeyboardKey.escape) {
      if (!_selects) {
        return KeyEventResult.ignored;
      }

      _commitSelection(const <Object>[]);
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      final void Function(T row, int index)? activate = widget.onRowActivate;

      if (index == -1 || activate == null) {
        return KeyEventResult.ignored;
      }

      activate(_paged[index].row, _displayOffset + index);
    } else if (key == LogicalKeyboardKey.f2) {
      // The spreadsheet's key for "edit this": the first cell of the active
      // row that edits.
      if (index == -1) {
        return KeyEventResult.ignored;
      }

      final _Entry<T> entry = _paged[index];

      for (final NebaDataTableColumn<T> column in _columns) {
        if (_cellEditable(column, entry.row, handled: widget.onCellEdit != null)) {
          _openEditor(entry.key, column.key);

          return KeyEventResult.handled;
        }
      }

      return KeyEventResult.ignored;
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  // -- Pressing and dragging rows -------------------------------------------

  /// Whether a press is on a row the table answers for, and which.
  bool _pressCandidate(PointerDownEvent event) {
    _pressed = null;

    if (!_pressable && !_navigable) {
      return false;
    }

    final int? line = _lineAt(event.position);

    if (line == null || line < 0 || line >= _lines.length) {
      return false;
    }

    final _Entry<T>? entry = _lines[line].entry;

    if (entry == null) {
      return false;
    }

    _pressed = entry;
    _pressedButtons = event.buttons;

    return true;
  }

  /// A mouse or a pen going down on a row, once nothing inside it claimed
  /// the press: what React's `pointerdown` does.
  void _pressDown(PointerDownEvent event) {
    final _Entry<T>? entry = _pressed;

    if (entry == null) {
      return;
    }

    if (_navigable) {
      // The table is the focus stop, not the row: a virtual body cannot hold
      // one on a row that scrolls away.
      _tableFocus.requestFocus();
    }

    if (!_selects) {
      if (_navigable) {
        _setActive(entry.key);
      }

      return;
    }

    _setActive(entry.key);

    if (event.buttons == kSecondaryMouseButton) {
      // A right press outside the selection takes it, so the menu that follows
      // is about what was pressed; on a chosen row it changes nothing.
      if (!_selectedKeys.contains(entry.key)) {
        _selectOnly(entry.key);
      }

      return;
    }

    if (_shiftHeld && _multiple) {
      _selectRange(entry.key, additive: _ctrl || _meta);

      return;
    }

    if ((_ctrl || _meta) && _multiple) {
      _toggleKey(entry.key);

      return;
    }

    _selectOnly(entry.key);

    if (_multiple) {
      _drag = (position: event.position, speed: 0, key: entry.key);
    }
  }

  void _pressMove(PointerMoveEvent event) {
    final ({Offset position, double speed, Object key})? drag = _drag;

    if (drag == null) {
      return;
    }

    double speed = 0;
    final RenderObject? viewport = _viewportKey.currentContext?.findRenderObject();

    if (_bounded && viewport is RenderBox && viewport.hasSize) {
      final Rect rect = viewport.localToGlobal(Offset.zero) & viewport.size;
      final double above = rect.top + _look.rowHeight - event.position.dy;
      final double below = event.position.dy - (rect.bottom - _look.rowHeight);

      speed = above > 0
          ? -math.min(above, 40.0)
          : below > 0
          ? math.min(below, 40.0)
          : 0;
    }

    _drag = (position: event.position, speed: speed, key: drag.key);

    // While the body runs, its frame takes the run once it has scrolled.
    if (_autoScroll.isActive && speed != 0) {
      return;
    }

    _dragTo(event.position);

    if (speed != 0 && !_autoScroll.isActive) {
      _autoScroll.start();
    }
  }

  /// Takes the run from the anchor to the row under [global], once per row
  /// reached rather than once per move.
  void _dragTo(Offset global) {
    final ({Offset position, double speed, Object key})? drag = _drag;
    final int? line = _lineAt(global);
    final _Entry<T>? entry = line == null ? null : _rowAtLine(line);

    if (drag == null || entry == null || drag.key == entry.key) {
      return;
    }

    _drag = (position: drag.position, speed: drag.speed, key: entry.key);
    _setActive(entry.key);
    _selectRange(entry.key, additive: false);
  }

  /// A drag that reaches an edge of the body keeps going, faster the further
  /// past it the pointer is, and stops at the end of the rows.
  void _autoScrollTick(Duration elapsed) {
    final ({Offset position, double speed, Object key})? drag = _drag;

    if (drag == null || drag.speed == 0 || !_vertical.hasClients) {
      _autoScroll.stop();

      return;
    }

    final ScrollPosition position = _vertical.position;
    final double from = position.pixels;
    final double next = (from + drag.speed).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (next != from) {
      position.jumpTo(next);
    }

    _dragTo(drag.position);

    if (next == from) {
      _autoScroll.stop();
    }
  }

  /// The press coming up: a touch chooses here, since a finger that went on
  /// to scroll never comes up as a press, and every press is a click.
  void _pressUp(PointerUpEvent event, {required bool touch}) {
    final _Entry<T>? entry = _pressed;

    _endDrag();

    if (entry == null) {
      return;
    }

    if (touch) {
      if (_navigable) {
        _tableFocus.requestFocus();
        _setActive(entry.key);
      }

      if (_selects) {
        _selectOnly(entry.key);
      }
    }

    // A click is a press that came up on the row it went down on.
    final int? line = _lineAt(event.position);

    if (_pressedButtons == kSecondaryMouseButton ||
        line == null ||
        line < 0 ||
        line >= _lines.length ||
        _lines[line].entry?.key != entry.key) {
      return;
    }

    final int index = _pageIndex[entry.key] ?? 0;
    final int position = _displayOffset + index;

    widget.onRowPressed?.call(entry.row, position);

    if ((_clickTimer?.isActive ?? false) && _clickKey == entry.key) {
      _clickTimer!.cancel();
      _clickKey = null;
      _doublePress(entry, position, event);
    } else {
      _clickTimer?.cancel();
      _clickKey = entry.key;
      _clickTimer = Timer(kDoubleTapTimeout, () => _clickKey = null);
    }
  }

  /// A double press opens the row, or the editor of the cell under it.
  void _doublePress(_Entry<T> entry, int position, PointerUpEvent event) {
    final RenderObject? content = _viewportKey.currentContext?.findRenderObject();
    final _Geometry? geometry = _geometry;

    if (content is RenderBox && geometry != null) {
      final double x = content.globalToLocal(event.position).dx;
      final NebaDataTableColumn<T>? column = _columnAt(_look.rtl ? geometry.width - x : x);

      if (column != null &&
          _cellEditable(column, entry.row, handled: widget.onCellEdit != null) &&
          _editing?.key != entry.key) {
        _openEditor(entry.key, column.key);

        return;
      }
    }

    widget.onRowActivate?.call(entry.row, position);
  }

  void _endDrag() {
    _drag = null;

    if (_autoScroll.isActive) {
      _autoScroll.stop();
    }
  }

  /// What a screen reader's tap on a row does: a press, from nowhere.
  void _semanticPress(_Entry<T> entry) {
    if (_selects) {
      _setActive(entry.key);
      _selectOnly(entry.key);
    }

    widget.onRowPressed?.call(entry.row, _displayOffset + (_pageIndex[entry.key] ?? 0));
  }

  // -- Columns --------------------------------------------------------------

  /// Every column's width written down, so a drag moves one boundary rather
  /// than the share every column without a width takes.
  Map<String, double> _frozenWidths() {
    final Map<String, double> frozen = <String, double>{..._widths};
    final _Geometry? geometry = _geometry;

    if (geometry != null) {
      for (int i = 0; i < _columns.length; i++) {
        frozen.putIfAbsent(_columns[i].key, () => geometry.widths[i]);
      }
    }

    return frozen;
  }

  /// A double press on a handle gives the column back the width it had.
  void _resetWidth(String key) {
    _setWidths(<String, double>{..._widths}..remove(key));
  }

  bool _startResize(String key, Offset position) {
    final Map<String, double> frozen = _frozenWidths();

    _frozen = frozen;
    _resizeFrom = frozen[key] ?? dataDefaultColumnWidth;

    return true;
  }

  void _resize(String key, Offset travelled) {
    final Map<String, double>? frozen = _frozen;

    if (frozen == null) {
      return;
    }

    final double delta = travelled.dx * (_look.rtl ? -1 : 1);

    _setWidths(<String, double>{
      ...frozen,
      key: math.max(_widthFloor(key), (_resizeFrom + delta).roundToDouble()),
    });
  }

  void _nudgeWidth(String key, {required bool wider}) {
    final Map<String, double> frozen = _frozenWidths();
    final double from = frozen[key] ?? dataDefaultColumnWidth;

    _setWidths(<String, double>{
      ...frozen,
      key: math.max(_widthFloor(key), from + (wider ? _keyboardStep : -_keyboardStep)),
    });
  }

  bool _startReorder(String key, Offset position) {
    final _Geometry? geometry = _geometry;
    final int index = _columns.indexWhere((NebaDataTableColumn<T> c) => c.key == key);

    if (geometry == null || index == -1) {
      return false;
    }

    final double width = geometry.widths[index];

    _reorderOrigin = geometry.starts[index] + (_look.rtl ? width - position.dx : position.dx);
    _reorderArmed = false;

    return true;
  }

  void _reorderMove(String key, Offset travelled) {
    if (!_reorderArmed) {
      if (travelled.dx.abs() < _reorderSlop) {
        return;
      }

      _reorderArmed = true;
      setState(() => _movingKey = key);
    }

    final _Geometry? geometry = _geometry;

    if (geometry == null) {
      return;
    }

    final double x = _reorderOrigin + travelled.dx * (_look.rtl ? -1 : 1);
    String? over;

    for (int i = 0; i < _columns.length; i++) {
      if (_columns[i].pinned == null &&
          x >= geometry.starts[i] &&
          x <= geometry.starts[i] + geometry.widths[i]) {
        over = _columns[i].key;
        break;
      }
    }

    final String? drop = over != null && over != key ? over : null;

    if (drop != _dropKey) {
      setState(() => _dropKey = drop);
    }
  }

  void _reorderEnd() {
    final String? moving = _movingKey;
    final String? target = _dropKey;

    _reorderArmed = false;
    setState(() {
      _movingKey = null;
      _dropKey = null;
    });

    if (moving != null && target != null && moving != target) {
      final List<String> keys = <String>[for (final NebaDataTableColumn<T> c in _columns) c.key];
      final int from = keys.indexOf(moving);
      final int to = keys.indexOf(target);

      keys.insert(to, keys.removeAt(from));
      _setOrder(keys);
    }
  }

  /// Alt and an arrow on a heading moves its column one place, stopping at a
  /// pinned neighbour.
  KeyEventResult _moveColumnByKey(String key, KeyEvent event) {
    final LogicalKeyboardKey pressed = event.logicalKey;

    if (event is KeyUpEvent ||
        !HardwareKeyboard.instance.isAltPressed ||
        (pressed != LogicalKeyboardKey.arrowLeft && pressed != LogicalKeyboardKey.arrowRight)) {
      return KeyEventResult.ignored;
    }

    final int step = (pressed == LogicalKeyboardKey.arrowRight) != _look.rtl ? 1 : -1;
    final List<String> keys = <String>[for (final NebaDataTableColumn<T> c in _columns) c.key];
    final int from = keys.indexOf(key);
    final int to = from + step;

    if (to < 0 || to >= _columns.length || _columns[to].pinned != null) {
      return KeyEventResult.handled;
    }

    keys.insert(to, keys.removeAt(from));
    _setOrder(keys);

    return KeyEventResult.handled;
  }

  // -- Editing --------------------------------------------------------------

  void _openEditor(Object key, String column) {
    setState(() => _editing = (key: key, column: column));
  }

  void _closeEditor({required bool refocus}) {
    setState(() {
      _editing = null;
      _editorFocused = false;
    });

    if (refocus) {
      // The arrows carry on from the row that was edited.
      _tableFocus.requestFocus();
    }
  }

  /// Hands what the editor holds to `onCellEdit`, when it holds a change. An
  /// emptied number field holds no number, and writes no zero.
  void _commitEdit(
    _Entry<T> entry,
    NebaDataTableColumn<T> column,
    String raw, {
    required bool refocus,
  }) {
    _closeEditor(refocus: refocus);

    final Object? initial = _cellValue(column, entry.row);
    final Object next;

    if (column.editType == NebaDataTableEditType.number) {
      final num? number = num.tryParse(raw.trim());

      if (number == null || number.isNaN) {
        return;
      }

      next = number;
    } else {
      next = raw;
    }

    if (_stringOf(next) != _stringOf(initial)) {
      widget.onCellEdit?.call(entry.row, column, next);
    }
  }

  // -- The export -----------------------------------------------------------

  /// Everything the reader is looking at, as a file: the search and the sort
  /// applied, the page not, because a file of page 3 is not one anybody asked
  /// for.
  void _export() {
    final ValueChanged<String>? onExport = widget.onExport;

    if (onExport == null) {
      return;
    }

    final List<NebaDataTableColumn<T>> shown = <NebaDataTableColumn<T>>[
      for (final NebaDataTableColumn<T> column in _columns)
        if (column.exportable) column,
    ];

    onExport(
      nebaToCsv(<List<Object?>>[
        <Object?>[for (final NebaDataTableColumn<T> column in shown) _labelText(column)],
        for (final _Entry<T> entry in _filtered)
          <Object?>[
            for (final NebaDataTableColumn<T> column in shown)
              column.exportValue != null
                  ? column.exportValue!(entry.row)
                  : _cellValue(column, entry.row),
          ],
      ], escapeFormulas: widget.exportEscapeFormulas),
    );
  }

  // -- Geometry -------------------------------------------------------------

  /// The columns laid across [available]: a column with a width keeps it, the
  /// rest share what is left, and once every column has one an empty column
  /// claims the slack, so a dragged width is the width it says.
  _Geometry _layoutColumns(double available) {
    final double tick = _showTicks ? dataTickWidths[_look.size]! : 0;
    double fixed = tick;
    double minimum = tick;
    int flexible = 0;

    for (final NebaDataTableColumn<T> column in _columns) {
      final double? width = _explicitWidth(column);

      if (width != null) {
        fixed += width;
        minimum += width;
      } else {
        flexible++;
        minimum += dataMinColumnWidth;
      }
    }

    final double width = math.max(available, minimum);
    final double share = flexible == 0 ? 0 : (width - fixed) / flexible;
    final List<double> starts = <double>[];
    final List<double> widths = <double>[];
    double x = tick;

    for (final NebaDataTableColumn<T> column in _columns) {
      final double each = _explicitWidth(column) ?? share;

      starts.add(x);
      widths.add(each);
      x += each;
    }

    return _Geometry(
      tick: tick,
      starts: starts,
      widths: widths,
      filler: _columns.isNotEmpty && flexible == 0 ? math.max(0, width - x) : 0,
      width: width,
      overflow: math.max(0, width - available),
    );
  }

  /// [pieces] laid across the table at [height], the pinned ones last so they
  /// are drawn over the columns that scroll under them.
  Widget _strip(_Geometry geometry, double height, List<_Piece> pieces) {
    return SizedBox(
      width: geometry.width,
      height: height,
      child: Stack(
        children: <Widget>[
          for (final _Piece piece in pieces)
            if (piece.pin == null)
              PositionedDirectional(
                key: piece.key,
                start: piece.start,
                top: piece.top,
                width: piece.width,
                height: piece.height ?? height,
                child: piece.child,
              ),
          for (final _Piece piece in pieces)
            if (piece.pin != null)
              ListenableBuilder(
                key: piece.key,
                listenable: _horizontal,
                builder: (BuildContext context, Widget? child) {
                  return PositionedDirectional(
                    start: piece.start + _shift(piece.pin!, geometry),
                    top: piece.top,
                    width: piece.width,
                    height: piece.height ?? height,
                    child: child!,
                  );
                },
                child: piece.child,
              ),
        ],
      ),
    );
  }

  // -- Building -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.sm;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.compact;
    final NebaVariant variant = widget.variant ?? defaults.variant ?? NebaVariant.outline;
    final NebaColor color = widget.color ?? NebaColor.primary;
    final NebaColorRoles roles = tokens.roles(color);

    _look = _Look(
      tokens: tokens,
      roles: roles,
      size: size,
      density: density,
      color: color,
      padX: NebaScale.paddingX[density]![size]!,
      rowHeight: widget.rowHeight ?? dataRowHeights[density]![size]!,
      headerHeight: dataHeaderHeights[density]![size]!,
      messages: nebaMessages(context, 'table', locale: widget.locale),
      duration: nebaDuration(context, NebaScale.duration),
      rtl: Directionality.of(context) == TextDirection.rtl,
    );

    _derive();
    _foldWhenIdle();
    _warnUnwindowed();

    final _Look look = _look;
    final double text = NebaScale.controlText[size]!;
    final bool showFooter = widget.footer ?? widget.paging == NebaDataTablePaging.pages;
    final bool bar =
        widget.searchable ||
        (widget.exportable && widget.onExport != null) ||
        widget.toolbar != null;
    final String range = fillNebaMessage(look.messages['range']!, <String, String>{
      'start': nebaFormatNumber(
        _total == 0 ? 0 : (widget.paging == NebaDataTablePaging.pages ? _bounds.start : 0) + 1,
      ),
      'end': nebaFormatNumber(widget.paging == NebaDataTablePaging.pages ? _bounds.end : _total),
      'total': nebaFormatNumber(_total),
    });
    final String chosen = _selects && _selectedKeys.isNotEmpty
        ? fillNebaMessage(look.messages['selected']!, <String, String>{
            'count': nebaFormatNumber(_selectedKeys.length),
          })
        : '';

    final Widget? caption = widget.caption;
    final String? name =
        widget.semanticLabel ?? (caption is Text && caption.data != null ? caption.data : null);

    final Widget table = Semantics(
      container: true,
      label: name,
      child: Focus(
        focusNode: _tableFocus,
        canRequestFocus: _navigable,
        skipTraversal: !_navigable,
        onKeyEvent: _handleKey,
        child: _viewport(look),
      ),
    );

    final Widget sheet = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (bar) _bar(look),
            if (constraints.hasBoundedHeight) Flexible(fit: FlexFit.loose, child: table) else table,
            if (showFooter) _footer(look, range, chosen),
            // The same two counts with no footer to draw them: a live region
            // says nothing until a search or a selection changes a number.
            if (!showFooter)
              NebaVisuallyHidden(
                child: NebaLiveRegion(
                  role: SemanticsRole.status,
                  child: Text(chosen.isEmpty ? range : '$range $chosen'),
                ),
              ),
          ],
        );
      },
    );

    final Widget box = NebaBox(
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: widget.elevation ?? 0,
      padded: false,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: text,
          height: NebaScale.controlLeading[size]! / text,
          color: tokens.fg,
        ),
        child: sheet,
      ),
    );

    // The table's own focus, and an open editor's: not any focus inside the
    // sheet, since the search field and the footer's controls ring themselves.
    final bool ringed = (_tableFocused && !NebaInputModality.pointer.value) || _editorFocused;

    return NebaFocusRing(
      visible: ringed,
      color: roles.ring,
      keyboardOnly: false,
      borderRadius: BorderRadius.circular(tokens.radius[size]!),
      child: box,
    );
  }

  /// A debug build says once, when a long table builds every row because
  /// nothing bounds it, why the screen is slow.
  void _warnUnwindowed() {
    if (!kDebugMode ||
        _warnedUnwindowed ||
        !widget.virtual ||
        _bounded ||
        _paged.length <= _unwindowedRows) {
      return;
    }

    _warnedUnwindowed = true;
    debugPrint(
      'Neba: a NebaDataTable is building ${_paged.length} rows at once, because nothing '
      'bounds its height. Give it a height or a maxHeight to build only the rows on screen, '
      'or page it with paging: NebaDataTablePaging.pages. Pass virtual: false if every row '
      'is meant to be built.',
    );
  }

  Widget _bar(_Look look) {
    final bool exports = widget.exportable && widget.onExport != null;
    final Widget? toolbar = widget.toolbar;
    final String placeholder = widget.searchPlaceholder ?? look.messages['search']!;

    return Container(
      decoration: BoxDecoration(border: Border(bottom: look.rule)),
      padding: EdgeInsets.all(look.padX),
      child: Row(
        children: <Widget>[
          if (widget.searchable)
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 256),
                  child: NebaTextField(
                    controller: _searchField,
                    size: look.size,
                    color: look.color,
                    density: look.density,
                    variant: NebaVariant.outline,
                    fullWidth: true,
                    startIcon: NebaGlyph(_searchGlyph),
                    placeholder: placeholder,
                    semanticLabel: placeholder,
                    textInputAction: TextInputAction.search,
                    onChanged: _handleSearch,
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          if (toolbar != null || exports) ...<Widget>[
            SizedBox(width: NebaScale.gap[look.size]),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: <Widget>[
                ?toolbar,
                if (exports)
                  NebaButton(
                    size: look.size,
                    color: look.color,
                    density: look.density,
                    variant: NebaVariant.outline,
                    onPressed: _export,
                    child: Text(look.messages['exportCsv']!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _footer(_Look look, String range, String chosen) {
    const List<FontFeature> tabular = <FontFeature>[FontFeature.tabularFigures()];
    final bool pages = widget.paging == NebaDataTablePaging.pages;

    return Container(
      decoration: BoxDecoration(border: Border(top: look.rule)),
      padding: EdgeInsets.symmetric(horizontal: look.padX, vertical: 6),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: NebaScale.metaText[look.size]),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            // One status around both counts, there whether or not anything is
            // chosen: a live region that arrives with its text is never read.
            NebaLiveRegion(
              role: SemanticsRole.status,
              child: Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    range,
                    style: TextStyle(color: look.tokens.mutedFg, fontFeatures: tabular),
                  ),
                  if (chosen.isNotEmpty)
                    Text(
                      chosen,
                      style: TextStyle(color: look.roles.accent, fontFeatures: tabular),
                    ),
                ],
              ),
            ),
            if (pages)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: <Widget>[
                  if (widget.pageSizeOptions.isNotEmpty)
                    NebaSelect<int>(
                      size: look.size,
                      color: look.color,
                      density: look.density,
                      variant: NebaVariant.outline,
                      label: Text(look.messages['rowsPerPage']!),
                      items: <NebaSelectOption<int>>[
                        for (final int option in widget.pageSizeOptions)
                          NebaSelectOption<int>(
                            value: option,
                            label: Text(nebaFormatNumber(option)),
                          ),
                      ],
                      value: _pageSize,
                      onValueChange: _handlePageSize,
                    ),
                  NebaPagination(
                    size: look.size,
                    color: look.color,
                    locale: widget.locale,
                    count: _bounds.pages,
                    page: _bounds.page,
                    siblingCount: 0,
                    onPageChange: _goToPage,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _viewport(_Look look) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _layoutColumns(0).width;
        final _Geometry geometry = _layoutColumns(available);

        _geometry = geometry;

        Widget content = _bounded
            ? _scrollingBody(look, geometry)
            : _flatBody(look, geometry, scrolls: constraints.hasBoundedHeight);

        content = SizedBox(width: geometry.width, child: content);
        content = RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: <Type, GestureRecognizerFactory>{
            _RowPressRecognizer: GestureRecognizerFactoryWithHandlers<_RowPressRecognizer>(
              () => _RowPressRecognizer(debugOwner: this),
              (_RowPressRecognizer recognizer) {
                recognizer
                  ..onCandidate = _pressCandidate
                  ..onDown = _pressDown
                  ..onMove = _pressMove
                  ..onUp = _pressUp
                  ..onEnd = _endDrag;
              },
            ),
          },
          child: content,
        );

        if (geometry.overflow > 0) {
          content = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontal,
            child: content,
          );
        }

        final double? height = widget.height;
        final double? maxHeight = widget.maxHeight;

        if (height != null) {
          content = SizedBox(height: height, child: content);
        } else if (maxHeight != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: content,
          );
        }

        return content;
      },
    );
  }

  Widget? _caption(_Look look) {
    final Widget? caption = widget.caption;

    if (caption == null) {
      return null;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: look.padX, vertical: 8),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: NebaScale.metaText[look.size], color: look.tokens.mutedFg),
        child: Align(alignment: AlignmentDirectional.centerStart, child: caption),
      ),
    );
  }

  Widget _scrollingBody(_Look look, _Geometry geometry) {
    final Widget? caption = _caption(look);
    Widget header = _header(look, geometry);

    if (widget.stickyHeader && look.tokens.blurSigma > 0) {
      // The rows scroll under a held header, which frosts them.
      header = ClipRect(
        child: BackdropFilter(filter: backdropFilter(look.tokens), child: header),
      );
    }

    final Widget body;

    if (_lines.isEmpty) {
      body = SliverToBoxAdapter(child: _emptyLine(look, geometry));
    } else if (_virtualized) {
      body = SliverFixedExtentList(
        key: _rowsKey,
        itemExtent: look.rowHeight,
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => _line(look, geometry, index),
          childCount: _lines.length,
          findChildIndexCallback: (Key key) => _lineIndex[key],
        ),
      );
    } else {
      body = SliverToBoxAdapter(
        child: Column(
          key: _rowsKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[for (int i = 0; i < _lines.length; i++) _line(look, geometry, i)],
        ),
      );
    }

    return CustomScrollView(
      key: _viewportKey,
      controller: _vertical,
      shrinkWrap: widget.height == null,
      // `scrollCacheExtent` replaces this from Flutter 3.43, and the package
      // still runs on 3.41.
      // ignore: deprecated_member_use
      cacheExtent: widget.overscan * look.rowHeight,
      slivers: <Widget>[
        if (caption != null) SliverToBoxAdapter(child: caption),
        if (widget.stickyHeader)
          PinnedHeaderSliver(child: header)
        else
          SliverToBoxAdapter(child: header),
        body,
      ],
    );
  }

  Widget _flatBody(_Look look, _Geometry geometry, {required bool scrolls}) {
    final Widget? caption = _caption(look);
    final Widget column = Column(
      key: _viewportKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ?caption,
        _header(look, geometry),
        if (_lines.isEmpty)
          _emptyLine(look, geometry)
        else
          Column(
            key: _rowsKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[for (int i = 0; i < _lines.length; i++) _line(look, geometry, i)],
          ),
      ],
    );

    return scrolls ? SingleChildScrollView(controller: _vertical, child: column) : column;
  }

  Widget _emptyLine(_Look look, _Geometry geometry) {
    return SizedBox(
      width: geometry.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: look.padX, vertical: 32),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: look.tokens.mutedFg),
          textAlign: TextAlign.center,
          child: Center(
            child:
                widget.empty ??
                Text(nebaMessages(context, 'empty', locale: widget.locale)['title']!),
          ),
        ),
      ),
    );
  }

  Widget _line(_Look look, _Geometry geometry, int index) {
    final _Line<T> line = _lines[index];
    final _Entry<T>? entry = line.entry;

    if (entry != null) {
      return _bodyRow(look, geometry, entry, line.index);
    }

    return _groupRow(look, geometry, line.label!, line.rows!);
  }

  // -- The header -----------------------------------------------------------

  Widget _header(_Look look, _Geometry geometry) {
    final double h = look.headerHeight;
    final bool grouped = _hasGroups;
    final double height = h * _headRows;
    final bool pinsStart = _columns.any(
      (NebaDataTableColumn<T> c) => c.pinned == NebaDataTablePin.start,
    );
    final List<_Piece> pieces = <_Piece>[];

    Widget headCell({required Widget child, AlignmentGeometry? alignment, double? padding}) {
      return Container(
        decoration: BoxDecoration(
          color: look.tokens.panelPress,
          border: Border(bottom: look.rule),
        ),
        padding: EdgeInsets.symmetric(horizontal: padding ?? look.padX),
        alignment: alignment ?? AlignmentDirectional.centerStart,
        child: child,
      );
    }

    if (_showTicks) {
      final int chosen = _chosenHere;
      final bool all = _pagedKeys.isNotEmpty && chosen == _pagedKeys.length;

      pieces.add(
        _Piece(
          key: const ValueKey<String>('tick'),
          start: 0,
          width: geometry.tick,
          pin: pinsStart ? NebaDataTablePin.start : null,
          child: headCell(
            padding: 0,
            alignment: Alignment.center,
            child: _multiple
                ? NebaCheckbox(
                    size: look.size,
                    color: look.color,
                    checked: all,
                    indeterminate: chosen > 0 && !all,
                    semanticLabel: look.messages['selectAll'],
                    onCheckedChange: (bool _) => _toggleAll(),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      );
    }

    // The merged headings over runs of columns with the same group.
    if (grouped) {
      int i = 0;

      while (i < _columns.length) {
        final String? group = _columns[i].group;
        int end = i + 1;

        while (group != null && end < _columns.length && _columns[end].group == group) {
          end++;
        }

        if (group != null) {
          final double start = geometry.starts[i];
          final double width = geometry.starts[end - 1] + geometry.widths[end - 1] - start;

          pieces.add(
            _Piece(
              key: ValueKey<String>('group-$i'),
              start: start,
              width: width,
              height: h,
              child: headCell(
                alignment: Alignment.center,
                child: Text(
                  group,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: look.tokens.mutedFg, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }

        i = end;
      }
    }

    for (int index = 0; index < _columns.length; index++) {
      final NebaDataTableColumn<T> column = _columns[index];
      final bool spans = grouped && column.group == null;
      final double top = grouped && !spans ? h : 0;
      final double cellHeight = spans ? height : h;

      pieces.add(
        _Piece(
          key: ValueKey<String>('head-${column.key}'),
          start: geometry.starts[index],
          width: geometry.widths[index],
          top: top,
          height: cellHeight,
          pin: column.pinned,
          child: _heading(look, column, index),
        ),
      );
    }

    if (geometry.filler > 0) {
      pieces.add(
        _Piece(
          key: const ValueKey<String>('filler'),
          start: geometry.width - geometry.filler,
          width: geometry.filler,
          child: headCell(padding: 0, child: const SizedBox.shrink()),
        ),
      );
    }

    // The resize handles, over the headings, straddling each boundary.
    for (int index = 0; index < _columns.length - 1; index++) {
      final NebaDataTableColumn<T> column = _columns[index];

      if (!(column.resizable ?? widget.resizable)) {
        continue;
      }

      final bool spans = grouped && column.group == null;

      pieces.add(
        _Piece(
          key: ValueKey<String>('resize-${column.key}'),
          start: geometry.starts[index] + geometry.widths[index] - 4,
          width: 8,
          top: grouped && !spans ? h : 0,
          height: spans ? height : h,
          pin: column.pinned,
          child: _ResizeHandle(
            label: fillNebaMessage(look.messages['resizeColumn']!, <String, String>{
              'column': _labelText(column),
            }),
            width: geometry.widths[index],
            minWidth: _widthFloor(column.key),
            accent: look.roles.accent,
            ring: look.roles.ring,
            duration: look.duration,
            rtl: look.rtl,
            onStart: (Offset position) => _startResize(column.key, position),
            onMove: (Offset travelled) => _resize(column.key, travelled),
            onReset: () => _resetWidth(column.key),
            onNudge: ({required bool wider}) => _nudgeWidth(column.key, wider: wider),
          ),
        ),
      );
    }

    return Semantics(container: true, child: _strip(geometry, height, pieces));
  }

  Widget _heading(_Look look, NebaDataTableColumn<T> column, int index) {
    final bool canSort = column.sortable ?? widget.sortable;
    final bool canMove = widget.reorderable && column.pinned == null;
    final List<NebaDataTableSort> sort = _sort;
    final int order = sort.indexWhere((NebaDataTableSort entry) => entry.key == column.key) + 1;
    final NebaDataTableSort? entry = order == 0 ? null : sort[order - 1];
    final NebaAlign align = column.headerAlign ?? column.align;
    final bool moving = _movingKey == column.key;
    final bool dropping = _dropKey == column.key;
    final Widget label = column.label ?? Text(column.key);
    final Color ink = entry != null ? look.roles.accent : look.tokens.mutedFg;

    Widget content;

    if (canSort) {
      content = _SortButton(
        label: label,
        name: _labelText(column),
        align: align,
        direction: entry?.direction,
        order: order,
        sortValue: entry == null
            ? null
            : fillNebaMessage(
                look.messages[entry.direction == NebaDataTableSortDirection.desc
                    ? 'sortDescending'
                    : 'sortAscending']!,
                <String, String>{'order': nebaFormatNumber(order)},
              ),
        ink: ink,
        accent: look.roles.accent,
        ring: look.roles.ring,
        duration: look.duration,
        onPressed: () => _applySort(column.key, additive: _shiftHeld),
      );
    } else {
      content = label;
    }

    // A heading carried takes the wash a dragged handle takes, over its own
    // ground, rather than a fade.
    final Color ground = moving
        ? Color.alphaBlend(look.roles.soft, look.tokens.panelPress)
        : look.tokens.panelPress;
    final bool forward =
        _movingKey != null &&
        _columns.indexWhere((NebaDataTableColumn<T> c) => c.key == _movingKey) < index;

    Widget cell = Container(
      decoration: BoxDecoration(
        color: ground,
        border: Border(bottom: look.rule),
      ),
      foregroundDecoration: dropping
          ? BoxDecoration(
              border: forward
                  ? BorderDirectional(end: BorderSide(color: look.roles.accent, width: 2))
                  : BorderDirectional(start: BorderSide(color: look.roles.accent, width: 2)),
            )
          : null,
      padding: EdgeInsets.symmetric(horizontal: look.padX),
      alignment: _alignmentOf(align),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: ink, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: _textAlignOf(align),
        child: content,
      ),
    );

    if (canMove) {
      cell = _HeadingMover(
        focusable: !canSort,
        ring: look.roles.ring,
        moving: moving,
        onKey: (KeyEvent event) => _moveColumnByKey(column.key, event),
        onStart: (Offset position) => _startReorder(column.key, position),
        onMove: (Offset travelled) => _reorderMove(column.key, travelled),
        onEnd: _reorderEnd,
        child: cell,
      );
    }

    return cell;
  }

  // -- The body -------------------------------------------------------------

  Widget _bodyRow(_Look look, _Geometry geometry, _Entry<T> entry, int index) {
    final bool selected = _selectedKeys.contains(entry.key);
    final bool active = _navigable && _activeKey == entry.key;
    final String? editing = _editing?.key == entry.key ? _editing!.column : null;
    final int position = _displayOffset + index;
    final int? stripe = switch (widget.striped) {
      NebaDataTableStripe.none => null,
      NebaDataTableStripe.odd => 0,
      NebaDataTableStripe.even => 1,
    };
    final bool striped = stripe != null && index % 2 == stripe;
    final bool pinsStart = _columns.any(
      (NebaDataTableColumn<T> c) => c.pinned == NebaDataTablePin.start,
    );
    final bool handled = widget.onCellEdit != null;
    final List<_Piece> cells = <_Piece>[];

    Widget ruled(Widget child, {AlignmentGeometry? alignment, double? padding}) {
      return Container(
        decoration: BoxDecoration(border: Border(bottom: look.rule)),
        padding: EdgeInsets.symmetric(horizontal: padding ?? look.padX),
        alignment: alignment,
        child: child,
      );
    }

    if (_showTicks) {
      final String first = _columns.isEmpty
          ? ''
          : _plainText(_cellValue(_columns.first, entry.row));

      // Out of the tab order, since Space already chooses the active row, and
      // named after its row.
      cells.add(
        _Piece(
          key: const ValueKey<String>('tick'),
          start: 0,
          width: geometry.tick,
          pin: pinsStart ? NebaDataTablePin.start : null,
          child: ruled(
            padding: 0,
            alignment: Alignment.center,
            ExcludeFocus(
              child: NebaCheckbox(
                size: look.size,
                color: look.color,
                checked: selected,
                semanticLabel: first.isEmpty
                    ? look.messages['selectRow']
                    : '${look.messages['selectRow']} $first',
                onCheckedChange: (bool _) {
                  if (_multiple) {
                    _toggleKey(entry.key);
                  } else {
                    _selectOnly(entry.key);
                  }
                },
              ),
            ),
          ),
        ),
      );
    }

    for (int c = 0; c < _columns.length; c++) {
      final NebaDataTableColumn<T> column = _columns[c];
      final bool open = editing == column.key;
      final bool editable = _cellEditable(column, entry.row, handled: handled);
      final Widget Function(BuildContext context, T row, int index)? builder = column.builder;
      Widget content;

      if (open) {
        content = _CellEditor(
          key: ValueKey<String>('editor-${column.key}'),
          initial: _stringOf(_cellValue(column, entry.row)),
          align: column.align,
          number: column.editType == NebaDataTableEditType.number,
          label: _labelText(column),
          roles: look.roles,
          onFocusChange: (bool focused) {
            if (_editorFocused != focused && mounted) {
              setState(() => _editorFocused = focused);
            }
          },
          onSubmit: (String raw) => _commitEdit(entry, column, raw, refocus: true),
          onCancel: () => _closeEditor(refocus: true),
          onBlur: (String raw) => _commitEdit(entry, column, raw, refocus: false),
        );
      } else if (builder != null) {
        content = Builder(builder: (BuildContext context) => builder(context, entry.row, position));
      } else {
        final Object? value = _cellValue(column, entry.row);

        content = value is Widget ? value : Text(_plainText(value));
      }

      Widget cell = ruled(
        alignment: _alignmentOf(column.align),
        DefaultTextStyle.merge(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: _textAlignOf(column.align),
          child: content,
        ),
      );

      if (editable && !open) {
        cell = MouseRegion(cursor: SystemMouseCursors.cell, child: cell);
      }

      cells.add(
        _Piece(
          key: ValueKey<String>('cell-${column.key}'),
          start: geometry.starts[c],
          width: geometry.widths[c],
          pin: column.pinned,
          child: cell,
        ),
      );
    }

    if (geometry.filler > 0) {
      cells.add(
        _Piece(
          key: const ValueKey<String>('filler'),
          start: geometry.width - geometry.filler,
          width: geometry.filler,
          child: ruled(padding: 0, const SizedBox.shrink()),
        ),
      );
    }

    final Color panel = look.tokens.panelPress;

    return _HoverRow(
      key: ValueKey<Object>(entry.key),
      hoverable: widget.hoverable && !selected,
      cursor: _pressable ? SystemMouseCursors.basic : MouseCursor.defer,
      builder: (BuildContext context, bool hovered) {
        final Color tint = selected
            ? look.roles.softPress
            : hovered
            ? look.roles.soft
            : striped
            ? look.stripe
            : const Color(0x00000000);

        return Semantics(
          container: true,
          selected: _selects ? selected : null,
          onTap: _pressable ? () => _semanticPress(entry) : null,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: tint),
            duration: look.duration,
            curve: NebaScale.ease,
            builder: (BuildContext context, Color? value, Widget? _) {
              final Color row = value ?? tint;

              return Container(
                height: look.rowHeight,
                color: row,
                foregroundDecoration: active
                    ? BoxDecoration(border: Border.all(color: look.roles.ring))
                    : null,
                child: _strip(geometry, look.rowHeight, <_Piece>[
                  for (final _Piece piece in cells)
                    if (piece.pin == null)
                      piece
                    else
                      _Piece(
                        key: piece.key,
                        start: piece.start,
                        width: piece.width,
                        pin: piece.pin,
                        // The tint over the sheet's own ground, so a frozen cell
                        // keeps the stripe, the hover and the selection and still
                        // covers what scrolls under it.
                        child: ColoredBox(color: Color.alphaBlend(row, panel), child: piece.child),
                      ),
                ]),
              );
            },
          ),
        );
      },
    );
  }

  /// The row that stands over a group, with a cell per column so a group's
  /// figure sits in the column it is a total of.
  Widget _groupRow(_Look look, _Geometry geometry, String label, List<_Entry<T>> rows) {
    final bool folded = _collapsed.contains(label);
    final List<T> plain = <T>[for (final _Entry<T> entry in rows) entry.row];
    final List<_Piece> pieces = <_Piece>[];
    final bool pinsStart = _columns.any(
      (NebaDataTableColumn<T> c) => c.pinned == NebaDataTablePin.start,
    );
    final Color ground = Color.alphaBlend(look.roles.soft, look.tokens.panelPress);

    void toggle() {
      setState(() {
        _collapsed = <String>{..._collapsed};

        if (!_collapsed.remove(label)) {
          _collapsed.add(label);
        }
      });
    }

    Widget cell(Widget child, {required NebaAlign align, NebaDataTablePin? pin, double? padding}) {
      return Container(
        decoration: BoxDecoration(
          color: pin == null ? null : ground,
          border: Border(bottom: look.rule),
        ),
        padding: EdgeInsets.symmetric(horizontal: padding ?? look.padX),
        alignment: _alignmentOf(align),
        child: child,
      );
    }

    if (_showTicks) {
      pieces.add(
        _Piece(
          key: const ValueKey<String>('tick'),
          start: 0,
          width: geometry.tick,
          pin: pinsStart ? NebaDataTablePin.start : null,
          child: cell(
            const SizedBox.shrink(),
            align: NebaAlign.center,
            pin: pinsStart ? NebaDataTablePin.start : null,
            padding: 0,
          ),
        ),
      );
    }

    final Widget title = Row(
      spacing: 6,
      children: <Widget>[
        if (widget.collapsibleGroups)
          AnimatedRotation(
            turns: folded ? (look.rtl ? 0.25 : -0.25) : 0,
            duration: look.duration,
            curve: NebaScale.ease,
            child: NebaGlyph(
              NebaGlyphs.chevron,
              size: NebaScale.controlText[look.size]! * 1.15,
              color: look.tokens.mutedFg,
            ),
          ),
        Flexible(
          child: Text(
            label.isEmpty ? look.messages['noGroup']! : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          nebaFormatNumber(rows.length),
          style: TextStyle(
            color: look.tokens.mutedFg,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    for (int c = 0; c < _columns.length; c++) {
      final NebaDataTableColumn<T> column = _columns[c];
      final Widget Function(List<T> rows)? aggregate = column.aggregate;
      Widget content;

      if (c == 0) {
        content = widget.collapsibleGroups
            ? _FoldButton(expanded: !folded, ring: look.roles.ring, onPressed: toggle, child: title)
            : title;
      } else if (aggregate != null) {
        content = DefaultTextStyle.merge(
          style: const TextStyle(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          child: aggregate(plain),
        );
      } else {
        content = const SizedBox.shrink();
      }

      pieces.add(
        _Piece(
          key: ValueKey<String>('cell-${column.key}'),
          start: geometry.starts[c],
          width: geometry.widths[c],
          pin: column.pinned,
          child: cell(content, align: c == 0 ? NebaAlign.start : column.align, pin: column.pinned),
        ),
      );
    }

    if (geometry.filler > 0) {
      pieces.add(
        _Piece(
          key: const ValueKey<String>('filler'),
          start: geometry.width - geometry.filler,
          width: geometry.filler,
          child: cell(const SizedBox.shrink(), align: NebaAlign.start, padding: 0),
        ),
      );
    }

    return Container(
      key: ValueKey<Object>(_GroupKey(label)),
      height: look.rowHeight,
      color: look.roles.soft,
      child: _strip(geometry, look.rowHeight, pieces),
    );
  }
}

// ---------------------------------------------------------------------------
// The parts
// ---------------------------------------------------------------------------

/// A row that knows whether the pointer is over it, so the light moves
/// without drawing the table again.
class _HoverRow extends StatefulWidget {
  const _HoverRow({
    required this.hoverable,
    required this.cursor,
    required this.builder,
    super.key,
  });

  final bool hoverable;
  final MouseCursor cursor;
  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  void _hover(bool hovered) {
    if (_hovered != hovered && mounted) {
      setState(() => _hovered = hovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (PointerEnterEvent event) => _hover(true),
      onExit: (PointerExitEvent event) => _hover(false),
      child: widget.builder(context, _hovered && widget.hoverable),
    );
  }
}

/// A sortable heading: a real button, heard with its place in the sort.
class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.name,
    required this.align,
    required this.direction,
    required this.order,
    required this.sortValue,
    required this.ink,
    required this.accent,
    required this.ring,
    required this.duration,
    required this.onPressed,
  });

  final Widget label;
  final String name;
  final NebaAlign align;
  final NebaDataTableSortDirection? direction;
  final int order;
  final String? sortValue;
  final Color ink;
  final Color accent;
  final Color ring;
  final Duration duration;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14;

    return Semantics(
      container: true,
      button: true,
      label: name,
      value: sortValue,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          final bool lit = interaction.hovered || interaction.focusVisible;
          final Color color = lit ? accent : ink;

          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            offset: 1,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: duration,
              curve: NebaScale.ease,
              builder: (BuildContext context, Color? value, Widget? _) {
                final Color tone = value ?? color;

                return DefaultTextStyle.merge(
                  style: TextStyle(color: tone),
                  child: Row(
                    mainAxisAlignment: _mainAxisOf(align),
                    spacing: 4,
                    children: <Widget>[
                      Flexible(child: ExcludeSemantics(child: label)),
                      // Turned rather than moved, the one allowance the rule
                      // against transforms makes. Unsorted, the arrow is
                      // there and unpainted until the heading is pointed at,
                      // and points the way the next press sorts.
                      RotatedBox(
                        quarterTurns: direction == NebaDataTableSortDirection.desc ? 0 : 2,
                        child: NebaGlyph(
                          NebaGlyphs.chevron,
                          size: fontSize * 1.15,
                          color: direction != null || lit ? tone : const Color(0x00000000),
                        ),
                      ),
                      if (order > 1)
                        ExcludeSemantics(
                          child: Text(
                            '$order',
                            style: TextStyle(
                              fontSize: fontSize * 0.85,
                              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// A heading that can be dragged along the row, and moved with Alt and an
/// arrow: the focus stop itself when it has no sort button to hold it.
class _HeadingMover extends StatefulWidget {
  const _HeadingMover({
    required this.focusable,
    required this.ring,
    required this.moving,
    required this.onKey,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
    required this.child,
  });

  final bool focusable;
  final Color ring;
  final bool moving;
  final KeyEventResult Function(KeyEvent event) onKey;
  final bool Function(Offset position) onStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onEnd;
  final Widget child;

  @override
  State<_HeadingMover> createState() => _HeadingMoverState();
}

class _HeadingMoverState extends State<_HeadingMover> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: widget.focusable,
      skipTraversal: !widget.focusable,
      onFocusChange: (bool focused) => setState(() => _focused = focused),
      onKeyEvent: (FocusNode node, KeyEvent event) => widget.onKey(event),
      child: NebaDragRegion(
        eager: false,
        slop: _reorderSlop,
        cursor: widget.moving ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
        onStart: widget.onStart,
        onMove: widget.onMove,
        onEnd: widget.onEnd,
        builder: (BuildContext context, bool dragging) => NebaFocusRing(
          // Inside the edge, since the scroll box would cut an outer ring off.
          visible: widget.focusable && _focused,
          color: widget.ring,
          offset: -2,
          child: widget.child,
        ),
      ),
    );
  }
}

/// The boundary between two headings: eight pixels of target for a line one
/// pixel wide, a drag and a double press for the pointer, and a focus stop
/// the arrow keys move.
class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({
    required this.label,
    required this.width,
    required this.minWidth,
    required this.accent,
    required this.ring,
    required this.duration,
    required this.rtl,
    required this.onStart,
    required this.onMove,
    required this.onReset,
    required this.onNudge,
  });

  final String label;
  final double width;
  final double minWidth;
  final Color accent;
  final Color ring;
  final Duration duration;
  final bool rtl;
  final bool Function(Offset position) onStart;
  final ValueChanged<Offset> onMove;
  final VoidCallback onReset;
  final void Function({required bool wider}) onNudge;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hovered = false;
  bool _focused = false;

  // A press while this runs is the second of a double press.
  Timer? _pressTimer;
  bool _resetting = false;

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  /// Heard before the drag region hears the same press, so a double press
  /// resets the width instead of starting a drag.
  void _down(PointerDownEvent event) {
    if (_pressTimer?.isActive ?? false) {
      _pressTimer!.cancel();
      _resetting = true;
      widget.onReset();
    } else {
      _pressTimer = Timer(kDoubleTapTimeout, () {});
    }
  }

  bool _start(Offset position) {
    if (_resetting) {
      _resetting = false;

      return false;
    }

    return widget.onStart(position);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;

    if (key != LogicalKeyboardKey.arrowLeft && key != LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.ignored;
    }

    widget.onNudge(wider: (key == LogicalKeyboardKey.arrowRight) != widget.rtl);

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final String width = '${widget.width.round()}';

    return Semantics(
      container: true,
      label: widget.label,
      value: width,
      increasedValue: '${(widget.width + _keyboardStep).round()}',
      decreasedValue: '${math.max(widget.minWidth, widget.width - _keyboardStep).round()}',
      onIncrease: () => widget.onNudge(wider: true),
      onDecrease: () => widget.onNudge(wider: false),
      child: Focus(
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        onKeyEvent: _key,
        child: NebaDragRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onStart: _start,
          onMove: widget.onMove,
          builder: (BuildContext context, bool dragging) {
            // Held as well as hovered: the pointer may be well away from the
            // handle while the drag runs. Focused too, so the line the arrows
            // move is drawn while they move it.
            final bool lit = _hovered || dragging || _focused;

            return Listener(
              onPointerDown: _down,
              child: MouseRegion(
                onEnter: (PointerEnterEvent event) => setState(() => _hovered = true),
                onExit: (PointerExitEvent event) => setState(() => _hovered = false),
                child: NebaFocusRing(
                  visible: _focused,
                  color: widget.ring,
                  offset: -2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          end: lit ? widget.accent : widget.accent.withValues(alpha: 0),
                        ),
                        duration: widget.duration,
                        curve: NebaScale.ease,
                        builder: (BuildContext context, Color? color, Widget? _) => SizedBox(
                          width: 1,
                          height: double.infinity,
                          child: ColoredBox(color: color ?? widget.accent),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The press that folds a group away and back, heard as expanded or not.
class _FoldButton extends StatelessWidget {
  const _FoldButton({
    required this.expanded,
    required this.ring,
    required this.onPressed,
    required this.child,
  });

  final bool expanded;
  final Color ring;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      expanded: expanded,
      child: NebaInteractive(
        onTap: onPressed,
        builder: (BuildContext context, NebaInteraction interaction, ValueListenable<Offset?> _) {
          return NebaFocusRing(
            visible: interaction.focusVisible,
            color: ring,
            offset: -2,
            child: SizedBox(width: double.infinity, child: child),
          );
        },
      ),
    );
  }
}

/// A cell's editor: a bare editable, the height of the row, rather than a
/// TextField, whose label column and message lines are a form's shape.
class _CellEditor extends StatefulWidget {
  const _CellEditor({
    required this.initial,
    required this.align,
    required this.number,
    required this.label,
    required this.roles,
    required this.onFocusChange,
    required this.onSubmit,
    required this.onCancel,
    required this.onBlur,
    super.key,
  });

  final String initial;
  final NebaAlign align;
  final bool number;
  final String label;
  final NebaColorRoles roles;
  final ValueChanged<bool> onFocusChange;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  final ValueChanged<String> onBlur;

  @override
  State<_CellEditor> createState() => _CellEditorState();
}

class _CellEditorState extends State<_CellEditor>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late final TextEditingController _controller = TextEditingController(text: widget.initial)
    ..selection = TextSelection(baseOffset: 0, extentOffset: widget.initial.length);
  final FocusNode _focus = FocusNode(debugLabel: 'NebaDataTable editor');
  final GlobalKey<EditableTextState> _editableKey = GlobalKey<EditableTextState>();
  late final NebaFieldGestures _gestures = NebaFieldGestures(delegate: this);

  /// Whether Enter or Escape has answered the editor, so the blur they cause
  /// commits nothing a second time, or at all after an Escape.
  bool _settled = false;

  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableKey;

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_handleFocus);
    // Asked for rather than taken by `autofocus`, which a scope that already
    // holds a focus, the table's, ignores.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocus);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    widget.onFocusChange(_focus.hasFocus);

    if (!_focus.hasFocus && !_settled) {
      _settled = true;
      widget.onBlur(_controller.text);
    }
  }

  void _submit() {
    if (!_settled) {
      _settled = true;
      widget.onSubmit(_controller.text);
    }
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final LogicalKeyboardKey key = event.logicalKey;

    // Enter commits and submits nothing: a table inside a form would
    // otherwise submit it every time a cell was finished.
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _submit();

      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape) {
      if (!_settled) {
        _settled = true;
        widget.onCancel();
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(context).style;

    return Semantics(
      label: widget.label,
      child: _gestures.wrap(
        NebaFieldEditable(
          editableKey: _editableKey,
          controller: _controller,
          focusNode: _focus,
          style: style,
          roles: widget.roles,
          empty: false,
          textAlign: _textAlignOf(widget.align),
          keyboardType: widget.number
              ? const TextInputType.numberWithOptions(signed: true, decimal: true)
              : TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: (String _) => _submit(),
          onKeyEvent: _key,
        ),
        disabled: false,
      ),
    );
  }
}

/// A press on a body row, which a control inside the row takes first.
///
/// A mouse or a pen acts as the button goes down, once the arena has given
/// the press over, which it does at once when nothing inside the row wants
/// it: the selection, the focus and the start of a drag through a run of
/// rows. A finger acts as it comes up without having scrolled, since a finger
/// on a row is as often the start of a scroll as a choice. Either way the
/// release on the same row is a click.
class _RowPressRecognizer extends OneSequenceGestureRecognizer {
  _RowPressRecognizer({super.debugOwner});

  bool Function(PointerDownEvent event)? onCandidate;
  ValueChanged<PointerDownEvent>? onDown;
  ValueChanged<PointerMoveEvent>? onMove;
  void Function(PointerUpEvent event, {required bool touch})? onUp;
  VoidCallback? onEnd;

  int? _pointer;
  PointerDownEvent? _down;
  PointerUpEvent? _up;
  bool _accepted = false;
  bool _downHandled = false;

  bool get _touch {
    final PointerDeviceKind? kind = _down?.kind;

    return kind == PointerDeviceKind.touch || kind == PointerDeviceKind.unknown;
  }

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    final bool button =
        event.buttons == kPrimaryButton ||
        (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton);

    return _pointer == null && button && super.isPointerAllowed(event);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!(onCandidate?.call(event) ?? false)) {
      return;
    }

    super.addAllowedPointer(event);
    _pointer = event.pointer;
    _down = event;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _pointer) {
      return;
    }

    final PointerDownEvent? down = _down;

    if (event is PointerMoveEvent) {
      if (_downHandled) {
        onMove?.call(event);
      } else if (!_accepted &&
          _touch &&
          down != null &&
          (event.position - down.position).distance > computeHitSlop(event.kind, gestureSettings)) {
        // A finger that travelled is a scroll, never a press.
        resolve(GestureDisposition.rejected);
      }
    } else if (event is PointerUpEvent) {
      stopTrackingPointer(event.pointer);

      if (_accepted) {
        onUp?.call(event, touch: _touch);
        _finish();
      } else {
        // The arena gives the press to the first of its members when the
        // pointer comes up, which is a control inside the row if there is
        // one; the click waits for that.
        _up = event;
      }
    } else if (event is PointerCancelEvent) {
      if (_downHandled) {
        onEnd?.call();
      }

      _downHandled = false;
      resolve(GestureDisposition.rejected);
      _finish();
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (pointer != _pointer || _accepted) {
      return;
    }

    _accepted = true;

    final PointerDownEvent? down = _down;

    if (down != null && !_touch) {
      _downHandled = true;
      onDown?.call(down);
    }

    final PointerUpEvent? up = _up;

    if (up != null) {
      onUp?.call(up, touch: _touch);
      _finish();
    }
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer != _pointer) {
      return;
    }

    if (_downHandled) {
      onEnd?.call();
    }

    _finish();
  }

  void _finish() {
    final int? pointer = _pointer;

    _pointer = null;
    _down = null;
    _up = null;
    _accepted = false;
    _downHandled = false;

    if (pointer != null) {
      stopTrackingPointer(pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'neba data table row';
}
