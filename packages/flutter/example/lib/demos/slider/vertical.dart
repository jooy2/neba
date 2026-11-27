import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, double, NebaColor)> _channels = <(String, double, NebaColor)>[
  ('Low', 70, NebaColor.primary),
  ('Mid', 45, NebaColor.info),
  ('High', 30, NebaColor.success),
];

class SliderVertical extends StatelessWidget {
  const SliderVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 32,
      children: <Widget>[
        for (final (String label, double value, NebaColor color) in _channels)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              NebaSlider(
                orientation: NebaOrientation.vertical,
                color: color,
                semanticLabel: label,
                defaultValue: value,
              ),
              Text(label, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
            ],
          ),
      ],
    );
  }
}
