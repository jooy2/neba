import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A bar that goes the other way grows down from the same zero the others grow
/// up from: the baseline is drawn where zero is, not at the bottom of the plot.
///
/// A point may override its series' colour, which is what marks the two months
/// that lost ground without spending a second series on them.
class BarChartNegative extends StatelessWidget {
  const BarChartNegative({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Net seat change'),
      subtitle: Text('Added minus removed'),
      child: NebaBarChart(
        label: 'Net seat change by month',
        categories: <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
        valueLabels: NebaChartValueLabels.all,
        series: <NebaChartSeries>[
          NebaChartSeries(
            name: 'Net seats',
            data: <Object>[
              124,
              88,
              NebaChartPoint(y: -46, color: NebaColor.danger),
              72,
              140,
              NebaChartPoint(y: -18, color: NebaColor.danger),
              206,
            ],
          ),
        ],
      ),
    );
  }
}
