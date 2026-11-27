import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class StatisticHero extends StatelessWidget {
  const StatisticHero({super.key});

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
            label: Text('Monthly recurring revenue'),
            value: 48210,
            prefix: Text(r'$'),
            previousValue: 42800,
            caption: Text('vs. last month'),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaStatistic(
            label: Text('Active workspaces'),
            value: 1284,
            previousValue: 1284,
            caption: Text('vs. last month'),
          ),
        ),
        NebaGrid(
          span: third,
          child: NebaStatistic(
            label: const Text('Churn'),
            value: 0.041,
            format: (num value) => _percent(value),
            previousValue: 0.036,
            betterWhen: NebaStatisticBetterWhen.down,
            caption: const Text('vs. last month'),
          ),
        ),
      ],
    );
  }
}

/// A share as a percentage with one digit after the point, as
/// `{ style: 'percent', maximumFractionDigits: 1 }` writes it.
String _percent(num value) {
  final String fixed = (value * 100).toStringAsFixed(1);

  return '${fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed}%';
}
