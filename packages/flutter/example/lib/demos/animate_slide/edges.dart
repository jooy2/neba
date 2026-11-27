import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSide> _edges = <NebaSide>[
  NebaSide.top,
  NebaSide.right,
  NebaSide.bottom,
  NebaSide.left,
];

class AnimateSlideEdges extends StatefulWidget {
  const AnimateSlideEdges({super.key});

  @override
  State<AnimateSlideEdges> createState() => _AnimateSlideEdgesState();
}

class _AnimateSlideEdgesState extends State<AnimateSlideEdges> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _run += 1),
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Play again'),
        ),
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.center,
          justifyContent: NebaJustifyContent.center,
          children: <Widget>[
            for (final NebaSide edge in _edges)
              ClipRect(
                key: ValueKey<NebaSide>(edge),
                child: NebaAnimateSlide(
                  key: ValueKey<String>('${edge.name}-$_run'),
                  from: edge,
                  duration: const Duration(milliseconds: 700),
                  child: NebaBox(
                    size: NebaSize.sm,
                    child: NebaTypography('from ${edge.name}', level: NebaTypographyLevel.caption),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
