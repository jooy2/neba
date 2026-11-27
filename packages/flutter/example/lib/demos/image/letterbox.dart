import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageLetterbox extends StatelessWidget {
  const ImageLetterbox({super.key});

  static const List<(String, NebaImageLetterbox)> letterboxes = <(String, NebaImageLetterbox)>[
    ('none', NebaImageLetterbox.none),
    ('color(0xFF18181B)', NebaImageLetterbox.color(Color(0xFF18181B))),
    ('blur', NebaImageLetterbox.blur),
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
          for (final (String label, NebaImageLetterbox letterbox) in letterboxes)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  // A contain keeps the whole portrait, and the letterbox says
                  // what fills the sides it leaves.
                  NebaImage(
                    image: const AssetImage('assets/samples/photos/greenhouse-fern-shadows.jpg'),
                    alt: '',
                    height: 160,
                    fit: BoxFit.contain,
                    letterbox: letterbox,
                    rounded: NebaSize.md,
                  ),
                  Text(
                    'NebaImageLetterbox.$label',
                    style: TextStyle(fontSize: 12, color: tokens.mutedFg),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
