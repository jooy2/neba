import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A short distance is a nudge; the default is the widget's own size, which
/// starts it exactly out of frame.
class AnimateSlideDistance extends StatelessWidget {
  const AnimateSlideDistance({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        NebaAnimateSlide(
          distance: 8,
          duration: Duration(milliseconds: 1200),
          repeat: double.infinity,
          alternate: true,
          fade: false,
          child: NebaChip(child: Text('8 px')),
        ),
        NebaAnimateSlide(
          distance: 64,
          duration: Duration(milliseconds: 1200),
          repeat: double.infinity,
          alternate: true,
          child: NebaChip(color: NebaColor.info, child: Text('64 px')),
        ),
      ],
    );
  }
}
