import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A slice takes the palette slot its position gives it, and a point's own
/// `color` overrides that. Here the four states mean something, and a colour
/// that says "failed" is doing a different job from one that says "series
/// four", so every slice names its own.
class PieChartColors extends StatelessWidget {
  const PieChartColors({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCard(
      title: Text('Pipeline runs'),
      subtitle: Text('Last 24 hours'),
      child: NebaPieChart(
        label: 'Pipeline runs by outcome',
        shape: NebaPieShape.donut,
        legend: NebaChartLegend(side: NebaSide.right, align: NebaAlign.center),
        data: <Object>[
          NebaChartPoint(x: 'Passed', y: 1284, color: NebaColor.success),
          NebaChartPoint(x: 'Failed', y: 96, color: NebaColor.danger),
          NebaChartPoint(x: 'Cancelled', y: 41, color: NebaColor.secondary),
          NebaChartPoint(x: 'Flaky', y: 28, color: NebaColor.warning),
        ],
      ),
    );
  }
}
