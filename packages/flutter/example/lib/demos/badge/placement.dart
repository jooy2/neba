import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BadgePlacement extends StatelessWidget {
  const BadgePlacement({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 6,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaCorner placement in NebaCorner.values)
              NebaBadge.count(
                count: 3,
                placement: placement,
                child: NebaButton(
                  onPressed: () {},
                  variant: NebaVariant.outline,
                  color: NebaColor.secondary,
                  size: NebaSize.lg,
                  child: Text(placement.name),
                ),
              ),
          ],
        ),
        // A circle's corner is further from its centre than a square's, so the
        // badge has to tuck in further or it floats off the edge.
        NebaFlex(
          wrap: true,
          spacing: 6,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaBadgeOverlap overlap in NebaBadgeOverlap.values)
              NebaFlex(
                spacing: 3,
                alignItems: NebaAlignItems.center,
                children: <Widget>[
                  NebaBadge.count(
                    count: 3,
                    overlap: overlap,
                    color: NebaColor.danger,
                    child: const NebaAvatar(initials: 'JD', size: NebaSize.lg),
                  ),
                  Text(
                    'overlap: ${overlap.name}',
                    style: TextStyle(fontSize: 12, color: tokens.mutedFg),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
