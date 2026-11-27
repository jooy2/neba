import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateFadeTiming extends StatelessWidget {
  const AnimateFadeTiming({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final int delay in const <int>[0, 200, 400, 600])
          NebaAnimateFade(
            delay: Duration(milliseconds: delay),
            duration: const Duration(milliseconds: 500),
            child: NebaChip(child: Text('${delay}ms')),
          ),
      ],
    );
  }
}
