import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

/// Percentage points against target: a value whose middle means something.
const List<NebaChartSeries> _againstTarget = <NebaChartSeries>[
  NebaChartSeries(name: 'EMEA', data: <num>[-12, -6, -2, 3, 8, 11, 6, 14]),
  NebaChartSeries(name: 'APAC', data: <num>[4, 9, 12, 7, -3, -8, -14, -5]),
  NebaChartSeries(name: 'Americas', data: <num>[-2, 1, 0, 2, 5, 4, 9, 12]),
];

/// A sign on every number but zero, which is the middle of the scale.
String _signed(num value) => value > 0 ? '+${value.round()}' : '${value.round()}';

class HeatmapChartDiverging extends StatelessWidget {
  const HeatmapChartDiverging({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Against target'),
      subtitle: Text('Percentage points'),
      child: NebaHeatmapChart(
        label: 'Revenue against target, by region and month',
        categories: _months,
        series: _againstTarget,
        scale: NebaHeatmapScale.diverging,
        valueLabels: NebaChartValueLabels.all,
        format: _signed,
      ),
    );
  }
}
