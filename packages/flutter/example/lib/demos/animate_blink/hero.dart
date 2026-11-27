import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateBlinkHero extends StatelessWidget {
  const AnimateBlinkHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaAnimateBlink(
      min: 0.35,
      duration: Duration(milliseconds: 1100),
      child: NebaChip(
        color: NebaColor.danger,
        variant: NebaVariant.solid,
        child: Text('Recording'),
      ),
    );
  }
}
