import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolCallHero extends StatelessWidget {
  const ToolCallHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          NebaToolCall(
            name: Text('search_docs'),
            status: NebaRunStatus.success,
            duration: Duration(milliseconds: 412),
            args: Text('{\n  "query": "acrylic surface",\n  "limit": 5\n}'),
            result: Text('{\n  "hits": 4,\n  "top": "design-language"\n}'),
          ),
          NebaToolCall(
            name: Text('read_file'),
            status: NebaRunStatus.running,
            meta: Text('src/styles.css'),
          ),
          NebaToolCall(
            name: Text('deploy'),
            status: NebaRunStatus.error,
            duration: Duration(milliseconds: 1840),
            args: Text('{\n  "environment": "production"\n}'),
            error: Text('No such environment: production'),
          ),
        ],
      ),
    );
  }
}
