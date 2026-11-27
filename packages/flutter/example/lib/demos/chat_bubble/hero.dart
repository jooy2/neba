import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const AssetImage _farah = AssetImage('assets/samples/people/farah-wells.jpg');

class ChatBubbleHero extends StatelessWidget {
  const ChatBubbleHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          const NebaChatBubble(
            avatar: NebaAvatar(image: _farah, name: 'Farah Wells', size: NebaSize.sm),
            name: Text('Farah'),
            time: Text('09:41'),
            child: Text('Are we still on for the review at 3?'),
          ),
          const NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.solid,
            time: Text('09:42'),
            status: NebaChatBubbleStatus.read,
            child: Text('Yes — I pushed the branch just now.'),
          ),
          NebaChatBubble(
            avatar: const NebaAvatar(image: _farah, name: 'Farah Wells', size: NebaSize.sm),
            preview: NebaChatBubbleLinkPreview(
              url: Uri.parse('https://example.com/rfc-14'),
              onPressed: () {},
              site: const Text('example.com'),
              title: const Text('RFC 14 · Acrylic surfaces'),
              description: const Text(
                'Why a Neba surface is a sheet of cut acrylic and not a moulded key.',
              ),
            ),
            child: const Text('Read this first'),
          ),
          const NebaChatBubble(
            avatar: NebaAvatar(image: _farah, name: 'Farah Wells', size: NebaSize.sm),
            typing: true,
          ),
        ],
      ),
    );
  }
}
