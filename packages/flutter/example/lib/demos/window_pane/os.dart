import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({NebaWindowOs os, String title, String note})>
_systems = <({NebaWindowOs os, String title, String note})>[
  (os: NebaWindowOs.macos, title: 'Finder', note: 'Traffic lights, centred title, Mica-flat bar'),
  (os: NebaWindowOs.macosx, title: 'Finder', note: 'Aqua: striped bar, glossy lights, square feet'),
  (os: NebaWindowOs.windows11, title: 'Explorer', note: 'Rounded corners, one sheet, no rule'),
  (os: NebaWindowOs.windows10, title: 'Explorer', note: 'Square corners, white bar, ruled off'),
  (os: NebaWindowOs.windows8, title: 'Explorer', note: 'Flat, and a band of colour round the edge'),
  (os: NebaWindowOs.windows7, title: 'Explorer', note: 'Aero glass, glowing title, wider close'),
  (os: NebaWindowOs.windowsxp, title: 'Explorer', note: 'Luna blue, framed, coloured plates'),
  (os: NebaWindowOs.linux, title: 'Files', note: 'A header bar, taller, with circles'),
];

class WindowPaneOs extends StatelessWidget {
  const WindowPaneOs({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 6,
      padded: false,
      children: <Widget>[
        for (final ({NebaWindowOs os, String title, String note}) system in _systems)
          NebaGrid(
            span: half,
            child: NebaWindowPane(
              os: system.os,
              title: Text(system.title),
              height: 130,
              active: system.os == NebaWindowOs.macos,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: <Widget>[
                    NebaTypography('os: ${system.os.name}', level: NebaTypographyLevel.caption),
                    NebaTypography(
                      system.note,
                      level: NebaTypographyLevel.caption,
                      color: NebaColor.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
