import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class LineChartHero extends StatelessWidget {
  const LineChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Weekly active users'),
      subtitle: Text('Last eight months'),
      child: NebaLineChart(
        label: 'Weekly active users by month',
        categories: <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Web', data: <num>[1820, 1960, 2140, 2080, 2390, 2620, 2810, 3040]),
          NebaChartSeries(
            name: 'Mobile',
            data: <num>[940, 1120, 1310, 1580, 1720, 2010, 2380, 2740],
          ),
          NebaChartSeries(name: 'Desktop app', data: <num>[610, 640, 620, 700, 690, 740, 810, 860]),
        ],
      ),
    );
  }
}
