import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateZoomHero extends StatefulWidget {
  const AnimateZoomHero({super.key});

  @override
  State<AnimateZoomHero> createState() => _AnimateZoomHeroState();
}

class _AnimateZoomHeroState extends State<AnimateZoomHero> {
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
        NebaAnimateZoom(
          key: ValueKey<int>(_run),
          duration: const Duration(milliseconds: 600),
          child: const NebaStatistic(
            label: Text('Uptime this quarter'),
            value: 99.98,
            previousValue: 99.94,
            unit: Text('%'),
          ),
        ),
      ],
    );
  }
}
