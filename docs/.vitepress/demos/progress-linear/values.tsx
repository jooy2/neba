import { useEffect, useState } from 'react';
import { ProgressLinear } from 'neba';

export default function ProgressLinearValues() {
  const [sent, setSent] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => setSent((value) => (value >= 4000 ? 0 : value + 320)), 700);

    return () => clearInterval(timer);
  }, []);

  return (
    <div className="flex w-full max-w-96 flex-col gap-5">
      {/* A range that is not 0–100, shown as a percentage of itself. */}
      <ProgressLinear value={3} min={0} max={4} label="Step 3 of 4" showValue color="info" />

      {/* And the same range with the caller saying what the number means. */}
      <ProgressLinear
        value={sent}
        max={4000}
        label="Transferred"
        showValue
        format={{ style: 'unit', unit: 'megabyte' }}
      />
    </div>
  );
}
