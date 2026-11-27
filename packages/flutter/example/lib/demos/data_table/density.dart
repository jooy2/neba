import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Job = ({int id, String queue, int attempts, String state});

const List<String> _states = <String>['queued', 'running', 'done', 'retrying'];

final List<_Job> _items = List<_Job>.generate(8, (int index) {
  return (
    id: 700 + index,
    queue: index.isEven ? 'default' : 'mailers',
    attempts: index % 3 + 1,
    state: _states[index % _states.length],
  );
});

final List<NebaDataTableColumn<_Job>> _headers = <NebaDataTableColumn<_Job>>[
  NebaDataTableColumn<_Job>(
    key: 'id',
    label: const Text('Job'),
    width: 90,
    align: NebaAlign.end,
    value: (_Job row) => row.id,
  ),
  NebaDataTableColumn<_Job>(
    key: 'queue',
    label: const Text('Queue'),
    width: 140,
    value: (_Job row) => row.queue,
  ),
  NebaDataTableColumn<_Job>(
    key: 'attempts',
    label: const Text('Tries'),
    width: 90,
    align: NebaAlign.end,
    value: (_Job row) => row.attempts,
  ),
  NebaDataTableColumn<_Job>(
    key: 'state',
    label: const Text('State'),
    value: (_Job row) => row.state,
  ),
];

Object _rowKey(_Job row, int index) => row.id;

class DataTableDensity extends StatefulWidget {
  const DataTableDensity({super.key});

  @override
  State<DataTableDensity> createState() => _DataTableDensityState();
}

class _DataTableDensityState extends State<DataTableDensity> {
  NebaSize _size = NebaSize.sm;
  bool _compact = true;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 2,
          children: <Widget>[
            NebaSegmentedButton<NebaSize>(
              semanticLabel: 'Size',
              size: NebaSize.xs,
              value: _size,
              onValueChange: (NebaSize? next) => setState(() => _size = next ?? _size),
              children: <NebaSegment<NebaSize>>[
                for (final NebaSize size in <NebaSize>[
                  NebaSize.xs,
                  NebaSize.sm,
                  NebaSize.md,
                  NebaSize.lg,
                ])
                  NebaSegment<NebaSize>(value: size, child: Text(size.name)),
              ],
            ),
            NebaSegmentedButton<bool>(
              semanticLabel: 'Density',
              size: NebaSize.xs,
              value: _compact,
              onValueChange: (bool? next) => setState(() => _compact = next ?? _compact),
              children: const <NebaSegment<bool>>[
                NebaSegment<bool>(value: true, child: Text('compact')),
                NebaSegment<bool>(value: false, child: Text('default')),
              ],
            ),
          ],
        ),
        NebaDataTable<_Job>(
          semanticLabel: 'Jobs',
          headers: _headers,
          items: _items,
          rowKey: _rowKey,
          size: _size,
          density: _compact ? NebaDensity.compact : NebaDensity.standard,
          striped: NebaDataTableStripe.even,
        ),
      ],
    );
  }
}
