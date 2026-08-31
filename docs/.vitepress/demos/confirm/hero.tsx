import { useState } from 'react';
import { Button, ConfirmProvider, Typography, useConfirm } from 'neba';

function Actions({ onLog }: { onLog: (line: string) => void }) {
  const confirm = useConfirm();

  return (
    <div className="flex flex-wrap gap-2">
      <Button
        color="danger"
        onClick={async () => {
          const yes = await confirm({
            title: 'Delete the project?',
            description: 'Everything in it goes with it. This cannot be undone.',
            confirmLabel: 'Delete',
            color: 'danger'
          });

          onLog(yes ? 'Deleted the project.' : 'Kept the project.');
        }}
      >
        Delete project
      </Button>

      <Button
        variant="outline"
        onClick={async () => {
          await confirm({ title: 'Your export is ready.', alert: true });
          onLog('Acknowledged the export.');
        }}
      >
        Show an alert
      </Button>
    </div>
  );
}

export default function ConfirmHero() {
  const [log, setLog] = useState<string[]>([]);

  return (
    <ConfirmProvider>
      <div className="flex flex-col gap-3">
        <Actions onLog={(line) => setLog((all) => [line, ...all].slice(0, 3))} />

        <Typography level="caption" className="text-(--neba-muted-fg)">
          {log.length === 0 ? 'Nothing answered yet.' : log.join(' · ')}
        </Typography>
      </div>
    </ConfirmProvider>
  );
}
