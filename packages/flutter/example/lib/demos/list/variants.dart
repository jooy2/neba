import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ListVariants extends StatelessWidget {
  const ListVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      // `text` is the one to reach for inside a Card: the card is already a
      // sheet, and a second bordered rectangle inside it is a rectangle too
      // many.
      child: NebaCard(
        title: const Text('Notifications'),
        subtitle: const Text('Where the alerts go'),
        child: NebaList(
          variant: NebaVariant.text,
          density: NebaDensity.compact,
          children: <Widget>[
            NebaListItem(
              onPressed: () {},
              href: Uri.parse('#email'),
              description: const Text('jane@example.com'),
              child: const Text('Email'),
            ),
            NebaListItem(
              onPressed: () {},
              href: Uri.parse('#slack'),
              description: const Text('#deploys'),
              child: const Text('Slack'),
            ),
            NebaListItem(
              onPressed: () {},
              href: Uri.parse('#webhook'),
              description: const Text('Not configured'),
              child: const Text('Webhook'),
            ),
          ],
        ),
      ),
    );
  }
}
