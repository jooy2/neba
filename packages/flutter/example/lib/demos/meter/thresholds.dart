import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaThreshold> _thresholds = <NebaThreshold>[
  NebaThreshold(from: 70, color: NebaColor.warning),
  NebaThreshold(from: 90, color: NebaColor.danger),
];

class MeterThresholds extends StatefulWidget {
  const MeterThresholds({super.key});

  @override
  State<MeterThresholds> createState() => _MeterThresholdsState();
}

class _MeterThresholdsState extends State<MeterThresholds> {
  double _used = 45;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          NebaMeter(
            value: _used,
            label: const Text('Disk used'),
            showValue: true,
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
