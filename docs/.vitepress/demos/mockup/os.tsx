import { Mockup, type NebaMockupOs } from 'neba';

const SYSTEMS: NebaMockupOs[] = ['macos', 'windows', 'linux'];

export default function MockupOs() {
  return (
    <div className="grid w-full grid-cols-1 gap-5 sm:grid-cols-3">
      {SYSTEMS.map((os) => (
        <div key={os} className="flex flex-col gap-2">
          <span className="text-[0.75rem] text-(--neba-muted-fg)">{os}</span>
          <Mockup device="desktop" os={os} bezel="thin" wallpaper="var(--neba-panel-hover)" />
        </div>
      ))}
    </div>
  );
}
