import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenuSizes extends StatelessWidget {
  const MenuSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaMenu(
            size: size,
            trigger: NebaButton(
              onPressed: () {},
              size: size,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: Text(size.name),
            ),
            children: const <Widget>[
              NebaMenuItem(shortcut: Text('⌘E'), child: Text('Rename')),
              NebaMenuItem(shortcut: Text('⌘D'), child: Text('Duplicate')),
              NebaMenuItem(child: Text('Move to archive')),
            ],
          ),
      ],
    );
  }
}
