import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _regions = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'icn', label: Text('Seoul')),
  NebaSelectOption<String>(value: 'nrt', label: Text('Tokyo')),
  NebaSelectOption<String>(value: 'fra', label: Text('Frankfurt')),
  NebaSelectOption<String>(value: 'iad', label: Text('Washington DC')),
  NebaSelectOption<String>(value: 'gru', label: Text('São Paulo'), disabled: true),
];

class SelectHero extends StatelessWidget {
  const SelectHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaSelect<String>(
          items: _regions,
          label: Text('Region'),
          placeholder: Text('Pick a region'),
          defaultValue: 'icn',
        ),
        NebaSelect<String>(items: _regions, label: Text('Failover'), placeholder: Text('None')),
      ],
    );
  }
}
