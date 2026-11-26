import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AspectRatioRatios extends StatelessWidget {
  const AspectRatioRatios({super.key});

  static const List<(String, double)> ratios = <(String, double)>[
    ('1 / 1', 1),
    ('4 / 3', 4 / 3),
    ('16 / 9', 16 / 9),
    ('21 / 9', 21 / 9),
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
          for (final (String label, double ratio) in ratios)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 3 : 6),
              child: NebaAspectRatio(
                ratio: ratio,
                rounded: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.panelHover,
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
                  ),
                  child: Center(
                    child: Text(label, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
