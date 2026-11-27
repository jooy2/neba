import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleGroupVariants extends StatelessWidget {
  const ToggleGroupVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaToggleGroup(
            semanticLabel: variant.name,
            variant: variant,
            defaultValue: const <String>['week'],
            children: const <Widget>[
              NebaToggle(value: 'day', child: Text('Day')),
              NebaToggle(value: 'week', child: Text('Week')),
              NebaToggle(value: 'month', child: Text('Month')),
            ],
          ),
      ],
    );
  }
}
