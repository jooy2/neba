import { Image, type NebaImageFrame } from 'neba';

const frames: Array<{ label: string; frame: NebaImageFrame }> = [
  { label: 'circle', frame: 'circle' },
  { label: 'cut', frame: 'cut' },
  { label: 'arch', frame: 'arch' },
  { label: 'mounted', frame: { mat: 10, border: true, elevation: 2 } },
  { label: 'feathered', frame: { shape: 'rect', feather: '10%' } },
  { label: 'heavy line', frame: { corner: 'xl', border: 3, borderColor: '#c8503f' } }
];

export default function ImageFrame() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-3 gap-4">
      {frames.map((each) => (
        <figure key={each.label} className="m-0 flex flex-col gap-1.5">
          <Image
            src="/samples/photos/red-umbrella-autumn-path.jpg"
            alt=""
            ratio={1}
            frame={each.frame}
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">{each.label}</figcaption>
        </figure>
      ))}
    </div>
  );
}
