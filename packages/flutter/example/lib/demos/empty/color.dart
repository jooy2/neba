import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyColor extends StatelessWidget {
  const EmptyColor({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaEmpty(
            variant: NebaVariant.outline,
            title: Text('No events'),
            child: Text('Nothing has happened in the last hour.'),
          ),
        ),
        NebaGrid(
          span: half,
          child: NebaEmpty(
            variant: NebaVariant.outline,
            color: NebaColor.danger,
            title: const Text('Could not load events'),
            actions: <Widget>[
              NebaButton(
                onPressed: () {},
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                color: NebaColor.danger,
                child: const Text('Try again'),
              ),
            ],
            child: const Text('The request timed out after 30 seconds.'),
          ),
        ),
      ],
    );
  }
}
