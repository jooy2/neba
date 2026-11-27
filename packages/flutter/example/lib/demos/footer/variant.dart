import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FooterVariant extends StatelessWidget {
  const FooterVariant({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
            child: NebaFooter(
              variant: variant,
              child: NebaTypography(
                'variant: NebaVariant.${variant.name}',
                level: NebaTypographyLevel.caption,
                color: NebaColor.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
