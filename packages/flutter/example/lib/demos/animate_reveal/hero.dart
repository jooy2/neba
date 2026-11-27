import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateRevealHero extends StatelessWidget {
  const AnimateRevealHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaAnimateReveal(
      duration: Duration(milliseconds: 900),
      child: NebaTypography('Nothing moved. It was let through.', level: NebaTypographyLevel.h4),
    );
  }
}
