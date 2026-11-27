import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _hours = <Object>[
  '00',
  '02',
  '04',
  '06',
  '08',
  '10',
  '12',
  '14',
  '16',
  '18',
  '20',
  '22',
];

/// Sessions by hour, one row per weekday.
const List<NebaChartSeries> _traffic = <NebaChartSeries>[
  NebaChartSeries(name: 'Mon', data: <num>[4, 2, 1, 6, 24, 41, 38, 44, 51, 33, 18, 9]),
  NebaChartSeries(name: 'Tue', data: <num>[3, 2, 2, 7, 27, 45, 40, 48, 55, 36, 20, 10]),
  NebaChartSeries(name: 'Wed', data: <num>[3, 1, 1, 8, 29, 47, 43, 51, 58, 38, 21, 11]),
  NebaChartSeries(name: 'Thu', data: <num>[4, 2, 2, 8, 28, 46, 41, 49, 56, 40, 23, 12]),
  NebaChartSeries(name: 'Fri', data: <num>[5, 3, 2, 7, 25, 42, 37, 44, 48, 34, 26, 16]),
  NebaChartSeries(name: 'Sat', data: <num>[9, 6, 3, 4, 11, 18, 22, 26, 29, 27, 24, 17]),
  NebaChartSeries(name: 'Sun', data: <num>[8, 5, 2, 3, 9, 15, 19, 23, 25, 24, 21, 13]),
];

class HeatmapChartHero extends StatelessWidget {
  const HeatmapChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Sessions by hour'),
      subtitle: Text('Thousands, last four weeks'),
      child: NebaHeatmapChart(
        label: 'Sessions by hour and weekday',
        categories: _hours,
        series: _traffic,
      ),
    );
  }
}
