import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class GridNested extends StatelessWidget {
  const GridNested({super.key});

  Widget _cell(String label) {
    return NebaBox(
      size: NebaSize.xs,
      variant: NebaVariant.solid,
      child: Center(child: Text(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A grid inside a grid is a NebaGridContainer inside a NebaGrid. The inner
    // grid divides the width its cell was given, so a span of 6 in here is
    // half of a half.
    return NebaGridContainer(
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: const NebaGridSpan.columns(6),
          child: NebaBox(
            padded: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: NebaGridContainer(
                spacing: 1,
                padded: false,
                children: <Widget>[
                  NebaGrid(span: const NebaGridSpan.columns(6), child: _cell('6')),
                  NebaGrid(span: const NebaGridSpan.columns(6), child: _cell('6')),
                  NebaGrid(span: const NebaGridSpan.columns(12), child: _cell('12')),
                ],
              ),
            ),
          ),
        ),
        const NebaGrid(
          span: NebaGridSpan.columns(6),
          child: NebaBox(child: Text('The other half, undivided')),
        ),
      ],
    );
  }
}
