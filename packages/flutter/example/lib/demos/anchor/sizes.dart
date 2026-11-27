import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<GlobalKey> _headings = <GlobalKey>[for (int i = 0; i < 3; i++) GlobalKey()];

final List<NebaAnchorItem> _items = <NebaAnchorItem>[
  NebaAnchorItem(target: _headings[0], label: const Text('Overview')),
  NebaAnchorItem(target: _headings[1], label: const Text('Installation')),
  NebaAnchorItem(target: _headings[2], label: const Text('Deployment')),
];

class AnchorSizes extends StatelessWidget {
  const AnchorSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 16,
      children: <Widget>[
        for (final NebaSize size in <NebaSize>[NebaSize.xs, NebaSize.sm, NebaSize.md, NebaSize.lg])
          NebaAnchor(
            size: size,
            items: _items,
            activeTarget: _headings[1],
            semanticLabel: size.name,
          ),
      ],
    );
  }
}
