import { Image, type NebaImagePosition } from 'neba';

const POSITIONS: NebaImagePosition[] = ['top', 'center', 'bottom'];

export default function ImagePosition() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-1 gap-3 sm:grid-cols-3">
      {POSITIONS.map((position) => (
        <figure key={position} className="m-0 flex flex-col gap-1.5">
          {/* A tall photograph in a short box: `cover` has to crop, and
              `position` says which part of it stays. */}
          <Image
            src="/samples/photos/lighthouse-cliff-wildflowers.jpg"
            alt=""
            height={120}
            position={position}
            rounded
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">
            position="{position}"
          </figcaption>
        </figure>
      ))}
    </div>
  );
}
