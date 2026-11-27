import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSize> _sizes = <NebaSize>[NebaSize.sm, NebaSize.md, NebaSize.lg, NebaSize.xl];

class AvatarShape extends StatelessWidget {
  const AvatarShape({super.key});

  @override
  Widget build(BuildContext context) {
    const AssetImage theo = AssetImage('assets/samples/people/theo-quinn.jpg');

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        for (final NebaAvatarShape shape in NebaAvatarShape.values)
          NebaFlex(
            wrap: true,
            spacing: 3,
            alignItems: NebaAlignItems.end,
            children: <Widget>[
              for (final NebaSize size in _sizes)
                NebaAvatar(size: size, shape: shape, image: theo, name: 'Theo Quinn'),
            ],
          ),
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in _sizes)
              NebaAvatar(
                size: size,
                shape: NebaAvatarShape.square,
                variant: NebaVariant.solid,
                color: NebaColor.secondary,
                name: 'Neba UI',
              ),
          ],
        ),
      ],
    );
  }
}
