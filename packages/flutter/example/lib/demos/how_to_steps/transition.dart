import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(
    title: Text('Pick a plan'),
    content: NebaTypography('Monthly or yearly. Yearly is two months free.'),
  ),
  NebaHowToStep(
    title: Text('Add a card'),
    content: NebaTypography('Charged on the first of the month, never before.'),
  ),
  NebaHowToStep(
    title: Text('Confirm'),
    content: NebaTypography('You can cancel from Billing at any time.'),
  ),
];

/// `null` is no transition at all.
const Map<String, NebaTransition?> _options = <String, NebaTransition?>{
  'fade': NebaTransition.fade(),
  'slide': NebaTransition.slide(from: NebaSide.right, distance: 24),
  'zoom': NebaTransition.zoom(scale: 0.96, duration: Duration(milliseconds: 220)),
  'none': null,
};

class HowToStepsTransition extends StatefulWidget {
  const HowToStepsTransition({super.key});

  @override
  State<HowToStepsTransition> createState() => _HowToStepsTransitionState();
}

class _HowToStepsTransitionState extends State<HowToStepsTransition> {
  String _effect = 'slide';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaSegmentedButton<String>(
          size: NebaSize.sm,
          semanticLabel: 'transition',
          value: _effect,
          onValueChange: (String? next) {
            if (next != null) {
              setState(() => _effect = next);
            }
          },
          children: <NebaSegment<String>>[
            for (final String name in _options.keys)
              NebaSegment<String>(value: name, child: Text(name)),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: NebaHowToSteps(transition: _options[_effect], steps: _steps),
        ),
      ],
    );
  }
}
