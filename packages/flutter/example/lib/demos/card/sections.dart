import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CardSections extends StatelessWidget {
  const CardSections({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaCard(
        title: const Text('Title'),
        subtitle: const Text('Subtitle'),
        headerAction: NebaButton(
          onPressed: press,
          size: NebaSize.xs,
          variant: NebaVariant.text,
          color: NebaColor.secondary,
          semanticLabel: 'More',
          child: const Text('···'),
        ),
        footer: Row(
          children: <Widget>[
            NebaButton(
              onPressed: press,
              size: NebaSize.sm,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Cancel'),
            ),
            const Spacer(),
            NebaButton(onPressed: press, size: NebaSize.sm, child: const Text('Confirm')),
          ],
        ),
        child: const Text(
          'The body. A slot you do not pass is not built, so a card with only a title has no '
          'empty header sitting above it.',
        ),
      ),
    );
  }
}
