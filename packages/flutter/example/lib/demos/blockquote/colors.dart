import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaColor> _families = <NebaColor>[
  NebaColor.primary,
  NebaColor.success,
  NebaColor.warning,
  NebaColor.danger,
];

class BlockquoteColors extends StatelessWidget {
  const BlockquoteColors({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          for (final NebaColor color in _families)
            NebaBlockquote(
              color: color,
              variant: NebaVariant.outline,
              size: NebaSize.sm,
              icon: null,
              child: const Text(
                'The sheet stays undyed whatever the family is: the colour is in the rule and '
                'the mark.',
              ),
            ),
        ],
      ),
    );
  }
}
