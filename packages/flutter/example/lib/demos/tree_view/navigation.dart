import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A sidebar: `text` so the tree draws no sheet of its own, `none` because
/// two levels of navigation say what they are with words. The package opens
/// nothing itself, so each `href` is followed by its `onPressed`.
class TreeViewNavigation extends StatelessWidget {
  const TreeViewNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    NebaTreeItem<String> page(String value, String label, {Widget? endIcon}) {
      return NebaTreeItem<String>(
        value: value,
        label: Text(label),
        href: Uri.parse('#$value'),
        onPressed: () {},
        endIcon: endIcon,
      );
    }

    return SizedBox(
      width: 224,
      child: NebaTreeView<String>(
        label: 'Documentation',
        variant: NebaVariant.text,
        lines: NebaTreeViewLines.none,
        density: NebaDensity.compact,
        defaultExpanded: const <String>['components'],
        defaultSelected: const <String>['inputs'],
        children: <NebaTreeItem<String>>[
          page('guide', 'Getting started'),
          NebaTreeItem<String>(
            value: 'components',
            label: const Text('Components'),
            children: <NebaTreeItem<String>>[
              page('display', 'Display'),
              page(
                'inputs',
                'Inputs',
                endIcon: const NebaBadge(content: Text('19'), variant: NebaVariant.outline),
              ),
              page('surfaces', 'Surfaces'),
            ],
          ),
          page('design', 'Design language'),
        ],
      ),
    );
  }
}
