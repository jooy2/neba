import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaMockupOs> _systems = <NebaMockupOs>[
  NebaMockupOs.macos,
  NebaMockupOs.windows,
  NebaMockupOs.linux,
];

class MockupOs extends StatelessWidget {
  const MockupOs({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 5,
      padded: false,
      children: <Widget>[
        for (final NebaMockupOs os in _systems)
          NebaGrid(
            span: third,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: <Widget>[
                Text(os.name, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                NebaMockup(
                  device: NebaMockupDevice.desktop,
                  os: os,
                  bezel: NebaMockupBezel.thin,
                  wallpaper: BoxDecoration(color: tokens.panelHover),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
