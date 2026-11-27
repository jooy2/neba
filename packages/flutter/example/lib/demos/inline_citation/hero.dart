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
    description: const Text('Every entry in a per-breakpoint map is a floor, not a range.'),
  ),
];

/// The citation for [item], numbered [index], set into the line.
WidgetSpan _cite(int index, NebaSourceItem item) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Padding(
      padding: const EdgeInsetsDirectional.only(start: 2),
      child: NebaInlineCitation(
        index: index,
        title: item.title,
        site: item.site,
        href: item.href,
        onPressed: item.onPressed,
        description: item.description,
      ),
    ),
  );
}

class InlineCitationHero extends StatelessWidget {
  const InlineCitationHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 15, height: 1.6),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(
                    text:
                        'A control never moves under the pointer, because scaling it would '
                        'resample its label',
                  ),
                  _cite(1, _items[0]),
                  const TextSpan(
                    text:
                        ' — and a value that changes at a breakpoint applies from that width up '
                        'rather than only at it',
                  ),
                  _cite(2, _items[1]),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          NebaSources(items: _items),
        ],
      ),
    );
  }
}
