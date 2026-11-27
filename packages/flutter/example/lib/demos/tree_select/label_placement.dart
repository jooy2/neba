import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaTreeSelectItem<String>> _categories = <NebaTreeSelectItem<String>>[
  NebaTreeSelectItem<String>(
    value: 'hardware',
    label: Text('Hardware'),
    children: <NebaTreeSelectItem<String>>[
      NebaTreeSelectItem<String>(value: 'laptops', label: Text('Laptops')),
      NebaTreeSelectItem<String>(value: 'monitors', label: Text('Monitors')),
    ],
  ),
  NebaTreeSelectItem<String>(
    value: 'software',
    label: Text('Software'),
    children: <NebaTreeSelectItem<String>>[
      NebaTreeSelectItem<String>(value: 'design', label: Text('Design tools')),
      NebaTreeSelectItem<String>(value: 'infra', label: Text('Infrastructure')),
    ],
  ),
];

class TreeSelectLabelPlacement extends StatelessWidget {
  const TreeSelectLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaTreeSelect<String>(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: Text('Pick a category'),
          items: _categories,
          defaultValue: <String>['laptops'],
        ),
        NebaTreeSelect<String>(
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: Text('Pick a category'),
          items: _categories,
        ),
      ],
    );
  }
}
