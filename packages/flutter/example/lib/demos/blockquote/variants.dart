import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BlockquoteVariants extends StatelessWidget {
  const BlockquoteVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          NebaBlockquote(
            variant: NebaVariant.text,
            child: Text(
              'The rule in the margin and nothing else, which is what a quote in running prose '
              'should be.',
            ),
          ),
          NebaBlockquote(
            variant: NebaVariant.outline,
            child: Text(
              'A hairline sheet under the words, for a quote that has to be found on a busy page.',
            ),
          ),
          NebaBlockquote(
            variant: NebaVariant.solid,
            child: Text(
              'The frosted sheet, for a pull quote that is the point of the section rather than '
              'an aside inside it.',
            ),
          ),
        ],
      ),
    );
  }
}
