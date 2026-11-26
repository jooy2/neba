import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TypographyColors extends StatelessWidget {
  const TypographyColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 1.5,
      children: <Widget>[
        const NebaTypography('No colour asked for — inherits the page.'),
        for (final NebaColor color in NebaColor.values) NebaTypography(color.name, color: color),
      ],
    );
  }
}
