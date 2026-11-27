import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Nesting is unlimited because a submenu's children are menu rows, and one of
/// those rows can be another submenu. A reach from a row into its open
/// submenu across the rows below it leaves the submenu open.
class MenuNested extends StatelessWidget {
  const MenuNested({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaMenu(
      trigger: NebaButton(
        onPressed: () {},
        variant: NebaVariant.outline,
        color: NebaColor.secondary,
        child: const Text('Insert'),
      ),
      children: const <Widget>[
        NebaMenuItem(child: Text('Text block')),
        NebaMenuSubmenu(
          label: Text('Media'),
          children: <Widget>[
            NebaMenuItem(child: Text('Image')),
            NebaMenuItem(child: Text('Video')),
            NebaMenuSubmenu(
              label: Text('Embed'),
              children: <Widget>[
                NebaMenuItem(child: Text('YouTube')),
                NebaMenuItem(child: Text('CodeSandbox')),
                NebaMenuSubmenu(
                  label: Text('Other'),
                  children: <Widget>[
                    NebaMenuItem(child: Text('By URL')),
                    NebaMenuItem(child: Text('By oEmbed')),
                  ],
                ),
              ],
            ),
          ],
        ),
        NebaMenuSubmenu(
          label: Text('Data'),
          children: <Widget>[
            NebaMenuItem(child: Text('Table')),
            NebaMenuItem(child: Text('Chart')),
          ],
        ),
      ],
    );
  }
}
