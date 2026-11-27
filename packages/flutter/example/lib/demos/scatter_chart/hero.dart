import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Session length against pages read, one point per visit.
const List<NebaChartPoint> _organic = <NebaChartPoint>[
  NebaChartPoint(x: 22, y: 2),
  NebaChartPoint(x: 41, y: 3),
  NebaChartPoint(x: 55, y: 4),
  NebaChartPoint(x: 68, y: 4),
  NebaChartPoint(x: 74, y: 6),
  NebaChartPoint(x: 90, y: 5),
  NebaChartPoint(x: 112, y: 8),
  NebaChartPoint(x: 128, y: 7),
  NebaChartPoint(x: 141, y: 10),
  NebaChartPoint(x: 166, y: 9),
  NebaChartPoint(x: 184, y: 12),
  NebaChartPoint(x: 203, y: 11),
];

const List<NebaChartPoint> _paid = <NebaChartPoint>[
  NebaChartPoint(x: 18, y: 1),
  NebaChartPoint(x: 30, y: 2),
  NebaChartPoint(x: 44, y: 2),
  NebaChartPoint(x: 61, y: 3),
  NebaChartPoint(x: 79, y: 2),
  NebaChartPoint(x: 96, y: 4),
  NebaChartPoint(x: 118, y: 3),
  NebaChartPoint(x: 137, y: 5),
  NebaChartPoint(x: 152, y: 4),
  NebaChartPoint(x: 178, y: 6),
];

class ScatterChartHero extends StatelessWidget {
  const ScatterChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Pages per visit'),
      subtitle: Text('Against session length, last 30 days'),
      child: NebaScatterChart(
        label: 'Pages read against session length, by channel',
        xAxis: NebaChartAxis(label: 'Seconds on site'),
        yAxis: NebaChartAxis(label: 'Pages'),
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Organic', data: _organic),
          NebaChartSeries(name: 'Paid', data: _paid),
        ],
      ),
    );
  }
}
