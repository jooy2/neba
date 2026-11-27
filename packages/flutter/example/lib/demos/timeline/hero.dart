import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimelineHero extends StatelessWidget {
  const TimelineHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaTimeline(
        active: 2,
        children: <Widget>[
          NebaTimelineItem(
            title: Text('Ordered'),
            meta: Text('12 Jul'),
            child: Text('Payment taken and the order confirmed.'),
          ),
          NebaTimelineItem(
            title: Text('Packed'),
            meta: Text('13 Jul'),
            child: Text('Left the warehouse in Incheon.'),
          ),
          NebaTimelineItem(
            title: Text('In transit'),
            meta: Text('14 Jul'),
            child: Text('Out for delivery with the local carrier.'),
          ),
          NebaTimelineItem(title: Text('Delivered'), child: Text('Expected tomorrow before 6pm.')),
        ],
      ),
    );
  }
}
