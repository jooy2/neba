import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

class GalleryHover extends StatelessWidget {
  const GalleryHover({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaGridContainer(
        spacing: 6,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final NebaGalleryHover hover in NebaGalleryHover.values)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 3 : 6),
              child: NebaFlex(
                direction: NebaOrientation.vertical,
                alignItems: NebaAlignItems.stretch,
                spacing: 2,
                children: <Widget>[
                  Text(hover.name, style: TextStyle(fontSize: 12, color: tokens.mutedFg)),
                  NebaGallery(
                    items: <NebaGalleryItem>[
                      photos[hover == NebaGalleryHover.none ? 0 : hover.index],
                    ],
                    columns: 1,
                    hover: hover,
                    ratio: 3 / 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
