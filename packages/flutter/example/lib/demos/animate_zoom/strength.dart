import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateZoomStrength extends StatefulWidget {
  const AnimateZoomStrength({super.key});

  @override
  State<AnimateZoomStrength> createState() => _AnimateZoomStrengthState();
}

class _AnimateZoomStrengthState extends State<AnimateZoomStrength> {
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
            for (final double from in const <double>[0.1, 0.4, 1.8])
              NebaAnimateZoom(
                key: ValueKey<String>('$from-$_run'),
                from: from,
                duration: const Duration(milliseconds: 700),
                child: NebaBox(
                  size: NebaSize.sm,
                  child: NebaTypography('from $from', level: NebaTypographyLevel.caption),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
