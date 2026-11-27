import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _frameworks = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'react', label: 'React'),
  NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
  NebaComboboxOption<String>(value: 'svelte', label: 'Svelte'),
  NebaComboboxOption<String>(value: 'solid', label: 'Solid'),
];

class ComboboxLabelPlacement extends StatelessWidget {
  const ComboboxLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaCombobox<String>(
          items: _frameworks,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: 'Search frameworks',
        ),
        NebaCombobox<String>(
          items: _frameworks,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: 'Search frameworks',
        ),
        NebaCombobox<String>.multiple(
          items: _frameworks,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Also used'),
          placeholder: 'Add a few',
        ),
      ],
    );
  }
}
