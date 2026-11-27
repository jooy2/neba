import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Region = ({String code, String city, int latency, double uptime, int nodes});

final List<NebaDataTableColumn<_Region>> _headers = <NebaDataTableColumn<_Region>>[
  NebaDataTableColumn<_Region>(
    key: 'code',
    label: const Text('Code'),
    width: 90,
    value: (_Region row) => row.code,
  ),
  NebaDataTableColumn<_Region>(
    key: 'city',
    label: const Text('City'),
    width: 160,
    value: (_Region row) => row.city,
  ),
  NebaDataTableColumn<_Region>(
    key: 'latency',
    label: const Text('p95'),
    group: 'Last 24 hours',
    width: 100,
    align: NebaAlign.end,
    value: (_Region row) => row.latency,
    builder: (BuildContext context, _Region row, int index) => Text('${row.latency} ms'),
  ),
  NebaDataTableColumn<_Region>(
    key: 'uptime',
    label: const Text('Uptime'),
    group: 'Last 24 hours',
    width: 110,
    align: NebaAlign.end,
    value: (_Region row) => row.uptime,
    builder: (BuildContext context, _Region row, int index) =>
        Text('${row.uptime.toStringAsFixed(2)}%'),
  ),
  NebaDataTableColumn<_Region>(
    key: 'nodes',
    label: const Text('Nodes'),
    group: 'Capacity',
    width: 100,
    align: NebaAlign.end,
    value: (_Region row) => row.nodes,
  ),
];

const List<_Region> _items = <_Region>[
  (code: 'icn1', city: 'Seoul', latency: 38, uptime: 99.99, nodes: 24),
  (code: 'fra1', city: 'Frankfurt', latency: 61, uptime: 99.94, nodes: 40),
  (code: 'iad1', city: 'Washington', latency: 44, uptime: 100, nodes: 36),
  (code: 'gru1', city: 'São Paulo', latency: 112, uptime: 99.81, nodes: 12),
];

Object _rowKey(_Region row, int index) => row.code;

class DataTableColumns extends StatelessWidget {
  const DataTableColumns({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDataTable<_Region>(
      semanticLabel: 'Regions',
      headers: _headers,
      items: _items,
      rowKey: _rowKey,
      resizable: true,
    );
  }
}
