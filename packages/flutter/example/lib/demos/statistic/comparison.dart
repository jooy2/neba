import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `betterWhen` is the whole reason the change can be trusted. Both cards
/// below went up; only one of them is good news, and the colour has to say
/// which.
class StatisticComparison extends StatelessWidget {
  const StatisticComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaStatistic(
            label: Text('Signups'),
            value: 3120,
            previousValue: 2740,
            caption: Text('betterWhen up (the default)'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaStatistic(
            label: Text('p95 latency'),
            value: 412,
            unit: Text('ms'),
            previousValue: 366,
            betterWhen: NebaStatisticBetterWhen.down,
            caption: Text('betterWhen down'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaStatistic(
            label: Text('Open incidents'),
            value: 7,
            previousValue: 12,
            betterWhen: NebaStatisticBetterWhen.down,
            delta: NebaStatisticDelta.absolute,
            caption: Text('delta: absolute'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaStatistic(
            label: Text('Seats used'),
            value: 188,
            previousValue: 160,
            delta: NebaStatisticDelta.both,
            caption: Text('delta: both'),
          ),
        ),
      ],
    );
  }
}
