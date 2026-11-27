import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _events = <String>[
  'deploy · api · 12:04',
  'deploy · web · 12:07',
  'rollback · web · 12:09',
  'deploy · web · 12:15',
];

class AnimateMarqueeVertical extends StatelessWidget {
  const AnimateMarqueeVertical({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 224),
      child: SizedBox(
        height: 128,
        child: NebaAnimateMarquee(
          orientation: NebaOrientation.vertical,
          speed: 30,
          gap: 8,
          children: <Widget>[
            for (final String event in _events)
              SizedBox(
                key: ValueKey<String>(event),
                width: double.infinity,
                child: NebaBox(
                  size: NebaSize.sm,
                  density: NebaDensity.compact,
                  child: NebaTypography(event, level: NebaTypographyLevel.caption),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
