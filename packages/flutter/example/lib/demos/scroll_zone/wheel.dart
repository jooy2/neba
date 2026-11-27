import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

List<Widget> _strip() {
  return <Widget>[
    for (int number = 1; number <= 14; number += 1)
      SizedBox(
        width: 112,
        child: NebaBox(
          size: NebaSize.sm,
          variant: NebaVariant.solid,
          child: Text('Item $number', textAlign: TextAlign.center),
        ),
      ),
  ];
}

/// A caption over a zone, as each case is labelled.
class _Case extends StatelessWidget {
  const _Case({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        NebaTypography(caption, level: NebaTypographyLevel.caption, color: NebaColor.secondary),
        child,
      ],
    );
  }
}

class ScrollZoneWheel extends StatelessWidget {
  const ScrollZoneWheel({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        _Case(
          caption: "The wheel is the page's",
          child: NebaScrollZone(label: 'Without the wheel', children: _strip()),
        ),
        _Case(
          caption: 'wheel — roll over the strip; the page waits until the pointer leaves',
          child: NebaScrollZone(label: 'With the wheel', wheel: true, children: _strip()),
        ),
      ],
    );
  }
}
