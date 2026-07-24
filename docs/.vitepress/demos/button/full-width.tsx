import { Button } from 'neba';

export default function ButtonFullWidth() {
  return (
    <div className="flex max-w-sm flex-col gap-2">
      <Button fullWidth size="lg">
        Create workspace
      </Button>
      <Button fullWidth variant="text" color="secondary">
        Maybe later
      </Button>
    </div>
  );
}
