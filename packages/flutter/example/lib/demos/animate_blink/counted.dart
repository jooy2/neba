import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateBlinkCounted extends StatefulWidget {
  const AnimateBlinkCounted({super.key});

  @override
  State<AnimateBlinkCounted> createState() => _AnimateBlinkCountedState();
}

class _AnimateBlinkCountedState extends State<AnimateBlinkCounted> {
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
          child: const Text('Draw attention'),
        ),
        NebaAnimateBlink(
          key: ValueKey<int>(_run),
          repeat: 3,
          duration: const Duration(milliseconds: 500),
          min: 0.2,
          child: const NebaTypography(
            'Payment overdue',
            level: NebaTypographyLevel.h4,
            color: NebaColor.danger,
          ),
        ),
      ],
    );
  }
}
