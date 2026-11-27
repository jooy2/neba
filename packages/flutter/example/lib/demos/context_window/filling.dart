import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const double _max = 200000;

class ContextWindowFilling extends StatefulWidget {
  const ContextWindowFilling({super.key});

  @override
  State<ContextWindowFilling> createState() => _ContextWindowFillingState();
}

class _ContextWindowFillingState extends State<ContextWindowFilling> {
  double _used = 48000;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          NebaContextWindow(
            max: _max,
            used: _used,
            tokens: NebaContextTokens(
              input: (_used * 0.72).roundToDouble(),
              output: (_used * 0.28).roundToDouble(),
            ),
            thresholds: const <NebaThreshold>[
              NebaThreshold(from: _max * 0.7, color: NebaColor.warning),
              NebaThreshold(from: _max * 0.9, color: NebaColor.danger),
            ],
          ),
          NebaSlider(
            semanticLabel: 'Tokens used',
            max: _max,
            step: 1000,
            value: _used,
            onValueChange: (double value) => setState(() => _used = value),
          ),
        ],
      ),
    );
  }
}
