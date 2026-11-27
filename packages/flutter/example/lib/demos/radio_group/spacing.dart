import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RadioGroupSpacing extends StatelessWidget {
  const RadioGroupSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaRadioGroup<String>(
      label: Text('Plan'),
      defaultValue: 'team',
      spacing: 4,
      children: <Widget>[
        NebaRadio<String>(
          value: 'starter',
          label: Text('Starter'),
          description: Text('One project, community support.'),
        ),
        NebaRadio<String>(
          value: 'team',
          label: Text('Team'),
          description: Text('Up to twelve seats.'),
        ),
        NebaRadio<String>(
          value: 'enterprise',
          label: Text('Enterprise'),
          description: Text('SSO and an uptime agreement.'),
        ),
      ],
    );
  }
}
