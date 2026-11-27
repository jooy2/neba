import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ColorPickerFormat extends StatefulWidget {
  const ColorPickerFormat({super.key});

  @override
  State<ColorPickerFormat> createState() => _ColorPickerFormatState();
}

class _ColorPickerFormatState extends State<ColorPickerFormat> {
  NebaColorFormat _format = NebaColorFormat.hex;
  String _color = '#f97316';

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaSegmentedButton<NebaColorFormat>(
          semanticLabel: 'Format',
          size: NebaSize.sm,
          value: _format,
          onValueChange: (NebaColorFormat? next) {
            if (next != null) {
              setState(() => _format = next);
            }
          },
          children: <NebaSegment<NebaColorFormat>>[
            for (final NebaColorFormat format in NebaColorFormat.values)
              NebaSegment<NebaColorFormat>(value: format, child: Text(format.name)),
          ],
        ),
        NebaColorPicker(
          format: _format,
          value: _color,
          onValueChange: (String next) => setState(() => _color = next),
        ),
        NebaTypography(_color, level: NebaTypographyLevel.caption),
      ],
    );
  }
}
