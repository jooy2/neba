import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Invoice = ({String number, String total});

final List<NebaTableColumn<_Invoice>> _headers = <NebaTableColumn<_Invoice>>[
  NebaTableColumn<_Invoice>(
    key: 'number',
    label: const Text('Invoice'),
    builder: (BuildContext context, _Invoice row, int index) => Text(row.number),
  ),
  NebaTableColumn<_Invoice>(
    key: 'total',
    label: const Text('Total'),
    align: NebaAlign.end,
    builder: (BuildContext context, _Invoice row, int index) => Text(row.total),
  ),
];

class TableEmpty extends StatelessWidget {
  const TableEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaTable<_Invoice>(
      headers: _headers,
      items: const <_Invoice>[],
      caption: const Text('Invoices'),
      empty: const Text('No invoices yet. The first one arrives after your trial.'),
    );
  }
}
