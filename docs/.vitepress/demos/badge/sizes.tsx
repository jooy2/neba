import { Badge, Button } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function BadgeSizes() {
  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-wrap items-center gap-6">
        {SIZES.map((size) => (
          <Badge key={size} size={size} content={12}>
            <Button size={size} variant="outline" color="secondary">
              {size}
            </Button>
          </Badge>
        ))}
      </div>
      <div className="flex flex-wrap items-center gap-6">
        {SIZES.map((size) => (
          <Badge key={size} size={size} dot color="success">
            <Button size={size} variant="outline" color="secondary">
              {size}
            </Button>
          </Badge>
        ))}
      </div>
    </div>
  );
}
