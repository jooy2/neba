import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({String name, String code})> _regions = <({String name, String code})>[
  (name: 'Seoul', code: 'icn'),
  (name: 'Tokyo', code: 'nrt'),
  (name: 'Frankfurt', code: 'fra'),
];

class ListDividers extends StatelessWidget {
  const ListDividers({super.key});

  List<Widget> _rows() {
    return <Widget>[
      for (final ({String name, String code}) region in _regions)
        NebaListItem(onPressed: () {}, endIcon: Text(region.code), child: Text(region.name)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        // Tiles on a sheet.
        NebaGrid(
          span: half,
          child: NebaList(children: _rows()),
        ),
        // Ruled lines. The rows square off and the sheet gives up its inset
        // so the rules can reach both edges.
        NebaGrid(
          span: half,
          child: NebaList(dividers: true, children: _rows()),
        ),
      ],
    );
  }
}
