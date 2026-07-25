import { useState } from 'react';
import { Slider } from 'neba';

export default function SliderRange() {
  const [range, setRange] = useState<number[]>([200, 800]);

  return (
    <div className="w-full max-w-md">
      <Slider
        label="Price"
        min={0}
        max={1000}
        step={50}
        value={range}
        onValueChange={(next) => setRange(next as number[])}
        showValue={(formatted) => `$${formatted[0]} – $${formatted[1]}`}
      />
    </div>
  );
}
