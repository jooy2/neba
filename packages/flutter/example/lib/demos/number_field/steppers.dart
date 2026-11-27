import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class NumberFieldSteppers extends StatelessWidget {
  const NumberFieldSteppers({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaNumberField(
          label: Text('End'),
          steppers: NebaNumberFieldSteppers.end,
          defaultValue: 2,
          min: 0,
        ),
        NebaNumberField(
          label: Text('Split'),
          steppers: NebaNumberFieldSteppers.split,
          defaultValue: 2,
          min: 0,
        ),
        NebaNumberField(
          label: Text('None'),
          steppers: NebaNumberFieldSteppers.none,
          defaultValue: 2,
          min: 0,
        ),
      ],
    );
  }
}
