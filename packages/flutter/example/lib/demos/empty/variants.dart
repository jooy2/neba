import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyVariants extends StatelessWidget {
  const EmptyVariants({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        for (final NebaVariant variant in const <NebaVariant>[
          NebaVariant.text,
          NebaVariant.outline,
          NebaVariant.solid,
        ])
          NebaGrid(
            span: third,
            child: NebaEmpty(variant: variant, title: Text(variant.name)),
          ),
      ],
    );
  }
}
