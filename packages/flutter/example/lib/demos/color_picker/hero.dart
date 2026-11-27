import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerHero extends StatefulWidget {
  const ColorPickerHero({super.key});

  @override
  State<ColorPickerHero> createState() => _ColorPickerHeroState();
}

class _ColorPickerHeroState extends State<ColorPickerHero> {
  String _color = '#1a58d1';

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        NebaColorPicker(
          value: _color,
          onValueChange: (String next) => setState(() => _color = next),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hex(_color),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.border),
          ),
        ),
      ],
    );
  }
}

/// The picker writes hex here, `#rrggbb`.
Color _hex(String value) {
  return Color(0xFF000000 | int.parse(value.substring(1, 7), radix: 16));
}
