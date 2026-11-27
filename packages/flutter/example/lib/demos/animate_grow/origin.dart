import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const Map<String, Alignment> _origins = <String, Alignment>{
  'center': Alignment.center,
  'topLeft': Alignment.topLeft,
  'bottomRight': Alignment.bottomRight,
  'topCenter': Alignment.topCenter,
};

class AnimateGrowOrigin extends StatefulWidget {
  const AnimateGrowOrigin({super.key});

  @override
  State<AnimateGrowOrigin> createState() => _AnimateGrowOriginState();
}

class _AnimateGrowOriginState extends State<AnimateGrowOrigin> {
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
            for (final MapEntry<String, Alignment> origin in _origins.entries)
              NebaAnimateGrow(
                key: ValueKey<String>('${origin.key}-$_run'),
                origin: origin.value,
                from: 0.2,
                duration: const Duration(milliseconds: 700),
                child: NebaBox(
                  size: NebaSize.sm,
                  child: NebaTypography(origin.key, level: NebaTypographyLevel.caption),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
