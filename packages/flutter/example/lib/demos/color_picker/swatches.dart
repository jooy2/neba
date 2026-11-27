import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The colours a product actually uses, one press away.
const List<String> _brand = <String>[
  '#0f172a',
  '#1a58d1',
  '#0891b2',
  '#16a34a',
  '#ca8a04',
  '#dc2626',
];

class ColorPickerSwatches extends StatelessWidget {
  const ColorPickerSwatches({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.start,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        NebaColorPicker(
          inline: true,
          size: NebaSize.sm,
          swatches: _brand,
          defaultValue: '#1a58d1',
          editable: false,
        ),
        NebaColorPicker(
          inline: true,
          size: NebaSize.sm,
          swatches: <String>[],
          defaultValue: '#dc2626',
        ),
      ],
    );
  }
}
