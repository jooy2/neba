import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Reading = ({int id, String sensor, double celsius, String taken});

final List<_Reading> _items = List<_Reading>.generate(100000, (int index) {
  return (
    id: index + 1,
    sensor: 'S-${'${index % 400 + 1}'.padLeft(4, '0')}',
    celsius: ((18 + (index * 13) % 170 / 10) * 10).round() / 10,
    taken: '2026-0${index % 9 + 1}-${'${index % 28 + 1}'.padLeft(2, '0')}',
  );
});

final List<_Reading> _few = _items.sublist(0, 2000);

final List<NebaDataTableColumn<_Reading>> _headers = <NebaDataTableColumn<_Reading>>[
  NebaDataTableColumn<_Reading>(
    key: 'id',
    label: const Text('#'),
    width: 90,
    align: NebaAlign.end,
    value: (_Reading row) => row.id,
  ),
  NebaDataTableColumn<_Reading>(
    key: 'sensor',
    label: const Text('Sensor'),
    width: 130,
    value: (_Reading row) => row.sensor,
  ),
  NebaDataTableColumn<_Reading>(
    key: 'celsius',
    label: const Text('°C'),
    width: 90,
    align: NebaAlign.end,
    value: (_Reading row) => row.celsius,
  ),
  NebaDataTableColumn<_Reading>(
    key: 'taken',
    label: const Text('Taken'),
    width: 140,
    value: (_Reading row) => row.taken,
  ),
];

Object _rowKey(_Reading row, int index) => row.id;

class DataTableVirtual extends StatefulWidget {
  const DataTableVirtual({super.key});

  @override
  State<DataTableVirtual> createState() => _DataTableVirtualState();
}

class _DataTableVirtualState extends State<DataTableVirtual> {
  bool _virtual = true;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.stretch,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaSegmentedButton<bool>(
            semanticLabel: 'Rows',
            size: NebaSize.sm,
            value: _virtual,
            onValueChange: (bool? next) => setState(() => _virtual = next ?? _virtual),
            children: const <NebaSegment<bool>>[
              NebaSegment<bool>(value: true, child: Text('virtual')),
              NebaSegment<bool>(value: false, child: Text('every row')),
            ],
          ),
        ),
        NebaDataTable<_Reading>(
          semanticLabel: 'Sensor readings',
          headers: _headers,
          items: _virtual ? _items : _few,
          rowKey: _rowKey,
          height: 260,
          virtual: _virtual,
          striped: NebaDataTableStripe.even,
        ),
        NebaTypography(
          _virtual
              ? '100,000 rows, about thirty of them built.'
              : '2,000 rows, all of them built, and that is already as far as this goes.',
          level: NebaTypographyLevel.caption,
        ),
      ],
    );
  }
}
