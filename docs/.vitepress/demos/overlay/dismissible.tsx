import { useState } from 'react';
import { Button, Card, Overlay } from 'neba';

export default function OverlayDismissible() {
  const [held, setHeld] = useState(false);
  const [loose, setLoose] = useState(false);

  return (
    <>
      <div className="flex flex-wrap gap-2">
        <Button variant="outline" onClick={() => setHeld(true)}>
          Cannot be dismissed
        </Button>
        <Button variant="outline" onClick={() => setLoose(true)}>
          Click anywhere to close
        </Button>
      </div>

      <Overlay open={held} label="Working">
        <Card
          title="No way past this"
          subtitle="Escape and a click outside are both refused."
          footer={<Button onClick={() => setHeld(false)}>Let me out</Button>}
        />
      </Overlay>

      <Overlay
        open={loose}
        onOpenChange={setLoose}
        dismissible
        tone="scrim"
        label="Dismissible overlay"
      >
        <p className="m-0 text-(--neba-fg)">Click the scrim, or press Escape.</p>
      </Overlay>
    </>
  );
}
