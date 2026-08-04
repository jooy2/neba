import { AspectRatio, type NebaAspectFit } from 'neba';
import { photo } from './photo';

const FITS: NebaAspectFit[] = ['cover', 'contain', 'fill'];

export default function AspectRatioFit() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      {FITS.map((fit) => (
        <div key={fit} className="flex flex-col gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{fit}</span>
          {/* The source is 3:4 and the box is square, so each value has to give
              something up: `cover` crops, `contain` letterboxes, `fill` squashes. */}
          <AspectRatio ratio={1} fit={fit} rounded className="bg-(--neba-panel-hover)">
            <img src={photo(148)} alt="A ridge of hills under a low sun" />
          </AspectRatio>
        </div>
      ))}
    </div>
  );
}
