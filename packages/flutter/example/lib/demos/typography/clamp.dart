import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TypographyClamp extends StatelessWidget {
  const TypographyClamp({super.key});

  static const String copy =
      'A Neba surface is a sheet of cut acrylic, not a moulded plastic key. Press is instant and '
      'release is slow, elevation is opt-in, and no control ever moves under the cursor.';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            children: <Widget>[
              NebaTypography('lines=1', level: NebaTypographyLevel.overline),
              NebaTypography(copy, lines: 1),
            ],
          ),
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            children: <Widget>[
              NebaTypography('lines=2', level: NebaTypographyLevel.overline),
              NebaTypography(copy, lines: 2),
            ],
          ),
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            children: <Widget>[
              NebaTypography('no clamp', level: NebaTypographyLevel.overline),
              NebaTypography(copy),
            ],
          ),
        ],
      ),
    );
  }
}
