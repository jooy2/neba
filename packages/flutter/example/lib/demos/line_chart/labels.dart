import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `valueLabels: last` names where each series ended up and leaves the rest to
/// the axis. `gradient` fades each line from a paler step of its own hue, so
/// the recent end is the loud one.
class LineChartLabels extends StatelessWidget {
  const LineChartLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Revenue by region'),
      subtitle: Text('Thousands, this year'),
      child: NebaLineChart(
        label: 'Revenue by region and quarter',
        categories: <Object>['Q1', 'Q2', 'Q3', 'Q4'],
        valueLabels: NebaChartValueLabels.last,
        gradient: true,
        markers: NebaChartMarkers.all,
        format: _dollars,
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Americas', data: <num>[312, 344, 391, 428]),
          NebaChartSeries(name: 'EMEA', data: <num>[208, 244, 231, 297]),
          NebaChartSeries(name: 'APAC', data: <num>[141, 172, 209, 264]),
        ],
      ),
    );
  }
}

/// Whole dollars, as `{ style: 'currency', currency: 'USD',
/// maximumFractionDigits: 0 }` writes these.
String _dollars(num value) => '\$${value.round()}';
