import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DataListOrientation extends StatelessWidget {
  const DataListOrientation({super.key});

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
          for (final NebaOrientation orientation in NebaOrientation.values)
            NebaGrid(
              span: half,
              child: NebaBox(
                child: NebaDataList(
                  orientation: orientation,
                  children: const <Widget>[
                    NebaDataListItem(label: Text('Plan'), child: Text('Team')),
                    NebaDataListItem(label: Text('Seats'), child: Text('12 of 20')),
                    NebaDataListItem(label: Text('Renews'), child: Text('1 April 2026')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
