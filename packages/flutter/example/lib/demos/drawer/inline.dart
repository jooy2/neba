import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The least width the frame is laid out at.
const double _width = 520;

class DrawerInline extends StatefulWidget {
  const DrawerInline({super.key});

  @override
  State<DrawerInline> createState() => _DrawerInlineState();
}

class _DrawerInlineState extends State<DrawerInline> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    final Widget frame = Container(
      height: 256,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: tokens.roles(NebaColor.primary).line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          NebaDrawer(
            mode: NebaDrawerMode.inline,
            open: _open,
            onOpenChange: (bool open) => setState(() => _open = open),
            showClose: true,
            title: const Text('Projects'),
            extent: 200,
            child: const NebaList(
              density: NebaDensity.compact,
              children: <Widget>[
                NebaListItem(child: Text('neba')),
                NebaListItem(child: Text('docs-site')),
                NebaListItem(child: Text('api-gateway')),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: <Widget>[
                  Text(
                    'The page is laid out around an inline drawer rather than under it. Closing '
                    'it takes it out of the flow.',
                    style: TextStyle(fontSize: 13, color: tokens.mutedFg),
                  ),
                  NebaButton(
                    onPressed: () => setState(() => _open = !_open),
                    size: NebaSize.sm,
                    variant: NebaVariant.outline,
                    child: Text(_open ? 'Collapse the sidebar' : 'Show the sidebar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // The panel and the page beside it are wider than a phone, so there the
    // frame keeps a width of its own and scrolls sideways.
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
