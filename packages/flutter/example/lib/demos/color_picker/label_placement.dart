import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerLabelPlacement extends StatelessWidget {
  const ColorPickerLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      columnSpacing: 4,
      rowSpacing: 6,
      alignItems: NebaAlignItems.end,
      children: <Widget>[
        NebaColorPicker(label: Text('Top'), defaultValue: '#8b5cf6'),
        NebaColorPicker(
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Notch'),
          defaultValue: '#8b5cf6',
        ),
      ],
    );
  }
}
