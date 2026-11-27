import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class NumberFieldStates extends StatelessWidget {
  const NumberFieldStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaNumberField(label: Text('Read-only'), readOnly: true, defaultValue: 4),
        NebaNumberField(label: Text('Disabled'), disabled: true, defaultValue: 4),
        NebaNumberField(
          label: Text('Seats'),
          min: 1,
          error: Text('At least one seat.'),
          defaultValue: 0,
        ),
        NebaNumberField(
          label: Text('Clamped'),
          min: 0,
          max: 5,
          defaultValue: 5,
          description: Text('0 to 5.'),
        ),
      ],
    );
  }
}
