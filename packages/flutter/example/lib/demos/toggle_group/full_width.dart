import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleGroupFullWidth extends StatelessWidget {
  const ToggleGroupFullWidth({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaToggleGroup(
        fullWidth: true,
        semanticLabel: 'View',
        defaultValue: <String>['board'],
        children: <Widget>[
          NebaToggle(value: 'list', child: Text('List')),
          NebaToggle(value: 'board', child: Text('Board')),
          NebaToggle(value: 'calendar', child: Text('Calendar')),
        ],
      ),
    );
  }
}
