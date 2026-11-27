import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<Object> _days = <Object>[for (int day = 1; day <= 14; day++) 'Jun $day'];
const List<num> _latency = <num>[
  180,
  172,
  195,
  210,
  188,
  176,
  402,
  368,
  214,
  199,
  186,
  178,
  192,
  205,
];

class LineChartReferences extends StatelessWidget {
  const LineChartReferences({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Response time'),
      subtitle: const Text('p95, milliseconds'),
      child: NebaLineChart(
        label: 'p95 response time by day',
        categories: _days,
        series: const <NebaChartSeries>[
          NebaChartSeries(name: 'p95', data: _latency, color: NebaColor.danger),
        ],
        yAxis: NebaChartAxis(min: 0, tickFormat: (Object value, int index) => '${value}ms'),
        references: const <NebaChartReference>[
          NebaChartReference(value: 250, label: 'SLA', color: NebaColor.warning),
          NebaChartReference(value: 0, to: 200, label: 'Budget'),
          NebaChartReference(
            value: 6,
            to: 7,
            axis: NebaChartReferenceAxis.category,
            label: 'Incident',
            color: NebaColor.danger,
          ),
        ],
        markers: NebaChartMarkers.all,
      ),
    );
  }
}
