import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _steps = <String>['Choose a plan', 'Add your details', 'Confirm and pay'];

class AnimateHeadlineControlled extends StatefulWidget {
  const AnimateHeadlineControlled({super.key});

  @override
  State<AnimateHeadlineControlled> createState() => _AnimateHeadlineControlledState();
}

class _AnimateHeadlineControlledState extends State<AnimateHeadlineControlled> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaAnimateHeadline(
          index: _step,
          children: <Widget>[
            for (final String label in _steps)
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        NebaButtonGroup(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          children: <Widget>[
            NebaButton(
              onPressed: () => setState(() => _step = math.max(_step - 1, 0)),
              child: const Text('Back'),
            ),
            NebaButton(
              onPressed: () => setState(() => _step = math.min(_step + 1, _steps.length - 1)),
              child: const Text('Next'),
            ),
          ],
        ),
        NebaTypography('Step ${_step + 1} of ${_steps.length}', level: NebaTypographyLevel.caption),
      ],
    );
  }
}
