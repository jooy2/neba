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
        device="mobile"
        width={128}
        wallpaper="url(/samples/photos/lighthouse-cliff-wildflowers.jpg) center / cover"
      />
      <Mockup
        device="desktop"
        hardware="laptop"
        width={300}
        wallpaper="url(/samples/photos/alpine-lake-dawn.jpg) center / cover"
      />
    </div>
  );
}
