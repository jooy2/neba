import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridHero extends StatelessWidget {
  const GridHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        const NebaGrid(
          span: NebaGridSpan.columns(8),
          child: NebaBox(variant: NebaVariant.solid, child: Text('span 8 — the main column')),
        ),
        const NebaGrid(
          span: NebaGridSpan.columns(4),
          child: NebaBox(variant: NebaVariant.solid, child: Text('span 4 — the aside')),
        ),
        for (int cell = 0; cell < 4; cell++)
          const NebaGrid(
            span: NebaGridSpan.columns(3),
            child: NebaBox(child: Text('span 3')),
          ),
      ],
    );
  }
}
