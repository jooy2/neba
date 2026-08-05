import { Mockup } from 'neba';
import { DesktopScreen } from './screen';

export default function MockupHardware() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">monitor</span>
        <Mockup device="desktop" hardware="monitor" width={340}>
          <DesktopScreen />
        </Mockup>
      </div>
      <div className="flex flex-col items-center gap-2">
        <span className="text-[0.75rem] text-(--neba-muted-fg)">laptop</span>
        <Mockup device="desktop" hardware="laptop" os="macos" width={340}>
          <DesktopScreen />
        </Mockup>
      </div>
    </div>
  );
}
