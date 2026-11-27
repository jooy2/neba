import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubbleStatus extends StatelessWidget {
  const ChatBubbleStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final NebaChatBubbleStatus status in NebaChatBubbleStatus.values)
            NebaChatBubble(
              side: NebaChatBubbleSide.end,
              variant: NebaVariant.solid,
              status: status,
              child: Text(status.name),
            ),
        ],
      ),
    );
  }
}
