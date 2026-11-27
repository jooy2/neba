import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateGrowHero extends StatefulWidget {
  const AnimateGrowHero({super.key});

  @override
  State<AnimateGrowHero> createState() => _AnimateGrowHeroState();
}

class _AnimateGrowHeroState extends State<AnimateGrowHero> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _run += 1),
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Play again'),
        ),
        NebaAnimateGrow(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 600),
          child: const NebaCard(
            size: NebaSize.sm,
            title: Text('Filters'),
            child: Text('Three of nine applied.'),
          ),
        ),
      ],
    );
  }
}
