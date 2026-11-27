import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RadioGroupOrientation extends StatelessWidget {
  const RadioGroupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaRadioGroup<String>(
      label: Text('Billing period'),
      orientation: NebaOrientation.horizontal,
      defaultValue: 'yearly',
      children: <Widget>[
        NebaRadio<String>(value: 'monthly', label: Text('Monthly')),
        NebaRadio<String>(value: 'yearly', label: Text('Yearly')),
        NebaRadio<String>(value: 'once', label: Text('One-off')),
      ],
    );
  }
}
