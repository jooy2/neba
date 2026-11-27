import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateLightingHover extends StatelessWidget {
  const AnimateLightingHover({super.key});

  @override
  Widget build(BuildContext context) {
    // An endless effect on hover stops when the pointer leaves; the keyboard
    // focus counts as the pointer, so it is reachable without a mouse.
    return NebaAnimateLighting(
      trigger: NebaAnimateTrigger.hover,
      size: NebaSize.md,
      glow: const Color(0xffd946ef),
      arc: 70,
      duration: const Duration(milliseconds: 1600),
      child: NebaButton(onPressed: () {}, size: NebaSize.lg, child: const Text('Upgrade the plan')),
    );
  }
}
