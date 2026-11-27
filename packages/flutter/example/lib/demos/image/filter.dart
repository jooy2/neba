import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageFilter extends StatelessWidget {
  const ImageFilter({super.key});

  static const List<(String, NebaImageFilter)> filters = <(String, NebaImageFilter)>[
    ('none', NebaImageFilter.none),
    ('grayscale', NebaImageFilter.grayscale),
    ('sepia', NebaImageFilter.sepia),
    ('mute', NebaImageFilter.mute),
    ('saturate', NebaImageFilter.saturate),
    ('contrast', NebaImageFilter.contrast),
  ];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 3,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final (String label, NebaImageFilter filter) in filters)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 6),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  NebaImage(
                    image: const AssetImage(
                      'assets/samples/photos/fresh-vegetables-market-stall.jpg',
                    ),
                    alt: '',
                    ratio: 3 / 2,
                    rounded: NebaSize.md,
                    filter: filter,
                  ),
                  Text(label, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
