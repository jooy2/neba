import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const List<NebaChartSeries> _series = <NebaChartSeries>[
  NebaChartSeries(name: 'Organic', data: <num>[4200, 4610, 4880, 5240, 5390, 5720]),
  NebaChartSeries(name: 'Paid', data: <num>[2100, 2480, 2310, 2760, 3020, 2880]),
  NebaChartSeries(name: 'Referral', data: <num>[980, 1040, 1190, 1120, 1310, 1440]),
];

/// The same three sources, three ways. Overlaid answers "how big is each";
/// stacked answers "how big is the total"; `full` answers "what is the mix",
/// and stops answering the first two.
class AreaChartStacked extends StatelessWidget {
  const AreaChartStacked({super.key});

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
          child: const _Sources(
            title: 'stacked={false}',
            label: 'Sessions by source, overlaid',
            stacked: NebaChartStacking.off,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Sources(
            title: 'stacked',
            label: 'Sessions by source, stacked',
            stacked: NebaChartStacking.on,
          ),
        ),
        NebaGrid(
          span: third,
          child: const _Sources(
            title: 'stacked="full"',
            label: 'Sessions by source, as a share',
            stacked: NebaChartStacking.full,
          ),
        ),
      ],
    );
  }
}

class _Sources extends StatelessWidget {
  const _Sources({required this.title, required this.label, required this.stacked});

  final String title;
  final String label;
  final NebaChartStacking stacked;

  @override
  Widget build(BuildContext context) {
    return NebaCard(
      title: Text(title),
      size: NebaSize.sm,
      child: NebaAreaChart(
        label: label,
        size: NebaSize.sm,
        height: 160,
        categories: _months,
        series: _series,
        stacked: stacked,
        legend: false,
      ),
    );
  }
}
