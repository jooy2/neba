import { Image } from 'neba';

export default function ImagePreview() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-2">
      <Image
        src="/samples/photos/vintage-camera-maple-leaves.jpg"
        alt="An old rangefinder camera among fallen maple leaves, enlarged on click"
        ratio={1}
        rounded="lg"
        preview
      />
      <span className="text-sm text-(--neba-muted-fg)">
        Click it, or reach it with <kbd>Tab</kbd> and press <kbd>Enter</kbd>.
      </span>
    </div>
  );
}
