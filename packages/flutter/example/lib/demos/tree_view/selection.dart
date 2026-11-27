import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const Map<String, String> _labels = <String, String>{
  'overview': 'Overview',
  'traffic': 'Traffic',
  'errors': 'Errors',
  'billing': 'Billing',
  'members': 'Members',
};

class TreeViewSelection extends StatefulWidget {
  const TreeViewSelection({super.key});

  @override
  State<TreeViewSelection> createState() => _TreeViewSelectionState();
}

class _TreeViewSelectionState extends State<TreeViewSelection> {
  List<String> _selected = <String>['traffic'];

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        SizedBox(
          width: 224,
          child: NebaTreeView<String>(
            label: 'Reports',
            multiple: true,
            selected: _selected,
            onSelectedChange: (List<String> next) => setState(() => _selected = next),
            defaultExpanded: const <String>['analytics'],
            children: const <NebaTreeItem<String>>[
              NebaTreeItem<String>(value: 'overview', label: Text('Overview')),
              NebaTreeItem<String>(
                value: 'analytics',
                label: Text('Analytics'),
                children: <NebaTreeItem<String>>[
                  NebaTreeItem<String>(value: 'traffic', label: Text('Traffic')),
                  NebaTreeItem<String>(value: 'errors', label: Text('Errors')),
                ],
              ),
              NebaTreeItem<String>(
                value: 'account',
                label: Text('Account'),
                children: <NebaTreeItem<String>>[
                  NebaTreeItem<String>(value: 'billing', label: Text('Billing')),
                  NebaTreeItem<String>(value: 'members', label: Text('Members')),
                ],
              ),
            ],
          ),
        ),
        NebaFlex(
          wrap: true,
          spacing: 1.5,
          children: <Widget>[
            if (_selected.isEmpty)
              const NebaChip(
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: Text('Nothing chosen'),
              )
            else
              for (final String value in _selected)
                NebaChip(
                  key: ValueKey<String>(value),
                  size: NebaSize.sm,
                  onDelete: () => setState(
                    () => _selected = <String>[
                      for (final String entry in _selected)
                        if (entry != value) entry,
                    ],
                  ),
                  child: Text(_labels[value] ?? value),
                ),
          ],
        ),
      ],
    );
  }
}
