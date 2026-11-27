import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FooterMeasure extends StatelessWidget {
  const FooterMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: const NebaFooter(
        maxWidth: NebaMeasure.size(NebaSize.sm),
        child: NebaTypography(
          'The sheet spans the window; the content is held to 640 logical pixels and centred.',
          level: NebaTypographyLevel.caption,
          color: NebaColor.secondary,
        ),
      ),
    );
  }
}
