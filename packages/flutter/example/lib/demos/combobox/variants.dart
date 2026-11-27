import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _fonts = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'sans', label: 'Sans-serif'),
  NebaComboboxOption<String>(value: 'serif', label: 'Serif'),
  NebaComboboxOption<String>(value: 'mono', label: 'Monospace'),
];

class ComboboxVariants extends StatelessWidget {
  const ComboboxVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaCombobox<String>(
          items: _fonts,
          variant: NebaVariant.solid,
          label: Text('Solid'),
          defaultValue: 'sans',
        ),
        NebaCombobox<String>(
          items: _fonts,
          variant: NebaVariant.outline,
          label: Text('Outline'),
          defaultValue: 'sans',
        ),
        NebaCombobox<String>(
          items: _fonts,
          variant: NebaVariant.text,
          label: Text('Text'),
          defaultValue: 'sans',
        ),
      ],
    );
  }
}
