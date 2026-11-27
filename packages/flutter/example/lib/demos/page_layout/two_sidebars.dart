import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

/// The least width the frame is laid out at.
const double _width = 500;

class PageLayoutTwoSidebars extends StatelessWidget {
  const PageLayoutTwoSidebars({super.key});

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
      child: NebaPageLayout(
        // A preview, not the page, so not the screen's main region.
        main: false,
        height: NebaPageLayoutHeight.auto,
        scroll: NebaPageLayoutScroll.content,
        collapseBelow: NebaBreakpoint.xs,
        header: const NebaHeader(children: <Widget>[Text('Reference')]),
        sidebar: NebaSidebar(
          label: 'Sections',
          width: 150,
          child: NebaList(
            variant: NebaVariant.text,
            size: NebaSize.sm,
            children: <Widget>[
              NebaListItem(
                onPressed: _open,
                href: Uri.parse('#'),
                selected: true,
                child: const Text('Button'),
              ),
              NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('Card')),
            ],
          ),
        ),
        endSidebar: NebaSidebar(
          label: 'On this page',
          width: 150,
          variant: NebaVariant.text,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const NebaTypography('On this page', level: NebaTypographyLevel.overline),
              NebaList(
                variant: NebaVariant.text,
                size: NebaSize.sm,
                children: <Widget>[
                  NebaListItem(onPressed: _open, href: Uri.parse('#'), child: const Text('Props')),
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
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              NebaTypography('Button', level: NebaTypographyLevel.h6),
              NebaTypography(
                'Navigation down one side, contents down the other.',
                color: NebaColor.secondary,
              ),
            ],
          ),
        ),
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
