import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ContextWindowHero extends StatelessWidget {
  const ContextWindowHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaContextWindow(
        max: 200000,
        tokens: NebaContextTokens(input: 94200, output: 12400, reasoning: 8100, cached: 61000),
        cost: 0.42,
        thresholds: <NebaThreshold>[
          NebaThreshold(from: 140000, color: NebaColor.warning),
          NebaThreshold(from: 180000, color: NebaColor.danger),
        ],
      ),
    );
  }
}
