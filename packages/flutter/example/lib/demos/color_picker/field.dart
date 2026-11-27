import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          NebaColorPicker(
            label: Text('Label colour'),
            description: Text('Shown on the project card and in the calendar.'),
            clearable: true,
            fullWidth: true,
            defaultValue: '#8b5cf6',
          ),
          NebaColorPicker(
            label: Text('Brand colour'),
            error: Text('This colour fails contrast against white.'),
            defaultValue: '#fef08a',
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
