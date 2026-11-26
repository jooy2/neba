import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AspectRatioFit extends StatelessWidget {
  const AspectRatioFit({super.key});

  static const List<(String, BoxFit)> fits = <(String, BoxFit)>[
    ('cover', BoxFit.cover),
    ('contain', BoxFit.contain),
    ('fill', BoxFit.fill),
  ];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final (String label, BoxFit fit) in fits)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 2,
                children: <Widget>[
                  Text(label, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                  // The source is 2:3 and the box is square, so each fit has to
                  // give something up: cover crops, contain letterboxes, fill
                  // squashes.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.panelHover,
                      borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
                    ),
                    child: NebaAspectRatio(
                      fit: fit,
                      rounded: true,
                      child: Image.asset(
                        'assets/samples/photos/red-umbrella-autumn-path.jpg',
                        semanticLabel: 'A red umbrella lying on a wet path of fallen leaves',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
