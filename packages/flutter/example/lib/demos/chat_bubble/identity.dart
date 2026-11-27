import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const AssetImage _sam = AssetImage('assets/samples/people/sam-arden.jpg');

class ChatBubbleIdentity extends StatelessWidget {
  const ChatBubbleIdentity({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          NebaChatBubble(
            avatar: NebaAvatar(image: _sam, name: 'Sam Arden', size: NebaSize.sm),
            name: Text('Sam Arden'),
            time: Text('14:02'),
            child: Text('Everything at once: an avatar, a name and a time.'),
          ),
          NebaChatBubble(
            avatar: NebaAvatar(image: _sam, name: 'Sam Arden', size: NebaSize.sm),
            child: Text('A follow-up in the same run keeps the avatar and drops the header.'),
          ),
          NebaChatBubble(
            time: Text('14:03'),
            child: Text('No avatar at all — the bubble takes the whole row.'),
          ),
        ],
      ),
    );
  }
}
