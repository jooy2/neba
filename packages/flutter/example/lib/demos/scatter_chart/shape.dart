import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

List<NebaChartPoint> _cloud(int offsetX, int offsetY) {
  return <NebaChartPoint>[
    for (int index = 0; index < 8; index++)
      NebaChartPoint(
        x: offsetX + index * 9 + (index * 37) % 11,
        y: (offsetY + (index * 53) % 17 + index * 2).toDouble(),
      ),
  ];
}

/// Four series is one past what the palette separates on a plot where any two
/// marks can end up side by side, so `NebaScatterShape.auto` gives each series
/// a shape of its own from the fourth on. The legend shows the same shapes.
class ScatterChartShape extends StatelessWidget {
  const ScatterChartShape({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Latency by region'),
      subtitle: const Text('Four regions, four shapes'),
      child: NebaScatterChart(
        label: 'Latency against request rate, by region',
        xAxis: const NebaChartAxis(label: 'Requests per second'),
        yAxis: const NebaChartAxis(label: 'p95 latency (ms)'),
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'us-east', data: _cloud(10, 40)),
          NebaChartSeries(name: 'eu-west', data: _cloud(16, 60)),
          NebaChartSeries(name: 'ap-south', data: _cloud(22, 30)),
          NebaChartSeries(name: 'sa-east', data: _cloud(28, 75)),
        ],
      ),
    );
  }
}
