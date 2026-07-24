import { Card } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function CardSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      {SIZES.map((size) => (
        <Card key={size} size={size} dividers title={`size ${size}`} subtitle="Subtitle">
          Body copy sits one step below the title.
        </Card>
      ))}
    </div>
  );
}
