import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RadioGroupStates extends StatelessWidget {
  const RadioGroupStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 10,
      children: <Widget>[
        NebaRadioGroup<String>(
          label: Text('One option is out of reach'),
          defaultValue: 'starter',
          children: <Widget>[
            NebaRadio<String>(value: 'starter', label: Text('Starter')),
            NebaRadio<String>(value: 'team', label: Text('Team')),
            NebaRadio<String>(value: 'enterprise', label: Text('Enterprise'), disabled: true),
          ],
        ),
        NebaRadioGroup<String>(
          label: Text('The whole set is read-only'),
          readOnly: true,
          defaultValue: 'team',
          children: <Widget>[
            NebaRadio<String>(value: 'starter', label: Text('Starter')),
            NebaRadio<String>(value: 'team', label: Text('Team')),
          ],
        ),
        NebaRadioGroup<String>(
          label: Text('Plan'),
          error: Text('Choose a plan to continue.'),
          children: <Widget>[
            NebaRadio<String>(value: 'starter', label: Text('Starter')),
            NebaRadio<String>(value: 'team', label: Text('Team')),
          ],
        ),
      ],
    );
  }
}
