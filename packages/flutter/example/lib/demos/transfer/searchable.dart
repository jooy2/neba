import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaTransferItem<String>> _people = <NebaTransferItem<String>>[
  for (final String name in <String>[
    'Kim Minji',
    'Alex Park',
    'Sam Lee',
    'Noa Cohen',
    'Ravi Patel',
    'Jane Doe',
    'Hana Sato',
    'Luis Ortiz',
    'Mia Fischer',
  ])
    NebaTransferItem<String>(
      value: name.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      label: Text(name),
    ),
];

class TransferSearchable extends StatelessWidget {
  const TransferSearchable({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaTransfer<String>(
        searchable: true,
        size: NebaSize.sm,
        items: _people,
        defaultValue: const <String>['sam-lee'],
        sourceLabel: const Text('Everyone'),
        targetLabel: const Text('On this channel'),
      ),
    );
  }
}
