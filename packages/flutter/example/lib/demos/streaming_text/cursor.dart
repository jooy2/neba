import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class StreamingTextCursor extends StatelessWidget {
  const StreamingTextCursor({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 15, height: 1.7),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            NebaStreamingText(streaming: true, child: Text('The block at the end is the default')),
            NebaStreamingText(
              streaming: true,
              cursor: Padding(
                padding: EdgeInsetsDirectional.only(start: 4),
                child: NebaProgressCircular(size: NebaSize.xs),
              ),
              child: Text('A ring instead, for an answer that is waiting on a tool'),
            ),
            NebaStreamingText(
              streaming: true,
              showCursor: false,
              child: Text(
                'And none at all, where something else already says the answer is not finished',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
