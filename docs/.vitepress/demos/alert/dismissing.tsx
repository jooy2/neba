import { useState } from 'react';
import { Alert, Button } from 'neba';

export default function AlertDismissing() {
  const [shown, setShown] = useState(true);

  return (
    <div className="flex w-full flex-col items-start gap-3">
      {shown ? (
        <Alert
          color="info"
          title="A new version is available"
          action={
            <Button size="xs" variant="outline" color="info">
              Reload
            </Button>
          }
          closeLabel="Dismiss the update notice"
          onClose={() => setShown(false)}
        >
          Version 2.4 fixes the deploy log ordering.
        </Alert>
      ) : (
        <Button size="sm" variant="text" onClick={() => setShown(true)}>
          Bring it back
        </Button>
      )}
    </div>
  );
}
