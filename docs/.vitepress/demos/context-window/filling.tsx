import { useState } from 'react';
import { ContextWindow, Slider } from 'neba';

const MAX = 200_000;

export default function ContextWindowFilling() {
  const [used, setUsed] = useState(48_000);

  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <ContextWindow
        locale="en-US"
        max={MAX}
        used={used}
        tokens={{ input: Math.round(used * 0.72), output: Math.round(used * 0.28) }}
        thresholds={[
          { from: MAX * 0.7, color: 'warning' },
          { from: MAX * 0.9, color: 'danger' }
        ]}
      />
      <Slider
        aria-label="Tokens used"
        max={MAX}
        step={1000}
        value={used}
        onValueChange={(value) => setUsed(value as number)}
      />
    </div>
  );
}
