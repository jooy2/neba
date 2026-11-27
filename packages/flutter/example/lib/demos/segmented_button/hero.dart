import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SegmentedButtonHero extends StatefulWidget {
  const SegmentedButtonHero({super.key});

  @override
  State<SegmentedButtonHero> createState() => _SegmentedButtonHeroState();
}

class _SegmentedButtonHeroState extends State<SegmentedButtonHero> {
  String? _range = 'week';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaSegmentedButton<String>(
          semanticLabel: 'Range',
          value: _range,
          onValueChange: (String? next) => setState(() => _range = next),
          children: const <NebaSegment<String>>[
            NebaSegment<String>(value: 'day', child: Text('Day')),
            NebaSegment<String>(value: 'week', child: Text('Week')),
            NebaSegment<String>(value: 'month', child: Text('Month')),
            NebaSegment<String>(value: 'year', child: Text('Year')),
          ],
        ),
        const NebaSegmentedButton<String>(
          semanticLabel: 'Layout',
          variant: NebaVariant.solid,
          defaultValue: 'grid',
          children: <NebaSegment<String>>[
            NebaSegment<String>(value: 'list', child: Text('List')),
            NebaSegment<String>(value: 'grid', child: Text('Grid')),
            NebaSegment<String>(value: 'map', child: Text('Map')),
          ],
        ),
      ],
    );
  }
}
