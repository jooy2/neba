import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShowTransparent extends StatelessWidget {
  const ShowTransparent({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

    return NebaGridContainer(
      spacing: 2,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 8 : 12),
          child: const NebaBox(variant: NebaVariant.solid, child: Text('The article')),
        ),
        // Still a grid item: a shown NebaShow builds its child where it
        // stands, with nothing between the container and the cell.
        const NebaShow(
          above: NebaBreakpoint.md,
          child: NebaGrid(
            span: NebaGridSpan.columns(4),
            child: NebaBox(child: Text('The aside, from md up')),
          ),
        ),
      ],
    );
  }
}
