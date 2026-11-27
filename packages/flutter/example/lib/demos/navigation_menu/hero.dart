import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _go() {}

class NavigationMenuHero extends StatelessWidget {
  const NavigationMenuHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaNavigationMenu(
      semanticLabel: 'Main',
      children: <Widget>[
        NebaNavigationMenuItem(
          label: const Text('Product'),
          columns: 2,
          children: <Widget>[
            NebaNavigationMenuLink(
              href: Uri.parse('#analytics'),
              onPressed: _go,
              title: const Text('Analytics'),
              description: const Text('Every number the product produces.'),
            ),
            NebaNavigationMenuLink(
              href: Uri.parse('#pipelines'),
              onPressed: _go,
              title: const Text('Pipelines'),
              description: const Text('Builds, tests and deploys.'),
            ),
            NebaNavigationMenuLink(
              href: Uri.parse('#insights'),
              onPressed: _go,
              title: const Text('Insights'),
              description: const Text('What the numbers mean.'),
            ),
            NebaNavigationMenuLink(
              href: Uri.parse('#alerts'),
              onPressed: _go,
              title: const Text('Alerts'),
              description: const Text('When to look at them.'),
            ),
          ],
        ),
        NebaNavigationMenuItem(
          label: const Text('Developers'),
          children: <Widget>[
            NebaNavigationMenuLink(
              href: Uri.parse('#docs'),
              onPressed: _go,
              title: const Text('Documentation'),
              description: const Text('Every component.'),
            ),
            NebaNavigationMenuLink(
              href: Uri.parse('#api'),
              onPressed: _go,
              title: const Text('API reference'),
            ),
            NebaNavigationMenuLink(
              href: Uri.parse('#changelog'),
              onPressed: _go,
              title: const Text('Changelog'),
            ),
          ],
        ),
        NebaNavigationMenuItem(
          label: const Text('Pricing'),
          href: Uri.parse('#pricing'),
          onPressed: _go,
        ),
        NebaNavigationMenuItem(label: const Text('Blog'), href: Uri.parse('#blog'), onPressed: _go),
      ],
    );
  }
}
