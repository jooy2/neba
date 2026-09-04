import { Image, type NebaImageFrame } from 'neba';

const PORTRAIT =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
      <rect width="200" height="200" fill="#3b4a6b"/>
      <circle cx="100" cy="82" r="38" fill="#e8c39e"/>
      <path d="M28 200c0-40 32-62 72-62s72 22 72 62Z" fill="#6f86bd"/>
    </svg>`
  );

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
          <Image src={PORTRAIT} alt="" ratio={1} frame={each.frame} />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">{each.label}</figcaption>
        </figure>
      ))}
    </div>
  );
}
