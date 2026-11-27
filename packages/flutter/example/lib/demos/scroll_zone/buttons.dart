import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _people = <String>[
  'Anya Sol',
  'Farah Wells',
  'Helen Voss',
  'Joon Mercer',
  'Lucas Adebayo',
  'Nadia Rowan',
  'Noa Marin',
  'Sam Arden',
  'Theo Quinn',
  'Victor Saye',
];

List<Widget> _avatars() {
  return <Widget>[
    for (final String name in _people)
      NebaAvatar(
        name: name,
        image: AssetImage('assets/samples/people/${name.toLowerCase().replaceAll(' ', '-')}.jpg'),
        size: NebaSize.lg,
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

class ScrollZoneButtons extends StatelessWidget {
  const ScrollZoneButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 6,
      children: <Widget>[
        _Case(
          caption: 'buttons="always"',
          child: NebaScrollZone(
            label: 'Always',
            buttons: NebaScrollZoneButtons.always,
            spacing: 3,
            children: _avatars(),
          ),
        ),
        _Case(
          caption: 'buttons="none" · snap',
          child: NebaScrollZone(
            label: 'None',
            buttons: NebaScrollZoneButtons.none,
            snap: true,
            spacing: 3,
            children: _avatars(),
          ),
        ),
      ],
    );
  }
}
