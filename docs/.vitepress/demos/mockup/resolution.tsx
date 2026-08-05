import { Mockup } from 'neba';

/**
 * Both mockups are drawn the same width on the page. What differs is the screen
 * behind that: 390 CSS pixels on the left and 1440 on the right, which is why
 * the same three cards stack on one and sit in a row on the other.
 */
export default function MockupResolution() {
  return (
    <div className="flex w-full flex-wrap items-start justify-center gap-5">
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">390 × 844</span>
        <Mockup device="mobile" bezel="thin" systemUi={false} notch="none" width={230}>
          <Cards />
        </Mockup>
      </div>
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">1440 × 900</span>
        <Mockup device="desktop" bezel="thin" systemUi={false} width={230}>
          <Cards />
        </Mockup>
      </div>
    </div>
  );
}

/**
 * A container query rather than a media query: the screen is a container named
 * `neba-screen`, so this answers to the device it is on rather than to the
 * window the page is in.
 */
function Cards() {
  return (
    <div className="grid grid-cols-1 gap-3 p-4 @min-[600px]/neba-screen:grid-cols-3">
      {['Requests', 'Error rate', 'Latency'].map((label) => (
        <div
          key={label}
          className="rounded-(--neba-radius-sm) border border-(--neba-border) bg-(--neba-primary-soft) p-4 text-[0.8125rem]"
        >
          {label}
        </div>
      ))}
    </div>
  );
}
