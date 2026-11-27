import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateLightingHero extends StatelessWidget {
  const AnimateLightingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const NebaAnimateLighting(
        size: NebaSize.md,
        child: NebaCard(
          size: NebaSize.md,
          title: Text('Analysing 4,281 rows'),
          child: Text('This usually takes about a minute.'),
        ),
      ),
    );
  }
}
