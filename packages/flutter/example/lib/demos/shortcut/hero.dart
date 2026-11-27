import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShortcutHero extends StatelessWidget {
  const ShortcutHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 13),
        child: const NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 4,
          children: <Widget>[
            _Row(label: 'Open the command palette', keys: 'Mod+K'),
            _Row(label: 'Save', keys: 'Mod+S'),
            _Row(label: 'Close the tab', keys: 'Mod+Shift+W'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.keys});

  final String label;
  final String keys;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: <Widget>[
        Expanded(child: Text(label)),
        NebaShortcut(keys: keys),
      ],
    );
  }
}
