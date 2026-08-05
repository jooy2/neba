import { Mockup } from 'neba';
import { DesktopScreen, PhoneScreen } from './screen';

export default function MockupDevices() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <Mockup device="desktop" width={380}>
        <DesktopScreen />
      </Mockup>
      <Mockup device="tablet" width={150}>
        <DesktopScreen />
      </Mockup>
      <Mockup device="mobile" width={110}>
        <PhoneScreen />
      </Mockup>
    </div>
  );
}
