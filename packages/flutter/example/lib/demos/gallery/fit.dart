import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryFit extends StatelessWidget {
  const GalleryFit({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    // Square tiles hold landscapes and portraits alike, so a contain keeps
    // each whole and the letterbox fills the space around it with the picture
    // blurred.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGallery(
        items: photos.sublist(0, 6),
        columns: wide ? 3 : 2,
        fit: BoxFit.contain,
        letterbox: NebaImageLetterbox.blur,
      ),
    );
  }
}
