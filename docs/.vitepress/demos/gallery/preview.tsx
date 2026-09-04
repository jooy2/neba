import { Gallery } from 'neba';
import { photos } from './photos';

export default function GalleryPreview() {
  return (
    <div className="flex w-full max-w-2xl flex-col gap-2">
      <Gallery
        items={photos.slice(0, 6)}
        layout="masonry"
        columns={{ xs: 2, sm: 3 }}
        preview
        watermark="© Neba"
        protect
        label="Field notes"
      />
      <span className="text-sm text-(--neba-muted-fg)">
        Open one, then use <kbd>←</kbd> and <kbd>→</kbd>.
      </span>
    </div>
  );
}
