import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _plans = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'starter', label: Text('Starter')),
  NebaSelectOption<String>(value: 'team', label: Text('Team')),
  NebaSelectOption<String>(value: 'enterprise', label: Text('Enterprise')),
];

class SelectLabelPlacement extends StatelessWidget {
  const SelectLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaSelect<String>(items: _plans, label: Text('Top'), placeholder: Text('Pick a plan')),
        NebaSelect<String>(
          items: _plans,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          placeholder: Text('Pick a plan'),
        ),
        NebaSelect<String>(
          items: _plans,
          labelPlacement: NebaLabelPlacement.float,
          label: Text('Float'),
          placeholder: Text('Pick a plan'),
        ),
      ],
    );
  }
}
