import { useState } from 'react';
import { Button, Card, Portal } from 'neba';

export default function PortalHero() {
  const [shown, setShown] = useState(false);

  return (
    <div className="flex flex-col items-start gap-3">
      <Button onClick={() => setShown((open) => !open)}>
        {shown ? 'Hide the banner' : 'Show a banner on <body>'}
      </Button>

      {shown ? (
        <Portal>
          <Card
            className="fixed inset-x-0 top-0 z-50 rounded-none border-x-0 border-t-0 text-center"
            density="compact"
          >
            Rendered into <code>document.body</code>, pinned to the top of the window.
          </Card>
        </Portal>
      ) : null}

      <p className="text-sm text-(--neba-muted-fg)">
        The banner is written inside this preview and lands at the end of <code>&lt;body&gt;</code>,
        which is why <code>fixed</code> is measured against the window rather than this box.
      </p>
    </div>
  );
}
