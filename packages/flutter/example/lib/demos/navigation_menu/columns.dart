import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _go() {}

/// A region and the name it goes by in the console.
const List<(String, String)> _regions = <(String, String)>[
  ('Seoul', 'ap-northeast-2'),
  ('Tokyo', 'ap-northeast-1'),
  ('Osaka', 'ap-northeast-3'),
  ('Frankfurt', 'eu-central-1'),
  ('Dublin', 'eu-west-1'),
  ('Virginia', 'us-east-1'),
];

class NavigationMenuColumns extends StatelessWidget {
  const NavigationMenuColumns({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaNavigationMenu(
      semanticLabel: 'Regions',
      size: NebaSize.sm,
      children: <Widget>[
        NebaNavigationMenuItem(
          label: const Text('One column'),
          children: <Widget>[
            for (final (String city, String _) in _regions.take(3))
              NebaNavigationMenuLink(
                href: Uri.parse('#${city.toLowerCase()}'),
                onPressed: _go,
                title: Text(city),
              ),
          ],
        ),
        NebaNavigationMenuItem(
          label: const Text('Three columns'),
          columns: 3,
          children: <Widget>[
            for (final (String city, String code) in _regions)
              NebaNavigationMenuLink(
                href: Uri.parse('#${city.toLowerCase()}'),
                onPressed: _go,
                title: Text(city),
                description: Text(code),
              ),
          ],
        ),
      ],
    );
  }
}
