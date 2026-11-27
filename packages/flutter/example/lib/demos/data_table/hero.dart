import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Build = ({int id, String branch, String status, int duration, String queued});

const List<String> _branches = <String>[
  'main',
  'release/2.4',
  'feat/acrylic',
  'fix/sticky-header',
  'chore/deps',
];
const List<String> _statuses = <String>['passed', 'running', 'failed'];

final List<_Build> _items = List<_Build>.generate(20000, (int index) {
  return (
    id: 91000 - index,
    branch: _branches[index % _branches.length],
    status: _statuses[index % 3],
    duration: 40 + (index * 37) % 900,
    queued: '${'${index % 24 + 1}'.padLeft(2, '0')}:${'${(index * 7) % 60}'.padLeft(2, '0')}',
  );
});

final List<NebaDataTableColumn<_Build>> _headers = <NebaDataTableColumn<_Build>>[
  NebaDataTableColumn<_Build>(
    key: 'id',
    label: const Text('Build'),
    width: 90,
    align: NebaAlign.end,
    value: (_Build row) => row.id,
  ),
  NebaDataTableColumn<_Build>(
    key: 'branch',
    label: const Text('Branch'),
    width: 180,
    value: (_Build row) => row.branch,
  ),
  NebaDataTableColumn<_Build>(
    key: 'status',
    label: const Text('Status'),
    width: 120,
    value: (_Build row) => row.status,
    builder: (BuildContext context, _Build row, int index) => NebaChip(
      size: NebaSize.xs,
      variant: NebaVariant.text,
      color: switch (row.status) {
        'passed' => NebaColor.success,
        'failed' => NebaColor.danger,
        _ => NebaColor.info,
      },
      child: Text(row.status),
    ),
  ),
  NebaDataTableColumn<_Build>(
    key: 'duration',
    label: const Text('Duration'),
    width: 110,
    align: NebaAlign.end,
    value: (_Build row) => row.duration,
    builder: (BuildContext context, _Build row, int index) =>
        Text('${row.duration ~/ 60}m ${row.duration % 60}s'),
  ),
  NebaDataTableColumn<_Build>(
    key: 'queued',
    label: const Text('Queued'),
    width: 100,
    align: NebaAlign.end,
    value: (_Build row) => row.queued,
  ),
];

Object _rowKey(_Build row, int index) => row.id;

class DataTableHero extends StatefulWidget {
  const DataTableHero({super.key});

  @override
  State<DataTableHero> createState() => _DataTableHeroState();
}

class _DataTableHeroState extends State<DataTableHero> {
  List<Object> _selected = <Object>[];

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        NebaDataTable<_Build>(
          semanticLabel: 'Builds',
          headers: _headers,
          items: _items,
          rowKey: _rowKey,
          height: 280,
          selectionMode: NebaDataTableSelectionMode.multiple,
          selected: _selected,
          onSelectedChange: (List<Object> selected, List<_Build> rows) =>
              setState(() => _selected = selected),
          sortable: true,
          resizable: true,
          striped: NebaDataTableStripe.even,
        ),
        const NebaTypography(
          '20,000 rows. Click a row, drag through a run of them, or hold Shift and press the '
          'arrow keys.',
          level: NebaTypographyLevel.caption,
        ),
      ],
    );
  }
}
