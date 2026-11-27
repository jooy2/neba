import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<Object> _hours = <Object>['00', '04', '08', '12', '16', '20'];
const List<num> _rate = <num>[12, 9, 34, 62, 48, 21];

/// The same six readings, three ways. `step` is the honest one for a value
/// that was set rather than measured: a plan tier, a rate limit, a thermostat.
class LineChartCurve extends StatelessWidget {
  const LineChartCurve({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        for (final NebaChartCurve curve in NebaChartCurve.values)
          NebaGrid(
            span: NebaGridSpan.columns(wide ? 4 : 12),
            child: NebaCard(
              title: Text('curve="${curve.name}"'),
              size: NebaSize.sm,
              child: NebaLineChart(
                label: 'Requests per second, ${curve.name}',
                size: NebaSize.sm,
                height: 140,
                curve: curve,
                categories: _hours,
                series: const <NebaChartSeries>[NebaChartSeries(name: 'Requests/s', data: _rate)],
              ),
            ),
          ),
      ],
    );
  }
}
