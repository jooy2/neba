import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _plans = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'starter', label: 'Starter'),
  NebaComboboxOption<String>(value: 'team', label: 'Team'),
];

class ComboboxStates extends StatelessWidget {
  const ComboboxStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaCombobox<String>(
          items: _plans,
          label: Text('Read-only'),
          readOnly: true,
          defaultValue: 'team',
        ),
        NebaCombobox<String>(
          items: _plans,
          label: Text('Disabled'),
          disabled: true,
          defaultValue: 'team',
        ),
        NebaCombobox<String>(
          items: _plans,
          label: Text('Plan'),
          placeholder: 'Pick one',
          error: Text('Choose a plan.'),
        ),
        NebaCombobox<String>.multiple(
          items: _plans,
          label: Text('Read-only tags'),
          readOnly: true,
          defaultValue: <String>['starter', 'team'],
        ),
      ],
    );
  }
}
