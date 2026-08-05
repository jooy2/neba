import { Mockup, type NebaMockupNotch } from 'neba';

const NOTCHES: NebaMockupNotch[] = ['dynamic-island', 'notch', 'punch-hole', 'none'];

export default function MockupNotch() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-5">
      {NOTCHES.map((notch) => (
        <div key={notch} className="flex flex-col items-center gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{notch}</span>
          <Mockup device="mobile" notch={notch} width={112} />
        </div>
      ))}
    </div>
  );
}
