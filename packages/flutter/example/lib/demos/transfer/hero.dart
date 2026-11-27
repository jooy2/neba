import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaTransferItem<String>> _columns = <NebaTransferItem<String>>[
  NebaTransferItem<String>(value: 'status', label: Text('Status')),
  NebaTransferItem<String>(value: 'duration', label: Text('Duration')),
  NebaTransferItem<String>(value: 'commit', label: Text('Commit')),
  NebaTransferItem<String>(value: 'author', label: Text('Author')),
  NebaTransferItem<String>(value: 'branch', label: Text('Branch')),
  NebaTransferItem<String>(value: 'region', label: Text('Region')),
  NebaTransferItem<String>(value: 'runtime', label: Text('Runtime')),
  NebaTransferItem<String>(value: 'id', label: Text('Deployment id'), disabled: true),
];

class TransferHero extends StatefulWidget {
  const TransferHero({super.key});

  @override
  State<TransferHero> createState() => _TransferHeroState();
}

class _TransferHeroState extends State<TransferHero> {
  List<String> _shown = <String>['status', 'duration', 'commit'];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaTransfer<String>(
        items: _columns,
        value: _shown,
        onValueChange: (List<String> next) => setState(() => _shown = next),
        sourceLabel: const Text('Hidden columns'),
        targetLabel: const Text('Shown columns'),
      ),
    );
  }
}
