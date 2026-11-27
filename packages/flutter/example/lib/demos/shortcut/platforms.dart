import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The same three shortcuts, named for three keyboards. `Mod` is the token that
/// changes meaning rather than spelling: Command on a Mac, Control everywhere
/// else, which is the whole reason writing `Ctrl` and hoping is wrong.
class ShortcutPlatforms extends StatelessWidget {
  const ShortcutPlatforms({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 13),
      child: const Wrap(
        spacing: 32,
        runSpacing: 24,
        children: <Widget>[
          _Platform(name: 'macOS', os: NebaShortcutOS.mac, lock: 'Meta+Ctrl+Q'),
          _Platform(name: 'Windows', os: NebaShortcutOS.windows, lock: 'Meta+L'),
          _Platform(name: 'Linux', os: NebaShortcutOS.linux, lock: 'Meta+L'),
        ],
      ),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform({required this.name, required this.os, required this.lock});

  final String name;
  final NebaShortcutOS os;
  final String lock;

  @override
  Widget build(BuildContext context) {
    TableRow row(String label, String keys) {
      return TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16, top: 6, bottom: 6),
            child: Text(label),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NebaShortcut(keys: keys, os: os),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: <Widget>[
        NebaTypography(name, level: NebaTypographyLevel.caption),
        Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            row('Save', 'Mod+S'),
            row('Search', 'Mod+Shift+F'),
            row('Lock', lock),
          ],
        ),
      ],
    );
  }
}
