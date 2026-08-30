import { HoverCard, Button } from 'neba';

const sides = ['top', 'right', 'bottom', 'left'] as const;

export default function HoverCardPlacement() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {sides.map((side) => (
        <HoverCard
          key={side}
          side={side}
          arrow
          size="sm"
          trigger={
            <Button size="sm" variant="outline">
              {side}
            </Button>
          }
          title="Deploy 4f21c8"
        >
          Built in 42s, shipped to production.
        </HoverCard>
      ))}
    </div>
  );
}
