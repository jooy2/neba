import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String?, int)> _plan = <(String, String?, int)>[
  ('Read the request', null, 120),
  ('Searched the documentation', '4 hits', 412),
  ('Opened two files', 'src/internal/responsive.ts', 86),
  ('Wrote the answer', null, 1840),
];

class AgentStepsGrowing extends StatefulWidget {
  const AgentStepsGrowing({super.key});

  @override
  State<AgentStepsGrowing> createState() => _AgentStepsGrowingState();
}

class _AgentStepsGrowingState extends State<AgentStepsGrowing> {
  int _done = 0;
  Timer? _timer;

  bool get _growing => _done < _plan.length;

  @override
  void initState() {
    super.initState();
    _next();
  }

  void _next() {
    _timer?.cancel();

    if (!_growing) {
      return;
    }

    _timer = Timer(const Duration(milliseconds: 1400), () {
      setState(() => _done += 1);
      _next();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaAgentSteps(
            running: _growing,
            children: <Widget>[
              for (final (String title, String? meta, int ms) in _plan.take(_done))
                NebaAgentStep(
                  key: ValueKey<String>(title),
                  title: Text(title),
                  meta: meta == null ? null : Text(meta),
                  duration: Duration(milliseconds: ms),
                ),
            ],
          ),
          NebaButton(
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            onPressed: () {
              setState(() => _done = 0);
              _next();
            },
            child: const Text('Run it again'),
          ),
        ],
      ),
    );
  }
}
