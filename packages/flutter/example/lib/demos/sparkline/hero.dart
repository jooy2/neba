import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<num> _signups = <num>[18, 22, 19, 27, 24, 31, 29, 36, 34, 41, 38, 47];
const List<num> _latency = <num>[188, 194, 181, 212, 240, 226, 208, 196, 231, 258, 244, 219];
const List<num> _errors = <num>[4, 2, 6, 3, 1, 5, 2, 0, 3, 1, 2, 1];

class SparklineHero extends StatelessWidget {
  const SparklineHero({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: third,
          child: const NebaStatistic(
            label: Text('Signups'),
            value: 47,
            previousValue: 38,
            caption: Text('Last 12 weeks'),
            child: NebaSparkline(data: _signups, label: 'Signups, last 12 weeks', endDot: true),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaStatistic(
            label: Text('p95 latency'),
            value: 219,
            unit: Text('ms'),
            previousValue: 244,
            betterWhen: NebaStatisticBetterWhen.down,
            caption: Text('Last 12 weeks'),
            child: NebaSparkline(
              data: _latency,
              label: 'p95 latency, last 12 weeks',
              color: NebaColor.info,
              endDot: true,
            ),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaStatistic(
            label: Text('Errors'),
            value: 1,
            previousValue: 2,
            betterWhen: NebaStatisticBetterWhen.down,
            caption: Text('Last 12 weeks'),
            child: NebaSparkline(
              data: _errors,
              shape: NebaSparklineShape.bar,
              color: NebaColor.danger,
              label: 'Errors, last 12 weeks',
            ),
          ),
        ),
      ],
    );
  }
}
