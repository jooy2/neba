import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ScrollAreaFade extends StatelessWidget {
  const ScrollAreaFade({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        children: <Widget>[
          for (final bool fade in <bool>[false, true])
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 6 : 12),
              child: NebaBox(
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 2,
                  children: <Widget>[
                    NebaTypography(fade ? 'fade' : 'no fade', level: NebaTypographyLevel.caption),
                    NebaScrollArea(
                      height: 140,
                      fade: fade,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: NebaFlex(
                          direction: NebaOrientation.vertical,
                          spacing: 1,
                          children: <Widget>[
                            for (int line = 1; line <= 14; line += 1) NebaTypography('Line $line'),
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
