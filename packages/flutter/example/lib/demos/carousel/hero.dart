import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String)> _slides = <(String, String)>[
  ('Ship on Friday', 'Preview deploys on every push, gone the moment the branch is.'),
  ('One prop vocabulary', 'A size of md means the same thing on every control here.'),
  ('Dark mode included', 'Every token has a second value; nothing to wire up.'),
];

class CarouselHero extends StatelessWidget {
  const CarouselHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCarousel(
      semanticLabel: 'Product highlights',
      children: <Widget>[
        for (final (String title, String body) in _slides)
          // The arrows are drawn over the frame, so a slide with words in it
          // pads far enough in to clear them. A photograph would not want
          // that.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 112),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 2,
                  justifyContent: NebaJustifyContent.center,
                  children: <Widget>[
                    NebaTypography(title, level: NebaTypographyLevel.h3),
                    NebaTypography(body),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
