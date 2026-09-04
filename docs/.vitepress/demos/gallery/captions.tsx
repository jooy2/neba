import { Gallery, type NebaGalleryCaption } from 'neba';
import { photos } from './photos';

const captions: NebaGalleryCaption[] = ['below', 'overlay', 'hover'];

export default function GalleryCaptions() {
  return (
    <div className="flex w-full max-w-3xl flex-col gap-6">
      {captions.map((caption) => (
        <div key={caption} className="flex flex-col gap-2">
          <code className="text-[0.75rem] text-(--neba-muted-fg)">caption="{caption}"</code>
          <Gallery items={photos.slice(0, 4)} columns={4} caption={caption} ratio="3 / 2" />
        </div>
      ))}
    </div>
  );
}
