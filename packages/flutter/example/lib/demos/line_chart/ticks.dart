import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _stages = <Object>[
  'Signed up',
  'Email verified',
  'Team invited',
  'Repo connected',
  'PR opened',
  'PR merged',
  'Deployed',
];
const List<num> _reached = <num>[4820, 4110, 2640, 2190, 1480, 1120, 640];

class LineChartTicks extends StatelessWidget {
  const LineChartTicks({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('Flat'),
            subtitle: Text('Cut to the slot, and two of the seven kept'),
            size: NebaSize.sm,
            child: NebaLineChart(
              label: 'Accounts reaching each onboarding stage',
              categories: _stages,
              series: <NebaChartSeries>[NebaChartSeries(name: 'Accounts', data: _reached)],
              markers: NebaChartMarkers.all,
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaCard(
            title: Text('tickAngle: -45'),
            subtitle: Text('All seven, and none of them cut'),
            size: NebaSize.sm,
            child: NebaLineChart(
              label: 'Accounts reaching each onboarding stage, turned axis',
              categories: _stages,
              series: <NebaChartSeries>[NebaChartSeries(name: 'Accounts', data: _reached)],
              xAxis: NebaChartAxis(tickAngle: -45),
              markers: NebaChartMarkers.all,
            ),
          ),
        ),
      ],
    );
  }
}
