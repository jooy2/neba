import { useState } from 'react';
import { Button, Overlay, ProgressCircular } from 'neba';

export default function OverlayHero() {
  const [open, setOpen] = useState(false);

  function run() {
    setOpen(true);
    window.setTimeout(() => setOpen(false), 2200);
  }

  return (
    <>
      <Button onClick={run}>Publish</Button>

      <Overlay open={open} tone="blur" label="Publishing">
        <div className="flex flex-col items-center gap-3 text-(--neba-fg)">
          <ProgressCircular size="lg" />
          <p className="m-0 text-sm">Publishing your site…</p>
        </div>
      </Overlay>
    </>
  );
}
