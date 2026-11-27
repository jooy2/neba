import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PortalHero extends StatefulWidget {
  const PortalHero({super.key});

  @override
  State<PortalHero> createState() => _PortalHeroState();
}

class _PortalHeroState extends State<PortalHero> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _shown = !_shown),
          child: Text(_shown ? 'Hide the banner' : 'Show a banner'),
        ),
        if (_shown)
          const NebaPortal(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: NebaCard(
                  density: NebaDensity.compact,
                  child: Text(
                    'Drawn in the root overlay, pinned to the top of the window.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        const NebaTypography(
          'The banner is written inside this preview and drawn in the app\'s root overlay, '
          'which is why it is placed against the window rather than this box.',
          level: NebaTypographyLevel.caption,
          color: NebaColor.secondary,
        ),
      ],
    );
  }
}
