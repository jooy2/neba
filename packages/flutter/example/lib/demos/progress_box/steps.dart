import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _steps = <String>['Account', 'Workspace', 'Billing', 'Invite', 'Done'];

/// When the thing being waited on genuinely has steps, `count` is the number
/// of them and the plates stop being a decoration.
class ProgressBoxSteps extends StatefulWidget {
  const ProgressBoxSteps({super.key});

  @override
  State<ProgressBoxSteps> createState() => _ProgressBoxStepsState();
}

class _ProgressBoxStepsState extends State<ProgressBoxSteps> {
  int _step = 2;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaProgressBox(
          size: NebaSize.lg,
          count: _steps.length,
          value: _step.toDouble(),
          max: _steps.length.toDouble(),
          color: NebaColor.success,
          label: Text(_steps[math.min(_step, _steps.length - 1)]),
        ),
        NebaFlex(
          spacing: 2,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            NebaButton(
              onPressed: _step == 0 ? null : () => setState(() => _step -= 1),
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: const Text('Back'),
            ),
            NebaButton(
              onPressed: _step == _steps.length ? null : () => setState(() => _step += 1),
              size: NebaSize.sm,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
