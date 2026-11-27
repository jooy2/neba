import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _frameworks = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'react', label: 'React'),
  NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
  NebaComboboxOption<String>(value: 'svelte', label: 'Svelte'),
  NebaComboboxOption<String>(value: 'solid', label: 'Solid'),
  NebaComboboxOption<String>(value: 'angular', label: 'Angular'),
  NebaComboboxOption<String>(value: 'ember', label: 'Ember', disabled: true),
];

class ComboboxHero extends StatelessWidget {
  const ComboboxHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaCombobox<String>(
          items: _frameworks,
          label: Text('Framework'),
          placeholder: 'Search or type your own',
          clearable: true,
        ),
        NebaCombobox<String>.multiple(
          items: _frameworks,
          label: Text('Also used'),
          placeholder: 'Add a few',
          defaultValue: <String>['react', 'svelte'],
        ),
      ],
    );
  }
}
