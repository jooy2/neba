import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<double> _sweeps = <double>[180, 240, 300, 360];

class GaugeChartSweep extends StatelessWidget {
  const GaugeChartSweep({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan span = NebaGridSpan.columns(wide ? 3 : 6);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          for (final double sweep in _sweeps)
            NebaGrid(
              span: span,
              child: NebaGaugeChart(
                variant: NebaVariant.outline,
                size: NebaSize.sm,
                label: '${sweep.round()} degrees',
                caption: Text('${sweep.round()}°'),
                value: 64,
                sweep: sweep,
              ),
            ),
        ],
      ),
    );
  }
}
