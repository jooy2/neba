import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class SidebarHero extends StatelessWidget {
  const SidebarHero({super.key});

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
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const NebaTypography('Sections', level: NebaTypographyLevel.overline),
                NebaList(
                  variant: NebaVariant.text,
                  size: NebaSize.sm,
                  children: <Widget>[
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      selected: true,
                      child: const Text('Overview'),
                    ),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('Components'),
                    ),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('Design'),
                    ),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('Changelog'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  NebaTypography('Overview', level: NebaTypographyLevel.h6),
                  NebaTypography(
                    'The content the sidebar sits beside.',
                    color: NebaColor.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
