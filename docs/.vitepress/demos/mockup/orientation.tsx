import { Mockup } from 'neba';
import { DesktopScreen } from './screen';

/** The bezel and the cut-out turn with the screen. */
export default function MockupOrientation() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <Mockup device="tablet" orientation="portrait" width={150}>
        <DesktopScreen />
      </Mockup>
      <Mockup device="tablet" orientation="landscape" width={230}>
        <DesktopScreen />
      </Mockup>
      <Mockup device="mobile" orientation="landscape" notch="notch" width={200} />
    </div>
  );
}
