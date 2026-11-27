import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RatingStates extends StatelessWidget {
  const RatingStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 1,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            NebaRating(defaultValue: 3, clearable: false),
            NebaTypography(
              'clearable: false. A score, once given, stays given',
              level: NebaTypographyLevel.caption,
              align: TextAlign.center,
            ),
          ],
        ),
        NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 1,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            NebaRating(defaultValue: 2, disabled: true),
            NebaTypography('disabled', level: NebaTypographyLevel.caption),
          ],
        ),
      ],
    );
  }
}
