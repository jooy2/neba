import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaThreshold> _thresholds = <NebaThreshold>[
  NebaThreshold(from: 70, color: NebaColor.warning),
  NebaThreshold(from: 90, color: NebaColor.danger),
];

class GaugeChartThresholds extends StatefulWidget {
  const GaugeChartThresholds({super.key});

  @override
  State<GaugeChartThresholds> createState() => _GaugeChartThresholdsState();
}

class _GaugeChartThresholdsState extends State<GaugeChartThresholds> {
  double _used = 45;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          NebaGaugeChart(
            variant: NebaVariant.outline,
            label: 'Disk used',
            caption: const Text('Disk used'),
            value: _used,
            thresholds: _thresholds,
          ),
          NebaSlider(
            semanticLabel: 'Disk used',
            value: _used,
            onValueChange: (double value) => setState(() => _used = value),
          ),
        ],
      ),
    );
  }
}
