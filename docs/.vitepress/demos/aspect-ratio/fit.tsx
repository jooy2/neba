import { AspectRatio, type NebaAspectFit } from 'neba';

const FITS: NebaAspectFit[] = ['cover', 'contain', 'fill'];

export default function AspectRatioFit() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-3">
      {FITS.map((fit) => (
        <div key={fit} className="flex flex-col gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{fit}</span>
          {/* The source is 2:3 and the box is square, so each value has to give
              something up: `cover` crops, `contain` letterboxes, `fill` squashes. */}
          <AspectRatio ratio={1} fit={fit} rounded className="bg-(--neba-panel-hover)">
            <img
              src="/samples/photos/red-umbrella-autumn-path.jpg"
              alt="A red umbrella lying on a wet path of fallen leaves"
            />
          </AspectRatio>
        </div>
      ))}
    </div>
  );
}
