import { Button, HoverCard } from 'neba';

const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function HoverCardSizes() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-3">
      {sizes.map((size) => (
        <HoverCard
          key={size}
          size={size}
          trigger={
            <Button size={size} variant="outline">
              {size}
            </Button>
          }
          title="Frankfurt"
          description="eu-central-1"
        >
          Four instances, all healthy.
        </HoverCard>
      ))}
    </div>
  );
}
