import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GaugeChartHero extends StatelessWidget {
  const GaugeChartHero({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          NebaGrid(
            span: third,
            child: NebaGaugeChart(
              variant: NebaVariant.outline,
              label: 'CPU',
              caption: const Text('CPU'),
              value: 0.38,
              format: _percent,
              max: 1,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaGaugeChart(
              variant: NebaVariant.outline,
              label: 'Memory',
              caption: Text('Memory'),
              value: 82,
              thresholds: <NebaThreshold>[
                NebaThreshold(from: 70, color: NebaColor.warning),
                NebaThreshold(from: 90, color: NebaColor.danger),
              ],
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaGaugeChart(
              variant: NebaVariant.outline,
              label: 'Disk',
              caption: Text('Disk'),
              value: 96,
              color: NebaColor.danger,
            ),
          ),
        ],
      ),
    );
  }
}

/// A share written as a whole percentage, as `{ style: 'percent' }` writes it.
String _percent(num value) => '${(value * 100).round()}%';
