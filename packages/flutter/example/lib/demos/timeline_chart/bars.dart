import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaTimelineSeries> _terms = <NebaTimelineSeries>[
  NebaTimelineSeries(
    name: 'Alpha',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: DateTime(2026, 1, 5), end: DateTime(2026, 3, 30), label: 'Alpha'),
    ],
  ),
  NebaTimelineSeries(
    name: 'Beta',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: DateTime(2026, 3, 16), end: DateTime(2026, 6, 8), label: 'Beta'),
    ],
  ),
  NebaTimelineSeries(
    name: 'GA',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: DateTime(2026, 5, 25), end: DateTime(2026, 8, 31), label: 'GA'),
    ],
  ),
];

class TimelineChartBars extends StatelessWidget {
  const TimelineChartBars({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: NebaCard(
            title: const Text('barSize + rounded'),
            size: NebaSize.sm,
            child: NebaTimelineChart(
              label: 'Programme phases, thick bars',
              barSize: 30,
              series: _terms,
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: NebaCard(
            title: const Text('density: compact'),
            size: NebaSize.sm,
            child: NebaTimelineChart(
              label: 'Programme phases, square ends',
              density: NebaDensity.compact,
              rounded: false,
              series: _terms,
            ),
          ),
        ),
      ],
    );
  }
}
