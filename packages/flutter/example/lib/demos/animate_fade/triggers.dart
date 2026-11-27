import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateFadeTriggers extends StatefulWidget {
  const AnimateFadeTriggers({super.key});

  @override
  State<AnimateFadeTriggers> createState() => _AnimateFadeTriggersState();
}

class _AnimateFadeTriggersState extends State<AnimateFadeTriggers> {
  bool _play = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        const NebaFlex(
          wrap: true,
          spacing: 4,
          alignItems: NebaAlignItems.center,
          justifyContent: NebaJustifyContent.center,
          children: <Widget>[
            NebaAnimateFade(
              trigger: NebaAnimateTrigger.hover,
              duration: Duration(milliseconds: 400),
              child: NebaBox(
                size: NebaSize.sm,
                child: NebaTypography('Hover me', level: NebaTypographyLevel.caption),
              ),
            ),
            NebaAnimateFade(
              trigger: NebaAnimateTrigger.visible,
              duration: Duration(milliseconds: 600),
              child: NebaBox(
                size: NebaSize.sm,
                child: NebaTypography('On scrolling into view', level: NebaTypographyLevel.caption),
              ),
            ),
          ],
        ),
        NebaSwitch(
          checked: _play,
          onCheckedChange: (bool play) => setState(() => _play = play),
          label: const Text('Play the manual one'),
          size: NebaSize.sm,
        ),
        NebaAnimateFade(
          trigger: NebaAnimateTrigger.manual,
          play: _play,
          duration: const Duration(milliseconds: 500),
          child: const NebaBox(
            size: NebaSize.sm,
            child: NebaTypography('Driven by the switch', level: NebaTypographyLevel.caption),
          ),
        ),
      ],
    );
  }
}
