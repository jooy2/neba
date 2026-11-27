import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<NebaTimelineSeries> _plan = <NebaTimelineSeries>[
  NebaTimelineSeries(
    name: 'Discovery',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(
        start: DateTime(2026, 1, 6),
        end: DateTime(2026, 1, 27),
        label: 'Interviews',
      ),
      NebaTimelinePoint(
        start: DateTime(2026, 1, 27),
        end: DateTime(2026, 2, 10),
        label: 'Synthesis',
      ),
    ],
  ),
  NebaTimelineSeries(
    name: 'Design',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(
        start: DateTime(2026, 2, 3),
        end: DateTime(2026, 3, 3),
        label: 'Wireframes',
      ),
      NebaTimelinePoint(
        start: DateTime(2026, 3, 3),
        end: DateTime(2026, 4, 7),
        label: 'Visual design',
      ),
    ],
  ),
  NebaTimelineSeries(
    name: 'Build',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: DateTime(2026, 3, 17), end: DateTime(2026, 5, 19), label: 'API'),
      NebaTimelinePoint(start: DateTime(2026, 4, 14), end: DateTime(2026, 6, 16), label: 'Client'),
    ],
  ),
  NebaTimelineSeries(
    name: 'Launch',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(
        start: DateTime(2026, 6, 2),
        end: DateTime(2026, 6, 30),
        label: 'Beta',
        color: NebaColor.success,
      ),
    ],
  ),
];

class TimelineChartHero extends StatelessWidget {
  const TimelineChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Release plan'),
      subtitle: const Text('First half of 2026'),
      child: NebaTimelineChart(label: 'Release plan by workstream', series: _plan),
    );
  }
}
