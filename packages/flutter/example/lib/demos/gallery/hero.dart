import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryHero extends StatelessWidget {
  const GalleryHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaGallery(
        items: photos.sublist(0, 8),
        layout: NebaGalleryLayout.justified,
        rowHeight: 160,
        caption: NebaGalleryCaption.hover,
        hover: NebaGalleryHover.zoom,
        preview: true,
        label: 'Field notes',
      ),
    );
  }
}
