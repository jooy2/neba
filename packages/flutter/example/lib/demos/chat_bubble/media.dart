import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChatBubbleMedia extends StatelessWidget {
  const ChatBubbleMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          NebaChatBubble(
            name: Text('Farah'),
            time: Text('11:20'),
            media: Image(
              image: AssetImage('assets/samples/photos/curved-wood-reading-nook.jpg'),
              semanticLabel: 'The reading nook, lit from one side',
              fit: BoxFit.cover,
            ),
            child: Text('The nook is in. Photograph from this morning.'),
          ),
          NebaChatBubble(
            side: NebaChatBubbleSide.end,
            variant: NebaVariant.solid,
            status: NebaChatBubbleStatus.delivered,
            media: Image(
              image: AssetImage('assets/samples/photos/greenhouse-fern-shadows.jpg'),
              semanticLabel: 'Ferns throwing shadows across a glasshouse wall',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
