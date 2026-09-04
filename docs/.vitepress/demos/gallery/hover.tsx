import { Gallery, type NebaGalleryHover } from 'neba';
import { photos } from './photos';

const hovers: NebaGalleryHover[] = ['none', 'lift', 'dim', 'zoom'];

export default function GalleryHover() {
  return (
    <div className="grid w-full max-w-3xl grid-cols-2 gap-6 sm:grid-cols-4">
      {hovers.map((hover) => (
        <div key={hover} className="flex flex-col gap-2">
          <code className="text-[0.75rem] text-(--neba-muted-fg)">{hover}</code>
          <Gallery
            items={[photos[hover === 'none' ? 0 : hovers.indexOf(hover)]]}
            columns={1}
            hover={hover}
            ratio="3 / 2"
          />
        </div>
      ))}
    </div>
  );
}
