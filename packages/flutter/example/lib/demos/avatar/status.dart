import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AvatarStatus extends StatelessWidget {
  const AvatarStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaBadge(
          color: NebaColor.success,
          overlap: NebaBadgeOverlap.circle,
          semanticLabel: 'Online',
          child: NebaAvatar(
            size: NebaSize.xl,
            image: AssetImage('assets/samples/people/lucas-adebayo.jpg'),
            name: 'Lucas Adebayo',
          ),
        ),
        NebaBadge(
          color: NebaColor.warning,
          overlap: NebaBadgeOverlap.circle,
          semanticLabel: 'Away',
          child: NebaAvatar(size: NebaSize.xl, name: 'Sam Park', color: NebaColor.warning),
        ),
        NebaBadge(
          color: NebaColor.secondary,
          overlap: NebaBadgeOverlap.circle,
          placement: NebaCorner.bottomEnd,
          semanticLabel: 'Offline',
          child: NebaAvatar(
            size: NebaSize.xl,
            image: AssetImage('assets/samples/people/helen-voss.jpg'),
            name: 'Helen Voss',
          ),
        ),
        NebaBadge.count(
          count: 12,
          overlap: NebaBadgeOverlap.circle,
          semanticLabel: '12 unread messages',
          child: NebaAvatar(size: NebaSize.xl, name: '홍길동', color: NebaColor.info),
        ),
      ],
    );
  }
}
