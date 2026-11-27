import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(
    title: Text('Fork'),
    content: NebaTypography('Your own copy, on your own account.'),
  ),
  NebaHowToStep(
    title: Text('Branch'),
    content: NebaTypography('One branch per change, named after the change.'),
  ),
  NebaHowToStep(
    title: Text('Open a PR'),
    content: NebaTypography('Describe what it does, not what it touches.'),
  ),
];

class HowToStepsDivider extends StatefulWidget {
  const HowToStepsDivider({super.key});

  @override
  State<HowToStepsDivider> createState() => _HowToStepsDividerState();
}

class _HowToStepsDividerState extends State<HowToStepsDivider> {
  bool _divider = true;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaCheckbox(
          size: NebaSize.sm,
          checked: _divider,
          onCheckedChange: (bool next) => setState(() => _divider = next),
          label: const Text('divider'),
        ),
        SizedBox(
          width: double.infinity,
          child: NebaHowToSteps(divider: _divider, steps: _steps),
        ),
      ],
    );
  }
}
