import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageHero extends StatelessWidget {
  const ImageHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Row(
        spacing: 16,
        children: <Widget>[
          Expanded(
            child: NebaImage(
              image: AssetImage('assets/samples/photos/misty-tea-terraces-sunrise.jpg'),
              alt: 'Terraced tea fields under morning mist',
              ratio: 16 / 9,
              rounded: NebaSize.md,
            ),
          ),
          Expanded(
            child: NebaImage(
              image: AssetImage('assets/samples/does-not-exist.png'),
              alt: 'A photograph that did not load',
              ratio: 16 / 9,
              rounded: NebaSize.md,
            ),
          ),
        ],
      ),
    );
  }
}
