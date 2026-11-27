import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _go() {}

class NavigationMenuOrientation extends StatelessWidget {
  const NavigationMenuOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      child: NebaNavigationMenu(
        orientation: NebaOrientation.vertical,
        size: NebaSize.sm,
        semanticLabel: 'Sections',
        children: <Widget>[
          NebaNavigationMenuItem(
            label: const Text('Overview'),
            href: Uri.parse('#overview'),
            onPressed: _go,
          ),
          NebaNavigationMenuItem(
            label: const Text('Deploys'),
            children: <Widget>[
              NebaNavigationMenuLink(
                href: Uri.parse('#production'),
                onPressed: _go,
                title: const Text('Production'),
              ),
              NebaNavigationMenuLink(
                href: Uri.parse('#preview'),
                onPressed: _go,
                title: const Text('Preview'),
              ),
            ],
          ),
          NebaNavigationMenuItem(
            label: const Text('Settings'),
            children: <Widget>[
              NebaNavigationMenuLink(
                href: Uri.parse('#general'),
                onPressed: _go,
                title: const Text('General'),
              ),
              NebaNavigationMenuLink(
                href: Uri.parse('#members'),
                onPressed: _go,
                title: const Text('Members'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
