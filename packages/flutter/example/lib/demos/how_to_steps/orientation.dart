import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(
    title: Text('Account'),
    content: NebaTypography('Name, email, and a password you have not used elsewhere.'),
  ),
  NebaHowToStep(
    title: Text('Workspace'),
    content: NebaTypography('Pick a name and a region. Both can be changed later.'),
  ),
  NebaHowToStep(
    title: Text('Invite'),
    content: NebaTypography('Add the people who will need it on day one.'),
  ),
];

class HowToStepsOrientation extends StatefulWidget {
  const HowToStepsOrientation({super.key});

  @override
  State<HowToStepsOrientation> createState() => _HowToStepsOrientationState();
}

class _HowToStepsOrientationState extends State<HowToStepsOrientation> {
  NebaOrientation _orientation = NebaOrientation.horizontal;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaSegmentedButton<NebaOrientation>(
          size: NebaSize.sm,
          semanticLabel: 'orientation',
          value: _orientation,
          onValueChange: (NebaOrientation? next) {
            if (next != null) {
              setState(() => _orientation = next);
            }
          },
          children: const <NebaSegment<NebaOrientation>>[
            NebaSegment<NebaOrientation>(value: NebaOrientation.vertical, child: Text('vertical')),
            NebaSegment<NebaOrientation>(
              value: NebaOrientation.horizontal,
              child: Text('horizontal'),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: NebaHowToSteps(orientation: _orientation, steps: _steps),
        ),
      ],
    );
  }
}
