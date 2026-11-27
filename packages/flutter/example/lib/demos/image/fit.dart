import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageFit extends StatelessWidget {
  const ImageFit({super.key});

  static const List<(String, BoxFit)> fits = <(String, BoxFit)>[
    ('cover', BoxFit.cover),
    ('contain', BoxFit.contain),
    ('fill', BoxFit.fill),
    ('none', BoxFit.none),
    ('scaleDown', BoxFit.scaleDown),
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
          for (final (String label, BoxFit fit) in fits)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 6),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  // A lone height sizes the box, and the box is wider than the
                  // portrait inside it, so every fit has to give something up.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.panelHover,
                      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
                    ),
                    child: NebaImage(
                      image: const AssetImage('assets/samples/photos/red-umbrella-autumn-path.jpg'),
                      alt: '',
                      height: 140,
                      fit: fit,
                      rounded: NebaSize.md,
                    ),
                  ),
                  Text('BoxFit.$label', style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
