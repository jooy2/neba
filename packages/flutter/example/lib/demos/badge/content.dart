import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BadgeContent extends StatelessWidget {
  const BadgeContent({super.key});

  @override
  Widget build(BuildContext context) {
    Widget button(String label) => NebaButton(
      onPressed: () {},
      variant: NebaVariant.outline,
      color: NebaColor.secondary,
      child: Text(label),
    );

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaBadge.count(count: 7, child: button('Seven')),
        // Past max, and the badge says so rather than growing.
        NebaBadge.count(count: 1204, child: button('Capped')),
        NebaBadge.count(count: 1204, max: 999, child: button('Higher cap')),
        // A count of nothing is not news, so it does not show up at all.
        NebaBadge.count(count: 0, child: button('Zero')),
        NebaBadge.count(
          count: 0,
          showZero: true,
          color: NebaColor.secondary,
          child: button('Zero, shown'),
        ),
        // Nothing to count, but something to report.
        NebaBadge(dot: true, color: NebaColor.danger, child: button('Dot')),
      ],
    );
  }
}
