import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class WindowPaneInteractive extends StatelessWidget {
  const WindowPaneInteractive({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      child: Container(
        height: 320,
        color: tokens.roles(NebaColor.secondary).soft,
        child: const Stack(
          children: <Widget>[
            NebaWindowPane(
              title: Text('Inspector'),
              position: NebaWindowPanePosition.absolute,
              draggable: true,
              resizable: true,
              width: 240,
              height: 170,
              defaultOffset: Offset(20, 20),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    NebaTypography('Drag the title bar.'),
                    NebaTypography(
                      'Pull any edge or corner to resize.',
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                  ],
                ),
              ),
            ),
            NebaWindowPane(
              os: NebaWindowOs.linux,
              title: Text('Console'),
              position: NebaWindowPanePosition.absolute,
              draggable: true,
              resizable: true,
              width: 200,
              height: 150,
              defaultOffset: Offset(100, 150),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: NebaTypography(
                  'Press one: the other steps back.',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
