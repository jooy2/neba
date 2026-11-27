import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSelectOption<String>> _periods = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'day', label: Text('Day')),
  NebaSelectOption<String>(value: 'week', label: Text('Week')),
  NebaSelectOption<String>(value: 'month', label: Text('Month')),
];

class SelectSizes extends StatelessWidget {
  const SelectSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaSelect<String>(
            items: _periods,
            size: size,
            defaultValue: 'week',
            semanticLabel: 'Period, ${size.name}',
          ),
      ],
    );
  }
}
