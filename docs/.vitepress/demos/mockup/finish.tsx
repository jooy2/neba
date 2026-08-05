import { Mockup, type NebaMockupFinish } from 'neba';

const FINISHES: NebaMockupFinish[] = ['graphite', 'silver', 'white'];

export default function MockupFinish() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-5">
      {FINISHES.map((finish) => (
        <div key={finish} className="flex flex-col items-center gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{finish}</span>
          <Mockup device="mobile" finish={finish} elevation={1} width={112} />
        </div>
      ))}
    </div>
  );
}
