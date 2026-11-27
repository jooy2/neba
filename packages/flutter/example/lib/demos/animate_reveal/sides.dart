import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSide> _sides = <NebaSide>[
  NebaSide.left,
  NebaSide.right,
  NebaSide.top,
  NebaSide.bottom,
];

class AnimateRevealSides extends StatefulWidget {
  const AnimateRevealSides({super.key});

  @override
  State<AnimateRevealSides> createState() => _AnimateRevealSidesState();
}

class _AnimateRevealSidesState extends State<AnimateRevealSides> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _run += 1),
          variant: NebaVariant.outline,
          size: NebaSize.sm,
          child: const Text('Play again'),
        ),
        NebaGridContainer(
          key: ValueKey<int>(_run),
          spacing: 3,
          padded: false,
          children: <Widget>[
            for (int index = 0; index < _sides.length; index++)
              NebaGrid(
                span: half,
                child: NebaAnimateReveal(
                  side: _sides[index],
                  delay: Duration(milliseconds: index * 160),
                  duration: const Duration(milliseconds: 800),
                  child: NebaBox(
                    variant: NebaVariant.outline,
                    size: NebaSize.sm,
                    child: NebaTypography(
                      'side: ${_sides[index].name}',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
