import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RatingHero extends StatefulWidget {
  const RatingHero({super.key});

  @override
  State<RatingHero> createState() => _RatingHeroState();
}

class _RatingHeroState extends State<RatingHero> {
  double _score = 4;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaRating(
          value: _score,
          onValueChange: (double value) => setState(() => _score = value),
          size: NebaSize.lg,
        ),
        NebaTypography(
          _score == 0 ? 'Not rated yet' : '${_score.toInt()} out of 5',
          level: NebaTypographyLevel.caption,
        ),
      ],
    );
  }
}
