import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridColumns extends StatelessWidget {
  const GridColumns({super.key});

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
        // Twelve does not divide by five. Fifteen does.
        NebaGridContainer(
          columns: 15,
          padded: false,
          children: <Widget>[
            for (int cell = 0; cell < 5; cell++)
              NebaGrid(span: const NebaGridSpan.columns(3), child: _cell('3 / 15')),
          ],
        ),
        // A finer grid for a layout that needs seven-eighths of a row.
        NebaGridContainer(
          columns: 24,
          padded: false,
          children: <Widget>[
            NebaGrid(span: const NebaGridSpan.columns(21), child: _cell('21 / 24')),
            NebaGrid(span: const NebaGridSpan.columns(3), child: _cell('3')),
          ],
        ),
      ],
    );
  }
}
