import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HoverCardSizes extends StatelessWidget {
  const HoverCardSizes({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaHoverCard(
            size: size,
            trigger: NebaButton(
              onPressed: press,
              size: size,
              variant: NebaVariant.outline,
              child: Text(size.name),
            ),
            title: const Text('Frankfurt'),
            description: const Text('eu-central-1'),
            child: const Text('Four instances, all healthy.'),
          ),
      ],
    );
  }
}
