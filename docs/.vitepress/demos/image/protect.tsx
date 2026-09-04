import { Image } from 'neba';

const PRINT =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 300">
      <rect width="240" height="300" fill="#f3ece1"/>
      <circle cx="120" cy="110" r="58" fill="#d9714f"/>
      <path d="M40 300 L120 168 L200 300 Z" fill="#2f4a3c"/>
      <rect x="40" y="248" width="160" height="6" fill="#b9a894"/>
    </svg>`
  );

export default function ImageProtect() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-2">
      <Image
        src={PRINT}
        alt="A print, offered without a right-click menu"
        ratio="4 / 5"
        rounded="lg"
        protect
        watermark={{ content: 'proof', position: 'top-start', size: 'sm', color: '#2f4a3c' }}
      />
      <span className="text-sm text-(--neba-muted-fg)">
        Try to right-click it, drag it out, or select across it.
      </span>
    </div>
  );
}
