import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TypographyHero extends StatelessWidget {
  const TypographyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        children: <Widget>[
          NebaTypography('Changelog', level: NebaTypographyLevel.overline),
          NebaTypography('A sheet of cut acrylic', level: NebaTypographyLevel.h2),
          NebaTypography(
            'Every surface in the library is the same material at a different opacity.',
            level: NebaTypographyLevel.lead,
          ),
          NebaTypography(
            'The blur makes it a sheet of something; the noise makes that something acrylic '
            'rather than glass. Depth is not part of the surface — it is opt-in.',
          ),
          NebaTypography('Updated 2 minutes ago', level: NebaTypographyLevel.caption),
        ],
      ),
    );
  }
}
