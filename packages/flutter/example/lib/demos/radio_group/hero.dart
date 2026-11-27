import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RadioGroupHero extends StatelessWidget {
  const RadioGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaRadioGroup<String>(
      label: Text('Plan'),
      defaultValue: 'team',
      children: <Widget>[
        NebaRadio<String>(value: 'starter', label: Text('Starter')),
        NebaRadio<String>(value: 'team', label: Text('Team')),
        NebaRadio<String>(value: 'enterprise', label: Text('Enterprise')),
      ],
    );
  }
}
