import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

List<Widget> _strip() {
  return <Widget>[
    for (int number = 1; number <= 14; number += 1)
      SizedBox(
        width: 96,
        child: NebaBox(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: Text('$number', textAlign: TextAlign.center),
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

class ScrollZoneModes extends StatelessWidget {
  const ScrollZoneModes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        _Case(
          caption: 'mode="item" · step=2',
          child: NebaScrollZone(
            label: 'One item at a time',
            step: 2,
            buttons: NebaScrollZoneButtons.always,
            children: _strip(),
          ),
        ),
        _Case(
          caption: 'mode="page"',
          child: NebaScrollZone(
            label: 'A page at a time',
            mode: NebaScrollZoneMode.page,
            buttons: NebaScrollZoneButtons.always,
            children: _strip(),
          ),
        ),
        _Case(
          caption: 'mode="hold" · speed=600',
          child: NebaScrollZone(
            label: 'Hold to scroll',
            mode: NebaScrollZoneMode.hold,
            speed: 600,
            buttons: NebaScrollZoneButtons.always,
            children: _strip(),
          ),
        ),
      ],
    );
  }
}
