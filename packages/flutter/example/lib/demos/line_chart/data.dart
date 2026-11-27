import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The three ways one series can be written. They draw the same chart: pick
/// whichever matches the shape the data already has.
class LineChartData extends StatelessWidget {
  const LineChartData({super.key});

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
          child: const NebaCard(
            title: Text('Bare numbers'),
            size: NebaSize.sm,
            child: NebaLineChart(
              label: 'Bare numbers',
              size: NebaSize.sm,
              height: 140,
              categories: <Object>['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
              series: <NebaChartSeries>[
                NebaChartSeries(name: 'Orders', data: <num>[24, 31, 28, 39, 44]),
              ],
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaCard(
            title: Text('Points with an x'),
            size: NebaSize.sm,
            child: NebaLineChart(
              label: 'Points carrying their own x',
              size: NebaSize.sm,
              height: 140,
              series: <NebaChartSeries>[
                NebaChartSeries(
                  name: 'Orders',
                  data: <NebaChartPoint>[
                    NebaChartPoint(x: 'Mon', y: 24),
                    NebaChartPoint(x: 'Tue', y: 31),
                    NebaChartPoint(x: 'Wed', y: 28),
                    NebaChartPoint(x: 'Thu', y: 39),
                    NebaChartPoint(x: 'Fri', y: 44),
                  ],
                ),
              ],
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: NebaCard(
            title: const Text('Dates'),
            size: NebaSize.sm,
            child: NebaLineChart(
              label: 'Points on dates',
              size: NebaSize.sm,
              height: 140,
              series: <NebaChartSeries>[
                NebaChartSeries(
                  name: 'Orders',
                  data: <NebaChartPoint>[
                    NebaChartPoint(x: DateTime(2026, 6, 1), y: 24),
                    NebaChartPoint(x: DateTime(2026, 6, 2), y: 31),
                    NebaChartPoint(x: DateTime(2026, 6, 3), y: 28),
                    NebaChartPoint(x: DateTime(2026, 6, 4), y: 39),
                    NebaChartPoint(x: DateTime(2026, 6, 5), y: 44),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
