import { Badge, Button } from 'neba';

const COLORS = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

export default function BadgeVariants() {
  return (
    <div className="flex flex-col gap-4">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <div key={variant} className="flex flex-wrap items-center gap-5">
          {COLORS.map((color) => (
            <Badge key={color} variant={variant} color={color} content={8}>
              <Button variant="outline" color="secondary" size="sm">
                {color}
              </Button>
            </Badge>
          ))}
        </div>
      ))}
    </div>
  );
}
