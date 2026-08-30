import { useState } from 'react';
import { GaugeChart, Slider } from 'neba';

const thresholds = [
  { from: 70, color: 'warning' },
  { from: 90, color: 'danger' }
] as const;

export default function GaugeChartThresholds() {
  const [used, setUsed] = useState(45);

  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      <GaugeChart
        variant="outline"
        label="Disk used"
        caption="Disk used"
        value={used}
        thresholds={thresholds}
      />
      <Slider
        aria-label="Disk used"
        value={used}
        onValueChange={(value) => setUsed(value as number)}
      />
    </div>
  );
}
