import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AgentStepsSize extends StatelessWidget {
  const AgentStepsSize({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          for (final NebaSize size in <NebaSize>[
            NebaSize.xs,
            NebaSize.sm,
            NebaSize.md,
            NebaSize.lg,
          ])
            NebaAgentSteps(
              size: size,
              density: NebaDensity.compact,
              children: <Widget>[
                NebaAgentStep(
                  title: Text('Planned at ${size.name}'),
                  duration: const Duration(milliseconds: 120),
                ),
                const NebaAgentStep(
                  title: Text('Searched the documentation'),
                  status: NebaRunStatus.running,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
