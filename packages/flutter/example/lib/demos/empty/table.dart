import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Deploy = ({String id, String environment, String status});

final List<NebaTableColumn<_Deploy>> _headers = <NebaTableColumn<_Deploy>>[
  NebaTableColumn<_Deploy>(
    key: 'environment',
    label: const Text('Environment'),
    width: 200,
    builder: (BuildContext context, _Deploy row, int index) => Text(row.environment),
  ),
  NebaTableColumn<_Deploy>(
    key: 'status',
    label: const Text('Status'),
    builder: (BuildContext context, _Deploy row, int index) => Text(row.status),
  ),
];

class EmptyTable extends StatelessWidget {
  const EmptyTable({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaTable<_Deploy>(
      headers: _headers,
      items: const <_Deploy>[],
      rowKey: (_Deploy row, int index) => ValueKey<String>(row.id),
      empty: NebaEmpty(
        density: NebaDensity.compact,
        title: const Text('No deploys yet'),
        actions: <Widget>[
          NebaButton(
            size: NebaSize.sm,
            onPressed: () {},
            child: const Text('Deploy the main branch'),
          ),
        ],
        child: const Text('Every deploy and its outcome will be listed here.'),
      ),
    );
  }
}
