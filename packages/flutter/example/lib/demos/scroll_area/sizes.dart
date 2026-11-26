import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ScrollAreaSizes extends StatelessWidget {
  const ScrollAreaSizes({super.key});

  static const List<NebaSize> sizes = <NebaSize>[NebaSize.xs, NebaSize.md, NebaSize.xl];

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          for (final NebaSize size in sizes)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: NebaBox(
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 2,
                  children: <Widget>[
                    NebaTypography(size.name, level: NebaTypographyLevel.caption),
                    NebaScrollArea(
                      size: size,
                      height: 120,
                      color: NebaColor.secondary,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: NebaFlex(
                          direction: NebaOrientation.vertical,
                          spacing: 1,
                          children: <Widget>[
                            for (int row = 1; row <= 12; row += 1) NebaTypography('Row $row'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
