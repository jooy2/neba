import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final List<Object> _days = <Object>[for (int day = 1; day <= 30; day++) '$day'];
const List<num> _spend = <num>[
  180,
  210,
  195,
  240,
  265,
  230,
  205,
  260,
  288,
  301,
  275,
  254,
  310,
  342,
  366,
  338,
  315,
  359,
  388,
  402,
  377,
  351,
  396,
  421,
  448,
  430,
  405,
  452,
  481,
  512,
];

/// One series, so there is no legend: the card's title already says what is
/// plotted, and a box with one swatch in it would only restate it.
class AreaChartSingle extends StatelessWidget {
  const AreaChartSingle({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Daily spend'),
      subtitle: const Text('This month, cumulative by day'),
      child: NebaAreaChart(
        label: 'Daily spend this month',
        categories: _days,
        curve: NebaChartCurve.smooth,
        format: _dollars,
        series: const <NebaChartSeries>[
          NebaChartSeries(name: 'Spend', data: _spend, color: NebaColor.success),
        ],
        xAxis: const NebaChartAxis(label: 'Day of month'),
      ),
    );
  }
}

/// Whole dollars, as `{ style: 'currency', currency: 'USD',
/// maximumFractionDigits: 0 }` writes these.
String _dollars(num value) => '\$${value.round()}';
