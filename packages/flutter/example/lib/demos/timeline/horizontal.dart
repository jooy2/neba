import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimelineHorizontal extends StatelessWidget {
  const TimelineHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: const NebaTimeline(
        orientation: NebaOrientation.horizontal,
        active: 1,
        density: NebaDensity.compact,
        children: <Widget>[
          NebaTimelineItem(bullet: Text('1'), title: Text('Cart'), meta: Text('3 items')),
          NebaTimelineItem(bullet: Text('2'), title: Text('Delivery'), meta: Text('Address')),
          NebaTimelineItem(bullet: Text('3'), title: Text('Payment'), meta: Text('Card')),
          NebaTimelineItem(bullet: Text('4'), title: Text('Done')),
        ],
      ),
    );
  }
}
