import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MeterValues extends StatelessWidget {
  const MeterValues({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          const NebaMeter(value: 12, max: 20, label: Text('Members'), showValue: true),
          NebaMeter(
            value: 12,
            max: 20,
            label: const Text('Members'),
            showValue: true,
            format: (double value) => '${value.round()} GB',
          ),
          NebaMeter(
            value: 4.8,
            max: 16,
            label: const Text('Memory'),
            showValue: true,
            // At most one decimal, and none when it is a whole number.
            format: (double value) {
              final String rounded = value.toStringAsFixed(1);

              return '${rounded.endsWith('.0') ? value.round() : rounded} GB';
            },
          ),
        ],
      ),
    );
  }
}
