import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<Object> _days = <Object>[for (int day = 1; day <= 14; day++) 'Jun $day'];
const List<num> _uptime = <num>[
  99.94,
  99.97,
  99.99,
  99.98,
  99.72,
  99.88,
  99.96,
  99.99,
  99.99,
  99.95,
  99.91,
  99.97,
  99.99,
  99.98,
];

/// A line chart crops its scale to the data, which is what makes a series that
/// lives between 99.7 and 100 legible at all. `yAxis` is where that gets
/// overridden: a floor, a ceiling, how many ticks, and how each one is
/// written.
class LineChartAxes extends StatelessWidget {
  const LineChartAxes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Availability'),
      subtitle: const Text('Rolling fourteen days'),
      child: NebaLineChart(
        label: 'Availability by day',
        categories: _days,
        series: const <NebaChartSeries>[NebaChartSeries(name: 'Uptime', data: _uptime)],
        yAxis: NebaChartAxis(
          min: 99.5,
          max: 100,
          tickCount: 5,
          tickFormat: (Object value, int index) => '$value%',
        ),
        xAxis: const NebaChartAxis(label: 'June'),
        markers: NebaChartMarkers.all,
      ),
    );
  }
}
