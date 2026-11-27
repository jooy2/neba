import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateRotateOrigin extends StatelessWidget {
  const AnimateRotateOrigin({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: NebaFlex(
        spacing: 8,
        alignItems: NebaAlignItems.center,
        justifyContent: NebaJustifyContent.center,
        children: <Widget>[
          NebaAnimateRotate(
            origin: Alignment.bottomLeft,
            from: -12,
            to: 12,
            duration: Duration(milliseconds: 1600),
            repeat: double.infinity,
            alternate: true,
            fade: false,
            child: NebaChip(color: NebaColor.warning, child: Text('bottomLeft')),
          ),
          NebaAnimateRotate(
            from: -12,
            to: 12,
            duration: Duration(milliseconds: 1600),
            repeat: double.infinity,
            alternate: true,
            fade: false,
            child: NebaChip(color: NebaColor.warning, child: Text('center')),
          ),
        ],
      ),
    );
  }
}
