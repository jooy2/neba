import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerInline extends StatelessWidget {
  const ColorPickerInline({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaColorPicker(inline: true, defaultValue: '#22c55e');
  }
}
