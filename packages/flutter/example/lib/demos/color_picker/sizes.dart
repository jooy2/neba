import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerSizes extends StatelessWidget {
  const ColorPickerSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaColorPicker(size: size, defaultValue: '#06b6d4'),
      ],
    );
  }
}
