import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RatingAppearance extends StatelessWidget {
  const RatingAppearance({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 2,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaRating(size: size, defaultValue: 3, semanticLabel: 'Rating, ${size.name}'),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final NebaColor color in <NebaColor>[
              NebaColor.primary,
              NebaColor.success,
              NebaColor.danger,
              NebaColor.info,
            ])
              NebaRating(color: color, defaultValue: 4, semanticLabel: 'Rating, ${color.name}'),
          ],
        ),
      ],
    );
  }
}
