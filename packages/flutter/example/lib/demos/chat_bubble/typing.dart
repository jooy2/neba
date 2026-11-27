import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubbleTyping extends StatefulWidget {
  const ChatBubbleTyping({super.key});

  @override
  State<ChatBubbleTyping> createState() => _ChatBubbleTypingState();
}

class _ChatBubbleTypingState extends State<ChatBubbleTyping> {
  bool _typing = true;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // A message that never arrives is a demo of half the prop.
    _timer = Timer.periodic(
      const Duration(milliseconds: 2600),
      (Timer timer) => setState(() => _typing = !_typing),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaChatBubble(
        avatar: const NebaAvatar(
          image: AssetImage('assets/samples/people/farah-wells.jpg'),
          name: 'Farah Wells',
          size: NebaSize.sm,
        ),
        name: const Text('Farah'),
        typing: _typing,
        child: const Text('Found it — the alias was pointing at the old path.'),
      ),
    );
  }
}
