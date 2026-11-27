import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class PageLayoutHero extends StatelessWidget {
  const PageLayoutHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Container(
      height: 384,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
      ),
      child: NebaPageLayout(
        height: NebaPageLayoutHeight.auto,
        scroll: NebaPageLayoutScroll.content,
        collapseBelow: NebaBreakpoint.sm,
        header: NebaHeader(
          brand: const <Widget>[
            NebaSidebarTrigger(),
            NebaAppLogo(
              name: 'Neba',
              image: AssetImage('assets/128x128.png'),
              showName: true,
              size: NebaSize.sm,
            ),
          ],
          actions: <Widget>[
            NebaButton(
              onPressed: _open,
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              child: const Text('Sign in'),
            ),
          ],
        ),
        sidebar: NebaSidebar(
          label: 'Sections',
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
              NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('Components')),
              NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('Design')),
            ],
          ),
        ),
        footer: const NebaFooter(
          child: NebaTypography(
            '© 2026 Neba',
            level: NebaTypographyLevel.caption,
            color: NebaColor.secondary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              const NebaTypography('Overview', level: NebaTypographyLevel.h5),
              NebaTypography.rich(
                TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(
                      text: 'The header, the sidebar and the footer are slots. This is the ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: NebaTextLink(
                        onPressed: _open,
                        href: Uri.parse('#'),
                        child: const Text('main'),
                      ),
                    ),
                    const TextSpan(text: ' region between them.'),
                  ],
                ),
                color: NebaColor.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
