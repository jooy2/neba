import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaCommandItem> _commands = <NebaCommandItem>[
  NebaCommandItem(value: 'overview', label: 'Go to overview', group: 'Navigate', shortcut: 'G O'),
  NebaCommandItem(value: 'deploys', label: 'Go to deployments', group: 'Navigate', shortcut: 'G D'),
  NebaCommandItem(
    value: 'logs',
    label: 'Go to logs',
    group: 'Navigate',
    keywords: <String>['traces', 'output'],
  ),
  NebaCommandItem(
    value: 'deploy',
    label: 'Deploy production',
    description: Text('Builds the current branch and moves traffic when it is healthy.'),
    group: 'Actions',
    shortcut: 'Mod+Shift+D',
    keywords: <String>['ship', 'release'],
  ),
  NebaCommandItem(
    value: 'rollback',
    label: 'Roll back the last deploy',
    group: 'Actions',
    keywords: <String>['undo', 'revert'],
  ),
  NebaCommandItem(value: 'invite', label: 'Invite a teammate', group: 'Actions'),
  NebaCommandItem(value: 'theme', label: 'Toggle dark mode', group: 'Preferences'),
  NebaCommandItem(
    value: 'shortcuts',
    label: 'Keyboard shortcuts',
    group: 'Preferences',
    shortcut: '?',
  ),
];

class CommandPaletteHero extends StatefulWidget {
  const CommandPaletteHero({super.key});

  @override
  State<CommandPaletteHero> createState() => _CommandPaletteHeroState();
}

class _CommandPaletteHeroState extends State<CommandPaletteHero> {
  bool _open = false;
  String? _ran;

  @override
  Widget build(BuildContext context) {
    final String? ran = _ran;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _open = true),
          variant: NebaVariant.outline,
          endIcon: const NebaShortcut(keys: 'Mod+K'),
          // Shrinks rather than overflows a narrow phone.
          child: const Flexible(child: Text('Open the palette', overflow: TextOverflow.ellipsis)),
        ),
        if (ran != null) NebaTypography('Ran: $ran', level: NebaTypographyLevel.caption),
        NebaCommandPalette(
          items: _commands,
          open: _open,
          onOpenChange: (bool open) => setState(() => _open = open),
          onSelect: (NebaCommandItem item) => setState(() => _ran = item.label),
        ),
      ],
    );
  }
}
