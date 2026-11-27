import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CollapsibleVariants extends StatelessWidget {
  const CollapsibleVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          NebaCollapsible(
            variant: NebaVariant.solid,
            title: Text('solid'),
            defaultOpen: true,
            child: NebaTypography('A filled sheet, for the fold a screen is about.'),
          ),
          NebaCollapsible(
            variant: NebaVariant.outline,
            title: Text('outline'),
            child: NebaTypography('A hairline around frosted acrylic. The default.'),
          ),
          NebaCollapsible(
            variant: NebaVariant.text,
            title: Text('text'),
            child: NebaTypography('No sheet at all, for a fold inside running prose or a Card.'),
          ),
        ],
      ),
    );
  }
}
