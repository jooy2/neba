import { AnimateZoom, Card } from 'neba';

export default function AnimateZoomVisible() {
  return (
    <div className="h-56 w-full max-w-sm overflow-y-auto">
      <div className="flex h-40 items-center justify-center text-sm text-(--neba-muted-fg)">
        Scroll down
      </div>

      <AnimateZoom trigger="visible" threshold={0.6} duration={600}>
        <Card title="Here it is" size="sm">
          It ran when six tenths of it was on screen, and only the first time.
        </Card>
      </AnimateZoom>

      <div className="h-40" />
    </div>
  );
}
