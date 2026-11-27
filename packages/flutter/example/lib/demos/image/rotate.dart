import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageRotate extends StatelessWidget {
  const ImageRotate({super.key});

  static const List<(String, int, NebaImageFlip)> poses = <(String, int, NebaImageFlip)>[
    ('as stored', 0, NebaImageFlip.none),
    ('flip: horizontal', 0, NebaImageFlip.horizontal),
    ('rotate: 90', 90, NebaImageFlip.none),
    ('rotate: 180', 180, NebaImageFlip.none),
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
          for (final (String label, int rotate, NebaImageFlip flip) in poses)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 3 : 6),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  // The width and the height describe the file, so the turned
                  // picture reserves a box on its side before it has loaded.
                  NebaImage(
                    image: const AssetImage('assets/samples/photos/alpine-lake-dawn.jpg'),
                    alt: '',
                    width: 560,
                    height: 373,
                    rounded: NebaSize.md,
                    rotate: rotate,
                    flip: flip,
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
