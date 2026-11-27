import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GaugeChartTicks extends StatelessWidget {
  const GaugeChartTicks({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          NebaGrid(
            span: half,
            child: const NebaGaugeChart(
              variant: NebaVariant.outline,
              label: 'Without marks',
              caption: Text('no ticks'),
              value: 7.4,
              max: 12,
              sweep: 270,
              format: _tenths,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaGaugeChart(
              variant: NebaVariant.outline,
              label: 'With marks',
              caption: Text('ticks = 7'),
              value: 7.4,
              max: 12,
              sweep: 270,
              ticks: 7,
              thickness: 0.14,
              format: _tenths,
            ),
          ),
        ],
      ),
    );
  }
}

/// A number to one decimal place at most, as `{ maximumFractionDigits: 1 }`
/// writes it.
String _tenths(num value) {
  final double rounded = (value * 10).round() / 10;

  return rounded == rounded.roundToDouble() ? '${rounded.round()}' : '$rounded';
}
