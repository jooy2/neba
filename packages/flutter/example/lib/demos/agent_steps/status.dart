import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AgentStepsStatus extends StatelessWidget {
  const AgentStepsStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaAgentSteps(
        children: <Widget>[
          NebaAgentStep(
            title: Text('Read the request'),
            status: NebaRunStatus.success,
            duration: Duration(milliseconds: 120),
          ),
          NebaAgentStep(
            title: Text('Called the deploy API'),
            status: NebaRunStatus.error,
            child: Text('No such environment: production'),
          ),
          NebaAgentStep(title: Text('Retrying'), status: NebaRunStatus.running),
          NebaAgentStep(title: Text('Report the result'), status: NebaRunStatus.pending),
        ],
      ),
    );
  }
}
