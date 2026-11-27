import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ImageFrame extends StatelessWidget {
  const ImageFrame({super.key});

  static const List<(String, NebaImageFrame)> frames = <(String, NebaImageFrame)>[
    ('circle', NebaImageFrame(shape: NebaImageFrameShape.circle)),
    ('cut', NebaImageFrame(shape: NebaImageFrameShape.cut)),
    ('arch', NebaImageFrame(shape: NebaImageFrameShape.arch)),
    ('mounted', NebaImageFrame(mat: 10, border: 1, elevation: 2)),
    ('feathered', NebaImageFrame(shape: NebaImageFrameShape.rect, featherFraction: 0.1)),
    ('heavy line', NebaImageFrame(corner: NebaSize.xl, border: 3, borderColor: Color(0xFFC8503F))),
  ];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final (String label, NebaImageFrame frame) in frames)
            NebaGrid(
              span: const NebaGridSpan.columns(4),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 1.5,
                children: <Widget>[
                  NebaImage(
                    image: const AssetImage('assets/samples/photos/red-umbrella-autumn-path.jpg'),
                    alt: '',
                    ratio: 1,
                    frame: frame,
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
