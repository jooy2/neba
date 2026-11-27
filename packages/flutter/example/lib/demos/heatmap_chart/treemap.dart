import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Storage by team, grouped by department.
const List<NebaChartSeries> _storage = <NebaChartSeries>[
  NebaChartSeries(
    name: 'Platform',
    data: <NebaChartPoint>[
      NebaChartPoint(x: 'Builds', y: 4200),
      NebaChartPoint(x: 'Registry', y: 2600),
      NebaChartPoint(x: 'Logs', y: 1900),
    ],
  ),
  NebaChartSeries(
    name: 'Product',
    data: <NebaChartPoint>[
      NebaChartPoint(x: 'Assets', y: 3100),
      NebaChartPoint(x: 'Uploads', y: 1400),
      NebaChartPoint(x: 'Exports', y: 720),
    ],
  ),
  NebaChartSeries(
    name: 'Data',
    data: <NebaChartPoint>[
      NebaChartPoint(x: 'Warehouse', y: 5400),
      NebaChartPoint(x: 'Snapshots', y: 2200),
    ],
  ),
];

class HeatmapChartTreemap extends StatelessWidget {
  const HeatmapChartTreemap({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Storage by team'),
      subtitle: Text('Gigabytes'),
      child: NebaHeatmapChart(
        label: 'Storage by team',
        shape: NebaHeatmapShape.treemap,
        // Whole gigabytes, which the default writes grouped by threes.
        series: _storage,
      ),
    );
  }
}
