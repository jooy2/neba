import { Mockup, type NebaMockupBezel } from 'neba';

const BEZELS: NebaMockupBezel[] = ['none', 'thin', 'standard', 'thick'];

export default function MockupBezel() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-5">
      {BEZELS.map((bezel) => (
        <div key={bezel} className="flex flex-col items-center gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{bezel}</span>
          {/* `thick` is an older phone rather than a wider frame: narrow sides,
              a forehead and a chin — and no cut-out, because a device with that
              much bezel had nowhere to put one. */}
          <Mockup
            device="mobile"
            bezel={bezel}
            notch={bezel === 'thick' ? 'none' : undefined}
            width={112}
          />
        </div>
      ))}
    </div>
  );
}
