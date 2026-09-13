import { Image, type NebaAspectFit } from 'neba';

const FITS: NebaAspectFit[] = ['cover', 'contain', 'fill', 'none', 'scale-down'];

export default function ImageFit() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-3 sm:grid-cols-3">
      {FITS.map((fit) => (
        <figure key={fit} className="m-0 flex flex-col gap-1.5">
          {/* A lone `height` sizes the box, and the box is wider than the
              portrait inside it, so every value has to give something up. */}
          <Image
            src="/samples/photos/red-umbrella-autumn-path.jpg"
            alt=""
            height={140}
            fit={fit}
            rounded
            className="bg-(--neba-panel-hover)"
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">fit="{fit}"</figcaption>
        </figure>
      ))}
    </div>
  );
}
