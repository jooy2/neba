import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

typedef _Region = ({String region, String mrr, List<num> trend});

const List<_Region> _rows = <_Region>[
  (region: 'Americas', mrr: r'$412K', trend: <num>[31, 34, 33, 38, 41, 39, 44, 48]),
  (region: 'EMEA', mrr: r'$298K', trend: <num>[28, 27, 30, 29, 31, 30, 33, 34]),
  (region: 'APAC', mrr: r'$186K', trend: <num>[11, 14, 13, 18, 17, 22, 26, 29]),
  (region: 'LATAM', mrr: r'$74K', trend: <num>[12, 11, 10, 11, 9, 8, 9, 7]),
];

/// The shape a sparkline is usually reached for: one strip per row, in a
/// column of its own. All four are drawn on the same `min` and `max`, without
/// which the bottom row's decline would fill its cell exactly as fully as the
/// top row's climb fills that one.
class SparklineShapes extends StatelessWidget {
  const SparklineShapes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: const Text('MRR by region'),
      child: NebaTable<_Region>(
        variant: NebaVariant.text,
        headers: <NebaTableColumn<_Region>>[
          NebaTableColumn<_Region>(
            key: 'region',
            label: const Text('Region'),
            builder: (BuildContext context, _Region row, int index) => Text(row.region),
          ),
          NebaTableColumn<_Region>(
            key: 'mrr',
            label: const Text('MRR'),
            align: NebaAlign.end,
            builder: (BuildContext context, _Region row, int index) => Text(row.mrr),
          ),
          NebaTableColumn<_Region>(
            key: 'trend',
            label: const Text('Eight weeks'),
            width: 140,
            builder: (BuildContext context, _Region row, int index) => NebaSparkline(
              data: row.trend,
              shape: NebaSparklineShape.area,
              size: NebaSize.sm,
              min: 0,
              max: 60,
              label: '${row.region} trend',
            ),
          ),
        ],
        items: _rows,
      ),
    );
  }
}
