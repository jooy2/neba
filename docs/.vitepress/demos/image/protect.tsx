import { Image } from 'neba';

export default function ImageProtect() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-2">
      <Image
        src="/samples/photos/lighthouse-cliff-wildflowers.jpg"
        alt="A print of a lighthouse, offered without a right-click menu"
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
