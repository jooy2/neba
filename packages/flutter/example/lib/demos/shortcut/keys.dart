import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShortcutKeys extends StatelessWidget {
  const ShortcutKeys({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 13),
        child: const NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 3,
          children: <Widget>[
            _Row(
              label: 'A single letter',
              shortcut: NebaShortcut(keys: 'K'),
            ),
            _Row(
              label: 'A named key',
              shortcut: NebaShortcut(keys: 'Escape'),
            ),
            _Row(
              label: 'Arrows, on every platform',
              shortcut: NebaShortcut.split(keys: <String>['ArrowUp', 'ArrowDown']),
            ),
            _Row(
              label: 'A key that is itself a plus',
              shortcut: NebaShortcut.split(keys: <String>['Mod', '+']),
            ),
            _Row(
              label: 'Three modifiers',
              shortcut: NebaShortcut(keys: 'Mod+Alt+Shift+Delete'),
            ),
            _Row(
              label: 'A function key',
              shortcut: NebaShortcut(keys: 'F12'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.shortcut});

  final String label;
  final Widget shortcut;

  @override
  Widget build(BuildContext context) {
    // The keys under their name on a screen too narrow for both on a line.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: <Widget>[Text(label), shortcut],
    );
  }
}
