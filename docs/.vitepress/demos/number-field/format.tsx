import { useState } from 'react';
import { NumberField } from 'neba';

export default function NumberFieldFormat() {
  const [rate, setRate] = useState<number | null>(0.075);

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-end gap-4">
        <NumberField
          label="Rate"
          value={rate}
          onValueChange={setRate}
          min={0}
          max={1}
          step={0.005}
          format={{ style: 'percent', minimumFractionDigits: 1 }}
        />
        <NumberField
          label="Weight"
          defaultValue={72.5}
          step={0.5}
          format={{ style: 'unit', unit: 'kilogram', unitDisplay: 'short' }}
        />
        <NumberField
          label="Won"
          defaultValue={39000}
          step={1000}
          locale="ko-KR"
          format={{ style: 'currency', currency: 'KRW' }}
        />
      </div>
      <p className="text-xs text-(--neba-muted-fg)">value: {String(rate)}</p>
    </div>
  );
}
