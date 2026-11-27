import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class SidebarResizable extends StatefulWidget {
  const SidebarResizable({super.key});

  @override
  State<SidebarResizable> createState() => _SidebarResizableState();
}

class _SidebarResizableState extends State<SidebarResizable> {
  double _width = 200;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Container(
      height: 288,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          NebaSidebar(
            collapseBelow: NebaBreakpoint.xs,
            resizable: true,
            width: 200,
            minWidth: 140,
            maxWidth: 320,
            onResize: (double width) => setState(() => _width = width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const NebaTypography('Files', level: NebaTypographyLevel.overline),
                NebaList(
                  variant: NebaVariant.text,
                  size: NebaSize.sm,
                  children: <Widget>[
                    NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('src')),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      selected: true,
                      child: const Text('package.json'),
                    ),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('README.md'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const NebaTypography('Drag the inner edge', level: NebaTypographyLevel.h6),
                  NebaTypography('${_width.round()}px', color: NebaColor.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
