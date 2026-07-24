import { Button } from 'neba';

export default function ButtonStates() {
  return (
    <div className="flex flex-col gap-3">
      {(['solid', 'outline', 'text'] as const).map((variant) => (
        <div key={variant} className="flex flex-wrap items-center gap-2">
          <Button variant={variant}>Normal</Button>
          <Button variant={variant} loading>
            Loading
          </Button>
          <Button variant={variant} disabled>
            Disabled
          </Button>
          <Button variant={variant} readOnly>
            Read-only
          </Button>
        </div>
      ))}
    </div>
  );
}
