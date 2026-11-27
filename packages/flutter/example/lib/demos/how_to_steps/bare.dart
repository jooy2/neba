import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(
    title: Text('Read the brief'),
    content: NebaTypography('Everything the client sent, in one sitting.'),
  ),
  NebaHowToStep(
    title: Text('Sketch'),
    content: NebaTypography('On paper. Three ideas, ten minutes each.'),
  ),
  NebaHowToStep(
    title: Text('Pick one'),
    content: NebaTypography('The one you would defend, not the safe one.'),
  ),
];

class HowToStepsBare extends StatelessWidget {
  const HowToStepsBare({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaHowToSteps(variant: NebaVariant.text, navigation: false, steps: _steps),
        NebaHowToSteps(
          variant: NebaVariant.solid,
          completion: false,
          density: NebaDensity.compact,
          size: NebaSize.sm,
          steps: _steps,
        ),
      ],
    );
  }
}
