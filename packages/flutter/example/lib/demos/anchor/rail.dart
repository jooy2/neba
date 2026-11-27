import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<GlobalKey> _headings = <GlobalKey>[for (int i = 0; i < 4; i++) GlobalKey()];

final List<NebaAnchorItem> _items = <NebaAnchorItem>[
  NebaAnchorItem(target: _headings[0], label: const Text('Overview')),
  NebaAnchorItem(target: _headings[1], label: const Text('Installation')),
  NebaAnchorItem(target: _headings[2], label: const Text('Configuration'), depth: 1),
  NebaAnchorItem(target: _headings[3], label: const Text('Deployment')),
];

class AnchorRail extends StatelessWidget {
  const AnchorRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 16,
      children: <Widget>[
        NebaAnchor(
          size: NebaSize.sm,
          items: _items,
          activeTarget: _headings[1],
          semanticLabel: 'With rail',
        ),
        NebaAnchor(
          size: NebaSize.sm,
          rail: false,
          items: _items,
          activeTarget: _headings[1],
          semanticLabel: 'Without rail',
        ),
      ],
    );
  }
}
