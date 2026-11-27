import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';

import '../../support/host.dart';

typedef _Row = Map<String, Object?>;

const List<_Row> _people = <_Row>[
  <String, Object?>{'id': 1, 'name': 'Nadia', 'role': 'Maintainer', 'commits': 214},
  <String, Object?>{'id': 2, 'name': 'Theo', 'role': 'Reviewer', 'commits': 37},
  <String, Object?>{'id': 3, 'name': 'Anya', 'role': 'Contributor', 'commits': 9},
  <String, Object?>{'id': 4, 'name': 'Émile', 'role': 'Contributor', 'commits': null},
];

const List<String> _names = <String>['Nadia', 'Theo', 'Anya', 'Émile'];

const List<NebaDataTableColumn<_Row>> _columns = <NebaDataTableColumn<_Row>>[
  NebaDataTableColumn<_Row>(key: 'name', label: Text('Name'), width: 160),
  NebaDataTableColumn<_Row>(key: 'role', label: Text('Role')),
  NebaDataTableColumn<_Row>(
    key: 'commits',
    label: Text('Commits'),
    width: 100,
    align: NebaAlign.end,
  ),
];

Object _idOf(_Row row, int index) => row['id']!;

/// A run of numbered rows.
List<_Row> _numbered(int count) {
  return List<_Row>.generate(count, (int i) => <String, Object?>{'id': i, 'name': 'Row $i'});
}

const List<NebaDataTableColumn<_Row>> _rowColumns = <NebaDataTableColumn<_Row>>[
  NebaDataTableColumn<_Row>(key: 'id', label: Text('ID'), width: 80, align: NebaAlign.end),
  NebaDataTableColumn<_Row>(key: 'name', label: Text('Name')),
];

void main() {
  Future<void> pump(WidgetTester tester, Widget table, {double width = 800, double height = 600}) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(alignment: AlignmentDirectional.topStart, child: table),
        ),
        width: width,
        height: height,
      ),
    );
  }

  /// The texts among [among] on screen, top to bottom.
  List<String> shown(WidgetTester tester, [List<String> among = _names]) {
    final List<(String, double)> found = <(String, double)>[
      for (final String text in among)
        for (final Element element in find.text(text).evaluate())
          (text, (element.renderObject! as RenderBox).localToGlobal(Offset.zero).dy),
    ]..sort(((String, double) a, (String, double) b) => a.$2.compareTo(b.$2));

    return <String>[for (final (String, double) entry in found) entry.$1];
  }

  /// The tint behind the row a text is in.
  Color tintOf(WidgetTester tester, String text) {
    return tester
        .widget<ColoredBox>(
          find.ancestor(of: find.text(text), matching: find.byType(ColoredBox)).first,
        )
        .color;
  }

  /// The box of the cell a text is in.
  Rect cellOf(WidgetTester tester, String text) {
    return tester.getRect(
      find.ancestor(of: find.text(text), matching: find.byType(Container)).first,
    );
  }

  Future<void> click(
    WidgetTester tester,
    Finder finder, {
    List<LogicalKeyboardKey> holding = const <LogicalKeyboardKey>[],
  }) async {
    for (final LogicalKeyboardKey key in holding) {
      await tester.sendKeyDownEvent(key);
    }

    await tester.tap(finder, kind: PointerDeviceKind.mouse);
    await tester.pump();

    for (final LogicalKeyboardKey key in holding.reversed) {
      await tester.sendKeyUpEvent(key);
    }
  }

  /// Moves the focus to the table, as Tab would.
  Future<void> focusTable(WidgetTester tester) async {
    tester
        .widgetList<Focus>(find.byType(Focus))
        .firstWhere((Focus focus) => focus.focusNode?.debugLabel == 'NebaDataTable')
        .focusNode!
        .requestFocus();
    await tester.pump();
    await tester.pump();
  }

  Future<void> key(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('builds a heading per column and reads each cell off its key', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Commits'), findsOneWidget);
      expect(shown(tester), _names);
      expect(find.text('214'), findsOneWidget);
    });

    testWidgets('falls back to the key without a label, and reads a typed row by value', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDataTable<(String, int)>(
          headers: <NebaDataTableColumn<(String, int)>>[
            NebaDataTableColumn<(String, int)>(key: 'city', value: ((String, int) row) => row.$1),
          ],
          items: const <(String, int)>[('Seoul', 1), ('Lagos', 2)],
        ),
      );

      expect(find.text('city'), findsOneWidget);
      expect(find.text('Seoul'), findsOneWidget);
    });

    testWidgets('hands the builder the row and its place in the order shown', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            ..._columns,
            NebaDataTableColumn<_Row>(
              key: 'place',
              builder: (BuildContext context, _Row row, int index) => Text('#$index ${row['id']}'),
            ),
          ],
          items: _people,
          defaultSort: const <NebaDataTableSort>[NebaDataTableSort(key: 'name')],
        ),
      );

      expect(find.text('#0 3'), findsOneWidget);
      expect(find.text('#3 2'), findsOneWidget);
    });

    testWidgets('leaves a hidden column out, and draws changed items', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            _columns.first,
            const NebaDataTableColumn<_Row>(key: 'role', label: Text('Role'), hidden: true),
          ],
          items: _people,
        ),
      );

      expect(find.text('Role'), findsNothing);
      expect(find.text('Maintainer'), findsNothing);

      await pump(tester, NebaDataTable<_Row>(headers: _columns, items: _people.sublist(0, 1)));

      expect(shown(tester), <String>['Nadia']);
    });

    testWidgets('says so when there are no rows', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: <_Row>[]));
      expect(find.text('Nothing here'), findsOneWidget);

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: <_Row>[],
          empty: Text('No member matches.'),
        ),
      );
      expect(find.text('No member matches.'), findsOneWidget);
    });

    testWidgets('holds a column at its width and shares the rest', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));

      expect(cellOf(tester, 'Nadia').width, 160);
      expect(cellOf(tester, '214').width, 100);
      // The sheet's hairline takes a pixel on each side.
      expect(cellOf(tester, 'Maintainer').width, 800 - 2 - 160 - 100);
    });

    testWidgets('rows are the size and density ladder tall, or rowHeight', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));
      expect(cellOf(tester, 'Nadia').height, 24);

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          size: NebaSize.md,
          density: NebaDensity.standard,
        ),
      );
      expect(cellOf(tester, 'Nadia').height, 32);

      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, rowHeight: 48),
      );
      expect(cellOf(tester, 'Nadia').height, 48);
    });

    testWidgets('tints the rows the stripe names', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          striped: NebaDataTableStripe.even,
          hoverable: false,
        ),
      );

      final NebaTokens tokens = NebaTheme.of(tester.element(find.text('Nadia')));
      final Color stripe = tokens.fg.withValues(alpha: 0.04);

      expect(tintOf(tester, 'Nadia').a, 0);
      expect(tintOf(tester, 'Theo'), stripe);
      expect(tintOf(tester, 'Anya').a, 0);

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          striped: NebaDataTableStripe.odd,
          hoverable: false,
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tintOf(tester, 'Nadia'), stripe);
      expect(tintOf(tester, 'Theo').a, 0);
    });

    testWidgets('lights the row under the pointer', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Theo')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final NebaColorRoles roles = NebaTheme.of(
        tester.element(find.text('Theo')),
      ).roles(NebaColor.primary);

      expect(tintOf(tester, 'Theo'), roles.soft);
      expect(tintOf(tester, 'Nadia').a, 0);

      await mouse.removePointer();
    });

    testWidgets('is drawn on a Box, which the sheet props pass through to', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          variant: NebaVariant.solid,
          elevation: 2,
        ),
      );

      final NebaBox box = tester.widget<NebaBox>(find.byType(NebaBox));

      expect(box.variant, NebaVariant.solid);
      expect(box.elevation, 2);
      expect(box.padded, isFalse);
    });

    testWidgets('writes a date as a date and a boolean as the word', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: const <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(key: 'when'),
            NebaDataTableColumn<_Row>(key: 'done'),
            NebaDataTableColumn<_Row>(key: 'size'),
          ],
          items: <_Row>[
            <String, Object?>{'when': DateTime(2026, 1, 5), 'done': true, 'size': 18.0},
          ],
        ),
      );

      expect(find.text('Jan 5, 2026'), findsOneWidget);
      expect(find.text('true'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
    });
  });

  group('column groups', () {
    const List<NebaDataTableColumn<_Row>> grouped = <NebaDataTableColumn<_Row>>[
      NebaDataTableColumn<_Row>(key: 'name', label: Text('Name'), width: 160),
      NebaDataTableColumn<_Row>(key: 'role', label: Text('Role'), group: 'Work', width: 120),
      NebaDataTableColumn<_Row>(key: 'commits', label: Text('Commits'), group: 'Work', width: 100),
    ];

    testWidgets('merges adjacent columns under one heading', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: grouped, items: _people));

      expect(find.text('Work'), findsOneWidget);
      expect(cellOf(tester, 'Work').width, 220);
      expect(cellOf(tester, 'Work').left, cellOf(tester, 'Role').left);
    });

    testWidgets('spans an ungrouped column across both header rows', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: grouped, items: _people));

      expect(cellOf(tester, 'Name').height, 2 * cellOf(tester, 'Role').height);
      expect(cellOf(tester, 'Name').top, cellOf(tester, 'Work').top);
    });
  });

  group('sorting', () {
    testWidgets('does nothing until a column sorts', (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));

      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(shown(tester), _names);
    });

    testWidgets('cycles ascending, descending and back to the order it came in', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, sortable: true),
      );

      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(shown(tester), <String>['Anya', 'Émile', 'Nadia', 'Theo']);

      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(shown(tester), <String>['Theo', 'Nadia', 'Émile', 'Anya']);

      await tester.tap(find.text('Name'));
      await tester.pump();
      expect(shown(tester), _names);
    });

    testWidgets('puts a row with no value last in both directions, and numbers as numbers', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, sortable: true),
      );

      await tester.tap(find.text('Commits'));
      await tester.pump();
      expect(shown(tester), <String>['Anya', 'Theo', 'Nadia', 'Émile']);

      await tester.tap(find.text('Commits'));
      await tester.pump();
      expect(shown(tester), <String>['Nadia', 'Theo', 'Anya', 'Émile']);
    });

    testWidgets('orders text with its digits as numbers', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: <_Row>[
            for (final String name in <String>['item10', 'item2', 'Item1'])
              <String, Object?>{'id': name.length, 'name': name},
          ],
          defaultSort: const <NebaDataTableSort>[NebaDataTableSort(key: 'name')],
        ),
      );

      expect(shown(tester, <String>['item10', 'item2', 'Item1']), <String>[
        'Item1',
        'item2',
        'item10',
      ]);
    });

    testWidgets("uses a column's own comparison", (WidgetTester tester) async {
      const List<String> rank = <String>['low', 'high', 'urgent'];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(
              key: 'priority',
              label: const Text('Priority'),
              compare: (_Row a, _Row b) =>
                  rank.indexOf(a['priority']! as String) - rank.indexOf(b['priority']! as String),
            ),
          ],
          items: const <_Row>[
            <String, Object?>{'priority': 'urgent'},
            <String, Object?>{'priority': 'low'},
            <String, Object?>{'priority': 'high'},
          ],
          sortable: true,
        ),
      );

      await tester.tap(find.text('Priority'));
      await tester.pump();

      expect(shown(tester, rank), <String>['low', 'high', 'urgent']);
    });

    testWidgets('reports the sort and honours a controlled one', (WidgetTester tester) async {
      final List<List<NebaDataTableSort>> reported = <List<NebaDataTableSort>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          sort: const <NebaDataTableSort>[
            NebaDataTableSort(key: 'name', direction: NebaDataTableSortDirection.desc),
          ],
          onSortChange: reported.add,
        ),
      );

      expect(shown(tester), <String>['Theo', 'Nadia', 'Émile', 'Anya']);

      await tester.tap(find.text('Role'));
      await tester.pump();

      expect(reported.single, const <NebaDataTableSort>[NebaDataTableSort(key: 'role')]);
      // Controlled: nothing moves until the caller says so.
      expect(shown(tester), <String>['Theo', 'Nadia', 'Émile', 'Anya']);
    });

    testWidgets('adds a column with Shift in a multiple sort, and says where it comes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<NebaDataTableSort>> reported = <List<NebaDataTableSort>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          sortMode: NebaDataTableSortMode.multiple,
          onSortChange: reported.add,
        ),
      );

      await tester.tap(find.text('Role'));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('Name'));
      await tester.tap(find.text('Name'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(reported.last, const <NebaDataTableSort>[
        NebaDataTableSort(key: 'role'),
        NebaDataTableSort(key: 'name', direction: NebaDataTableSortDirection.desc),
      ]);
      expect(shown(tester), <String>['Émile', 'Anya', 'Nadia', 'Theo']);
      expect(find.text('2'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('Role'), matching: find.byType(Semantics)).first,
        ),
        matchesSemantics(
          label: 'Role',
          value: 'sort 1, ascending',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.ancestor(of: find.text('Name'), matching: find.byType(Semantics)).first,
        ),
        matchesSemantics(
          label: 'Name',
          value: 'sort 2, descending',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('leaves the rows alone when the caller has sorted them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          manual: <NebaDataTableStage>{NebaDataTableStage.sort},
          sort: <NebaDataTableSort>[NebaDataTableSort(key: 'name')],
        ),
      );

      expect(shown(tester), _names);
    });
  });

  group('row identity', () {
    testWidgets('keeps the state a cell holds with its row when the rows are sorted', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            ..._columns,
            NebaDataTableColumn<_Row>(
              key: 'tick',
              builder: (BuildContext context, _Row row, int index) =>
                  NebaCheckbox(semanticLabel: 'Tick ${row['name']}'),
            ),
          ],
          items: _people,
          rowKey: _idOf,
          sortable: true,
        ),
      );

      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.tap(find.bySemanticsLabel('Tick Theo'));
      await tester.pump();
      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(shown(tester), <String>['Anya', 'Émile', 'Nadia', 'Theo']);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tick Theo')),
        matchesSemantics(
          label: 'Tick Theo',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tick Nadia')),
        matchesSemantics(
          label: 'Tick Nadia',
          hasCheckedState: true,
          isChecked: false,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      semantics.dispose();
    });
  });

  group('search and filter', () {
    testWidgets('matches every searchable column, ignoring case and accents', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, search: 'emile'),
      );
      expect(shown(tester), <String>['Émile']);

      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, search: 'CONTRIB'),
      );
      expect(shown(tester), <String>['Anya', 'Émile']);
    });

    testWidgets('skips a column that opts out', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(key: 'name'),
            NebaDataTableColumn<_Row>(key: 'role', searchable: false),
          ],
          items: _people,
          search: 'review',
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('types into its own field, reports the query and goes back to page one', (
      WidgetTester tester,
    ) async {
      final List<String> queries = <String>[];
      final List<int> pages = <int>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(30),
          searchable: true,
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 10,
          defaultPage: 2,
          onSearchChange: queries.add,
          onPageChange: pages.add,
        ),
      );

      expect(find.text('Row 10'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'row 2');
      await tester.pump();

      expect(queries.last, 'row 2');
      expect(pages.last, 1);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.text('Row 21'), findsOneWidget);
      expect(find.text('Row 10'), findsNothing);
      expect(find.text('1–10 of 11'), findsOneWidget);
    });

    testWidgets('folds its rows between frames once it is drawn, and only once', (
      WidgetTester tester,
    ) async {
      int reads = 0;

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(
              key: 'name',
              value: (_Row row) {
                reads++;

                return row['name'];
              },
              builder: (BuildContext context, _Row row, int index) => Text('${row['name']}'),
            ),
          ],
          items: _people,
          searchable: true,
        ),
      );

      expect(reads, 0);

      await tester.pump(const Duration(seconds: 1));
      expect(reads, _people.length);

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'nad');
      await tester.pump();

      expect(shown(tester), <String>['Nadia']);
      expect(reads, _people.length);
    });

    testWidgets('folds nothing in a table without a field until it is searched', (
      WidgetTester tester,
    ) async {
      int reads = 0;
      NebaDataTable<_Row> table(String search) {
        return NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(
              key: 'name',
              value: (_Row row) {
                reads++;

                return row['name'];
              },
              builder: (BuildContext context, _Row row, int index) => Text('${row['name']}'),
            ),
          ],
          items: _people,
          search: search,
        );
      }

      await pump(tester, table(''));
      await tester.pump(const Duration(seconds: 1));
      expect(reads, 0);

      await pump(tester, table('the'));
      expect(reads, _people.length);
      expect(shown(tester), <String>['Theo']);
    });

    testWidgets('sorts once while the query changes', (WidgetTester tester) async {
      int comparisons = 0;
      // Held across renders, as the page asks: the sort is kept on them.
      final List<NebaDataTableColumn<_Row>> headers = <NebaDataTableColumn<_Row>>[
        NebaDataTableColumn<_Row>(
          key: 'name',
          compare: (_Row a, _Row b) {
            comparisons++;

            return (a['name']! as String).compareTo(b['name']! as String);
          },
        ),
      ];
      NebaDataTable<_Row> table(String search) {
        return NebaDataTable<_Row>(
          headers: headers,
          items: _people,
          search: search,
          sort: const <NebaDataTableSort>[NebaDataTableSort(key: 'name')],
        );
      }

      await pump(tester, table(''));
      final int sorted = comparisons;

      expect(sorted, greaterThan(0));

      await pump(tester, table('a'));
      await pump(tester, table('an'));

      expect(comparisons, sorted);
      expect(shown(tester), <String>['Anya']);
    });

    testWidgets('says how many rows a search leaves, with a footer or without one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, search: 'contrib'),
      );
      expect(find.text('1–2 of 2'), findsOneWidget);

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          search: 'contrib',
          footer: true,
        ),
      );
      expect(find.text('1–2 of 2'), findsOneWidget);
    });

    testWidgets('says how many rows are chosen in the same status', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.multiple,
          defaultSelected: <Object>[1, 2],
        ),
      );

      expect(find.text('1–4 of 4 2 selected'), findsOneWidget);
    });

    testWidgets("applies the caller's own filter after the search", (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          search: 'contributor',
          filter: (_Row row, int index) => row['commits'] != null,
        ),
      );

      expect(shown(tester), <String>['Anya']);
    });
  });

  group('paging', () {
    testWidgets('cuts the rows into pages and steps through them', (WidgetTester tester) async {
      final List<int> pages = <int>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(25),
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 10,
          onPageChange: pages.add,
        ),
      );

      expect(find.text('Row 0'), findsOneWidget);
      expect(find.text('Row 10'), findsNothing);
      expect(find.text('1–10 of 25'), findsOneWidget);

      await tester.tap(find.descendant(of: find.byType(NebaPagination), matching: find.text('3')));
      await tester.pump();

      expect(pages, <int>[3]);
      expect(find.text('Row 20'), findsOneWidget);
      expect(find.text('Row 0'), findsNothing);
      expect(find.text('21–25 of 25'), findsOneWidget);
    });

    testWidgets('hands the builder a row number that runs across the pages', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(
              key: 'n',
              builder: (BuildContext context, _Row row, int index) => Text('n${index + 1}'),
            ),
          ],
          items: _numbered(25),
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 10,
          defaultPage: 2,
        ),
      );

      expect(find.text('n11'), findsOneWidget);
    });

    testWidgets('takes the total from rowCount when the caller pages', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          paging: NebaDataTablePaging.pages,
          manual: const <NebaDataTableStage>{NebaDataTableStage.pages},
          rowCount: 842,
          pageSize: 10,
          page: 3,
        ),
      );

      expect(find.text('Row 0'), findsOneWidget);
      expect(find.text('21–30 of 842'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(NebaPagination), matching: find.text('85')),
        findsOneWidget,
      );
    });

    testWidgets('moves back into range when a search shortens the table', (
      WidgetTester tester,
    ) async {
      NebaDataTable<_Row> table(String search) {
        return NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(40),
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 10,
          page: 4,
          search: search,
        );
      }

      await pump(tester, table(''));
      expect(find.text('Row 30'), findsOneWidget);

      await pump(tester, table('row 1'));
      // Row 1 and Row 10 to Row 19: eleven rows, two pages, the second shown.
      expect(find.text('11–11 of 11'), findsOneWidget);
      expect(find.text('Row 19'), findsOneWidget);
    });

    testWidgets('changes how many rows a page holds from its select', (WidgetTester tester) async {
      final List<int> sizes = <int>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(60),
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 10,
          pageSizeOptions: const <int>[10, 25],
          onPageSizeChange: sizes.add,
        ),
        height: 900,
      );

      expect(find.text('Rows per page'), findsWidgets);

      await tester.tap(find.byType(NebaSelect<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25').last);
      await tester.pumpAndSettle();

      expect(sizes, <int>[25]);
      expect(find.text('1–25 of 60'), findsOneWidget);
    });

    testWidgets('drops the page-size select when it offers no sizes', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(30),
          paging: NebaDataTablePaging.pages,
          pageSizeOptions: const <int>[],
        ),
      );

      expect(find.byType(NebaSelect<int>), findsNothing);
      expect(find.byType(NebaPagination), findsOneWidget);
    });
  });

  group('virtual scrolling', () {
    testWidgets('builds a window of the rows rather than all of them', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(1000), height: 200),
      );

      expect(find.text('Row 0'), findsOneWidget);
      expect(find.text('Row 100'), findsNothing);
      expect(find.text('Row 999'), findsNothing);
    });

    testWidgets('builds the rows it scrolls to', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(1000), height: 200),
      );

      final ScrollableState body = tester.state<ScrollableState>(
        find.byWidgetPredicate(
          (Widget widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
        ),
      );

      body.position.jumpTo(24.0 * 500);
      await tester.pump();

      expect(find.text('Row 0'), findsNothing);
      expect(find.text('Row 505'), findsOneWidget);
      // The scroll is the whole of the rows' height.
      expect(body.position.maxScrollExtent, greaterThan(24.0 * 990));
    });

    testWidgets('builds every row when nothing bounds the height, or virtual is off', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(60)));
      expect(find.text('Row 59', skipOffstage: false), findsOneWidget);

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(60),
          height: 200,
          virtual: false,
        ),
      );
      expect(find.text('Row 59', skipOffstage: false), findsOneWidget);
    });

    testWidgets('says once in a debug build that a long table with no height is not virtual', (
      WidgetTester tester,
    ) async {
      final List<String?> printed = <String?>[];
      final DebugPrintCallback previous = debugPrint;

      debugPrint = (String? message, {int? wrapWidth}) => printed.add(message);
      addTearDown(() => debugPrint = previous);

      await pump(tester, NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(600)));
      await pump(tester, NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(601)));

      expect(printed.where((String? line) => line!.contains('600 rows at once')), hasLength(1));
      expect(printed, hasLength(1));

      await pump(tester, const SizedBox());
      await pump(
        tester,
        NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(600), height: 200),
      );
      await pump(tester, const SizedBox());
      await pump(
        tester,
        NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(600), virtual: false),
      );
      await pump(tester, const SizedBox());
      await pump(tester, NebaDataTable<_Row>(headers: _rowColumns, items: _numbered(20)));

      expect(printed, hasLength(1));
    });
  });

  group('selection', () {
    testWidgets('chooses nothing until a mode is set', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));
      await click(tester, find.text('Theo'));

      expect(find.textContaining('selected'), findsNothing);
      expect(tester.getSemantics(find.text('Theo')), matchesSemantics(label: 'Theo\nReviewer\n37'));

      semantics.dispose();
    });

    testWidgets('reports the keys and the rows behind them', (WidgetTester tester) async {
      final List<List<Object>> keys = <List<Object>>[];
      final List<List<_Row>> rows = <List<_Row>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.single,
          onSelectedChange: (List<Object> selected, List<_Row> chosen) {
            keys.add(selected);
            rows.add(chosen);
          },
        ),
      );

      await click(tester, find.text('Theo'));

      expect(keys.single, <Object>[2]);
      expect(rows.single, <_Row>[_people[1]]);
      expect(find.textContaining('1 selected'), findsOneWidget);
    });

    testWidgets('chooses a row a finger pressed only when the press comes up as a tap', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(100),
          height: 200,
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      await tester.drag(find.text('Row 3'), const Offset(0, -100));
      await tester.pump();
      expect(keys, isEmpty);

      await tester.tap(find.text('Row 6'));
      await tester.pump();
      expect(keys.single, <Object>[6]);
    });

    testWidgets('drops the rest on a plain click, adds one with Ctrl and takes a run with Shift', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      await click(tester, find.text('Row 1'));
      await click(tester, find.text('Row 4'));
      expect(keys.last, <Object>[4]);

      await click(
        tester,
        find.text('Row 6'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft],
      );
      expect(keys.last, <Object>[4, 6]);

      await click(
        tester,
        find.text('Row 2'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.shiftLeft],
      );
      expect(keys.last, <Object>[2, 3, 4, 5, 6]);

      final NebaColorRoles roles = NebaTheme.of(
        tester.element(find.text('Row 3')),
      ).roles(NebaColor.primary);

      await tester.pump(const Duration(seconds: 1));
      expect(tintOf(tester, 'Row 3'), roles.softPress);
    });

    testWidgets('chooses the pressed row with Shift when the anchor is hidden', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];
      NebaDataTable<_Row> table(String search) {
        return NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          search: search,
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        );
      }

      await pump(tester, table(''));
      await click(tester, find.text('Row 1'));
      await pump(tester, table('row 5'));
      await click(
        tester,
        find.text('Row 5'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.shiftLeft],
      );

      expect(keys.last, <Object>[5]);
    });

    testWidgets('keeps a single-select table to one row however it is clicked', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          selectionMode: NebaDataTableSelectionMode.single,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      await click(tester, find.text('Row 1'));
      await click(
        tester,
        find.text('Row 4'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.controlLeft],
      );
      await click(
        tester,
        find.text('Row 6'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.shiftLeft],
      );

      expect(keys, <List<Object>>[
        <Object>[1],
        <Object>[4],
        <Object>[6],
      ]);
    });

    testWidgets('keeps the rows chosen on other pages when the caller pages', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];
      final List<List<_Row>> rows = <List<_Row>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(20).sublist(10),
          rowKey: _idOf,
          manual: const <NebaDataTableStage>{NebaDataTableStage.pages},
          rowCount: 20,
          paging: NebaDataTablePaging.pages,
          pageSize: 10,
          page: 2,
          selectionMode: NebaDataTableSelectionMode.multiple,
          defaultSelected: const <Object>[3],
          onSelectedChange: (List<Object> selected, List<_Row> chosen) {
            keys.add(selected);
            rows.add(chosen);
          },
        ),
      );

      await click(
        tester,
        find.text('Row 12'),
        holding: <LogicalKeyboardKey>[LogicalKeyboardKey.metaLeft],
      );

      expect(keys.last, <Object>[3, 12]);
      expect(rows.last.map((_Row row) => row['id']), <Object>[12]);
    });

    testWidgets('takes the run a mouse drags through, once per row it reaches', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.text('Row 2')),
        kind: PointerDeviceKind.mouse,
      );

      await tester.pump();

      for (int step = 1; step <= 12; step++) {
        await mouse.moveBy(const Offset(0, 6));
        await tester.pump();
      }

      await mouse.up();
      await tester.pump();

      expect(keys.first, <Object>[2]);
      expect(keys.last, <Object>[2, 3, 4, 5]);
      expect(keys, hasLength(4));
    });

    testWidgets('scrolls a dragged run at the edge and stops at the end of the rows', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(30),
          height: 200,
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      final Rect body = tester.getRect(find.byType(CustomScrollView));
      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.text('Row 1')),
        kind: PointerDeviceKind.mouse,
      );

      await tester.pump();
      await mouse.moveTo(Offset(body.center.dx, body.bottom - 2));

      for (int frame = 0; frame < 120; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(keys.last.last, 29);
      expect(tester.binding.transientCallbackCount, 0);

      await mouse.up();
      await tester.pump();
    });

    testWidgets('walks the rows with the arrow keys, choosing as it goes', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(10),
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      await focusTable(tester);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.arrowDown);
      expect(keys.last, <Object>[1]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(keys.last, <Object>[1, 2, 3]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(keys.last, <Object>[1, 2, 3, 4]);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await key(tester, LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(keys.last, hasLength(10));

      await key(tester, LogicalKeyboardKey.escape);
      expect(keys.last, isEmpty);
    });

    testWidgets(
      'keeps the chosen row through Home, End and the Page keys, and moves the active one',
      (WidgetTester tester) async {
        final List<List<Object>> keys = <List<Object>>[];

        await pump(
          tester,
          NebaDataTable<_Row>(
            headers: _rowColumns,
            items: _numbered(200),
            height: 200,
            selectionMode: NebaDataTableSelectionMode.multiple,
            onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
          ),
        );

        await click(tester, find.text('Row 2'));
        await key(tester, LogicalKeyboardKey.end);
        expect(keys, <List<Object>>[
          <Object>[2],
        ]);
        expect(find.text('Row 199'), findsOneWidget);

        await key(tester, LogicalKeyboardKey.home);
        await key(tester, LogicalKeyboardKey.pageDown);
        expect(keys, hasLength(1));

        // The active row went along: the next arrow carries on from there.
        await key(tester, LogicalKeyboardKey.arrowDown);
        expect((keys.last.single as int) > 2, isTrue);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await key(tester, LogicalKeyboardKey.end);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        expect(keys.last.last, 199);
      },
    );

    testWidgets('keeps the active row on screen as the arrows walk past the edge', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _rowColumns,
          items: _numbered(100),
          height: 200,
          caption: const Text('Readings'),
          selectionMode: NebaDataTableSelectionMode.single,
        ),
      );

      await focusTable(tester);

      for (int i = 0; i < 20; i++) {
        await key(tester, LogicalKeyboardKey.arrowDown);
      }

      final Rect body = tester.getRect(find.byType(CustomScrollView));

      expect(tester.getRect(find.text('Row 19')).bottom, lessThanOrEqualTo(body.bottom));

      for (int i = 0; i < 19; i++) {
        await key(tester, LogicalKeyboardKey.arrowUp);
      }

      // Below the sticky header, not under it.
      final Rect header = cellOf(tester, 'ID');

      expect(cellOf(tester, 'Row 0').top, greaterThanOrEqualTo(header.bottom - 0.5));
    });

    testWidgets('rings the active row in a table the keyboard acts on', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          selectionMode: NebaDataTableSelectionMode.single,
        ),
      );

      await click(tester, find.text('Theo'));

      final Container row = tester.widget<Container>(
        find.ancestor(of: find.text('Theo'), matching: find.byType(Container)).at(1),
      );
      final NebaColorRoles roles = NebaTheme.of(
        tester.element(find.text('Theo')),
      ).roles(NebaColor.primary);

      expect(row.foregroundDecoration, BoxDecoration(border: Border.all(color: roles.ring)));
    });

    testWidgets('opens a row from the keyboard without choosing when nothing is chosen', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          onRowActivate: (_Row row, int index) => opened.add('${row['name']} $index'),
        ),
      );

      await focusTable(tester);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.enter);

      expect(opened, <String>['Theo 1']);
      expect(find.textContaining('selected'), findsNothing);
    });

    testWidgets('takes no focus with nothing a keyboard could do in it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));

      final Focus focus = tester
          .widgetList<Focus>(find.byType(Focus))
          .firstWhere((Focus focus) => focus.focusNode?.debugLabel == 'NebaDataTable');

      expect(focus.canRequestFocus, isFalse);
      expect(focus.skipTraversal, isTrue);
    });

    testWidgets('answers a click and a double click in a table that chooses many rows', (
      WidgetTester tester,
    ) async {
      final List<String> pressed = <String>[];
      final List<String> opened = <String>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          selectionMode: NebaDataTableSelectionMode.multiple,
          onRowPressed: (_Row row, int index) => pressed.add('${row['name']}'),
          onRowActivate: (_Row row, int index) => opened.add('${row['name']}'),
        ),
      );

      await click(tester, find.text('Anya'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(pressed, <String>['Anya']);
      expect(opened, isEmpty);

      await click(tester, find.text('Theo'));
      await tester.pump(const Duration(milliseconds: 50));
      await click(tester, find.text('Theo'));

      expect(pressed, <String>['Anya', 'Theo', 'Theo']);
      expect(opened, <String>['Theo']);
    });

    testWidgets('ticks a row and every row from the header', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.multiple,
          checkboxes: true,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Select row Theo'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Select row Anya'));
      await tester.pump();
      expect(keys.last, <Object>[2, 3]);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Select all rows')),
        matchesSemantics(
          label: 'Select all rows',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Select all rows'));
      await tester.pump();
      expect(keys.last, <Object>[2, 3, 1, 4]);

      await tester.tap(find.bySemanticsLabel('Select all rows'));
      await tester.pump();
      expect(keys.last, isEmpty);

      semantics.dispose();
    });

    testWidgets("keeps a row's tick out of the tab order, and its press off the row", (
      WidgetTester tester,
    ) async {
      final List<String> pressed = <String>[];
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.multiple,
          checkboxes: true,
          defaultSelected: const <Object>[1],
          onRowPressed: (_Row row, int index) => pressed.add('${row['name']}'),
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      expect(
        find.ancestor(
          of: find.bySemanticsLabel('Select row Theo'),
          matching: find.byType(ExcludeFocus),
        ),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Select row Theo'), kind: PointerDeviceKind.mouse);
      await tester.pump();

      expect(keys.last, <Object>[1, 2]);
      expect(pressed, isEmpty);
    });

    testWidgets('honours a controlled selection', (WidgetTester tester) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.multiple,
          selected: const <Object>[3],
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      expect(find.textContaining('1 selected'), findsOneWidget);

      await click(tester, find.text('Nadia'));

      expect(keys.last, <Object>[1]);
      await tester.pump();
      // Still what the caller says.
      expect(find.textContaining('1 selected'), findsOneWidget);
    });

    testWidgets('hears a chosen row as selected', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          rowKey: _idOf,
          selectionMode: NebaDataTableSelectionMode.single,
          defaultSelected: <Object>[2],
        ),
      );

      expect(
        tester.getSemantics(find.text('Theo')),
        matchesSemantics(
          label: 'Theo\nReviewer\n37',
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Nadia')),
        matchesSemantics(
          label: 'Nadia\nMaintainer\n214',
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      expect(tester.getSemantics(find.text('Nadia')).label, contains('Maintainer'));

      semantics.dispose();
    });
  });

  group('resizing', () {
    testWidgets('draws no handle until it is asked for', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaDataTable<_Row>(headers: _columns, items: _people));
      expect(find.bySemanticsLabel('Resize Name'), findsNothing);

      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, resizable: true),
      );
      expect(find.bySemanticsLabel('Resize Name'), findsOneWidget);
      expect(find.bySemanticsLabel('Resize Role'), findsOneWidget);
      // The last column has no boundary after it to move.
      expect(find.bySemanticsLabel('Resize Commits'), findsNothing);
      expect(tester.getSemantics(find.bySemanticsLabel('Resize Name')).value, '160');

      semantics.dispose();
    });

    testWidgets('drags a column wider and freezes the rest where they were', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<Map<String, double>> widths = <Map<String, double>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          resizable: true,
          onColumnWidthsChange: widths.add,
        ),
      );

      final double role = cellOf(tester, 'Maintainer').width;
      final Offset handle = tester.getCenter(find.bySemanticsLabel('Resize Name'));

      await tester.timedDragFrom(handle, const Offset(40, 0), const Duration(milliseconds: 200));
      await tester.pump();

      expect(widths.last, <String, double>{'name': 200, 'role': role, 'commits': 100});
      expect(cellOf(tester, 'Nadia').width, 200);
      expect(cellOf(tester, 'Maintainer').width, role);

      semantics.dispose();
    });

    testWidgets('gives a column its own width back on a double press', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<Map<String, double>> widths = <Map<String, double>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          resizable: true,
          defaultColumnWidths: const <String, double>{'name': 240},
          onColumnWidthsChange: widths.add,
        ),
      );

      final Finder handle = find.bySemanticsLabel('Resize Name');

      await tester.tap(handle);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(handle);
      await tester.pump();

      expect(widths.last, isEmpty);
      expect(cellOf(tester, 'Nadia').width, 160);

      await tester.pump(const Duration(seconds: 1));
      semantics.dispose();
    });

    testWidgets('reports the widths and honours controlled ones', (WidgetTester tester) async {
      final List<Map<String, double>> widths = <Map<String, double>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          resizable: true,
          columnWidths: const <String, double>{'name': 300},
          onColumnWidthsChange: widths.add,
        ),
      );

      expect(cellOf(tester, 'Nadia').width, 300);
    });

    testWidgets('widens a column from the keyboard, a step at a time', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<Map<String, double>> widths = <Map<String, double>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          resizable: true,
          onColumnWidthsChange: widths.add,
        ),
      );

      final Focus handle = tester.widget<Focus>(
        find
            .descendant(of: find.bySemanticsLabel('Resize Name'), matching: find.byType(Focus))
            .first,
      );

      expect(handle.skipTraversal, isFalse);

      Focus.of(
        tester.element(
          find
              .descendant(
                of: find.bySemanticsLabel('Resize Name'),
                matching: find.byType(MouseRegion),
              )
              .first,
        ),
      ).requestFocus();
      await tester.pump();
      await key(tester, LogicalKeyboardKey.arrowRight);
      await key(tester, LogicalKeyboardKey.arrowRight);

      expect(widths.last['name'], 192);

      await key(tester, LogicalKeyboardKey.arrowLeft);
      expect(widths.last['name'], 176);

      semantics.dispose();
    });
  });

  group('pinned columns', () {
    const List<NebaDataTableColumn<_Row>> wide = <NebaDataTableColumn<_Row>>[
      NebaDataTableColumn<_Row>(key: 'role', label: Text('Role'), width: 300),
      NebaDataTableColumn<_Row>(key: 'commits', label: Text('Commits'), width: 300),
      NebaDataTableColumn<_Row>(
        key: 'name',
        label: Text('Name'),
        width: 120,
        pinned: NebaDataTablePin.start,
      ),
      NebaDataTableColumn<_Row>(
        key: 'id',
        label: Text('ID'),
        width: 80,
        pinned: NebaDataTablePin.end,
      ),
    ];

    testWidgets('moves a pinned column to its edge whatever the order said', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataTable<_Row>(headers: wide, items: _people), width: 500);

      final Rect table = tester.getRect(find.byType(NebaDataTable<_Row>));

      // Inside the sheet's hairline at each edge.
      expect(cellOf(tester, 'Name').left, table.left + 1);
      expect(cellOf(tester, 'Role').left, cellOf(tester, 'Name').right);
      expect(cellOf(tester, 'ID').right, table.right - 1);
    });

    testWidgets('holds a pinned column against its edge while the rest scroll', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataTable<_Row>(headers: wide, items: _people), width: 500);

      final Rect name = cellOf(tester, 'Nadia');
      final Rect id = cellOf(tester, '1');
      final Rect role = cellOf(tester, 'Maintainer');
      final ScrollableState across = tester.state<ScrollableState>(
        find.byWidgetPredicate(
          (Widget widget) => widget is Scrollable && widget.axisDirection == AxisDirection.right,
        ),
      );

      expect(id.right, tester.getRect(find.byType(NebaDataTable<_Row>)).right - 1);

      across.position.jumpTo(200);
      await tester.pump();

      expect(cellOf(tester, 'Nadia'), name);
      expect(cellOf(tester, '1'), id);
      expect(cellOf(tester, 'Maintainer').left, role.left - 200);
    });

    testWidgets('freezes the tick column with the columns pinned to the start', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: wide,
          items: _people,
          selectionMode: NebaDataTableSelectionMode.multiple,
          checkboxes: true,
        ),
        width: 500,
      );

      final Rect tick = tester.getRect(find.bySemanticsLabel('Select row Nadia'));

      tester
          .state<ScrollableState>(
            find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Scrollable && widget.axisDirection == AxisDirection.right,
            ),
          )
          .position
          .jumpTo(150);
      await tester.pump();

      expect(tester.getRect(find.bySemanticsLabel('Select row Nadia')), tick);

      semantics.dispose();
    });

    testWidgets("paints a pinned cell on the sheet's own ground", (WidgetTester tester) async {
      await pump(tester, const NebaDataTable<_Row>(headers: wide, items: _people), width: 500);

      final NebaTokens tokens = NebaTheme.of(tester.element(find.text('Nadia')));

      expect(tintOf(tester, 'Nadia'), Color.alphaBlend(const Color(0x00000000), tokens.panelPress));
    });
  });

  group('column order', () {
    testWidgets('draws the columns in the order given, leaving the rest where they were', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          columnOrder: <String>['commits'],
        ),
      );

      expect(cellOf(tester, 'Commits').left, lessThan(cellOf(tester, 'Name').left));
      expect(cellOf(tester, 'Name').left, lessThan(cellOf(tester, 'Role').left));
    });

    testWidgets('moves a column with Alt and an arrow on its heading, and keeps the focus', (
      WidgetTester tester,
    ) async {
      final List<List<String>> orders = <List<String>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          reorderable: true,
          onColumnOrderChange: orders.add,
        ),
      );

      Focus.of(tester.element(find.text('Name'))).requestFocus();
      await tester.pump();

      final FocusNode focused = FocusManager.instance.primaryFocus!;

      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await key(tester, LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);

      expect(orders.single, <String>['role', 'name', 'commits']);
      expect(cellOf(tester, 'Name').left, greaterThan(cellOf(tester, 'Role').left));
      expect(FocusManager.instance.primaryFocus, focused);
    });

    testWidgets('lets a heading with no sort button take the focus when it moves', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: _columns, items: _people, reorderable: true),
      );

      final Iterable<Focus> movers = tester
          .widgetList<Focus>(find.ancestor(of: find.text('Name'), matching: find.byType(Focus)))
          .where((Focus focus) => focus.focusNode == null);

      expect(movers.first.canRequestFocus, isTrue);
    });

    testWidgets('carries a heading to move its column, and still sorts from a press', (
      WidgetTester tester,
    ) async {
      final List<List<String>> orders = <List<String>>[];
      final List<List<NebaDataTableSort>> sorts = <List<NebaDataTableSort>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          reorderable: true,
          onColumnOrderChange: orders.add,
          onSortChange: sorts.add,
        ),
      );

      await tester.tap(find.text('Commits'), kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(sorts, hasLength(1));
      expect(orders, isEmpty);

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.text('Commits')),
        kind: PointerDeviceKind.mouse,
      );

      await mouse.moveBy(const Offset(-20, 0));
      await tester.pump();

      final NebaColorRoles roles = NebaTheme.of(
        tester.element(find.text('Name')),
      ).roles(NebaColor.primary);
      final NebaTokens tokens = NebaTheme.of(tester.element(find.text('Name')));

      // The carried heading takes a wash rather than a fade.
      expect(
        (tester
                    .widget<Container>(
                      find
                          .ancestor(of: find.text('Commits'), matching: find.byType(Container))
                          .first,
                    )
                    .decoration!
                as BoxDecoration)
            .color,
        Color.alphaBlend(roles.soft, tokens.panelPress),
      );

      await mouse.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump();

      // It lands before the heading under it, which is marked on that edge.
      expect(
        tester
            .widget<Container>(
              find.ancestor(of: find.text('Name'), matching: find.byType(Container)).first,
            )
            .foregroundDecoration,
        BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: roles.accent, width: 2)),
        ),
      );

      await mouse.up();
      await tester.pump();

      expect(orders.single, <String>['commits', 'name', 'role']);
      expect(sorts, hasLength(1));
    });
  });

  group('editing', () {
    List<NebaDataTableColumn<_Row>> editable({bool Function(_Row row)? when}) {
      return <NebaDataTableColumn<_Row>>[
        NebaDataTableColumn<_Row>(
          key: 'name',
          label: const Text('Name'),
          editable: true,
          editableWhen: when,
        ),
        const NebaDataTableColumn<_Row>(
          key: 'commits',
          label: Text('Commits'),
          editable: true,
          editType: NebaDataTableEditType.number,
        ),
      ];
    }

    Future<void> doubleClick(WidgetTester tester, Finder finder) async {
      await tester.tap(finder, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(finder, kind: PointerDeviceKind.mouse);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('does not edit without a handler above it', (WidgetTester tester) async {
      await pump(tester, NebaDataTable<_Row>(headers: editable(), items: _people));
      await doubleClick(tester, find.text('Theo'));

      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('opens an editor on a double click and commits on Enter, not opening the row', (
      WidgetTester tester,
    ) async {
      final List<String> edits = <String>[];
      final List<String> opened = <String>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(),
          items: _people,
          onRowActivate: (_Row row, int index) => opened.add('${row['name']}'),
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) =>
              edits.add('${row['id']} ${column.key} $value'),
        ),
      );

      await doubleClick(tester, find.text('Theo'));

      expect(find.byType(EditableText), findsOneWidget);
      expect(opened, isEmpty);

      // The sheet rings for an open editor, as it does for the table's focus.
      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing).first).visible, isTrue);

      await tester.enterText(find.byType(EditableText), 'Theodore');
      await key(tester, LogicalKeyboardKey.enter);

      expect(edits, <String>['2 name Theodore']);
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('throws the edit away on Escape and gives the focus back to the table', (
      WidgetTester tester,
    ) async {
      final List<String> edits = <String>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(),
          items: _people,
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) =>
              edits.add('$value'),
        ),
      );

      await doubleClick(tester, find.text('Theo'));
      await tester.enterText(find.byType(EditableText), 'Thea');
      await key(tester, LogicalKeyboardKey.escape);
      await tester.pump();

      expect(edits, isEmpty);
      expect(find.byType(EditableText), findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'NebaDataTable');
    });

    testWidgets('keeps the presses inside an open editor off the row', (WidgetTester tester) async {
      final List<String> pressed = <String>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(),
          items: _people,
          onRowPressed: (_Row row, int index) => pressed.add('${row['name']}'),
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) {},
        ),
      );

      await doubleClick(tester, find.text('Theo'));
      pressed.clear();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byType(EditableText), kind: PointerDeviceKind.mouse);
      await tester.pump();

      expect(pressed, isEmpty);
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets('asks the column which rows may be edited', (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(when: (_Row row) => row['id'] != 2),
          items: _people,
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) {},
        ),
      );

      await doubleClick(tester, find.text('Theo'));
      expect(find.byType(EditableText), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
      await doubleClick(tester, find.text('Anya'));
      expect(find.byType(EditableText), findsOneWidget);
    });

    testWidgets("opens the active row's editor on F2", (WidgetTester tester) async {
      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(),
          items: _people,
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) {},
        ),
      );

      await focusTable(tester);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.f2);
      await tester.pump();

      expect(find.byType(EditableText), findsOneWidget);
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'Nadia');
    });

    testWidgets('hands back a number for a number column, and no zero for an emptied one', (
      WidgetTester tester,
    ) async {
      final List<Object> values = <Object>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: editable(),
          items: _people,
          onCellEdit: (_Row row, NebaDataTableColumn<_Row> column, Object value) =>
              values.add(value),
        ),
      );

      await doubleClick(tester, find.text('37'));
      await tester.enterText(find.byType(EditableText), '40');
      await key(tester, LogicalKeyboardKey.enter);

      expect(values.single, 40);
      expect(values.single, isA<int>());

      await tester.pump(const Duration(milliseconds: 500));
      await doubleClick(tester, find.text('214'));
      await tester.enterText(find.byType(EditableText), ' ');
      await key(tester, LogicalKeyboardKey.enter);

      expect(values, hasLength(1));
    });
  });

  group('grouping', () {
    List<_Row> team() {
      return <_Row>[
        <String, Object?>{'id': 1, 'name': 'Nadia', 'team': 'Core', 'spend': 10},
        <String, Object?>{'id': 2, 'name': 'Theo', 'team': 'Docs', 'spend': 4},
        <String, Object?>{'id': 3, 'name': 'Anya', 'team': 'Core', 'spend': 7},
        <String, Object?>{'id': 4, 'name': 'Émile', 'team': null, 'spend': 1},
      ];
    }

    NebaDataTable<_Row> grouped({
      List<String>? folded,
      List<NebaDataTableSort>? sort,
      NebaDataTableStripe striped = NebaDataTableStripe.none,
    }) {
      return NebaDataTable<_Row>(
        headers: <NebaDataTableColumn<_Row>>[
          const NebaDataTableColumn<_Row>(key: 'name', label: Text('Name')),
          NebaDataTableColumn<_Row>(
            key: 'spend',
            label: const Text('Spend'),
            aggregate: (List<_Row> rows) =>
                Text('Σ ${rows.fold<int>(0, (int sum, _Row row) => sum + (row['spend']! as int))}'),
          ),
        ],
        items: team(),
        rowKey: _idOf,
        groupBy: (_Row row) => row['team'] as String?,
        defaultCollapsedGroups: folded,
        defaultSort: sort,
        striped: striped,
        hoverable: false,
      );
    }

    testWidgets('heads each group with its count, the rows in no group first', (
      WidgetTester tester,
    ) async {
      await pump(tester, grouped());

      expect(shown(tester, <String>['No group', 'Core', 'Docs', ..._names]), <String>[
        'No group',
        'Émile',
        'Core',
        'Nadia',
        'Anya',
        'Docs',
        'Theo',
      ]);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('puts an aggregate in the column it is a total of', (WidgetTester tester) async {
      await pump(tester, grouped());

      expect(find.text('Σ 17'), findsOneWidget);
      expect(cellOf(tester, 'Σ 17').left, cellOf(tester, 'Spend').left);
    });

    testWidgets('folds a group away and back, and starts with the ones it was told to fold', (
      WidgetTester tester,
    ) async {
      await pump(tester, grouped(folded: <String>['Docs']));
      expect(find.text('Theo'), findsNothing);
      expect(find.text('Docs'), findsOneWidget);

      await tester.tap(find.text('Core'));
      await tester.pump();
      expect(find.text('Nadia'), findsNothing);

      await tester.tap(find.text('Docs'));
      await tester.pump();
      expect(find.text('Theo'), findsOneWidget);
    });

    testWidgets('keeps the folded headings when every group is folded', (
      WidgetTester tester,
    ) async {
      await pump(tester, grouped(folded: <String>['', 'Core', 'Docs']));

      expect(find.text('Core'), findsOneWidget);
      expect(find.text('Nothing here'), findsNothing);
    });

    testWidgets('groups after the sort, so each group stays sorted', (WidgetTester tester) async {
      await pump(tester, grouped(sort: const <NebaDataTableSort>[NebaDataTableSort(key: 'name')]));

      expect(shown(tester), <String>['Émile', 'Anya', 'Nadia', 'Theo']);
    });

    testWidgets('stripes grouped rows by their place on the page, across the headings', (
      WidgetTester tester,
    ) async {
      await pump(tester, grouped(striped: NebaDataTableStripe.even));

      final Color stripe = NebaTheme.of(
        tester.element(find.text('Nadia')),
      ).fg.withValues(alpha: 0.04);

      // Émile, Nadia, Anya, Theo: the second and the fourth.
      expect(tintOf(tester, 'Nadia'), stripe);
      expect(tintOf(tester, 'Theo'), stripe);
      expect(tintOf(tester, 'Anya').a, 0);
    });

    testWidgets('drags a run past a group heading to the row under the pointer', (
      WidgetTester tester,
    ) async {
      final List<List<Object>> keys = <List<Object>>[];

      await pump(
        tester,
        NebaDataTable<_Row>(
          headers: const <NebaDataTableColumn<_Row>>[NebaDataTableColumn<_Row>(key: 'name')],
          items: team(),
          rowKey: _idOf,
          groupBy: (_Row row) => row['team'] as String?,
          selectionMode: NebaDataTableSelectionMode.multiple,
          onSelectedChange: (List<Object> selected, List<_Row> _) => keys.add(selected),
        ),
      );

      final TestGesture mouse = await tester.startGesture(
        tester.getCenter(find.text('Émile')),
        kind: PointerDeviceKind.mouse,
      );

      await tester.pump();
      // Onto the Core heading, which counts as the end of the group over it.
      await mouse.moveTo(tester.getCenter(find.text('Core')));
      await tester.pump();
      expect(keys.last, <Object>[4]);

      await mouse.moveTo(tester.getCenter(find.text('Anya')));
      await tester.pump();
      await mouse.up();

      expect(keys.last, <Object>[4, 1, 3]);
    });
  });

  group('export', () {
    const List<NebaDataTableColumn<_Row>> exported = <NebaDataTableColumn<_Row>>[
      NebaDataTableColumn<_Row>(key: 'name', label: Text('Name')),
      NebaDataTableColumn<_Row>(key: 'role', label: Text('Role')),
      NebaDataTableColumn<_Row>(key: 'commits', exportable: false),
    ];

    Future<String> export(
      WidgetTester tester,
      NebaDataTable<_Row> Function(ValueChanged<String>) table,
    ) async {
      final List<String> files = <String>[];

      await pump(tester, table(files.add));
      await tester.tap(find.text('Export CSV'));
      await tester.pump();

      return files.single;
    }

    testWidgets('draws its button only with somewhere to hand the file', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(headers: exported, items: _people, exportable: true),
      );

      expect(find.text('Export CSV'), findsNothing);
    });

    testWidgets('writes the headings and what the search left, not the page', (
      WidgetTester tester,
    ) async {
      final String csv = await export(
        tester,
        (ValueChanged<String> onExport) => NebaDataTable<_Row>(
          headers: exported,
          items: _people,
          exportable: true,
          onExport: onExport,
          search: 'contrib',
          paging: NebaDataTablePaging.pages,
          defaultPageSize: 1,
        ),
      );

      expect(csv, '\uFEFFName,Role\r\nAnya,Contributor\r\nÉmile,Contributor');
    });

    testWidgets('writes what a column says rather than what it draws, and escapes formulas', (
      WidgetTester tester,
    ) async {
      final List<_Row> rows = <_Row>[
        <String, Object?>{'name': '=HYPERLINK("x")', 'role': 'a,b'},
      ];

      String csv = await export(
        tester,
        (ValueChanged<String> onExport) => NebaDataTable<_Row>(
          headers: <NebaDataTableColumn<_Row>>[
            const NebaDataTableColumn<_Row>(key: 'name', label: Text('Name')),
            NebaDataTableColumn<_Row>(
              key: 'role',
              label: const Text('Role'),
              builder: (BuildContext context, _Row row, int index) => const Text('drawn'),
              exportValue: (_Row row) => 'kept ${row['role']}',
            ),
          ],
          items: rows,
          exportable: true,
          onExport: onExport,
        ),
      );

      expect(csv, '\uFEFFName,Role\r\n"\'=HYPERLINK(""x"")","kept a,b"');

      csv = await export(
        tester,
        (ValueChanged<String> onExport) => NebaDataTable<_Row>(
          headers: const <NebaDataTableColumn<_Row>>[
            NebaDataTableColumn<_Row>(key: 'name', label: Text('Name')),
          ],
          items: rows,
          exportable: true,
          exportEscapeFormulas: false,
          onExport: onExport,
        ),
      );

      expect(csv, '\uFEFFName\r\n"=HYPERLINK(""x"")"');
    });
  });

  group('ink', () {
    testWidgets('writes the headings muted and a sorted one in the accent', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaDataTable<_Row>(
          headers: _columns,
          items: _people,
          sortable: true,
          defaultSort: <NebaDataTableSort>[NebaDataTableSort(key: 'name')],
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final NebaTokens tokens = NebaTheme.of(tester.element(find.text('Name')));
      final TextStyle name = DefaultTextStyle.of(tester.element(find.text('Name'))).style;
      final TextStyle role = DefaultTextStyle.of(tester.element(find.text('Role'))).style;

      expect(name.color, tokens.roles(NebaColor.primary).accent);
      expect(role.color, tokens.mutedFg);
      expect(role.fontWeight, FontWeight.w600);
    });

    testWidgets('lays out right to left', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: const Align(
              alignment: AlignmentDirectional.topStart,
              child: NebaDataTable<_Row>(headers: _columns, items: _people),
            ),
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(cellOf(tester, 'Name').right, greaterThan(cellOf(tester, 'Role').right));
      expect(cellOf(tester, 'Name').right, 800 - 1);
    });
  });
}
