import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaHowToStep> _steps = <NebaHowToStep>[
  NebaHowToStep(
    title: Text('Install'),
    content: NebaTypography('One package, one stylesheet import.'),
  ),
  NebaHowToStep(
    title: Text('Wrap'),
    content: NebaTypography('Nothing to wrap. There is no provider.'),
  ),
  NebaHowToStep(
    title: Text('Use it'),
    content: NebaTypography('Import the component and render it.'),
  ),
];

class HowToStepsControlled extends StatefulWidget {
  const HowToStepsControlled({super.key});

  @override
  State<HowToStepsControlled> createState() => _HowToStepsControlledState();
}

class _HowToStepsControlledState extends State<HowToStepsControlled> {
  int _step = 0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        Row(
          spacing: 12,
          children: <Widget>[
            Expanded(
              child: NebaTypography(
                _completed ? 'finished' : 'step ${_step + 1} of ${_steps.length}',
                color: NebaColor.secondary,
              ),
            ),
            NebaButton(
              onPressed: () => setState(() {
                _completed = false;
                _step = 0;
              }),
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              child: const Text('Reset from outside'),
            ),
          ],
        ),
        NebaHowToSteps(
          steps: _steps,
          step: _step,
          onStepChange: (int next) => setState(() => _step = next),
          completed: _completed,
          onCompletedChange: (bool next) => setState(() => _completed = next),
        ),
      ],
    );
  }
}
