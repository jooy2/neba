import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleGroupOrientation extends StatelessWidget {
  const ToggleGroupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaToggleGroup(
      orientation: NebaOrientation.vertical,
      semanticLabel: 'Density',
      defaultValue: <String>['cosy'],
      children: <Widget>[
        NebaToggle(value: 'compact', child: Text('Compact')),
        NebaToggle(value: 'cosy', child: Text('Cosy')),
        NebaToggle(value: 'roomy', child: Text('Roomy')),
      ],
    );
  }
}
