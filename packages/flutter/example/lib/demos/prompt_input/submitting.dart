import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PromptInputSubmitting extends StatefulWidget {
  const PromptInputSubmitting({super.key});

  @override
  State<PromptInputSubmitting> createState() => _PromptInputSubmittingState();
}

class _PromptInputSubmittingState extends State<PromptInputSubmitting> {
  String _answer = '';
  bool _submitting = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _ask(String _) {
    setState(() {
      _answer = '';
      _submitting = true;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _answer = 'The send button became a stop button without moving.';
        _submitting = false;
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          NebaStreamingText(streaming: _submitting, lines: 2, child: Text(_answer)),
          NebaPromptInput(
            label: const Text('Message'),
            placeholder: 'Press send, then press stop',
            submitting: _submitting,
            onSubmit: _ask,
            onStop: _stop,
            initialValue: 'Tell me about the send button',
          ),
        ],
      ),
    );
  }
}
