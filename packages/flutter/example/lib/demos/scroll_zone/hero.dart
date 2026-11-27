import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String)> _shows = <(String, String)>[
  ('Aurora', 'Documentary'),
  ('Deep Field', 'Science'),
  ('The Long Road', 'Drama'),
  ('Salt & Stone', 'Cooking'),
  ('Night Shift', 'Thriller'),
  ('Paper Boats', 'Family'),
  ('Signal', 'Mystery'),
];

class ScrollZoneHero extends StatelessWidget {
  const ScrollZoneHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 2,
      children: <Widget>[
        const NebaTypography('Continue watching', level: NebaTypographyLevel.h6),
        NebaScrollZone(
          label: 'Continue watching',
          spacing: 3,
          children: <Widget>[
            for (final (String name, String note) in _shows)
              SizedBox(
                width: 160,
                child: NebaCard(
                  size: NebaSize.sm,
                  title: Text(name),
                  subtitle: Text(note),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: tokens.roles(NebaColor.primary).soft,
                      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.sm]!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
