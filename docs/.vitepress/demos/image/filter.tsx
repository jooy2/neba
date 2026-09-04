import { Image } from 'neba';

const filters = ['none', 'grayscale', 'sepia', 'mute', 'saturate', 'contrast'] as const;

const ORCHARD =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 160">
      <rect width="240" height="160" fill="#8fc4d6"/>
      <circle cx="196" cy="36" r="18" fill="#ffe7a8"/>
      <path d="M0 108 L60 76 L108 104 L164 68 L240 100 L240 160 L0 160 Z" fill="#5d8f5a"/>
      <path d="M0 130 L78 108 L146 132 L240 112 L240 160 L0 160 Z" fill="#39633c"/>
      <circle cx="52" cy="120" r="13" fill="#c8503f"/>
      <circle cx="188" cy="128" r="10" fill="#c8503f"/>
    </svg>`
  );

export default function ImageFilter() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-3 sm:grid-cols-3">
      {filters.map((filter) => (
        <figure key={filter} className="m-0 flex flex-col gap-1.5">
          <Image src={ORCHARD} alt="" ratio="3 / 2" rounded filter={filter} />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">{filter}</figcaption>
        </figure>
      ))}
    </div>
  );
}
