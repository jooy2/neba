import { Carousel, Typography } from 'neba';

const COLORS = ['primary', 'success', 'warning', 'danger'] as const;

function Panel({ index }: { index: number }) {
  return (
    <div
      className="flex h-32 items-center justify-center"
      style={{ background: `var(--neba-${COLORS[index % COLORS.length]}-soft-press)` }}
    >
      <Typography level="h4">{index + 1}</Typography>
    </div>
  );
}

/**
 * The chrome is optional and the ends are a choice. Without `loop` the arrows go
 * inert at the ends rather than wrapping — which is the honest thing for a set
 * that has a first and a last.
 */
export default function CarouselOptions() {
  return (
    <div className="flex w-full flex-col gap-6">
      <div className="flex flex-col gap-2">
        <Typography level="caption">loop=&#123;false&#125;</Typography>
        <Carousel label="Not looping" loop={false} variant="text">
          {[0, 1, 2, 3].map((index) => (
            <Panel key={index} index={index} />
          ))}
        </Carousel>
      </div>

      <div className="flex flex-col gap-2">
        <Typography level="caption">arrows=&#123;false&#125; — dots and dragging only</Typography>
        <Carousel label="Dots only" arrows={false} variant="text">
          {[0, 1, 2, 3].map((index) => (
            <Panel key={index} index={index} />
          ))}
        </Carousel>
      </div>

      <div className="flex flex-col gap-2">
        <Typography level="caption">
          autoPlay — a button to stop it, and it pauses on hover, on focus and in a background tab
        </Typography>
        <Carousel label="Auto playing" autoPlay interval={2500} indicators variant="text">
          {[0, 1, 2, 3].map((index) => (
            <Panel key={index} index={index} />
          ))}
        </Carousel>
      </div>
    </div>
  );
}
