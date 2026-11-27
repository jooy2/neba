import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RatingPrecision extends StatefulWidget {
  const RatingPrecision({super.key});

  @override
  State<RatingPrecision> createState() => _RatingPrecisionState();
}

class _RatingPrecisionState extends State<RatingPrecision> {
  double _score = 3.5;

  @override
  Widget build(BuildContext context) {
    final String written = _score == _score.roundToDouble()
        ? _score.toInt().toString()
        : _score.toString();

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaRating(
          value: _score,
          onValueChange: (double value) => setState(() => _score = value),
          precision: 0.5,
          size: NebaSize.lg,
        ),
        NebaTypography(
          '${_score == 0 ? 'nothing' : written} chosen',
          level: NebaTypographyLevel.caption,
        ),
        const NebaRating(
          defaultValue: 7,
          count: 10,
          precision: 0.5,
          size: NebaSize.sm,
          semanticLabel: 'Out of ten',
        ),
      ],
    );
  }
}
