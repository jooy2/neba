import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _folders = <String>['All', 'Work', 'Recipes', 'Trips'];

class WindowPaneHero extends StatelessWidget {
  const WindowPaneHero({super.key});

  @override
  Widget build(BuildContext context) {
    final Color soft = NebaTheme.of(context).roles(NebaColor.primary).soft;

    return NebaWindowPane(
      title: const Text('Notes'),
      height: 280,
      elevation: 2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: 120,
              color: soft,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  const NebaTypography(
                    'Folders',
                    level: NebaTypographyLevel.caption,
                    color: NebaColor.secondary,
                  ),
                  for (final String folder in _folders) NebaTypography(folder),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NebaTypography('Cold brew, third attempt', level: NebaTypographyLevel.h6),
                    NebaTypography(
                      'Edited 4 minutes ago',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 12), child: NebaDivider()),
                    NebaTypography(
                      'Coarse grind, 1:8, sixteen hours on the counter. Strained twice. Less bitter than the last one and it keeps for a week.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
