import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _tags = <String>[
  'Design',
  'Engineering',
  'Research',
  'Marketing',
  'Support',
  'Finance',
  'Legal',
  'People',
  'Security',
  'Data',
  'Sales',
  'Operations',
];

class ScrollZoneLines extends StatelessWidget {
  const ScrollZoneLines({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        NebaScrollZone(
          label: 'Teams, one line',
          spacing: 2,
          children: <Widget>[for (final String tag in _tags) NebaChip(child: Text(tag))],
        ),
        NebaScrollZone(
          label: 'Teams, two lines',
          lines: 2,
          spacing: 2,
          children: <Widget>[
            for (final String tag in _tags) NebaChip(color: NebaColor.secondary, child: Text(tag)),
          ],
        ),
      ],
    );
  }
}
