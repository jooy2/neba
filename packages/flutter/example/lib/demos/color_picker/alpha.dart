import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerAlpha extends StatefulWidget {
  const ColorPickerAlpha({super.key});

  @override
  State<ColorPickerAlpha> createState() => _ColorPickerAlphaState();
}

class _ColorPickerAlphaState extends State<ColorPickerAlpha> {
  String _color = 'rgba(217, 70, 239, 0.65)';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaColorPicker(
          alpha: true,
          format: NebaColorFormat.rgb,
          value: _color,
          onValueChange: (String next) => setState(() => _color = next),
        ),
        NebaTypography(_color, level: NebaTypographyLevel.caption),
      ],
    );
  }
}
