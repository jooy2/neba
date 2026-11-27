import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class PageLayoutSpan extends StatefulWidget {
  const PageLayoutSpan({super.key});

  @override
  State<PageLayoutSpan> createState() => _PageLayoutSpanState();
}

class _PageLayoutSpanState extends State<PageLayoutSpan> {
  NebaPageLayoutSpan _span = NebaPageLayoutSpan.full;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        NebaSegmentedButton<NebaPageLayoutSpan>(
          size: NebaSize.sm,
          value: _span,
          onValueChange: (NebaPageLayoutSpan? next) {
            if (next != null) {
              setState(() => _span = next);
            }
          },
          children: <NebaSegment<NebaPageLayoutSpan>>[
            for (final NebaPageLayoutSpan span in NebaPageLayoutSpan.values)
              NebaSegment<NebaPageLayoutSpan>(value: span, child: Text('headerSpan: ${span.name}')),
          ],
        ),
        Container(
          height: 288,
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
            collapseBelow: NebaBreakpoint.xs,
            headerSpan: _span,
            header: const NebaHeader(
              brand: <Widget>[
                NebaAppLogo(
                  name: 'Neba',
                  image: AssetImage('assets/128x128.png'),
                  showName: true,
                  size: NebaSize.sm,
                ),
              ],
            ),
            sidebar: NebaSidebar(
              label: 'Sections',
              width: 160,
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
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: NebaTypography(
                _span == NebaPageLayoutSpan.full
                    ? 'The bar takes the corner: a website.'
                    : 'The rail takes the corner: an application.',
                color: NebaColor.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
