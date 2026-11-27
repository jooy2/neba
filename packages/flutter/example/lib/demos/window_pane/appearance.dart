import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class WindowPaneAppearance extends StatelessWidget {
  const WindowPaneAppearance({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 6,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const NebaWindowPane(
            os: NebaWindowOs.windows10,
            title: Text('Accent'),
            accent: true,
            color: NebaColor.primary,
            height: 120,
            child: _Note('accent · color: NebaColor.primary'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaWindowPane(
            title: Text('Translucent'),
            transparency: 0.45,
            height: 120,
            child: _Note('transparency: 0.45'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaWindowPane(
            title: Text('Flat'),
            elevation: 0,
            height: 120,
            child: _Note('elevation: 0'),
          ),
        ),
        NebaGrid(
          span: half,
          child: const NebaWindowPane(
            os: NebaWindowOs.linux,
            title: Text('Behind'),
            active: false,
            height: 120,
            child: _Note('active: false'),
          ),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: NebaTypography(text, level: NebaTypographyLevel.caption, color: NebaColor.secondary),
    );
  }
}
