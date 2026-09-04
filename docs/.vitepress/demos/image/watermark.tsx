import { Image } from 'neba';

const ROWBOAT = '/samples/photos/rowboat-misty-pond-sunrise.jpg';

export default function ImageWatermark() {
  return (
    <div className="grid w-full max-w-xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Image
        src={ROWBOAT}
        alt="A rowboat moored on a misty pond"
        ratio="3 / 2"
        rounded
        watermark="© Neba"
      />

      <Image
        src={ROWBOAT}
        alt="A rowboat moored on a misty pond, marked as a proof"
        ratio="3 / 2"
        rounded
        watermark={{ content: 'PROOF · DO NOT COPY', repeat: true, opacity: 0.22 }}
      />
    </div>
  );
}
