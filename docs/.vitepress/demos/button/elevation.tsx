import { Button } from 'neba';

export default function ButtonElevation() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <Button elevation={0} size="lg">
        elevation 0
      </Button>
      <Button elevation={1} size="lg">
        elevation 1
      </Button>
      <Button elevation={2} size="lg">
        elevation 2
      </Button>
      <Button elevation={3} size="lg">
        elevation 3
      </Button>
    </div>
  );
}
