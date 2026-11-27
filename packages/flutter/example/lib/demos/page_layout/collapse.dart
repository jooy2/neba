import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class PageLayoutCollapse extends StatelessWidget {
  const PageLayoutCollapse({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 416),
      child: Container(
        height: 320,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
        ),
        child: NebaPageLayout(
          // A preview, not the page, so not the screen's main region.
          main: false,
          height: NebaPageLayoutHeight.auto,
          scroll: NebaPageLayoutScroll.content,
          collapseBelow: NebaBreakpoint.xl,
          header: const NebaHeader(
            brand: <Widget>[
              NebaSidebarTrigger(),
              NebaAppLogo(name: 'Neba', image: AssetImage('assets/128x128.png'), size: NebaSize.sm),
            ],
          ),
          sidebar: NebaSidebar(
            label: 'Sections',
            title: const Text('Sections'),
            child: NebaList(
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
                NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('Design')),
              ],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: <Widget>[
                NebaTypography('Narrow', level: NebaTypographyLevel.h6),
                NebaTypography(
                  'Below the breakpoint the column is a drawer, and the hamburger is what opens it.',
                  color: NebaColor.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
