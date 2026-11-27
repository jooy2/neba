import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

/// The least width the frame is laid out at.
const double _width = 480;

class SidebarSides extends StatelessWidget {
  const SidebarSides({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    final Widget frame = Container(
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
            width: 160,
            label: 'Sections',
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
                      child: const Text('Props'),
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
                  NebaTypography('Two sidebars', level: NebaTypographyLevel.h6),
                  NebaTypography(
                    'Each has its own width and its own drawer.',
                    color: NebaColor.secondary,
                  ),
                ],
              ),
            ),
          ),
          NebaSidebar(
            collapseBelow: NebaBreakpoint.xs,
            side: NebaSidebarSide.end,
            width: 160,
            label: 'On this page',
            variant: NebaVariant.text,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const NebaTypography('On this page', level: NebaTypographyLevel.overline),
                NebaList(
                  variant: NebaVariant.text,
                  size: NebaSize.sm,
                  children: <Widget>[
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('Props'),
                    ),
                    NebaListItem(
                      onPressed: _open,
                      href: Uri.parse('#'),
                      child: const Text('Examples'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Two columns and the content between them are wider than a phone, so
    // there the frame keeps a width of its own and scrolls sideways.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return constraints.maxWidth >= _width
            ? frame
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: _width, child: frame),
              );
      },
    );
  }
}
