import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaSourceItem> _items = <NebaSourceItem>[
  NebaSourceItem(
    title: const Text('The design language'),
    site: const Text('neba.cdget.com'),
    href: Uri.parse('https://neba.cdget.com/design/design-language'),
    onPressed: () {},
    description: const Text('A Neba surface is a sheet of cut acrylic, not a moulded plastic key.'),
  ),
  NebaSourceItem(
    title: const Text('Breakpoints'),
    site: const Text('neba.cdget.com'),
    href: Uri.parse('https://neba.cdget.com/design/breakpoints'),
    onPressed: () {},
    description: const Text('Every entry in a per-breakpoint map is a floor.'),
  ),
  NebaSourceItem(
    title: const Text('Prop conventions'),
    site: const Text('neba.cdget.com'),
    href: Uri.parse('https://neba.cdget.com/design/prop-conventions'),
    onPressed: () {},
  ),
];

class SourcesHero extends StatelessWidget {
  const SourcesHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaSources(items: _items, defaultOpen: true),
    );
  }
}
