import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateFadeHero extends StatefulWidget {
  const AnimateFadeHero({super.key});

  @override
  State<AnimateFadeHero> createState() => _AnimateFadeHeroState();
}

class _AnimateFadeHeroState extends State<AnimateFadeHero> {
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
        NebaAnimateFade(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 700),
          child: const NebaCard(
            size: NebaSize.sm,
            title: Text('Deployment finished'),
            child: Text('Two services restarted, no errors.'),
          ),
        ),
      ],
    );
  }
}
