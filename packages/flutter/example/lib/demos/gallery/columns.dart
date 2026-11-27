import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryColumns extends StatelessWidget {
  const GalleryColumns({super.key});

  @override
  Widget build(BuildContext context) {
    // A count that changes with the window is read off the window.
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = width >= NebaBreakpoint.lg.width
        ? 6
        : width >= NebaBreakpoint.sm.width
        ? 4
        : 2;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        alignItems: NebaAlignItems.stretch,
        spacing: 6,
        children: <Widget>[
          NebaGallery(
            items: photos.sublist(0, 6),
            columns: columns,
            gap: NebaGallery.gaps[NebaSize.xs],
            ratio: 3 / 2,
          ),
          NebaGallery(items: photos.sublist(0, 6), columns: 3, gap: 20, ratio: 3 / 2),
        ],
      ),
    );
  }
}
