import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `active` describes a sequence that is going to plan. A step that failed
/// and stopped it is not something an index can say, which is what the
/// per-step `status` and `color` overrides are for.
class TimelineStatus extends StatelessWidget {
  const TimelineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaTimeline(
        active: 2,
        children: <Widget>[
          NebaTimelineItem(
            title: Text('Queued'),
            meta: Text('09:31'),
            child: Text('Picked up by the runner.'),
          ),
          NebaTimelineItem(
            title: Text('Built'),
            meta: Text('09:33'),
            connector: NebaTimelineConnector.dashed,
            child: Text('Artifacts uploaded.'),
          ),
          NebaTimelineItem(
            title: Text('Tests failed'),
            meta: Text('09:36'),
            color: NebaColor.danger,
            status: NebaTimelineStatus.current,
            child: Text('3 of 412 assertions did not pass.'),
          ),
          NebaTimelineItem(
            title: Text('Deploy'),
            status: NebaTimelineStatus.upcoming,
            child: Text('Blocked until the tests pass.'),
          ),
        ],
      ),
    );
  }
}
