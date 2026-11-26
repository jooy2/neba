import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridSpacing extends StatelessWidget {
  const GridSpacing({super.key});

  Widget _cell(String label) {
    return NebaBox(
      size: NebaSize.sm,
      child: Center(child: Text(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: <Widget>[
        // One number sets both gutters. Fractions are allowed.
        for (final double spacing in <double>[0, 1.5, 4])
          NebaGridContainer(
            spacing: spacing,
            padded: false,
            children: <Widget>[
              for (int cell = 0; cell < 4; cell++)
                NebaGrid(span: const NebaGridSpan.columns(3), child: _cell('spacing $spacing')),
            ],
          ),
        // Or one per axis: tight columns, generous rows.
        NebaGridContainer(
          columnSpacing: 1,
          rowSpacing: 6,
          padded: false,
          children: <Widget>[
            for (int cell = 0; cell < 6; cell++)
              NebaGrid(span: const NebaGridSpan.columns(4), child: _cell('1 / 6')),
          ],
        ),
      ],
    );
  }
}
