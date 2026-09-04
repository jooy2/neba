import { useState } from 'react';
import { Gallery, Segment, SegmentedButton, type NebaGalleryLayout } from 'neba';
import { photos } from './photos';

const layouts: NebaGalleryLayout[] = ['grid', 'masonry', 'justified', 'quilted'];

// A quilt is the one layout that reads the item's own spans, so the set is
// given a couple of larger tiles before it is handed over.
const quilted = photos.map((photo, index) =>
  index % 5 === 0 ? { ...photo, cols: 2, rows: 2 } : photo
);

export default function GalleryLayouts() {
  const [layout, setLayout] = useState<NebaGalleryLayout>('grid');

  return (
    <div className="flex w-full max-w-3xl flex-col gap-4">
      <SegmentedButton
        aria-label="Layout"
        value={layout}
        onValueChange={(value) => setLayout(value as NebaGalleryLayout)}
      >
        {layouts.map((each) => (
          <Segment key={each} value={each}>
            {each}
          </Segment>
        ))}
      </SegmentedButton>

      <Gallery
        items={layout === 'quilted' ? quilted : photos}
        layout={layout}
        columns={{ xs: 2, sm: 3, lg: 4 }}
        rowHeight={layout === 'quilted' ? 96 : 180}
        label="Field notes"
      />
    </div>
  );
}
