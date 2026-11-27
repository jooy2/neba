import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Ticket = ({String id, String title, String priority, int points});

const List<String> _rank = <String>['low', 'normal', 'high', 'urgent'];

const List<_Ticket> _items = <_Ticket>[
  (id: 'NB-12', title: 'Sticky header loses its blur', priority: 'high', points: 3),
  (id: 'NB-31', title: 'Chip count wraps at 100', priority: 'low', points: 3),
  (id: 'NB-04', title: 'Focus ring clipped in a cell', priority: 'urgent', points: 8),
  (id: 'NB-27', title: 'Locale ignored by the footer', priority: 'normal', points: 1),
  (id: 'NB-19', title: 'Drag selection skips a row', priority: 'urgent', points: 5),
  (id: 'NB-08', title: 'Column widths reset on filter', priority: 'high', points: 8),
];

final List<NebaDataTableColumn<_Ticket>> _headers = <NebaDataTableColumn<_Ticket>>[
  NebaDataTableColumn<_Ticket>(
    key: 'id',
    label: const Text('Key'),
    width: 90,
    value: (_Ticket row) => row.id,
  ),
  NebaDataTableColumn<_Ticket>(
    key: 'title',
    label: const Text('Summary'),
    sortable: false,
    value: (_Ticket row) => row.title,
  ),
  NebaDataTableColumn<_Ticket>(
    key: 'priority',
    label: const Text('Priority'),
    width: 120,
    value: (_Ticket row) => row.priority,
    // Alphabetically `urgent` is last; by rank it is first.
    compare: (_Ticket a, _Ticket b) => _rank.indexOf(a.priority) - _rank.indexOf(b.priority),
  ),
  NebaDataTableColumn<_Ticket>(
    key: 'points',
    label: const Text('Points'),
    width: 100,
    align: NebaAlign.end,
    value: (_Ticket row) => row.points,
  ),
];

Object _rowKey(_Ticket row, int index) => row.id;

class DataTableSorting extends StatefulWidget {
  const DataTableSorting({super.key});

  @override
  State<DataTableSorting> createState() => _DataTableSortingState();
}

class _DataTableSortingState extends State<DataTableSorting> {
  List<NebaDataTableSort> _sort = const <NebaDataTableSort>[
    NebaDataTableSort(key: 'priority', direction: NebaDataTableSortDirection.desc),
  ];

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaDataTable<_Ticket>(
          semanticLabel: 'Tickets',
          headers: _headers,
          items: _items,
          rowKey: _rowKey,
          sortable: true,
          sortMode: NebaDataTableSortMode.multiple,
          sort: _sort,
          onSortChange: (List<NebaDataTableSort> sort) => setState(() => _sort = sort),
        ),
        NebaTypography(
          _sort.isEmpty
              ? 'Unsorted. Click a heading; Shift-click a second one to add it.'
              : _sort
                    .map((NebaDataTableSort entry) => '${entry.key} ${entry.direction.name}')
                    .join(', then '),
          level: NebaTypographyLevel.caption,
        ),
      ],
    );
  }
}
