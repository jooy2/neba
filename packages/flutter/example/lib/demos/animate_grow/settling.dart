import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Above 1 it arrives oversized and settles back down onto the page.
class AnimateGrowSettling extends StatelessWidget {
  const AnimateGrowSettling({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        NebaAnimateGrow(
          from: 0.6,
          duration: Duration(milliseconds: 1400),
          repeat: double.infinity,
          alternate: true,
          child: NebaChip(child: Text('from 0.6')),
        ),
        NebaAnimateGrow(
          from: 1.3,
          duration: Duration(milliseconds: 1400),
          repeat: double.infinity,
          alternate: true,
          fade: false,
          child: NebaChip(color: NebaColor.success, child: Text('from 1.3')),
        ),
      ],
    );
  }
}
