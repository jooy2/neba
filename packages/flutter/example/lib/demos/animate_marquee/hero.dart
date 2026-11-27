import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _customers = <String>[
  'Northwind',
  'Contoso',
  'Umbrella',
  'Initech',
  'Hooli',
  'Globex',
];

class AnimateMarqueeHero extends StatelessWidget {
  const AnimateMarqueeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaAnimateMarquee(
        speed: 45,
        gap: 24,
        children: <Widget>[
          for (final String name in _customers)
            NebaChip(key: ValueKey<String>(name), variant: NebaVariant.outline, child: Text(name)),
        ],
      ),
    );
  }
}
