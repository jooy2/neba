import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenuState extends StatefulWidget {
  const MenuState({super.key});

  @override
  State<MenuState> createState() => _MenuStateState();
}

class _MenuStateState extends State<MenuState> {
  String _density = 'cosy';
  final Map<String, bool> _columns = <String, bool>{
    'status': true,
    'owner': true,
    'updated': false,
  };

  @override
  Widget build(BuildContext context) {
    final List<String> shown = <String>[
      for (final MapEntry<String, bool> column in _columns.entries)
        if (column.value) column.key,
    ];

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaMenu(
          trigger: NebaButton(
            onPressed: () {},
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            child: const Text('View'),
          ),
          children: <Widget>[
            // A tick says "and", a dot says "instead of": the distinction
            // NebaCheckbox and NebaRadio make everywhere else.
            NebaMenuGroup(
              label: const Text('Columns'),
              children: <Widget>[
                for (final String key in _columns.keys)
                  NebaMenuCheckboxItem(
                    checked: _columns[key],
                    onCheckedChange: (bool checked) => setState(() => _columns[key] = checked),
                    child: Text(key),
                  ),
              ],
            ),
            const NebaMenuSeparator(),
            NebaMenuGroup(
              label: const Text('Density'),
              children: <Widget>[
                NebaMenuRadioGroup<String>(
                  value: _density,
                  onValueChange: (String value) => setState(() => _density = value),
                  children: const <Widget>[
                    NebaMenuRadioItem<String>(value: 'compact', child: Text('Compact')),
                    NebaMenuRadioItem<String>(value: 'cosy', child: Text('Cosy')),
                    NebaMenuRadioItem<String>(value: 'roomy', child: Text('Roomy')),
                  ],
                ),
              ],
            ),
          ],
        ),
        NebaTypography(
          '$_density · ${shown.isEmpty ? 'no columns' : shown.join(', ')}',
          level: NebaTypographyLevel.caption,
          color: NebaColor.secondary,
        ),
      ],
    );
  }
}
