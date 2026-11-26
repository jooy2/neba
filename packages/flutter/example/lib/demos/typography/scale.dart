import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TypographyScale extends StatelessWidget {
  const TypographyScale({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final NebaTypographyLevel level in NebaTypographyLevel.values)
          NebaFlex(
            spacing: 4,
            alignItems: NebaAlignItems.baseline,
            children: <Widget>[
              SizedBox(
                width: 80,
                child: Text(level.name, style: TextStyle(fontSize: 11, color: tokens.mutedFg)),
              ),
              NebaTypography('The quick brown fox', level: level),
            ],
          ),
      ],
    );
  }
}
