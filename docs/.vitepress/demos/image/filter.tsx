import { Image } from 'neba';

const filters = ['none', 'grayscale', 'sepia', 'mute', 'saturate', 'contrast'] as const;

export default function ImageFilter() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-3 sm:grid-cols-3">
      {filters.map((filter) => (
        <figure key={filter} className="m-0 flex flex-col gap-1.5">
          <Image
            src="/samples/photos/fresh-vegetables-market-stall.jpg"
            alt=""
            ratio="3 / 2"
            rounded
            filter={filter}
          />
          <figcaption className="text-[0.75rem] text-(--neba-muted-fg)">{filter}</figcaption>
        </figure>
      ))}
    </div>
  );
}
