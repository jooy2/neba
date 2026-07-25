import { Alert, Button } from 'neba';

export default function AlertHero() {
  return (
    <div className="flex w-full flex-col gap-3">
      <Alert color="success">Your changes have been saved.</Alert>
      <Alert
        color="danger"
        title="Deploy failed"
        action={
          <Button size="xs" variant="outline" color="danger">
            Retry
          </Button>
        }
        onClose={() => {}}
      >
        The build exited with code 1. Check the logs for the failing step.
      </Alert>
    </div>
  );
}
