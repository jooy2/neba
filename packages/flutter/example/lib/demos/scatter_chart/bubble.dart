import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A third number per point turns a dot into a bubble. `z` is read as an
/// area, so the plan with four times the revenue draws a bubble twice as wide
/// rather than four times as wide.
const List<NebaChartPoint> _plans = <NebaChartPoint>[
  NebaChartPoint(x: 12, y: 4.2, z: 180, label: 'Free'),
  NebaChartPoint(x: 29, y: 6.8, z: 620, label: 'Starter'),
  NebaChartPoint(x: 48, y: 8.1, z: 1450, label: 'Team'),
  NebaChartPoint(x: 71, y: 9.4, z: 2900, label: 'Business'),
  NebaChartPoint(x: 96, y: 11.2, z: 4100, label: 'Enterprise'),
];

class ScatterChartBubble extends StatelessWidget {
  const ScatterChartBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Revenue by plan'),
      subtitle: Text('Seats against weekly sessions'),
      child: NebaScatterChart(
        label: 'Revenue by plan, against seats and weekly sessions',
        xAxis: NebaChartAxis(label: 'Seats'),
        yAxis: NebaChartAxis(label: 'Sessions per week'),
        maxRadius: 26,
        // Each point's `label` names its plan, so the tooltip says which
        // bubble it is rather than repeating the y already on the axis.
        series: <NebaChartSeries>[NebaChartSeries(name: 'Plan', data: _plans)],
      ),
    );
  }
}
