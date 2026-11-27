import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateSlideHero extends StatefulWidget {
  const AnimateSlideHero({super.key});

  @override
  State<AnimateSlideHero> createState() => _AnimateSlideHeroState();
}

class _AnimateSlideHeroState extends State<AnimateSlideHero> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
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
          ClipRect(
            child: NebaAnimateSlide(
              key: ValueKey<int>(_run),
              from: NebaSide.left,
              duration: const Duration(milliseconds: 600),
              child: const NebaAlert(
                color: NebaColor.success,
                title: Text('Invitation sent'),
                child: Text('They will get an email in the next minute.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
