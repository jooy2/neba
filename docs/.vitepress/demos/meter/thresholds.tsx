import { useState } from 'react';
import { Meter, Slider } from 'neba';

const thresholds = [
  { from: 70, color: 'warning' },
  { from: 90, color: 'danger' }
] as const;

export default function MeterThresholds() {
  const [used, setUsed] = useState(45);

  return (
    <div className="flex w-full max-w-sm flex-col gap-6">
      <Meter value={used} label="Disk used" showValue thresholds={thresholds} />
      <Slider
        aria-label="Disk used"
        value={used}
        onValueChange={(value) => setUsed(value as number)}
      />
    </div>
  );
}
