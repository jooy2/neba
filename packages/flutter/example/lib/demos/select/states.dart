import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _plans = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'starter', label: Text('Starter')),
  NebaSelectOption<String>(value: 'team', label: Text('Team')),
];

class SelectStates extends StatelessWidget {
  const SelectStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaSelect<String>(
          items: _plans,
          label: Text('Read-only'),
          readOnly: true,
          defaultValue: 'team',
        ),
        NebaSelect<String>(
          items: _plans,
          label: Text('Disabled'),
          disabled: true,
          defaultValue: 'team',
        ),
        NebaSelect<String>(
          items: _plans,
          label: Text('Plan'),
          placeholder: Text('Pick one'),
          error: Text('Choose a plan.'),
        ),
        NebaSelect<String>(
          items: _plans,
          label: Text('With help'),
          description: Text('Billed monthly.'),
          defaultValue: 'starter',
        ),
      ],
    );
  }
}
