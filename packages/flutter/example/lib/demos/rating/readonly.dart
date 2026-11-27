import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, double, int)> _reviews = <(String, double, int)>[
  ('Cold brew concentrate', 4.6, 1284),
  ('Ceramic pour-over cone', 3.2, 96),
  ('Paper filters, 100 pack', 5, 12),
];

class RatingReadonly extends StatelessWidget {
  const RatingReadonly({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          for (final (String name, double score, int count) in _reviews)
            Row(
              spacing: 16,
              children: <Widget>[
                Expanded(child: NebaTypography(name)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: <Widget>[
                    NebaRating(value: score, readOnly: true, size: NebaSize.sm),
                    NebaTypography(
                      '${score == score.roundToDouble() ? score.toInt() : score} ($count)',
                      level: NebaTypographyLevel.caption,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
