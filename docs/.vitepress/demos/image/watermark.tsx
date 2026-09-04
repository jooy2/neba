import { Image } from 'neba';

const HARBOUR =
  'data:image/svg+xml,' +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 200">
      <rect width="300" height="200" fill="#20476b"/>
      <circle cx="60" cy="46" r="20" fill="#ffd98a"/>
      <path d="M0 132 L300 132 L300 200 L0 200 Z" fill="#123351"/>
      <path d="M120 132 L150 74 L180 132 Z" fill="#e9eef5"/>
      <rect x="146" y="60" width="4" height="72" fill="#e9eef5"/>
    </svg>`
  );

export default function ImageWatermark() {
  return (
    <div className="grid w-full max-w-xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Image src={HARBOUR} alt="A harbour at dusk" ratio="3 / 2" rounded watermark="© Neba" />

      <Image
        src={HARBOUR}
        alt="A harbour at dusk, marked as a proof"
        ratio="3 / 2"
        rounded
        watermark={{ content: 'PROOF · DO NOT COPY', repeat: true, opacity: 0.22 }}
      />
    </div>
  );
}
