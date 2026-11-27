import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BadgeSizes extends StatelessWidget {
  const BadgeSizes({super.key});

  @override
  Widget build(BuildContext context) {
    Widget button(NebaSize size) => NebaButton(
      onPressed: () {},
      size: size,
      variant: NebaVariant.outline,
      color: NebaColor.secondary,
      child: Text(size.name),
    );

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 6,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaBadge.count(count: 12, size: size, child: button(size)),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 6,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaBadge(dot: true, size: size, color: NebaColor.success, child: button(size)),
          ],
        ),
      ],
    );
  }
}
