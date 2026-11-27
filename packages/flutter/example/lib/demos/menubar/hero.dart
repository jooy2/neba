import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenubarHero extends StatelessWidget {
  const MenubarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaToolbar(
        size: NebaSize.sm,
        children: <Widget>[
          NebaMenubar(
            size: NebaSize.sm,
            semanticLabel: 'Application',
            children: <Widget>[
              NebaMenubarMenu(
                label: Text('File'),
                children: <Widget>[
                  NebaMenuItem(shortcut: Text('⌘N'), child: Text('New file')),
                  NebaMenuItem(shortcut: Text('⌘O'), child: Text('Open…')),
                  NebaMenuSubmenu(
                    label: Text('Open recent'),
                    children: <Widget>[
                      NebaMenuItem(child: Text('neba/src/index.ts')),
                      NebaMenuItem(child: Text('neba/README.md')),
                    ],
                  ),
                  NebaMenuSeparator(),
                  NebaMenuItem(shortcut: Text('⌘S'), child: Text('Save')),
                  NebaMenuItem(color: NebaColor.danger, child: Text('Close window')),
                ],
              ),
              NebaMenubarMenu(
                label: Text('Edit'),
                children: <Widget>[
                  NebaMenuItem(shortcut: Text('⌘Z'), child: Text('Undo')),
                  NebaMenuItem(shortcut: Text('⇧⌘Z'), child: Text('Redo')),
                  NebaMenuSeparator(),
                  NebaMenuItem(shortcut: Text('⌘X'), child: Text('Cut')),
                  NebaMenuItem(shortcut: Text('⌘C'), child: Text('Copy')),
                ],
              ),
              NebaMenubarMenu(
                label: Text('View'),
                children: <Widget>[
                  NebaMenuGroup(
                    label: Text('Panels'),
                    children: <Widget>[
                      NebaMenuCheckboxItem(defaultChecked: true, child: Text('Sidebar')),
                      NebaMenuCheckboxItem(child: Text('Terminal')),
                    ],
                  ),
                  NebaMenuSeparator(),
                  NebaMenuRadioGroup<String>(
                    defaultValue: 'comfortable',
                    children: <Widget>[
                      NebaMenuRadioItem<String>(value: 'compact', child: Text('Compact')),
                      NebaMenuRadioItem<String>(value: 'comfortable', child: Text('Comfortable')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
