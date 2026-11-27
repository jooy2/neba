import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class NumberFieldLabelPlacement extends StatelessWidget {
  const NumberFieldLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      rowSpacing: 6,
      columnSpacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaNumberField(label: Text('Top'), defaultValue: 3, min: 1),
        NebaNumberField(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          defaultValue: 3,
          min: 1,
        ),
        NebaNumberField(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          min: 1,
          placeholder: 'How many?',
        ),
      ],
    );
  }
}
