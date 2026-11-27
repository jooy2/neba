/// `NebaTable`, rows of records under a header, read across.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/box/neba_box.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One column of a [NebaTable].
@immutable
class NebaTableColumn<T> {
  /// A column named [key].
  const NebaTableColumn({
    required this.key,
    this.label,
    this.width,
    this.align = NebaAlign.start,
    this.builder,
  });

  /// The column's name, and the field a cell reads from a row that is a
  /// [Map] when there is no [builder].
  final String key;

  /// The header. Defaults to [key] in a [Text].
  final Widget? label;

  /// The column's width in logical pixels. Left out, the columns share the
  /// rest by their content.
  final double? width;

  /// Where the header and the cells line up.
  final NebaAlign align;

  /// Builds a cell from its row.
  final Widget Function(BuildContext context, T row, int index)? builder;
}

/// Rows of records under a header, on a sheet.
///
/// [headers] says what each column shows and [items] are the rows. A cell is
/// built by its column's builder, or read from a row that is a [Map] by the
/// column's key. [onRowPressed] makes every row a press and a focus stop,
/// and a table with no rows says so across its width.
///
/// ```dart
/// NebaTable<Map<String, Object?>>(
///   headers: const <NebaTableColumn<Map<String, Object?>>>[
///     NebaTableColumn(key: 'name', label: Text('Name')),
///   ],
///   items: rows,
/// )
/// ```
class NebaTable<T> extends StatefulWidget {
  /// A table of [items] in [headers].
  const NebaTable({
    required this.headers,
    required this.items,
    this.rowKey,
    this.caption,
    this.locale,
    this.empty,
    this.striped = false,
    this.hoverable = false,
    this.stickyHeader = false,
    this.maxHeight,
    this.onRowPressed,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.transition,
    super.key,
  });

  /// The columns.
  final List<NebaTableColumn<T>> headers;

  /// The rows.
  final List<T> items;

  /// A row's key, which keeps a row's state with it when the rows move.
  final LocalKey Function(T row, int index)? rowKey;

  /// A line above the table saying what it holds.
  final Widget? caption;

  /// The language of the empty line. Defaults to `NebaProvider`'s, then the
  /// app's.
  final Locale? locale;

  /// What a table with no rows says, in place of "No data".
  final Widget? empty;

  /// Whether every other row is tinted.
  final bool striped;

  /// Whether the row under the pointer is lit. A pressable row always is.
  final bool hoverable;

  /// Whether the header stays put while the rows scroll under it, in a table
  /// held to [maxHeight].
  final bool stickyHeader;

  /// The tallest the table grows before its rows scroll.
  final double? maxHeight;

  /// Called with the row pressed, by a pointer or by Enter or Space on a row
  /// that holds the focus.
  final void Function(T row, int index)? onRowPressed;

  /// The weight of the sheet. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.outline].
  final NebaVariant? variant;

  /// The cells' type and padding. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the header, the rules and the lit row.
  final NebaColor color;

  /// How much padding a cell has. Defaults to `NebaProvider`'s, then
  /// [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// How the table arrives when it is first built.
  final NebaTransition? transition;

  /// A cell's padding above and below, by density and size.
  static const Map<NebaDensity, Map<NebaSize, double>> cellPaddingY =
      <NebaDensity, Map<NebaSize, double>>{
        NebaDensity.standard: <NebaSize, double>{
          NebaSize.xs: 4,
          NebaSize.sm: 6,
          NebaSize.md: 10,
          NebaSize.lg: 12,
          NebaSize.xl: 14,
        },
        NebaDensity.compact: <NebaSize, double>{
          NebaSize.xs: 2,
          NebaSize.sm: 4,
          NebaSize.md: 6,
          NebaSize.lg: 8,
          NebaSize.xl: 10,
        },
      };

  @override
  State<NebaTable<T>> createState() => _NebaTableState<T>();
}

class _NebaTableState<T> extends State<NebaTable<T>> {
  final GlobalKey _body = GlobalKey();
  final List<FocusNode> _rowFocus = <FocusNode>[];
  int? _hovered;
  int? _focused;

  @override
  void initState() {
    super.initState();
    NebaInputModality.pointer.addListener(_handleModality);
  }

  void _handleModality() {
    if (_focused != null && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    NebaInputModality.pointer.removeListener(_handleModality);

    for (final FocusNode node in _rowFocus) {
      node.dispose();
    }

    super.dispose();
  }

  bool get _pressable => widget.onRowPressed != null;

  /// Whether the rows' table holds the header as its first row.
  bool get _headerInBody => !widget.stickyHeader;

  /// The row under [position] in the body table, or `null`.
  int? _rowAt(Offset position) {
    final RenderObject? table = _body.currentContext?.findRenderObject();

    if (table is! RenderTable || widget.items.isEmpty) {
      return null;
    }

    final int first = _headerInBody ? 1 : 0;

    for (int row = first; row < table.rows; row++) {
      if (table.getRowBox(row).contains(position)) {
        return row - first;
      }
    }

    return null;
  }

  void _hover(int? row) {
    if (row != _hovered) {
      setState(() => _hovered = row);
    }
  }

  void _press(int index) {
    widget.onRowPressed?.call(widget.items[index], index);
  }

  void _syncFocus() {
    final int count = _pressable ? widget.items.length : 0;

    while (_rowFocus.length > count) {
      _rowFocus.removeLast().dispose();
    }

    while (_rowFocus.length < count) {
      _rowFocus.add(FocusNode(debugLabel: 'NebaTable row ${_rowFocus.length}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = widget.size ?? defaults.size ?? NebaSize.md;
    final NebaDensity density = widget.density ?? defaults.density ?? NebaDensity.standard;
    final NebaColorRoles roles = tokens.roles(widget.color);
    final double padX = NebaScale.paddingX[density]![size]!;
    final double padY = NebaTable.cellPaddingY[density]![size]!;
    final double text = NebaScale.controlText[size]!;
    final double leading = NebaScale.controlLeading[size]!;
    final List<NebaTableColumn<T>> columns = widget.headers;
    final bool sticky = widget.stickyHeader;
    final bool lit = widget.hoverable || _pressable;
    final Duration duration = nebaDuration(context, NebaScale.duration);
    final EdgeInsets cellPadding = EdgeInsets.symmetric(horizontal: padX, vertical: padY);

    _syncFocus();

    Alignment alignOf(NebaAlign align) => switch (align) {
      NebaAlign.start => AlignmentDirectional.centerStart.resolve(Directionality.of(context)),
      NebaAlign.center => Alignment.center,
      NebaAlign.end => AlignmentDirectional.centerEnd.resolve(Directionality.of(context)),
    };

    TextAlign textAlignOf(NebaAlign align) => switch (align) {
      NebaAlign.start => TextAlign.start,
      NebaAlign.center => TextAlign.center,
      NebaAlign.end => TextAlign.end,
    };

    // Columns of their own width are fixed; the rest share what is left by
    // their content, as a table laid out by the browser does. A header laid
    // out apart from its rows cannot read their content, so the rest share
    // it equally then.
    final Map<int, TableColumnWidth> widths = <int, TableColumnWidth>{
      for (int i = 0; i < columns.length; i++)
        i: columns[i].width != null
            ? FixedColumnWidth(columns[i].width!)
            : sticky
            ? const FlexColumnWidth()
            : const IntrinsicColumnWidth(flex: 1),
    };

    TableRow headerRow() {
      return TableRow(
        decoration: BoxDecoration(color: roles.panelPress),
        children: <Widget>[
          for (final NebaTableColumn<T> column in columns)
            Semantics(
              role: SemanticsRole.columnHeader,
              child: Padding(
                padding: cellPadding,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontWeight: FontWeight.w600),
                  textAlign: textAlignOf(column.align),
                  softWrap: false,
                  child: Align(
                    alignment: alignOf(column.align),
                    widthFactor: 1,
                    child: column.label ?? Text(column.key),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    Widget cellOf(NebaTableColumn<T> column, T row, int index) {
      final Widget Function(BuildContext context, T row, int index)? builder = column.builder;

      if (builder != null) {
        return builder(context, row, index);
      }

      final Object? value = row is Map ? row[column.key] : null;

      return value is Widget ? value : Text(value == null ? '' : '$value');
    }

    TableRow bodyRow(int index) {
      final T row = widget.items[index];
      final Color tint = lit && _hovered == index
          ? roles.soft
          : widget.striped && index.isOdd
          ? tokens.fg.withValues(alpha: 0.04)
          : const Color(0x00000000);
      final bool ringed = _pressable && _focused == index && !NebaInputModality.pointer.value;

      return TableRow(
        key: widget.rowKey?.call(row, index),
        // A row that holds the focus after a key is ringed inside its edges,
        // as CSS `outline-offset: -2px` rings it, over its rule.
        decoration: BoxDecoration(
          color: tint,
          border: ringed
              ? Border.all(color: roles.ring, width: 2)
              : Border(top: BorderSide(color: roles.line)),
        ),
        children: <Widget>[
          for (int c = 0; c < columns.length; c++)
            Padding(
              padding: cellPadding,
              child: DefaultTextStyle.merge(
                textAlign: textAlignOf(columns[c].align),
                child: Align(
                  alignment: alignOf(columns[c].align),
                  widthFactor: 1,
                  child: c == 0 && _pressable
                      ? Focus(
                          focusNode: _rowFocus[index],
                          onFocusChange: (bool focused) => setState(
                            () => _focused = focused
                                ? index
                                : _focused == index
                                ? null
                                : _focused,
                          ),
                          onKeyEvent: (FocusNode node, KeyEvent event) {
                            if (event is KeyDownEvent &&
                                (event.logicalKey == LogicalKeyboardKey.enter ||
                                    event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                                    event.logicalKey == LogicalKeyboardKey.space)) {
                              _press(index);
                              return KeyEventResult.handled;
                            }

                            return KeyEventResult.ignored;
                          },
                          child: cellOf(columns[c], row, index),
                        )
                      : cellOf(columns[c], row, index),
                ),
              ),
            ),
        ],
      );
    }

    final bool empty = widget.items.isEmpty;

    Widget body = Table(
      key: _body,
      columnWidths: widths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        if (_headerInBody) headerRow(),
        if (!empty)
          for (int i = 0; i < widget.items.length; i++) bodyRow(i),
      ],
    );

    if (lit && !empty) {
      body = MouseRegion(
        cursor: _pressable && _hovered != null ? SystemMouseCursors.click : MouseCursor.defer,
        onHover: (PointerHoverEvent event) => _hover(_rowAt(event.localPosition)),
        onExit: (PointerExitEvent event) => _hover(null),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: _pressable
              ? (TapUpDetails details) {
                  final int? row = _rowAt(details.localPosition);

                  if (row != null) {
                    _press(row);
                  }
                }
              : null,
          child: body,
        ),
      );
    }

    if (empty) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          body,
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: roles.line)),
            ),
            padding: EdgeInsets.symmetric(horizontal: padX, vertical: 32),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tokens.mutedFg),
              textAlign: TextAlign.center,
              child: Center(
                child:
                    widget.empty ??
                    Text(nebaMessages(context, 'table', locale: widget.locale)['empty']!),
              ),
            ),
          ),
        ],
      );
    }

    final double? maxHeight = widget.maxHeight;

    Widget table;

    if (sticky) {
      final Widget header = Table(
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[headerRow()],
      );

      table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header,
          Flexible(child: SingleChildScrollView(child: body)),
        ],
      );
    } else {
      table = maxHeight == null ? body : SingleChildScrollView(child: body);
    }

    if (maxHeight != null) {
      table = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: table,
      );
    }

    final Widget? caption = widget.caption;

    final Widget sheet = NebaBox(
      variant: widget.variant,
      size: size,
      color: widget.color,
      density: density,
      elevation: widget.elevation,
      padded: false,
      transition: widget.transition,
      child: AnimatedDefaultTextStyle(
        duration: duration,
        style: DefaultTextStyle.of(
          context,
        ).style.merge(TextStyle(fontSize: text, height: leading / text, color: tokens.fg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (caption != null)
              Padding(
                padding: cellPadding,
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: NebaScale.metaText[size], color: tokens.mutedFg),
                  child: caption,
                ),
              ),
            Flexible(fit: FlexFit.loose, child: table),
          ],
        ),
      ),
    );

    // The sheet, edge and all, is held to the height, as a border box is.
    return maxHeight == null
        ? sheet
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: sheet,
          );
  }
}
