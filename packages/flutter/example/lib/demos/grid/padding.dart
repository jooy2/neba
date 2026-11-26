import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridPadding extends StatelessWidget {
  const GridPadding({super.key});

  Widget _row({required bool padded}) {
    return NebaBox(
      padded: false,
      child: NebaGridContainer(
        padded: padded,
        children: <Widget>[
          for (int cell = 0; cell < 3; cell++)
            NebaGrid(
              span: const NebaGridSpan.columns(4),
              child: NebaBox(
                size: NebaSize.sm,
                variant: NebaVariant.solid,
                child: Center(child: Text(padded ? 'padded' : 'padded: false')),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      // The default pads on the size scale; off, for a grid already inside
      // something that pads.
      children: <Widget>[_row(padded: true), _row(padded: false)],
    );
  }
}
