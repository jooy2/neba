import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShowHero extends StatelessWidget {
  const ShowHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        children: <Widget>[
          NebaShow(
            below: NebaBreakpoint.md,
            child: NebaBox(
              variant: NebaVariant.solid,
              color: NebaColor.secondary,
              child: NebaTypography('Narrow — under 768 pixels. Resize the window.'),
            ),
          ),
          NebaShow(
            above: NebaBreakpoint.md,
            child: NebaBox(
              variant: NebaVariant.solid,
              child: NebaTypography('Wide — 768 pixels and up. Resize the window.'),
            ),
          ),
        ],
      ),
    );
  }
}
