import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String)> _slides = <(String, String)>[
  (
    'assets/samples/photos/alpine-lake-dawn.jpg',
    'A still alpine lake with the first light on the far ridge',
  ),
  (
    'assets/samples/photos/misty-tea-terraces-sunrise.jpg',
    'Terraced tea fields under morning mist',
  ),
  (
    'assets/samples/photos/rowboat-misty-pond-sunrise.jpg',
    'A rowboat moored on a misty pond at sunrise',
  ),
  ('assets/samples/photos/frosted-pinecones-moss.jpg', 'Frosted pine cones lying on moss'),
];

/// The other side of the padding rule: a picture fills the frame, so there is
/// nothing to pad in, and the arrows are drawn over the photograph itself.
class CarouselPhotos extends StatelessWidget {
  const CarouselPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaCarousel(
        semanticLabel: 'Photographs',
        indicators: true,
        children: <Widget>[
          for (final (String path, String alt) in _slides)
            NebaImage(image: AssetImage(path), alt: alt, ratio: 3 / 2),
        ],
      ),
    );
  }
}
