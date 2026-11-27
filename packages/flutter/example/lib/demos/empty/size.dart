import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptySize extends StatelessWidget {
  const EmptySize({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaEmpty(variant: NebaVariant.outline, size: NebaSize.sm, title: Text('sm')),
        NebaEmpty(variant: NebaVariant.outline, size: NebaSize.md, title: Text('md')),
        NebaEmpty(variant: NebaVariant.outline, size: NebaSize.lg, title: Text('lg')),
        NebaEmpty(
          variant: NebaVariant.outline,
          size: NebaSize.lg,
          density: NebaDensity.compact,
          title: Text('lg, compact'),
        ),
      ],
    );
  }
}
