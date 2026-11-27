import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaSourceItem> _items = <NebaSourceItem>[
  NebaSourceItem(
    title: const Text('The design language'),
    site: const Text('neba.cdget.com'),
    href: Uri.parse('https://neba.cdget.com/design/design-language'),
    onPressed: () {},
  ),
  NebaSourceItem(
    title: const Text('Breakpoints'),
    site: const Text('neba.cdget.com'),
    href: Uri.parse('https://neba.cdget.com/design/breakpoints'),
    onPressed: () {},
  ),
];

class SourcesVariant extends StatelessWidget {
  const SourcesVariant({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final NebaVariant variant in <NebaVariant>[
            NebaVariant.text,
            NebaVariant.outline,
            NebaVariant.solid,
          ])
            NebaSources(
              variant: variant,
              title: Text(variant.name),
              items: _items,
              defaultOpen: true,
            ),
        ],
      ),
    );
  }
}
