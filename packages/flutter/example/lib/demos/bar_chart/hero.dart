import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BarChartHero extends StatelessWidget {
  const BarChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Deploys per team'),
      subtitle: Text('Last quarter'),
      child: NebaBarChart(
        label: 'Deploys per team, last quarter',
        categories: <Object>['Platform', 'Payments', 'Growth', 'Mobile', 'Data'],
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Deploys', data: <num>[318, 264, 197, 152, 88]),
        ],
        valueLabels: NebaChartValueLabels.all,
      ),
    );
  }
}
