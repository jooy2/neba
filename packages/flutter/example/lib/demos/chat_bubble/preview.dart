import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubblePreview extends StatelessWidget {
  const ChatBubblePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          NebaChatBubble(
            name: const Text('Sam'),
            time: const Text('16:05'),
            preview: NebaChatBubbleLinkPreview(
              url: Uri.parse('https://example.com/acrylic'),
              onPressed: () {},
              site: const Text('example.com'),
              title: const Text('Acrylic surfaces, one year on'),
              description: const Text(
                'What survived contact with real products, what did not, '
                'and the two rules we would keep.',
              ),
              image: const AssetImage(
                'assets/samples/photos/concrete-stairway-geometric-shadows.jpg',
              ),
              newTab: true,
            ),
            child: const Text('This is the one I was talking about'),
          ),
          NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.solid,
            preview: NebaChatBubbleLinkPreview(
              url: Uri.parse('https://example.com/rfc-14'),
              onPressed: () {},
              site: const Text('example.com'),
              title: const Text('RFC 14 · Cut edges'),
            ),
          ),
        ],
      ),
    );
  }
}
