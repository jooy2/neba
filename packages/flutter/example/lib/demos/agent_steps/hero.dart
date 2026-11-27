import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AgentStepsHero extends StatelessWidget {
  const AgentStepsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaAgentSteps(
        running: true,
        runningTitle: Text('Writing the answer'),
        children: <Widget>[
          NebaAgentStep(title: Text('Read the request'), duration: Duration(milliseconds: 120)),
          NebaAgentStep(
            title: Text('Searched the documentation'),
            meta: Text('4 hits'),
            duration: Duration(milliseconds: 412),
            child: NebaToolCall(
              size: NebaSize.sm,
              variant: NebaVariant.text,
              name: Text('search_docs'),
              status: NebaRunStatus.success,
              duration: Duration(milliseconds: 412),
              args: Text('{ "query": "responsive slots" }'),
              result: Text('design/breakpoints, internal/responsive.ts'),
            ),
          ),
          NebaAgentStep(
            title: Text('Opened two files'),
            meta: Text('src/internal/responsive.ts'),
            duration: Duration(milliseconds: 86),
          ),
        ],
      ),
    );
  }
}
