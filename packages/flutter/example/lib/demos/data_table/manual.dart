import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Event = ({int id, String actor, String action, String at});

const List<String> _actions = <String>['deployed', 'reverted', 'invited', 'archived', 'renamed'];
const int _total = 842;

/// Stands in for the request a real table would make, answering after a
/// moment as a server would.
Timer _fetchPage(
  int page,
  int pageSize,
  List<NebaDataTableSort> sort,
  ValueChanged<List<_Event>> done,
) {
  final bool descending =
      sort.isNotEmpty && sort.first.direction == NebaDataTableSortDirection.desc;

  return Timer(const Duration(milliseconds: 120), () {
    done(
      List<_Event>.generate(pageSize, (int offset) {
        final int index = (page - 1) * pageSize + offset;
        final int id = descending ? _total - index : index + 1;

        return (
          id: id,
          actor: 'svc-${'${id % 12 + 1}'.padLeft(2, '0')}',
          action: _actions[id % _actions.length],
          at: '2026-08-${'${id % 28 + 1}'.padLeft(2, '0')}',
        );
      }),
    );
  });
}

final List<NebaDataTableColumn<_Event>> _headers = <NebaDataTableColumn<_Event>>[
  NebaDataTableColumn<_Event>(
    key: 'id',
    label: const Text('Event'),
    width: 100,
    align: NebaAlign.end,
    value: (_Event row) => row.id,
  ),
  NebaDataTableColumn<_Event>(
    key: 'actor',
    label: const Text('Actor'),
    width: 130,
    value: (_Event row) => row.actor,
  ),
  NebaDataTableColumn<_Event>(
    key: 'action',
    label: const Text('Action'),
    sortable: false,
    value: (_Event row) => row.action,
  ),
  NebaDataTableColumn<_Event>(
    key: 'at',
    label: const Text('Date'),
    width: 130,
    sortable: false,
    value: (_Event row) => row.at,
  ),
];

const Set<NebaDataTableStage> _manual = <NebaDataTableStage>{
  NebaDataTableStage.sort,
  NebaDataTableStage.filter,
  NebaDataTableStage.pages,
};

Object _rowKey(_Event row, int index) => row.id;

class DataTableManual extends StatefulWidget {
  const DataTableManual({super.key});

  @override
  State<DataTableManual> createState() => _DataTableManualState();
}

class _DataTableManualState extends State<DataTableManual> {
  int _page = 1;
  int _pageSize = 10;
  List<NebaDataTableSort> _sort = const <NebaDataTableSort>[
    NebaDataTableSort(key: 'id', direction: NebaDataTableSortDirection.desc),
  ];
  List<_Event> _rows = const <_Event>[];
  Timer? _request;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  void _load() {
    _request?.cancel();
    _request = _fetchPage(_page, _pageSize, _sort, (List<_Event> rows) {
      if (mounted) {
        setState(() => _rows = rows);
      }
    });
  }

  void _change(VoidCallback change) {
    setState(change);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return NebaDataTable<_Event>(
      semanticLabel: 'Audit log',
      headers: _headers,
      items: _rows,
      rowKey: _rowKey,
      manual: _manual,
      rowCount: _total,
      paging: NebaDataTablePaging.pages,
      page: _page,
      onPageChange: (int page) => _change(() => _page = page),
      pageSize: _pageSize,
      onPageSizeChange: (int size) => _change(() => _pageSize = size),
      sortable: true,
      sort: _sort,
      onSortChange: (List<NebaDataTableSort> sort) => _change(() => _sort = sort),
      striped: NebaDataTableStripe.even,
    );
  }
}
