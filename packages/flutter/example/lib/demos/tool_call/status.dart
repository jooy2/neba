import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolCallStatus extends StatefulWidget {
  const ToolCallStatus({super.key});

  @override
  State<ToolCallStatus> createState() => _ToolCallStatusState();
}

class _ToolCallStatusState extends State<ToolCallStatus> {
  NebaRunStatus _status = NebaRunStatus.pending;
  Timer? _timer;

  void _show(NebaRunStatus status) {
    _timer?.cancel();
    setState(() => _status = status);

    // The clock is the point of `running`: with no `duration` the header
    // counts its own seconds, and stops the moment one is handed to it.
    if (status == NebaRunStatus.running) {
      _timer = Timer(
        const Duration(milliseconds: 3200),
        () => setState(() => _status = NebaRunStatus.success),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NebaRunStatus status = _status;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaToolCall(
            name: const Text('index_repository'),
            status: status,
            duration: status == NebaRunStatus.success ? const Duration(milliseconds: 3180) : null,
            result: status == NebaRunStatus.success ? const Text('1,204 files indexed') : null,
            error: status == NebaRunStatus.error ? const Text('Repository is not readable') : null,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final NebaRunStatus name in NebaRunStatus.values)
                NebaButton(
                  size: NebaSize.sm,
                  variant: name == status ? NebaVariant.solid : NebaVariant.outline,
                  onPressed: () => _show(name),
                  child: Text(name.name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
