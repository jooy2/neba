import { AspectRatio } from 'neba';

const RATIOS: Array<{ label: string; ratio: string }> = [
  { label: '1 / 1', ratio: '1 / 1' },
  { label: '4 / 3', ratio: '4 / 3' },
  { label: '16 / 9', ratio: '16 / 9' },
  { label: '21 / 9', ratio: '21 / 9' }
];

export default function AspectRatioRatios() {
  return (
    <div className="grid w-full max-w-2xl grid-cols-2 gap-4 sm:grid-cols-4">
      {RATIOS.map(({ label, ratio }) => (
        <div key={label} className="flex flex-col gap-2">
          <AspectRatio
            ratio={ratio}
            rounded
            className="border border-(--neba-border) bg-(--neba-panel-hover)"
          >
            <div className="flex size-full items-center justify-center text-[0.75rem] text-(--neba-muted-fg)">
              {label}
            </div>
          </AspectRatio>
        </div>
      ))}
    </div>
  );
}
