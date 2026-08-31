import { Image } from 'neba';

const CARD =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
      <rect width="240" height="240" fill="#1f2a44"/>
      <circle cx="120" cy="96" r="44" fill="#5b8def"/>
      <rect x="40" y="164" width="160" height="14" rx="7" fill="#3a4a6b"/>
      <rect x="64" y="190" width="112" height="10" rx="5" fill="#2e3c58"/>
    </svg>`
  );

export default function ImagePreview() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-2">
      <Image src={CARD} alt="A member card, enlarged on click" ratio={1} rounded="lg" preview />
      <span className="text-sm text-(--neba-muted-fg)">
        Click it, or reach it with <kbd>Tab</kbd> and press <kbd>Enter</kbd>.
      </span>
    </div>
  );
}
