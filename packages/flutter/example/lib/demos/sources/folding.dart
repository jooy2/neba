import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaSourceItem> _items = <NebaSourceItem>[
  for (final (String title, String path) in <(String, String)>[
    ('The design language', 'design/design-language'),
    ('Breakpoints', 'design/breakpoints'),
    ('Prop conventions', 'design/prop-conventions'),
    ('Browser support', 'browser-support'),
  ])
    NebaSourceItem(
      title: Text(title),
      href: Uri.parse('https://neba.cdget.com/$path'),
      onPressed: () {},
    ),
];

class SourcesFolding extends StatelessWidget {
  const SourcesFolding({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaSources(items: _items),
          NebaSources(
            items: _items,
            collapsible: false,
            title: const Text('Always open'),
            variant: NebaVariant.outline,
          ),
        ],
      ),
    );
  }
}
