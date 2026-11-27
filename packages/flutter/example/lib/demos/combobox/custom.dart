import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _timezones = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'Asia/Seoul', label: 'Asia/Seoul'),
  NebaComboboxOption<String>(value: 'Asia/Tokyo', label: 'Asia/Tokyo'),
  NebaComboboxOption<String>(value: 'Europe/Berlin', label: 'Europe/Berlin'),
  NebaComboboxOption<String>(value: 'America/New_York', label: 'America/New_York'),
];

class ComboboxCustom extends StatelessWidget {
  const ComboboxCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaCombobox<String>(
          items: _timezones,
          label: const Text('Anything goes'),
          placeholder: 'Type a timezone',
          customLabel: (String query) => Text('Use “$query” anyway'),
          description: const Text('A typed value is offered as the last row.'),
        ),
        const NebaCombobox<String>(
          items: _timezones,
          allowCustom: false,
          label: Text('Closed set'),
          placeholder: 'Pick a timezone',
          emptyMessage: Text('No such timezone.'),
          description: Text('Only what the list holds.'),
        ),
      ],
    );
  }
}
