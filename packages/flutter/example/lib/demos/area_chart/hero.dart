import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AreaChartHero extends StatelessWidget {
  const AreaChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Storage used'),
      subtitle: Text('Gigabytes, by tier'),
      child: NebaAreaChart(
        label: 'Storage used by tier and month',
        categories: <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
        stacked: NebaChartStacking.on,
        curve: NebaChartCurve.smooth,
        format: _whole,
        series: <NebaChartSeries>[
          NebaChartSeries(name: 'Hot', data: <num>[120, 138, 149, 162, 171, 188, 204, 226]),
          NebaChartSeries(name: 'Warm', data: <num>[340, 352, 361, 388, 402, 419, 440, 462]),
          NebaChartSeries(name: 'Archive', data: <num>[610, 648, 690, 742, 801, 866, 940, 1024]),
        ],
      ),
    );
  }
}

/// A whole number with its thousands grouped, as `{ maximumFractionDigits: 0 }`
/// writes it.
String _whole(num value) {
  final String digits = value.round().abs().toString();
  final StringBuffer grouped = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      grouped.write(',');
    }

    grouped.write(digits[index]);
  }

  return '${value < 0 ? '-' : ''}$grouped';
}
