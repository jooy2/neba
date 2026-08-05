import { Mockup } from 'neba';

export default function MockupWallpaper() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      <Mockup
        device="mobile"
        width={128}
        wallpaper="linear-gradient(160deg, oklch(62% 0.19 262), oklch(48% 0.16 318))"
      />
      <Mockup
        device="desktop"
        hardware="laptop"
        width={300}
        wallpaper="radial-gradient(120% 120% at 20% 0%, oklch(72% 0.13 196), oklch(38% 0.12 262))"
      />
    </div>
  );
}
