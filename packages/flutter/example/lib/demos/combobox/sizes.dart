import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaComboboxOption<String>> _periods = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'day', label: 'Day'),
  NebaComboboxOption<String>(value: 'week', label: 'Week'),
  NebaComboboxOption<String>(value: 'month', label: 'Month'),
];

class ComboboxSizes extends StatelessWidget {
  const ComboboxSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaCombobox<String>(
                items: _periods,
                size: size,
                defaultValue: 'week',
                semanticLabel: 'Period, ${size.name}',
              ),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaCombobox<String>.multiple(
                items: _periods,
                size: size,
                defaultValue: const <String>['week'],
                semanticLabel: 'Periods, ${size.name}',
              ),
          ],
        ),
      ],
    );
  }
}
