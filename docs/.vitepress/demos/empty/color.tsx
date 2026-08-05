import { Button, Empty } from 'neba';

export default function EmptyColor() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <Empty variant="outline" title="No events">
        Nothing has happened in the last hour.
      </Empty>

      <Empty
        variant="outline"
        color="danger"
        title="Could not load events"
        action={
          <Button size="sm" variant="outline" color="danger">
            Try again
          </Button>
        }
      >
        The request timed out after 30 seconds.
      </Empty>
    </div>
  );
}
