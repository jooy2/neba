import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridAlignment extends StatelessWidget {
  const GridAlignment({super.key});

  Widget _cell(String label, {double? height}) {
    return NebaBox(
      size: NebaSize.sm,
      child: SizedBox(
        height: height,
        child: Center(child: Text(label)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: <Widget>[
        // Three columns in a twelve-column row leave three spare.
        // justifyContent decides where the slack goes.
        for (final NebaJustifyContent justify in <NebaJustifyContent>[
          NebaJustifyContent.start,
          NebaJustifyContent.center,
          NebaJustifyContent.end,
          NebaJustifyContent.spaceBetween,
        ])
          NebaGridContainer(
            justifyContent: justify,
            padded: false,
            children: <Widget>[
              for (int cell = 0; cell < 3; cell++)
                NebaGrid(span: const NebaGridSpan.columns(3), child: _cell(justify.name)),
            ],
          ),
        // Items are as tall as their row by default; alignItems opts out, and
        // alignSelf lets one item disagree with the rest.
        NebaGridContainer(
          alignItems: NebaAlignItems.center,
          padded: false,
          children: <Widget>[
            NebaGrid(span: const NebaGridSpan.columns(4), child: _cell('tall', height: 56)),
            NebaGrid(span: const NebaGridSpan.columns(4), child: _cell('centred')),
            NebaGrid(
              span: const NebaGridSpan.columns(4),
              alignSelf: NebaAlignSelf.end,
              child: _cell('alignSelf end'),
            ),
          ],
        ),
      ],
    );
  }
}
