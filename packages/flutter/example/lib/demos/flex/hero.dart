import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FlexHero extends StatelessWidget {
  const FlexHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      spacing: 3,
      children: <Widget>[
        Expanded(
          child: NebaBox(variant: NebaVariant.solid, child: Text('A row')),
        ),
        Expanded(
          child: NebaBox(variant: NebaVariant.solid, child: Text('with a gutter')),
        ),
        Expanded(
          child: NebaBox(variant: NebaVariant.solid, child: Text('of three')),
        ),
      ],
    );
  }
}
