import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _fonts = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'sans', label: Text('Sans-serif')),
  NebaSelectOption<String>(value: 'serif', label: Text('Serif')),
  NebaSelectOption<String>(value: 'mono', label: Text('Monospace')),
];

class SelectVariants extends StatelessWidget {
  const SelectVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaSelect<String>(
          items: _fonts,
          variant: NebaVariant.solid,
          label: Text('Solid'),
          defaultValue: 'sans',
        ),
        NebaSelect<String>(
          items: _fonts,
          variant: NebaVariant.outline,
          label: Text('Outline'),
          defaultValue: 'sans',
        ),
        NebaSelect<String>(
          items: _fonts,
          variant: NebaVariant.text,
          label: Text('Text'),
          defaultValue: 'sans',
        ),
      ],
    );
  }
}
