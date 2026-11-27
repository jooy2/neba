import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

// Three weeks the exporter was down. Not three weeks of nothing.
const List<num?> _readings = <num?>[42, 47, 51, null, null, null, 58, 55, 62, 68];

class SparklineGaps extends StatelessWidget {
  const SparklineGaps({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaDataList(
        size: NebaSize.sm,
        children: <Widget>[
          NebaDataListItem(
            label: Text('nulls: gap'),
            child: NebaSparkline(data: _readings, label: 'Readings, broken at the gap', width: 160),
          ),
          NebaDataListItem(
            label: Text('nulls: connect'),
            child: NebaSparkline(
              data: _readings,
              nulls: NebaChartNulls.connect,
              label: 'Readings, bridged',
              width: 160,
            ),
          ),
          NebaDataListItem(
            label: Text('nulls: zero'),
            child: NebaSparkline(
              data: _readings,
              nulls: NebaChartNulls.zero,
              label: 'Readings, read as zero',
              width: 160,
            ),
          ),
        ],
      ),
    );
  }
}
