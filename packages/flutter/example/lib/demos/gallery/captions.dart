import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryCaptions extends StatelessWidget {
  const GalleryCaptions({super.key});

  static const List<NebaGalleryCaption> captions = <NebaGalleryCaption>[
    NebaGalleryCaption.below,
    NebaGalleryCaption.overlay,
    NebaGalleryCaption.hover,
  ];

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        alignItems: NebaAlignItems.stretch,
        spacing: 6,
        children: <Widget>[
          for (final NebaGalleryCaption caption in captions)
            NebaFlex(
              direction: NebaOrientation.vertical,
              alignItems: NebaAlignItems.stretch,
              spacing: 2,
              children: <Widget>[
                Text(
                  'NebaGalleryCaption.${caption.name}',
                  style: TextStyle(fontSize: 12, color: tokens.mutedFg),
                ),
                NebaGallery(
                  items: photos.sublist(0, 4),
                  columns: 4,
                  caption: caption,
                  ratio: 3 / 2,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
