import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DataListDividers extends StatelessWidget {
  const DataListDividers({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          for (final bool dividers in <bool>[false, true])
            NebaGrid(
              span: half,
              child: NebaBox(
                child: NebaDataList(
                  dividers: dividers,
                  density: NebaDensity.compact,
                  size: NebaSize.sm,
                  children: const <Widget>[
                    NebaDataListItem(label: Text('Runtime'), child: Text('Node 26')),
                    NebaDataListItem(label: Text('Framework'), child: Text('Next.js 16')),
                    NebaDataListItem(label: Text('Bundle'), child: Text('215.3 kB')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
