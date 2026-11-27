import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateFloatHero extends StatelessWidget {
  const AnimateFloatHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaAnimateFloat(
      child: SizedBox(
        width: 208,
        child: NebaCard(
          size: NebaSize.sm,
          elevation: 2,
          child: NebaTypography('Not fixed to the page.'),
        ),
      ),
    );
  }
}
