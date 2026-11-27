import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TreeViewLines extends StatelessWidget {
  const TreeViewLines({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 6,
      children: <Widget>[
        for (final NebaTreeViewLines lines in NebaTreeViewLines.values)
          SizedBox(
            width: 208,
            child: NebaTreeView<String>(
              label: lines.name,
              lines: lines,
              size: NebaSize.sm,
              defaultExpanded: const <String>['app', 'routes'],
              children: <NebaTreeItem<String>>[
                NebaTreeItem<String>(
                  value: 'app',
                  label: Text('app (${lines.name})'),
                  children: const <NebaTreeItem<String>>[
                    NebaTreeItem<String>(
                      value: 'routes',
                      label: Text('routes'),
                      children: <NebaTreeItem<String>>[
                        NebaTreeItem<String>(value: 'home', label: Text('home.tsx')),
                        NebaTreeItem<String>(value: 'about', label: Text('about.tsx')),
                      ],
                    ),
                    NebaTreeItem<String>(value: 'root', label: Text('root.tsx')),
                  ],
                ),
                const NebaTreeItem<String>(value: 'public', label: Text('public')),
              ],
            ),
          ),
      ],
    );
  }
}
