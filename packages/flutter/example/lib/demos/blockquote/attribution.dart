import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BlockquoteAttribution extends StatelessWidget {
  const BlockquoteAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    const Text quote = Text('Make it work, make it right, make it fast.');

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          // Nothing at all.
          NebaBlockquote(variant: NebaVariant.outline, child: quote),
          // A person.
          NebaBlockquote(variant: NebaVariant.outline, author: Text('Kent Beck'), child: quote),
          // A person and the work it came from.
          NebaBlockquote(
            variant: NebaVariant.outline,
            author: Text('Kent Beck'),
            source: Text('Extreme Programming Explained'),
            child: quote,
          ),
        ],
      ),
    );
  }
}
