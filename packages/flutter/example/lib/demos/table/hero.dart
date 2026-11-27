import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Deploy = ({String id, String environment, String status, int duration});

final List<NebaTableColumn<_Deploy>> _headers = <NebaTableColumn<_Deploy>>[
  NebaTableColumn<_Deploy>(
    key: 'environment',
    label: const Text('Environment'),
    width: 180,
    builder: (BuildContext context, _Deploy row, int index) => Text(row.environment),
  ),
  NebaTableColumn<_Deploy>(
    key: 'status',
    label: const Text('Status'),
    width: 140,
    builder: (BuildContext context, _Deploy row, int index) => NebaChip(
      size: NebaSize.xs,
      variant: NebaVariant.text,
      color: switch (row.status) {
        'Live' => NebaColor.success,
        'Failed' => NebaColor.danger,
        _ => NebaColor.info,
      },
      child: Text(row.status),
    ),
  ),
  NebaTableColumn<_Deploy>(
    key: 'duration',
    label: const Text('Duration'),
    align: NebaAlign.end,
    builder: (BuildContext context, _Deploy row, int index) => Text('${row.duration}m'),
  ),
];

const List<_Deploy> _items = <_Deploy>[
  (id: '1', environment: 'production', status: 'Live', duration: 4),
  (id: '2', environment: 'staging', status: 'Building', duration: 2),
  (id: '3', environment: 'preview/1284', status: 'Failed', duration: 1),
];

class TableHero extends StatelessWidget {
  const TableHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaTable<_Deploy>(
      headers: _headers,
      items: _items,
      rowKey: (_Deploy row, int index) => ValueKey<String>(row.id),
      hoverable: true,
    );
  }
}
