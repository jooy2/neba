import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The two widths a column count cannot reach: `auto` is as wide as what is in
/// the cell, and `grow` is that plus whatever the row has left over.
class GridAutoGrow extends StatelessWidget {
  const GridAutoGrow({super.key});

  @override
  Widget build(BuildContext context) {
    // The contents' width on a phone, a third of the row from 768 pixels up.
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        NebaGridContainer(
          spacing: 2,
          padded: false,
          alignItems: NebaAlignItems.center,
          wrap: false,
          children: <Widget>[
            const NebaGrid(
              span: NebaGridSpan.auto,
              child: NebaAvatar(name: 'Rhea Patel', size: NebaSize.sm),
            ),
            const NebaGrid(
              span: NebaGridSpan.grow,
              child: NebaTypography('Rhea Patel opened a pull request', lines: 1),
            ),
            const NebaGrid(
              span: NebaGridSpan.auto,
              child: NebaChip(size: NebaSize.sm, color: NebaColor.success, child: Text('Ready')),
            ),
            NebaGrid(
              span: NebaGridSpan.auto,
              child: NebaButton(
                onPressed: () {},
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: const Text('Review'),
              ),
            ),
          ],
        ),
        NebaGridContainer(
          spacing: 2,
          padded: false,
          children: <Widget>[
            NebaGrid(
              span: wide ? const NebaGridSpan.columns(4) : NebaGridSpan.auto,
              child: const NebaBox(
                size: NebaSize.sm,
                child: Text('auto, then 4', textAlign: TextAlign.center),
              ),
            ),
            NebaGrid(
              span: wide ? const NebaGridSpan.columns(8) : NebaGridSpan.grow,
              child: const NebaBox(
                size: NebaSize.sm,
                child: Text('grow, then 8', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
