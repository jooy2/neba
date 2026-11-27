import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `min` is a dimming rather than a disappearance, which is what keeps the
/// word readable while it pulses.
class AnimateBlinkFloor extends StatelessWidget {
  const AnimateBlinkFloor({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final double min in const <double>[0, 0.3, 0.6])
          NebaAnimateBlink(
            min: min,
            duration: const Duration(milliseconds: 1200),
            child: NebaChip(color: NebaColor.warning, child: Text('min $min')),
          ),
      ],
    );
  }
}
