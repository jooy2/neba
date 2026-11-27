import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _go() {}

class NavigationMenuHeader extends StatelessWidget {
  const NavigationMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaHeader(
      position: NebaPosition.static,
      brand: const <Widget>[
        NebaAppLogo(name: 'Neba', image: AssetImage('assets/128x128.png'), size: NebaSize.sm),
      ],
      actions: <Widget>[
        NebaButton(
          onPressed: _go,
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Sign in'),
        ),
      ],
      children: <Widget>[
        // The words wrap onto a second line rather than run into the action.
        Flexible(
          child: NebaNavigationMenu(
            size: NebaSize.sm,
            semanticLabel: 'Main',
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Product'),
                children: <Widget>[
                  NebaNavigationMenuLink(
                    href: Uri.parse('#analytics'),
                    onPressed: _go,
                    title: const Text('Analytics'),
                    description: const Text('Every number.'),
                  ),
                  NebaNavigationMenuLink(
                    href: Uri.parse('#pipelines'),
                    onPressed: _go,
                    title: const Text('Pipelines'),
                    description: const Text('Build and ship.'),
                  ),
                ],
              ),
              NebaNavigationMenuItem(
                label: const Text('Docs'),
                href: Uri.parse('#docs'),
                onPressed: _go,
              ),
              NebaNavigationMenuItem(
                label: const Text('Pricing'),
                href: Uri.parse('#pricing'),
                onPressed: _go,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
