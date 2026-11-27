import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateFadeMode extends StatelessWidget {
  const AnimateFadeMode({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        NebaAnimateFade(
          duration: Duration(milliseconds: 1200),
          repeat: double.infinity,
          alternate: true,
          child: NebaChip(color: NebaColor.success, child: Text('enter')),
        ),
        NebaAnimateFade(
          mode: NebaAnimateMode.exit,
          duration: Duration(milliseconds: 1200),
          repeat: double.infinity,
          alternate: true,
          child: NebaChip(color: NebaColor.danger, child: Text('exit')),
        ),
      ],
    );
  }
}
