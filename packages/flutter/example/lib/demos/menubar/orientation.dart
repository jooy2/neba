import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenubarOrientation extends StatelessWidget {
  const MenubarOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 160,
      child: NebaMenubar(
        orientation: NebaOrientation.vertical,
        size: NebaSize.sm,
        semanticLabel: 'Sections',
        children: <Widget>[
          NebaMenubarMenu(
            label: Text('Project'),
            children: <Widget>[
              NebaMenuItem(child: Text('Settings')),
              NebaMenuItem(child: Text('Members')),
            ],
          ),
          NebaMenubarMenu(
            label: Text('Deploys'),
            children: <Widget>[
              NebaMenuItem(child: Text('Production')),
              NebaMenuItem(child: Text('Preview')),
            ],
          ),
          NebaMenubarMenu(
            label: Text('Billing'),
            children: <Widget>[NebaMenuItem(child: Text('Invoices'))],
          ),
        ],
      ),
    );
  }
}
