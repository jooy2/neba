import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubbleSides extends StatelessWidget {
  const ChatBubbleSides({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          NebaChatBubble(child: Text('side: start, the default — someone else')),
          NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.solid,
            child: Text('side: end with variant: solid — you'),
          ),
          NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.text,
            child: Text('side: end on its own, if a filled column is not the house style'),
          ),
        ],
      ),
    );
  }
}
