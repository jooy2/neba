import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyTitle extends StatelessWidget {
  const EmptyTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: third,
          child: const NebaEmpty(variant: NebaVariant.outline),
        ),
        NebaGrid(
          span: third,
          child: const NebaEmpty(
            variant: NebaVariant.outline,
            title: Text('No invoices'),
            child: Text('Nothing has been billed to this account yet.'),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaEmpty(
            variant: NebaVariant.outline,
            showTitle: false,
            child: Text('Nothing matched that filter.'),
          ),
        ),
      ],
    );
  }
}
