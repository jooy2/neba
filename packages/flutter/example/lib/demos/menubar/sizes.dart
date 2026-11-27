import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenubarSizes extends StatelessWidget {
  const MenubarSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaSize size in <NebaSize>[NebaSize.xs, NebaSize.sm, NebaSize.md, NebaSize.lg])
          NebaMenubar(
            size: size,
            semanticLabel: size.name,
            children: const <Widget>[
              NebaMenubarMenu(
                label: Text('File'),
                children: <Widget>[NebaMenuItem(child: Text('New file'))],
              ),
              NebaMenubarMenu(
                label: Text('Edit'),
                children: <Widget>[NebaMenuItem(child: Text('Undo'))],
              ),
              NebaMenubarMenu(
                label: Text('View'),
                children: <Widget>[NebaMenuItem(child: Text('Sidebar'))],
              ),
            ],
          ),
      ],
    );
  }
}
