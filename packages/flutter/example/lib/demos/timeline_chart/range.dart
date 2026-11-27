import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// 2 March 2026 at [hour]:[minute].
DateTime _at(int hour, int minute) => DateTime(2026, 3, 2, hour, minute);

/// A single day, so the axis steps in hours rather than in months. `min` and
/// `max` pin it to the working day; the run that started before nine is cut at
/// the edge rather than dragging the whole axis back to midnight.
final List<NebaTimelineSeries> _shifts = <NebaTimelineSeries>[
  NebaTimelineSeries(
    name: 'Build',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: _at(7, 40), end: _at(9, 20), label: 'Nightly'),
      NebaTimelinePoint(start: _at(11, 10), end: _at(12, 5), label: 'PR #4182'),
      NebaTimelinePoint(start: _at(15, 30), end: _at(16, 40), label: 'PR #4190'),
    ],
  ),
  NebaTimelineSeries(
    name: 'Deploy',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: _at(12, 20), end: _at(12, 50), label: 'staging'),
      NebaTimelinePoint(start: _at(17, 0), end: _at(17, 35), label: 'production'),
    ],
  ),
  NebaTimelineSeries(
    name: 'Incident',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(
        start: _at(13, 5),
        end: _at(14, 10),
        label: 'Elevated 5xx',
        color: NebaColor.danger,
      ),
    ],
  ),
];

class TimelineChartRange extends StatelessWidget {
  const TimelineChartRange({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Pipeline'),
      subtitle: const Text('2 March, 09:00 – 18:00'),
      child: NebaTimelineChart(
        label: 'Pipeline activity on 2 March',
        min: _at(9, 0),
        max: _at(18, 0),
        series: _shifts,
      ),
    );
  }
}
