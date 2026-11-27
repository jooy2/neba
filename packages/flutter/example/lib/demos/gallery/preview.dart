import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryPreview extends StatelessWidget {
  const GalleryPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        alignItems: NebaAlignItems.stretch,
        spacing: 2,
        children: <Widget>[
          NebaGallery(
            items: photos.sublist(0, 6),
            layout: NebaGalleryLayout.masonry,
            columns: wide ? 3 : 2,
            preview: true,
            watermark: const NebaImageWatermark('© Neba'),
            protect: true,
            label: 'Field notes',
          ),
          Text(
            'Open one, then use the left and right arrow keys.',
            style: TextStyle(fontSize: 14, color: tokens.mutedFg),
          ),
        ],
      ),
    );
  }
}
