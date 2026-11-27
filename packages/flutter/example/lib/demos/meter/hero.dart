import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MeterHero extends StatelessWidget {
  const MeterHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          NebaMeter(value: 38, label: Text('Storage'), showValue: true),
          NebaMeter(
            value: 82,
            label: Text('Seats'),
            showValue: true,
            thresholds: <NebaThreshold>[
              NebaThreshold(from: 70, color: NebaColor.warning),
              NebaThreshold(from: 90, color: NebaColor.danger),
            ],
          ),
          NebaMeter(value: 96, label: Text('API quota'), showValue: true, color: NebaColor.danger),
        ],
      ),
    );
  }
}
