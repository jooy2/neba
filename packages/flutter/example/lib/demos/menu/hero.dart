import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenuHero extends StatelessWidget {
  const MenuHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaMenu(
      trigger: NebaButton(
        onPressed: () {},
        variant: NebaVariant.outline,
        color: NebaColor.secondary,
        child: const Text('Actions'),
      ),
      children: const <Widget>[
        NebaMenuItem(shortcut: Text('⌘E'), child: Text('Rename')),
        NebaMenuItem(shortcut: Text('⌘D'), child: Text('Duplicate')),
        NebaMenuSubmenu(
          label: Text('Move to'),
          children: <Widget>[
            NebaMenuItem(child: Text('Archive')),
            NebaMenuItem(child: Text('Templates')),
            NebaMenuSubmenu(
              label: Text('Team'),
              children: <Widget>[
                NebaMenuItem(child: Text('Design')),
                NebaMenuItem(child: Text('Platform')),
              ],
            ),
          ],
        ),
        NebaMenuSeparator(),
        NebaMenuItem(color: NebaColor.danger, shortcut: Text('⌫'), child: Text('Delete')),
      ],
    );
  }
}
