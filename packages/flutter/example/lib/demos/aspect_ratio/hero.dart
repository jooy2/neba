import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AspectRatioHero extends StatelessWidget {
  const AspectRatioHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaAspectRatio(
        ratio: 16 / 9,
        rounded: true,
        child: Image.asset(
          'assets/samples/photos/alpine-lake-dawn.jpg',
          semanticLabel: 'A still alpine lake with the first light on the far ridge',
        ),
      ),
    );
  }
}
