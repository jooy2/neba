import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AvatarHero extends StatelessWidget {
  const AvatarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaAvatar(
          image: AssetImage('assets/samples/people/nadia-rowan.jpg'),
          name: 'Nadia Rowan',
          size: NebaSize.lg,
        ),
        NebaAvatar(name: 'Sam Park', color: NebaColor.success, size: NebaSize.lg),
        NebaAvatar(
          name: '홍길동',
          variant: NebaVariant.solid,
          color: NebaColor.info,
          size: NebaSize.lg,
        ),
        NebaAvatar(
          shape: NebaAvatarShape.square,
          variant: NebaVariant.outline,
          color: NebaColor.warning,
          size: NebaSize.lg,
          child: Text('N'),
        ),
        NebaBadge(
          color: NebaColor.success,
          overlap: NebaBadgeOverlap.circle,
          semanticLabel: 'Online',
          child: NebaAvatar(
            image: AssetImage('assets/samples/people/joon-mercer.jpg'),
            name: 'Joon Mercer',
            size: NebaSize.lg,
          ),
        ),
        NebaAvatar(size: NebaSize.lg, color: NebaColor.secondary),
      ],
    );
  }
}
