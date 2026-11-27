import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BlockquoteHero extends StatelessWidget {
  const BlockquoteHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          NebaBlockquote(
            author: Text('Antoine de Saint-Exupéry'),
            source: Text('Terre des Hommes'),
            child: Text(
              'Perfection is achieved, not when there is nothing more to add, but when there is '
              'nothing left to take away.',
            ),
          ),
          NebaBlockquote(
            variant: NebaVariant.outline,
            color: NebaColor.info,
            icon: null,
            child: Text(
              'A design system is not a component library. It is an agreement about what the '
              'components mean.',
            ),
          ),
        ],
      ),
    );
  }
}
