import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _weeks = <Object>['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];

const List<NebaChartSeries> _retention = <NebaChartSeries>[
  NebaChartSeries(name: 'Jan', data: <num>[100, 68, 54, 47, 43, 41]),
  NebaChartSeries(name: 'Feb', data: <num>[100, 71, 58, 51, 48, 45]),
  NebaChartSeries(name: 'Mar', data: <num>[100, 74, 62, 56, 52, 50]),
  NebaChartSeries(name: 'Apr', data: <num?>[100, 77, 66, 60, 57, null]),
];

/// The share of a cohort still active, which is already a percentage.
String _percent(num value) => '${value.round()}%';

class HeatmapChartLabels extends StatelessWidget {
  const HeatmapChartLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('valueLabels'),
            size: NebaSize.sm,
            child: NebaHeatmapChart(
              label: 'Retention by cohort and week',
              size: NebaSize.sm,
              categories: _weeks,
              series: _retention,
              valueLabels: NebaChartValueLabels.all,
              format: _percent,
              min: 0,
              max: 100,
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('min · max'),
            size: NebaSize.sm,
            child: NebaHeatmapChart(
              label: 'Retention by cohort and week, scaled to the data',
              size: NebaSize.sm,
              categories: _weeks,
              series: _retention,
            ),
          ),
        ),
      ],
    );
  }
}
