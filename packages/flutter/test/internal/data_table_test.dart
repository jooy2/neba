import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/internal/data_table.dart';

const NebaDataTableSort _asc = NebaDataTableSort(key: 'a');
const NebaDataTableSort _desc = NebaDataTableSort(
  key: 'a',
  direction: NebaDataTableSortDirection.desc,
);

void main() {
  group('the default comparison', () {
    test('puts an empty value last, and NaN with it', () {
      expect(dataCompareValues(null, 1), greaterThan(0));
      expect(dataCompareValues(1, ''), lessThan(0));
      expect(dataCompareValues(double.nan, 1), greaterThan(0));
      expect(dataCompareValues(null, ''), 0);
    });

    test('compares numbers as numbers, dates as instants and false before true', () {
      expect(dataCompareValues(2, 10), lessThan(0));
      expect(dataCompareValues(2.5, 2), greaterThan(0));
      expect(dataCompareValues(DateTime(2026), DateTime(2025)), greaterThan(0));
      expect(dataCompareValues(false, true), lessThan(0));
    });

    test('compares text by its digits as numbers, ignoring case and accents', () {
      expect(dataCompareValues('item2', 'item10'), lessThan(0));
      expect(dataCompareValues('item010', 'item10'), 0);
      expect(dataCompareValues('apple', 'Banana'), lessThan(0));
      expect(dataCompareValues('Émile', 'emile'), 0);
      expect(dataCompareValues('São Paulo', 'Seoul'), lessThan(0));
      expect(dataCompareValues('abc', 'ab'), greaterThan(0));
    });
  });

  group('sorting rows', () {
    final List<int> rows = <int>[3, 1, 2, 1];

    DataRowComparator<int>? byValue(String key) {
      return key == 'a' ? DataRowComparator<int>((int a, int b) => a - b) : null;
    }

    test('hands the rows back as they are with nothing to sort by', () {
      expect(dataSortRows<int>(rows, <NebaDataTableSort>[], byValue), same(rows));
      expect(
        dataSortRows<int>(rows, <NebaDataTableSort>[const NebaDataTableSort(key: 'gone')], byValue),
        same(rows),
      );
    });

    test('sorts both ways', () {
      expect(dataSortRows<int>(rows, <NebaDataTableSort>[_asc], byValue), <int>[1, 1, 2, 3]);
      expect(dataSortRows<int>(rows, <NebaDataTableSort>[_desc], byValue), <int>[3, 2, 1, 1]);
    });

    test('is stable, so rows that tie keep the order they came in', () {
      final List<({String name, int rank})> people = <({String name, int rank})>[
        (name: 'c', rank: 1),
        (name: 'a', rank: 2),
        (name: 'b', rank: 1),
        (name: 'd', rank: 2),
      ];

      final List<({String name, int rank})> sorted = dataSortRows<({String name, int rank})>(
        people,
        <NebaDataTableSort>[const NebaDataTableSort(key: 'rank')],
        (String key) => DataRowComparator<({String name, int rank})>(
          (({String name, int rank}) a, ({String name, int rank}) b) => a.rank - b.rank,
        ),
      );

      expect(sorted.map((({String name, int rank}) p) => p.name), <String>['c', 'b', 'a', 'd']);
    });

    test('keeps the empty rows last in a descending sort too', () {
      final List<int?> values = <int?>[2, null, 5, 1];
      DataRowComparator<int?> comparator(String key) {
        return DataRowComparator<int?>(
          (int? a, int? b) => a! - b!,
          isEmpty: (int? row) => row == null,
        );
      }

      expect(dataSortRows<int?>(values, <NebaDataTableSort>[_desc], comparator), <int?>[
        5,
        2,
        1,
        null,
      ]);
      expect(dataSortRows<int?>(values, <NebaDataTableSort>[_asc], comparator), <int?>[
        1,
        2,
        5,
        null,
      ]);
    });
  });

  group('the next sort', () {
    test('cycles ascending, descending and unsorted', () {
      final List<NebaDataTableSort> first = dataNextSort(
        <NebaDataTableSort>[],
        'a',
        additive: false,
      );
      final List<NebaDataTableSort> second = dataNextSort(first, 'a', additive: false);

      expect(first, <NebaDataTableSort>[_asc]);
      expect(second, <NebaDataTableSort>[_desc]);
      expect(dataNextSort(second, 'a', additive: false), isEmpty);
    });

    test('replaces the sort, or adds to it in place when additive', () {
      const NebaDataTableSort b = NebaDataTableSort(key: 'b');

      expect(dataNextSort(<NebaDataTableSort>[_asc], 'b', additive: false), <NebaDataTableSort>[b]);
      expect(dataNextSort(<NebaDataTableSort>[_asc], 'b', additive: true), <NebaDataTableSort>[
        _asc,
        b,
      ]);
      expect(dataNextSort(<NebaDataTableSort>[b, _asc], 'a', additive: true), <NebaDataTableSort>[
        b,
        _desc,
      ]);
      expect(dataNextSort(<NebaDataTableSort>[b, _desc], 'a', additive: true), <NebaDataTableSort>[
        b,
      ]);
    });
  });

  test('clamps the page into range', () {
    final DataPageBounds bounds = dataPageBounds(137, 3, 10);

    expect((bounds.pages, bounds.page, bounds.start, bounds.end), (14, 3, 20, 30));

    final DataPageBounds last = dataPageBounds(25, 14, 10);

    expect((last.pages, last.page, last.start, last.end), (3, 3, 20, 25));

    final DataPageBounds none = dataPageBounds(0, 2, 10);

    expect((none.pages, none.page, none.start, none.end), (1, 1, 0, 0));
  });

  test('takes the run between two keys whichever comes first', () {
    const List<String> order = <String>['a', 'b', 'c', 'd'];

    expect(dataKeysBetween<String>(order, 'b', 'd'), <String>['b', 'c', 'd']);
    expect(dataKeysBetween<String>(order, 'd', 'b'), <String>['b', 'c', 'd']);
    expect(dataKeysBetween<String>(order, 'a', 'z'), isEmpty);
    expect(
      dataKeysBetween<String>(order, 'c', 'a', positions: <String, int>{'a': 0, 'c': 2}),
      <String>['a', 'b', 'c'],
    );
  });
}
