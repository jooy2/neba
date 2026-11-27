/// The arithmetic a DataTable is made of: the React package's
/// `src/internal/data-table.ts` in Dart.
///
/// Here rather than in the widget for the React package's reason: none of it
/// is layout. Sorting rows, cutting a page out of the result and finding the
/// run between two rows are questions with plain answers, and a widget file
/// that also has to draw a resize handle is not where they can be read or
/// tested. Every function takes plain values and returns plain values, and
/// nothing here knows what a column is. Matching a query against the rows is
/// `search.dart`'s.
///
/// The library talking to itself, except for the sort's two types, which
/// `NebaDataTable` exports as the React package exports `DataTableSort`.
library;

import 'package:flutter/foundation.dart';

import 'package:neba/src/internal/search.dart';
import 'package:neba/src/types.dart';

// ---------------------------------------------------------------------------
// Scales
// ---------------------------------------------------------------------------

/// A row's height, by density and size: the one size in the library that has
/// to be a number, because the scroll position is arithmetic on it.
///
/// The ladder stays at or below the control heights, a `md` row being a
/// button's 32 pixels and `compact` taking it to 28, because a DataTable is a
/// hundred rows on one screen. A caller who puts a chip or an avatar in a cell
/// raises `rowHeight`.
const Map<NebaDensity, Map<NebaSize, double>> dataRowHeights = <NebaDensity, Map<NebaSize, double>>{
  NebaDensity.standard: <NebaSize, double>{
    NebaSize.xs: 24,
    NebaSize.sm: 28,
    NebaSize.md: 32,
    NebaSize.lg: 38,
    NebaSize.xl: 44,
  },
  NebaDensity.compact: <NebaSize, double>{
    NebaSize.xs: 20,
    NebaSize.sm: 24,
    NebaSize.md: 28,
    NebaSize.lg: 32,
    NebaSize.xl: 38,
  },
};

/// The header, one step taller than the rows under it, and a fixed number so
/// a second header row has a place to sit.
const Map<NebaDensity, Map<NebaSize, double>> dataHeaderHeights =
    <NebaDensity, Map<NebaSize, double>>{
      NebaDensity.standard: <NebaSize, double>{
        NebaSize.xs: 28,
        NebaSize.sm: 32,
        NebaSize.md: 36,
        NebaSize.lg: 42,
        NebaSize.xl: 48,
      },
      NebaDensity.compact: <NebaSize, double>{
        NebaSize.xs: 24,
        NebaSize.sm: 28,
        NebaSize.md: 32,
        NebaSize.lg: 36,
        NebaSize.xl: 42,
      },
    };

/// The tick column: the checkbox and the two padding tracks, rounded to a
/// whole pixel, since a column narrower than the box in it clips its ring.
const Map<NebaSize, double> dataTickWidths = <NebaSize, double>{
  NebaSize.xs: 30,
  NebaSize.sm: 34,
  NebaSize.md: 38,
  NebaSize.lg: 42,
  NebaSize.xl: 50,
};

/// How wide a column is when neither the caller nor a drag has said and the
/// table is drawn at its narrowest.
const double dataDefaultColumnWidth = 160;

/// How narrow a drag may make a column. Below this the heading is a letter.
const double dataMinColumnWidth = 48;

// ---------------------------------------------------------------------------
// Sorting
// ---------------------------------------------------------------------------

/// Which way a column runs when it is sorted.
enum NebaDataTableSortDirection {
  /// Smallest first.
  asc,

  /// Largest first.
  desc,
}

/// One key of the sort and its direction. A sort is a list of these, the
/// first key outermost.
@immutable
class NebaDataTableSort {
  /// The column [key], sorted in [direction].
  const NebaDataTableSort({required this.key, this.direction = NebaDataTableSortDirection.asc});

  /// The column's key.
  final String key;

  /// Which way it runs.
  final NebaDataTableSortDirection direction;

  @override
  bool operator ==(Object other) {
    return other is NebaDataTableSort && other.key == key && other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(key, direction);

  @override
  String toString() => 'NebaDataTableSort($key, ${direction.name})';
}

/// Whether a cell holds nothing to sort by. `NaN` is empty by another name: it
/// compares false against everything, so a subtraction would make the order
/// depend on which rows happened to be next to each other.
bool dataIsEmptyValue(Object? value) {
  return value == null || value == '' || (value is num && value.isNaN);
}

/// The default comparison, for the columns that do not bring one.
///
/// Empty sorts last in both directions, which is the asymmetry every
/// spreadsheet has: a blank is the absence of a value, not the smallest one.
/// Numbers compare as numbers, dates as instants, booleans with `false` first,
/// and anything else as text through [dataCollate].
int dataCompareValues(Object? a, Object? b) {
  return dataCompareSortKeys(dataSortKey(a), dataSortKey(b));
}

/// A text value made ready to collate, so its fold is done once per row
/// rather than once per comparison.
@immutable
class DataCollated {
  /// [text] folded by [dataCollationKey].
  const DataCollated(this.text);

  /// The folded text.
  final String text;
}

/// [value] as [dataCompareSortKeys] reads it: `null` for a value with nothing
/// to sort by, a number, a boolean or a date as it is, and anything else as
/// its folded text.
Object? dataSortKey(Object? value) {
  if (dataIsEmptyValue(value)) {
    return null;
  }

  if (value is num || value is bool || value is DateTime) {
    return value;
  }

  return DataCollated(dataCollationKey(value));
}

/// Two values from [dataSortKey] in order, as [dataCompareValues] orders the
/// values they came from.
int dataCompareSortKeys(Object? a, Object? b) {
  if (a == null || b == null) {
    return a == null && b == null
        ? 0
        : a == null
        ? 1
        : -1;
  }

  if (a is num && b is num) {
    return a.compareTo(b);
  }

  if (a is bool && b is bool) {
    return (a ? 1 : 0) - (b ? 1 : 0);
  }

  if (a is DateTime && b is DateTime) {
    return a.compareTo(b);
  }

  return dataCollate(_collated(a), _collated(b));
}

String _collated(Object value) => value is DataCollated ? value.text : dataCollationKey(value);

/// The text [value] is collated by: its accents folded away and its case
/// lowered, which is what a collator at `sensitivity: 'base'` ignores.
String dataCollationKey(Object? value) => nebaFold('$value').toLowerCase();

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

/// Two collation keys in order, a run of digits compared as the number it
/// spells, so `item2` comes before `item10`: the React package's collator at
/// `numeric: true`.
///
/// The widgets layer has no `Intl.Collator`, so everything else is compared
/// by code unit, which keeps the alphabet of every script in its own order
/// but knows no language's rules: a Swedish `å` after `z` is a caller's
/// `compare`.
int dataCollate(String a, String b) {
  int i = 0;
  int j = 0;

  while (i < a.length && j < b.length) {
    final int x = a.codeUnitAt(i);
    final int y = b.codeUnitAt(j);

    if (_isDigit(x) && _isDigit(y)) {
      int iEnd = i;
      int jEnd = j;

      while (iEnd < a.length && _isDigit(a.codeUnitAt(iEnd))) {
        iEnd++;
      }

      while (jEnd < b.length && _isDigit(b.codeUnitAt(jEnd))) {
        jEnd++;
      }

      // Leading zeros spell nothing, so `007` and `7` are the same number.
      int iStart = i;
      int jStart = j;

      while (iStart < iEnd - 1 && a.codeUnitAt(iStart) == 0x30) {
        iStart++;
      }

      while (jStart < jEnd - 1 && b.codeUnitAt(jStart) == 0x30) {
        jStart++;
      }

      final int length = (iEnd - iStart) - (jEnd - jStart);

      if (length != 0) {
        return length;
      }

      final int digits = a.substring(iStart, iEnd).compareTo(b.substring(jStart, jEnd));

      if (digits != 0) {
        return digits;
      }

      i = iEnd;
      j = jEnd;
      continue;
    }

    if (x != y) {
      return x - y;
    }

    i++;
    j++;
  }

  return (a.length - i) - (b.length - j);
}

/// How one key orders two rows: a comparison written ascending, and which rows
/// hold nothing for it, or `null` when every row holds something. Rows that
/// hold nothing go last whichever way the key runs.
@immutable
class DataRowComparator<T> {
  /// A comparator from [compare] and [isEmpty].
  const DataRowComparator(this.compare, {this.isEmpty});

  /// Orders two rows, ascending.
  final int Function(T a, T b) compare;

  /// Whether a row holds nothing for the key.
  final bool Function(T row)? isEmpty;
}

/// [rows] sorted by every key of [sort] at once, the first key outermost.
///
/// The sort is stable, which is what makes a multi-key sort composable: rows
/// that tie on every key keep the order they arrived in. `comparatorFor`
/// returns `null` for a key no column claims, so a sort left over from a
/// column that has since gone is skipped rather than throwing. With nothing
/// to sort by, [rows] comes back as it is.
List<T> dataSortRows<T>(
  List<T> rows,
  List<NebaDataTableSort> sort,
  DataRowComparator<T>? Function(String key) comparatorFor,
) {
  if (sort.isEmpty) {
    return rows;
  }

  final List<({DataRowComparator<T> comparator, int sign})> steps =
      <({DataRowComparator<T> comparator, int sign})>[
        for (final NebaDataTableSort entry in sort)
          if (comparatorFor(entry.key) case final DataRowComparator<T> comparator)
            (
              comparator: comparator,
              sign: entry.direction == NebaDataTableSortDirection.desc ? -1 : 1,
            ),
      ];

  if (steps.isEmpty) {
    return rows;
  }

  // Dart's sort is not stable, so each row carries where it started and a
  // tie is settled by that.
  final List<int> order = List<int>.generate(rows.length, (int index) => index);

  order.sort((int left, int right) {
    final T a = rows[left];
    final T b = rows[right];

    for (final ({DataRowComparator<T> comparator, int sign}) step in steps) {
      final bool Function(T row)? isEmpty = step.comparator.isEmpty;

      if (isEmpty != null) {
        final bool aEmpty = isEmpty(a);
        final bool bEmpty = isEmpty(b);

        if (aEmpty != bEmpty) {
          return aEmpty ? 1 : -1;
        }

        if (aEmpty) {
          continue;
        }
      }

      final int result = step.comparator.compare(a, b);

      if (result != 0) {
        return result * step.sign;
      }
    }

    return left - right;
  });

  return <T>[for (final int index in order) rows[index]];
}

/// What pressing a heading does to [current]: ascending, then descending, then
/// unsorted, because the order the rows arrived in is a state the reader
/// could not get back to if the cycle had two steps.
///
/// [additive] is a Shift-press in a multiple sort. It keeps the key where it
/// already is in the list, so flipping the second key does not make it the
/// first.
List<NebaDataTableSort> dataNextSort(
  List<NebaDataTableSort> current,
  String key, {
  required bool additive,
}) {
  NebaDataTableSort? existing;

  for (final NebaDataTableSort entry in current) {
    if (entry.key == key) {
      existing = entry;
      break;
    }
  }

  final NebaDataTableSortDirection? direction = existing == null
      ? NebaDataTableSortDirection.asc
      : existing.direction == NebaDataTableSortDirection.asc
      ? NebaDataTableSortDirection.desc
      : null;

  if (!additive) {
    return direction == null
        ? <NebaDataTableSort>[]
        : <NebaDataTableSort>[NebaDataTableSort(key: key, direction: direction)];
  }

  if (direction == null) {
    return <NebaDataTableSort>[
      for (final NebaDataTableSort entry in current)
        if (entry.key != key) entry,
    ];
  }

  if (existing == null) {
    return <NebaDataTableSort>[...current, NebaDataTableSort(key: key, direction: direction)];
  }

  return <NebaDataTableSort>[
    for (final NebaDataTableSort entry in current)
      entry.key == key ? NebaDataTableSort(key: key, direction: direction) : entry,
  ];
}

// ---------------------------------------------------------------------------
// Paging
// ---------------------------------------------------------------------------

/// Where one page starts and stops, and how many there are.
@immutable
class DataPageBounds {
  /// The bounds of [page] of [pages], from [start] to one before [end].
  const DataPageBounds({
    required this.pages,
    required this.page,
    required this.start,
    required this.end,
  });

  /// How many pages the rows come to, never below one.
  final int pages;

  /// The page actually shown, clamped into range.
  final int page;

  /// Index of the first row on it.
  final int start;

  /// One past the last.
  final int end;
}

/// The page arithmetic, with the clamp in it: a filter that cuts a twenty-page
/// table to three leaves the caller's page at 14, and a table that answers
/// with an empty screen has told the reader their search found nothing.
DataPageBounds dataPageBounds(int total, int page, int pageSize) {
  final int size = pageSize < 1 ? 1 : pageSize;
  final int pages = total <= 0 ? 1 : (total + size - 1) ~/ size;
  final int current = page < 1
      ? 1
      : page > pages
      ? pages
      : page;
  final int start = (current - 1) * size;
  final int end = start + size < total ? start + size : total;

  return DataPageBounds(pages: pages, page: current, start: start, end: end < start ? start : end);
}

// ---------------------------------------------------------------------------
// Selection
// ---------------------------------------------------------------------------

/// Every key between [from] and [to], both included, in the order the rows
/// are in now, which is what a Shift-press means: the run the reader can see
/// between the two rows. Which of the two is the anchor does not matter. A
/// key that is not in [order], a row the search hides, gives an empty run.
///
/// [positions] is where each key sits in [order], for a caller that already
/// holds it: a drag asks once for every row it reaches.
List<K> dataKeysBetween<K>(List<K> order, K from, K to, {Map<K, int>? positions}) {
  final int a = positions != null ? (positions[from] ?? -1) : order.indexOf(from);
  final int b = positions != null ? (positions[to] ?? -1) : order.indexOf(to);

  if (a == -1 || b == -1) {
    return <K>[];
  }

  return order.sublist(a < b ? a : b, (a < b ? b : a) + 1);
}
