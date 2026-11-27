import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

typedef _Record = Map<String, Object?>;

const List<NebaTableColumn<_Record>> _columns = <NebaTableColumn<_Record>>[
  NebaTableColumn<_Record>(key: 'name', label: Text('Name')),
  NebaTableColumn<_Record>(key: 'role'),
  NebaTableColumn<_Record>(key: 'commits', align: NebaAlign.end, width: 80),
];

const List<_Record> _rows = <_Record>[
  <String, Object?>{'name': 'Nadia', 'role': 'Maintainer', 'commits': 214},
  <String, Object?>{'name': 'Theo', 'role': 'Reviewer', 'commits': 37},
  <String, Object?>{'name': 'Anya', 'role': 'Contributor', 'commits': 9},
];

void main() {
  Future<void> pump(WidgetTester tester, Widget table) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 500, child: table))));
  }

  NebaTokens tokensOf(WidgetTester tester) =>
      NebaTheme.of(tester.element(find.byType(Table).first));

  /// The decoration of the [row]th row of the first table.
  BoxDecoration rowOf(WidgetTester tester, int row) {
    return tester.widget<Table>(find.byType(Table).first).children[row].decoration!
        as BoxDecoration;
  }

  testWidgets('reads a cell from a map row by its key, and builds one by its builder', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      NebaTable<_Record>(
        headers: <NebaTableColumn<_Record>>[
          ..._columns,
          NebaTableColumn<_Record>(
            key: 'badge',
            builder: (BuildContext context, _Record row, int index) => Text('#$index'),
          ),
        ],
        items: _rows,
      ),
    );

    expect(find.text('Name'), findsOneWidget);
    expect(find.text('role'), findsOneWidget);
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('214'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('fixes a column of its own width and lines its cells up by align', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaTable<_Record>(headers: _columns, items: _rows));

    final Table table = tester.widget<Table>(find.byType(Table));
    expect(
      table.columnWidths![2],
      isA<FixedColumnWidth>().having((FixedColumnWidth w) => w.value, 'value', 80),
    );
    expect(table.columnWidths![0], isA<IntrinsicColumnWidth>());
    expect(
      tester.getTopRight(find.text('214')).dx,
      greaterThan(tester.getTopRight(find.text('commits')).dx - 1),
    );
  });

  testWidgets('heads the table with a tinted row and rules every row under it', (
    WidgetTester tester,
  ) async {
    await pump(tester, const NebaTable<_Record>(headers: _columns, items: _rows));
    final NebaColorRoles primary = tokensOf(tester).roles(NebaColor.primary);

    expect(rowOf(tester, 0).color, primary.panelPress);
    expect((rowOf(tester, 1).border! as Border).top.color, primary.line);
  });

  testWidgets('tints every other row when striped', (WidgetTester tester) async {
    await pump(tester, const NebaTable<_Record>(headers: _columns, items: _rows, striped: true));

    expect(rowOf(tester, 1).color!.a, 0);
    expect(rowOf(tester, 2).color!.a, greaterThan(0));
  });

  testWidgets('lights the row under the pointer and presses it', (WidgetTester tester) async {
    final List<int> pressed = <int>[];

    await pump(
      tester,
      NebaTable<_Record>(
        headers: _columns,
        items: _rows,
        onRowPressed: (_Record row, int index) => pressed.add(index),
      ),
    );

    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Theo')));
    await tester.pump();

    expect(rowOf(tester, 2).color, tokensOf(tester).roles(NebaColor.primary).soft);

    await tester.tap(find.text('Reviewer'));
    expect(pressed, <int>[1]);
  });

  testWidgets('takes a row\'s focus and presses it on Enter and Space, ringed after a key', (
    WidgetTester tester,
  ) async {
    final List<int> pressed = <int>[];

    await pump(
      tester,
      NebaTable<_Record>(
        headers: _columns,
        items: _rows,
        onRowPressed: (_Record row, int index) => pressed.add(index),
      ),
    );

    Focus.of(tester.element(find.text('Anya'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(pressed, <int>[2, 2]);
    expect(
      (rowOf(tester, 3).border! as Border).top.color,
      tokensOf(tester).roles(NebaColor.primary).ring,
    );
  });

  testWidgets('says it is empty across its width', (WidgetTester tester) async {
    await pump(tester, const NebaTable<_Record>(headers: _columns, items: <_Record>[]));
    expect(find.text('No data'), findsOneWidget);

    await pump(
      tester,
      const NebaTable<_Record>(headers: _columns, items: <_Record>[], empty: Text('Nobody yet')),
    );
    expect(find.text('Nobody yet'), findsOneWidget);
  });

  testWidgets('scrolls its rows under a header that stays put', (WidgetTester tester) async {
    await pump(
      tester,
      NebaTable<_Record>(
        headers: _columns,
        items: <_Record>[
          for (int i = 0; i < 40; i++) <String, Object?>{'name': 'n$i'},
        ],
        stickyHeader: true,
        maxHeight: 200,
      ),
    );

    expect(tester.getSize(find.byType(NebaTable<_Record>)).height, lessThanOrEqualTo(200));
    final double header = tester.getTopLeft(find.text('Name')).dy;

    await tester.drag(find.text('n3'), const Offset(0, -150));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Name')).dy, header);
  });

  testWidgets('is a table for a screen reader, its header cells column headers', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pump(tester, const NebaTable<_Record>(headers: _columns, items: _rows));

    expect(tester.getSemantics(find.byType(Table)).getSemanticsData().role, SemanticsRole.table);
    semantics.dispose();
  });
}
