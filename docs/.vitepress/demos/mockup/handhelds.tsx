import { Mockup } from 'neba';

/**
 * A phone runs `ios` or `android`, a tablet `ipados` or `android`. The status
 * bar, the bar at the bottom and the cut-out all follow from the pair.
 */
export default function MockupHandhelds() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">ios</span>
        <Mockup device="mobile" os="ios" width={128} />
      </div>
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">android</span>
        <Mockup device="mobile" os="android" width={128} />
      </div>
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">ipados</span>
        <Mockup device="tablet" os="ipados" width={168} />
      </div>
    </div>
  );
}
