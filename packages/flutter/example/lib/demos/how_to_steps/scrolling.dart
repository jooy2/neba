import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaHowToStep> _steps = <NebaHowToStep>[
  for (int index = 0; index < 14; index++)
    NebaHowToStep(
      title: Text('Migration ${'${index + 1}'.padLeft(3, '0')}'),
      content: const NebaTypography(
        'Run it against the staging database first, then production. Nothing here is '
        'reversible.',
      ),
    ),
];

class HowToStepsScrolling extends StatelessWidget {
  const HowToStepsScrolling({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaHowToSteps(title: const Text('Fourteen migrations'), maxHeight: 340, steps: _steps);
  }
}
