import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridOffset extends StatelessWidget {
  const GridOffset({super.key});

  Widget _cell(String label) {
    return NebaBox(
      size: NebaSize.sm,
      child: Center(child: Text(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: <Widget>[
        // The middle third: four columns in, four columns wide.
        NebaGridContainer(
          padded: false,
          children: <Widget>[
            NebaGrid(
              span: const NebaGridSpan.columns(4),
              offset: 4,
              child: _cell('span 4, offset 4'),
            ),
          ],
        ),
        // Pushed to the end of the row.
        NebaGridContainer(
          padded: false,
          children: <Widget>[
            NebaGrid(
              span: const NebaGridSpan.columns(3),
              offset: 9,
              child: _cell('span 3, offset 9'),
            ),
          ],
        ),
        // An offset is space pushed in ahead of the item, so the gap here is
        // between the two cells rather than measured from the start of the row.
        NebaGridContainer(
          padded: false,
          children: <Widget>[
            NebaGrid(span: const NebaGridSpan.columns(3), child: _cell('span 3')),
            NebaGrid(
              span: const NebaGridSpan.columns(3),
              offset: 3,
              child: _cell('span 3, offset 3'),
            ),
          ],
        ),
      ],
    );
  }
}
