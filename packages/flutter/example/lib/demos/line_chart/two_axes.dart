import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<num> _revenue = <num>[182000, 196000, 214000, 208000, 231000, 246000];
const List<num> _conversion = <num>[2.4, 2.6, 2.5, 2.9, 3.1, 3.4];

class LineChartTwoAxes extends StatelessWidget {
  const LineChartTwoAxes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('Revenue and conversion'),
      subtitle: const Text('Two units, one plot'),
      child: NebaLineChart(
        label: 'Revenue and conversion rate by month',
        categories: const <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        markers: NebaChartMarkers.all,
        yAxis: const NebaChartAxis(label: 'Revenue'),
        format: _dollars,
        secondaryAxis: NebaChartAxis(
          label: 'Conversion',
          tickFormat: (Object value, int index) => '$value%',
        ),
        series: const <NebaChartSeries>[
          NebaChartSeries(name: 'Revenue', data: _revenue),
          NebaChartSeries(
            name: 'Conversion',
            data: _conversion,
            axis: NebaChartSeriesAxis.secondary,
          ),
        ],
      ),
    );
  }
}

/// Whole dollars with their thousands grouped, as `{ style: 'currency',
/// currency: 'USD', maximumFractionDigits: 0 }` writes them.
String _dollars(num value) {
  final String digits = value.round().abs().toString();
  final StringBuffer grouped = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write(',');
    }

    grouped.write(digits[index]);
  }

  return '${value < 0 ? '-' : ''}\$$grouped';
}
