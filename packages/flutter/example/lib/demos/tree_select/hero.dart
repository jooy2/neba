import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaTreeSelectItem<String>> _categories = <NebaTreeSelectItem<String>>[
  NebaTreeSelectItem<String>(
    value: 'hardware',
    label: Text('Hardware'),
    children: <NebaTreeSelectItem<String>>[
      NebaTreeSelectItem<String>(value: 'laptops', label: Text('Laptops')),
      NebaTreeSelectItem<String>(value: 'monitors', label: Text('Monitors')),
      NebaTreeSelectItem<String>(value: 'peripherals', label: Text('Peripherals')),
    ],
  ),
  NebaTreeSelectItem<String>(
    value: 'software',
    label: Text('Software'),
    children: <NebaTreeSelectItem<String>>[
      NebaTreeSelectItem<String>(value: 'design', label: Text('Design tools')),
      NebaTreeSelectItem<String>(value: 'infra', label: Text('Infrastructure')),
      NebaTreeSelectItem<String>(value: 'legacy', label: Text('Legacy licences'), disabled: true),
    ],
  ),
  NebaTreeSelectItem<String>(
    value: 'services',
    label: Text('Services'),
    children: <NebaTreeSelectItem<String>>[
      NebaTreeSelectItem<String>(value: 'support', label: Text('Support contracts')),
      NebaTreeSelectItem<String>(value: 'training', label: Text('Training')),
    ],
  ),
];

class TreeSelectHero extends StatefulWidget {
  const TreeSelectHero({super.key});

  @override
  State<TreeSelectHero> createState() => _TreeSelectHeroState();
}

class _TreeSelectHeroState extends State<TreeSelectHero> {
  List<String> _one = <String>['laptops'];
  List<String> _many = <String>[];

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTreeSelect<String>(
          label: const Text('Category'),
          placeholder: const Text('Pick a category'),
          items: _categories,
          value: _one,
          onValueChange: (List<String> next) => setState(() => _one = next),
          defaultExpanded: const <String>['hardware'],
          clearable: true,
        ),
        NebaTreeSelect<String>(
          label: const Text('Watching'),
          placeholder: const Text('Pick any number'),
          items: _categories,
          multiple: true,
          searchable: true,
          value: _many,
          onValueChange: (List<String> next) => setState(() => _many = next),
          format: (List<NebaTreeSelectItem<String>> chosen) =>
              chosen.length == 1 ? chosen.first.label! : Text('${chosen.length} categories'),
          clearable: true,
        ),
      ],
    );
  }
}
