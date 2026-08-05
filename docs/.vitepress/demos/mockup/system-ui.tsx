import { Mockup } from 'neba';
import { PhoneScreen } from './screen';

export default function MockupSystemUi() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">systemUi</span>
        <Mockup device="mobile" width={140}>
          <PhoneScreen />
        </Mockup>
      </div>
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">systemUi={'{false}'}</span>
        {/* The bars gave their space back rather than uncovering anything — and
            the cut-out stayed, because that one is a hole in the glass. */}
        <Mockup device="mobile" systemUi={false} width={140}>
          <PhoneScreen />
        </Mockup>
      </div>
    </div>
  );
}
