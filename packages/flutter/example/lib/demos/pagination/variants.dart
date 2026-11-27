import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `variant` is how the pages look at rest. The current page is always
/// filled, whatever the row's resting variant is: it is the one thing here
/// that has to be legible without being read.
class PaginationVariants extends StatelessWidget {
  const PaginationVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        for (final NebaVariant variant in <NebaVariant>[
          NebaVariant.text,
          NebaVariant.outline,
          NebaVariant.solid,
        ])
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            children: <Widget>[
              NebaTypography('variant: ${variant.name}', level: NebaTypographyLevel.caption),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: NebaPagination(count: 9, defaultPage: 4, variant: variant),
              ),
            ],
          ),
      ],
    );
  }
}
