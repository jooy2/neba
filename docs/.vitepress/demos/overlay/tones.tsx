import { useState } from 'react';
import { Button, Overlay, Typography } from 'neba';
import type { OverlayTone } from 'neba';

const TONES: OverlayTone[] = ['scrim', 'blur', 'solid', 'clear'];

export default function OverlayTones() {
  const [tone, setTone] = useState<OverlayTone | null>(null);

  return (
    <>
      <div className="flex flex-wrap gap-2">
        {TONES.map((name) => (
          <Button key={name} variant="outline" onClick={() => setTone(name)}>
            {name}
          </Button>
        ))}
      </div>

      <Overlay
        open={tone !== null}
        onOpenChange={(next) => !next && setTone(null)}
        tone={tone ?? 'scrim'}
        dismissible
        label={`${tone} overlay`}
      >
        <div className="flex flex-col items-center gap-3">
          <Typography level="h4">tone=&ldquo;{tone}&rdquo;</Typography>
          <Button onClick={() => setTone(null)}>Close</Button>
        </div>
      </Overlay>
    </>
  );
}
