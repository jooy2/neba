import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleGroupHero extends StatelessWidget {
  const ToggleGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaToggleGroup(
          semanticLabel: 'Text alignment',
          defaultValue: <String>['left'],
          children: <Widget>[
            NebaToggle(value: 'left', child: Text('Left')),
            NebaToggle(value: 'center', child: Text('Center')),
            NebaToggle(value: 'right', child: Text('Right')),
          ],
        ),
        NebaToggleGroup(
          multiple: true,
          semanticLabel: 'Marks',
          defaultValue: <String>['bold', 'underline'],
          children: <Widget>[
            NebaToggle(value: 'bold', child: Text('Bold')),
            NebaToggle(value: 'italic', child: Text('Italic')),
            NebaToggle(value: 'underline', child: Text('Underline')),
          ],
        ),
      ],
    );
  }
}
