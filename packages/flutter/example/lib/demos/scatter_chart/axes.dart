import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaChartPoint> _readings = <NebaChartPoint>[
  NebaChartPoint(x: -8, y: 412),
  NebaChartPoint(x: -3, y: 388),
  NebaChartPoint(x: 2, y: 341),
  NebaChartPoint(x: 6, y: 310),
  NebaChartPoint(x: 11, y: 264),
  NebaChartPoint(x: 15, y: 238),
  NebaChartPoint(x: 19, y: 201),
  NebaChartPoint(x: 24, y: 176),
  NebaChartPoint(x: 28, y: 168),
  NebaChartPoint(x: 31, y: 155),
];

/// Neither axis is dragged down to zero: a scatter is about where the cloud
/// sits, and a scale that starts at zero on both axes would push all of it
/// into one corner. `min` and `max` pin an axis when a comparison needs a
/// fixed frame.
class ScatterChartAxes extends StatelessWidget {
  const ScatterChartAxes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Heating load'),
      subtitle: const Text('Against outdoor temperature'),
      child: NebaScatterChart(
        label: 'Heating load against outdoor temperature',
        xAxis: NebaChartAxis(
          label: 'Outdoor °C',
          min: -10,
          max: 35,
          tickFormat: (Object value, int index) => '$value°',
        ),
        yAxis: const NebaChartAxis(label: 'kWh per day', grid: false),
        pointRadius: 5,
        series: const <NebaChartSeries>[
          NebaChartSeries(name: 'Readings', data: _readings, color: NebaColor.warning),
        ],
      ),
    );
  }
}
