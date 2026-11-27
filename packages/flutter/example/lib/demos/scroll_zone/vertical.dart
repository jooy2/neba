import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<(String, String)> _releases = <(String, String)>[
  ('1.5.0', 'Breadcrumb trails'),
  ('1.4.0', 'Charts'),
  ('1.3.0', 'Date pickers'),
  ('1.2.0', 'Menus'),
  ('1.1.0', 'Tables'),
  ('1.0.0', 'First release'),
  ('0.9.0', 'Beta'),
  ('0.8.0', 'Alpha'),
];

class ScrollZoneVertical extends StatelessWidget {
  const ScrollZoneVertical({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: SizedBox(
        height: 224,
        child: NebaScrollZone(
          orientation: NebaOrientation.vertical,
          label: 'Releases',
          spacing: 2,
          buttons: NebaScrollZoneButtons.always,
          children: <Widget>[
            for (final (String version, String note) in _releases)
              NebaBox(
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NebaTypography(version),
                    NebaTypography(
                      note,
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
