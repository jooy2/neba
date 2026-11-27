import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The legend is interactive by default: press an entry to hide its series,
/// and the others keep the colour they had. `hidden` starts one off.
class LineChartLegend extends StatelessWidget {
  const LineChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Tickets by priority'),
      child: NebaLineChart(
        label: 'Tickets by priority and month',
        categories: <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        legend: NebaChartLegend(side: NebaSide.right, align: NebaAlign.start),
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Urgent', data: <num>[12, 18, 9, 14, 8, 11]),
          NebaChartSeries(name: 'High', data: <num>[48, 52, 41, 60, 55, 49]),
          NebaChartSeries(name: 'Normal', data: <num>[190, 204, 176, 221, 208, 194]),
          NebaChartSeries(name: 'Low', data: <num>[88, 71, 94, 66, 79, 84], hidden: true),
        ],
      ),
    );
  }
}
