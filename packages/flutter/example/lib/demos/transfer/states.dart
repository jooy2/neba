import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaTransferItem<String>> _items = <NebaTransferItem<String>>[
  NebaTransferItem<String>(value: 'read', label: Text('Read')),
  NebaTransferItem<String>(value: 'write', label: Text('Write')),
  NebaTransferItem<String>(value: 'deploy', label: Text('Deploy')),
  NebaTransferItem<String>(value: 'billing', label: Text('Billing'), disabled: true),
];

class TransferStates extends StatelessWidget {
  const TransferStates({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          NebaTransfer<String>(
            size: NebaSize.sm,
            height: 120,
            items: _items,
            defaultValue: <String>['read'],
          ),
          NebaTransfer<String>(
            size: NebaSize.sm,
            height: 120,
            items: _items,
            defaultValue: <String>['read'],
            disabled: true,
          ),
        ],
      ),
    );
  }
}
