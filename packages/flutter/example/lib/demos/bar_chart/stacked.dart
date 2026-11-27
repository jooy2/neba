import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const List<NebaChartSeries> _series = <NebaChartSeries>[
  NebaChartSeries(name: 'New', data: <num>[180, 204, 176, 231, 248, 262]),
  NebaChartSeries(name: 'Renewed', data: <num>[420, 438, 461, 452, 489, 514]),
  NebaChartSeries(name: 'Churned', data: <num>[64, 71, 58, 82, 69, 55]),
];

class BarChartStacked extends StatelessWidget {
  const BarChartStacked({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: third,
          child: const _Subscriptions(
            title: 'Grouped',
            subtitle: 'Which series is bigger',
            label: 'Subscriptions, grouped',
            stacked: NebaChartStacking.off,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Subscriptions(
            title: 'stacked',
            subtitle: 'What the total is made of',
            label: 'Subscriptions, stacked',
            stacked: NebaChartStacking.on,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Subscriptions(
            title: 'stacked="full"',
            subtitle: 'The mix',
            label: 'Subscriptions, as a share',
            stacked: NebaChartStacking.full,
          ),
        ),
      ],
    );
  }
}

class _Subscriptions extends StatelessWidget {
  const _Subscriptions({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.stacked,
  });

  final String title;
  final String subtitle;
  final String label;
  final NebaChartStacking stacked;

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: Text(title),
      subtitle: Text(subtitle),
      size: NebaSize.sm,
      child: NebaBarChart(
        label: label,
        size: NebaSize.sm,
        height: 180,
        categories: _months,
        series: _series,
        stacked: stacked,
        legend: false,
      ),
    );
  }
}
