import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImagePosition extends StatelessWidget {
  const ImagePosition({super.key});

  static const List<(String, Alignment)> positions = <(String, Alignment)>[
    ('topCenter', Alignment.topCenter),
    ('center', Alignment.center),
    ('bottomCenter', Alignment.bottomCenter),
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
          for (final (String label, Alignment position) in positions)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  // A tall photograph in a short box: a cover has to crop, and
                  // the position says which part of it stays.
                  NebaImage(
                    image: const AssetImage(
                      'assets/samples/photos/lighthouse-cliff-wildflowers.jpg',
                    ),
                    alt: '',
                    height: 120,
                    position: position,
                    rounded: NebaSize.md,
                  ),
                  Text('Alignment.$label', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
