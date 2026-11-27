import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TreeViewHero extends StatelessWidget {
  const TreeViewHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 288),
      child: const NebaTreeView<String>(
        label: 'Project files',
        lines: NebaTreeViewLines.folder,
        defaultExpanded: <String>['src', 'components'],
        defaultSelected: <String>['button'],
        children: <NebaTreeItem<String>>[
          NebaTreeItem<String>(
            value: 'src',
            label: Text('src'),
            children: <NebaTreeItem<String>>[
              NebaTreeItem<String>(
                value: 'components',
                label: Text('components'),
                children: <NebaTreeItem<String>>[
                  NebaTreeItem<String>(value: 'button', label: Text('Button.tsx')),
                  NebaTreeItem<String>(value: 'card', label: Text('Card.tsx')),
                ],
              ),
              NebaTreeItem<String>(
                value: 'internal',
                label: Text('internal'),
                children: <NebaTreeItem<String>>[
                  NebaTreeItem<String>(value: 'styles', label: Text('styles.ts')),
                ],
              ),
              NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
            ],
          ),
          NebaTreeItem<String>(value: 'package', label: Text('package.json')),
          NebaTreeItem<String>(value: 'readme', label: Text('README.md')),
        ],
      ),
    );
  }
}
