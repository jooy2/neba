import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolCallBody extends StatelessWidget {
  const ToolCallBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          const NebaToolCall(
            name: Text('run_query'),
            status: NebaRunStatus.success,
            duration: Duration(milliseconds: 86),
            defaultOpen: true,
            args: Text('select id, name from regions where active = true'),
            result: NebaDataList(
              size: NebaSize.sm,
              dividers: true,
              children: <Widget>[
                NebaDataListItem(label: Text('Rows'), child: Text('4')),
                NebaDataListItem(label: Text('Scanned'), child: Text('1.2k')),
              ],
            ),
          ),
          NebaToolCall(
            name: const Text('write_file'),
            status: NebaRunStatus.success,
            duration: const Duration(milliseconds: 12),
            args: const NebaCodeBlock(
              size: NebaSize.sm,
              language: 'json',
              code: '{ "path": "src/index.ts", "mode": "append" }',
            ),
            result: const Text('18 bytes written'),
          ),
        ],
      ),
    );
  }
}
