import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenubarWindow extends StatelessWidget {
  const MenubarWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaWindowPane(
        os: NebaWindowOs.windows11,
        title: const Text('notes.txt'),
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: tokens.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              alignment: AlignmentDirectional.centerStart,
              child: const NebaMenubar(
                size: NebaSize.xs,
                children: <Widget>[
                  NebaMenubarMenu(
                    label: Text('File'),
                    children: <Widget>[
                      NebaMenuItem(child: Text('New')),
                      NebaMenuSeparator(),
                      NebaMenuItem(child: Text('Exit')),
                    ],
                  ),
                  NebaMenubarMenu(
                    label: Text('Edit'),
                    children: <Widget>[NebaMenuItem(child: Text('Find…'))],
                  ),
                  NebaMenubarMenu(
                    label: Text('Format'),
                    children: <Widget>[NebaMenuItem(child: Text('Word wrap'))],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: NebaTypography('The strip sits on the window, not on a sheet of its own.'),
            ),
          ],
        ),
      ),
    );
  }
}
