import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SpoilerHero extends StatelessWidget {
  const SpoilerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaSpoiler(
        child: NebaTypography(
          'Rosebud was the name of the sled. It is in the last shot of the film, going into '
          'the furnace with everything else nobody wanted.',
        ),
      ),
    );
  }
}
