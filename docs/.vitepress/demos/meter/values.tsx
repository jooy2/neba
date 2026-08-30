import { Meter } from 'neba';

export default function MeterValues() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-5">
      <Meter value={12} min={0} max={20} label="Members" showValue />
      <Meter
        value={12}
        min={0}
        max={20}
        label="Members"
        showValue
        format={{ style: 'unit', unit: 'gigabyte', unitDisplay: 'short' }}
      />
      <Meter
        value={4.8}
        min={0}
        max={16}
        label="Memory"
        showValue
        format={{ maximumFractionDigits: 1, style: 'unit', unit: 'gigabyte' }}
      />
    </div>
  );
}
