import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HoverCardDelay extends StatelessWidget {
  const HoverCardDelay({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaHoverCard(
          delay: Duration.zero,
          trigger: NebaTextLink(
            onPressed: () {},
            href: Uri.parse('#now'),
            child: const Text('Opens at once'),
          ),
          title: const Text('delay 0'),
          child: const Text('The card is up on the first frame the pointer is over the link.'),
        ),
        NebaHoverCard(
          delay: const Duration(milliseconds: 700),
          closeDelay: const Duration(milliseconds: 400),
          trigger: NebaTextLink(
            onPressed: () {},
            href: Uri.parse('#later'),
            child: const Text('Waits 700ms'),
          ),
          title: const Text('delay 700'),
          child: const Text('Long enough that crossing a paragraph of links opens none of them.'),
        ),
      ],
    );
  }
}
