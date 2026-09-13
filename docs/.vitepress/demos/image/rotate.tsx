import { Image, type NebaImageFlip, type NebaImageRotation } from 'neba';

const POSES: { label: string; rotate?: NebaImageRotation; flip?: NebaImageFlip }[] = [
  { label: 'as stored' },
  { label: 'flip="horizontal"', flip: 'horizontal' },
  { label: 'rotate={90}', rotate: 90 },
  { label: 'rotate={180}', rotate: 180 }
];

export default function ImageRotate() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 items-start gap-3 sm:grid-cols-4">
      {POSES.map(({ label, rotate, flip }) => (
        <figure key={label} className="m-0 flex flex-col gap-1.5">
          {/* `width` and `height` describe the file, so the turned picture
              reserves a box on its side before it has loaded. */}
          <Image
            src="/samples/photos/alpine-lake-dawn.jpg"
            alt=""
            width={560}
            height={373}
            rounded
            rotate={rotate}
            flip={flip}
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">{label}</figcaption>
        </figure>
      ))}
    </div>
  );
}
