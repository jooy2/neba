import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/gallery/data/photos.dart';

// A quilt is the one layout that reads the item's own spans, so the set is
// given a couple of larger tiles before it is handed over.
final List<NebaGalleryItem> _quilted = <NebaGalleryItem>[
  for (int index = 0; index < photos.length; index++)
    index % 5 == 0
        ? NebaGalleryItem(
            image: photos[index].image,
            alt: photos[index].alt,
            title: photos[index].title,
            description: photos[index].description,
            ratio: photos[index].ratio,
            cols: 2,
            rows: 2,
          )
        : photos[index],
];

class GalleryLayouts extends StatefulWidget {
  const GalleryLayouts({super.key});

  @override
  State<GalleryLayouts> createState() => _GalleryLayoutsState();
}

class _GalleryLayoutsState extends State<GalleryLayouts> {
  NebaGalleryLayout _layout = NebaGalleryLayout.grid;

  @override
  Widget build(BuildContext context) {
    final bool quilted = _layout == NebaGalleryLayout.quilted;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        alignItems: NebaAlignItems.stretch,
        spacing: 4,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: NebaSegmentedButton<NebaGalleryLayout>(
              semanticLabel: 'Layout',
              value: _layout,
              onValueChange: (NebaGalleryLayout? value) =>
                  setState(() => _layout = value ?? _layout),
              children: <NebaSegment<NebaGalleryLayout>>[
                for (final NebaGalleryLayout layout in NebaGalleryLayout.values)
                  NebaSegment<NebaGalleryLayout>(value: layout, child: Text(layout.name)),
              ],
            ),
          ),
          NebaGallery(
            items: quilted ? _quilted : photos,
            layout: _layout,
            rowHeight: quilted ? 96 : 180,
            label: 'Field notes',
          ),
        ],
      ),
    );
  }
}
