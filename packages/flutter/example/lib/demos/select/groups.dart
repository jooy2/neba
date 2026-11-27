import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A group is a run of adjacent options naming it, so the list's order is the
/// order given. The last one belongs to no group and stays where it was put.
const List<NebaSelectOption<String>> _zones = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'icn', label: Text('Seoul'), group: 'Asia'),
  NebaSelectOption<String>(value: 'nrt', label: Text('Tokyo'), group: 'Asia'),
  NebaSelectOption<String>(value: 'sin', label: Text('Singapore'), group: 'Asia'),
  NebaSelectOption<String>(value: 'cdg', label: Text('Paris'), group: 'Europe'),
  NebaSelectOption<String>(value: 'lhr', label: Text('London'), group: 'Europe'),
  NebaSelectOption<String>(value: 'utc', label: Text('UTC')),
];

class SelectGroups extends StatelessWidget {
  const SelectGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaSelect<String>(items: _zones, label: Text('Time zone'), defaultValue: 'icn');
  }
}
