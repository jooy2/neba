import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _team = <String>['Anya Sol', 'Theo Quinn', 'Lucas Adebayo', 'Nadia Rowan'];

class StackHero extends StatelessWidget {
  const StackHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaStack(
      ring: true,
      max: 3,
      total: 12,
      overflow: (int hidden) => NebaAvatar(initials: '+$hidden'),
      children: <Widget>[
        for (final String name in _team)
          NebaAvatar(
            name: name,
            image: AssetImage(
              'assets/samples/people/${name.toLowerCase().replaceAll(' ', '-')}.jpg',
            ),
          ),
      ],
    );
  }
}
