import { useState } from 'react';
import { Button, Reasoning } from 'neba';

export default function ReasoningStreaming() {
  const [streaming, setStreaming] = useState(false);

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <Reasoning streaming={streaming}>
        The panel opened when the stream started and folds itself away when it stops. What is left
        is a line saying it happened and how long it took.
      </Reasoning>
      <Button size="sm" variant="outline" onClick={() => setStreaming((on) => !on)}>
        {streaming ? 'Stop the stream' : 'Start the stream'}
      </Button>
    </div>
  );
}
