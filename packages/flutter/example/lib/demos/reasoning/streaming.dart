import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ReasoningStreaming extends StatefulWidget {
  const ReasoningStreaming({super.key});

  @override
  State<ReasoningStreaming> createState() => _ReasoningStreamingState();
}

class _ReasoningStreamingState extends State<ReasoningStreaming> {
  bool _streaming = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaReasoning(
            streaming: _streaming,
            child: const Text(
              'The panel opened when the stream started and folds itself away when it stops. '
              'What is left is a line saying it happened and how long it took.',
            ),
          ),
          NebaButton(
            size: NebaSize.sm,
            variant: NebaVariant.outline,
            onPressed: () => setState(() => _streaming = !_streaming),
            child: Text(_streaming ? 'Stop the stream' : 'Start the stream'),
          ),
        ],
      ),
    );
  }
}
