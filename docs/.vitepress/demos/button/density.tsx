import { Button } from 'neba';

export default function ButtonDensity() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-3">
        <Button density="default">Save changes</Button>
        <Button density="default" variant="outline">
          Save changes
        </Button>
      </div>
      <div className="flex flex-wrap items-center gap-3">
        <Button density="compact">Save changes</Button>
        <Button density="compact" variant="outline">
          Save changes
        </Button>
      </div>
    </div>
  );
}
