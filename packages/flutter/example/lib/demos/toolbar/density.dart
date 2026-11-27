import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolbarDensity extends StatelessWidget {
  const ToolbarDensity({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        for (final (NebaDensity density, String name) in const <(NebaDensity, String)>[
          (NebaDensity.standard, 'standard'),
          (NebaDensity.compact, 'compact'),
        ])
          NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 2,
            children: <Widget>[
              NebaTypography('density: $name', level: NebaTypographyLevel.caption),
              NebaToolbar(
                density: density,
                start: const <Widget>[NebaTypography('Files', level: NebaTypographyLevel.h6)],
                end: <Widget>[
                  NebaButtonGroup(
                    variant: NebaVariant.outline,
                    size: NebaSize.sm,
                    color: NebaColor.secondary,
                    children: <Widget>[
                      NebaButton(onPressed: () {}, child: const Text('Rename')),
                      NebaButton(onPressed: () {}, child: const Text('Move')),
                    ],
                  ),
                ],
                children: const <Widget>[
                  Expanded(
                    child: NebaTextField(
                      size: NebaSize.sm,
                      placeholder: 'Filter…',
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
