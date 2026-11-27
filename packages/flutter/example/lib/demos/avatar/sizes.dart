import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AvatarSizes extends StatelessWidget {
  const AvatarSizes({super.key});

  @override
  Widget build(BuildContext context) {
    const AssetImage anya = AssetImage('assets/samples/people/anya-sol.jpg');

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaAvatar(size: size, image: anya, name: 'Anya Sol'),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaAvatar(size: size, name: 'Anya Sol', color: NebaColor.info),
          ],
        ),
        // An avatar is on the control ladder, so it lines up with the button
        // beside it.
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaFlex(
                spacing: 2,
                alignItems: NebaAlignItems.center,
                children: <Widget>[
                  NebaAvatar(size: size, name: 'Anya Sol'),
                  NebaButton(
                    onPressed: () {},
                    size: size,
                    variant: NebaVariant.outline,
                    color: NebaColor.secondary,
                    child: Text(size.name),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
