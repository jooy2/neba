import { NumberField } from 'neba';

export default function NumberFieldHero() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <NumberField label="Seats" defaultValue={3} min={1} max={20} />
      <NumberField
        label="Budget"
        defaultValue={1240}
        min={0}
        step={10}
        format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
        description="Shift steps by 10× and Alt by a tenth."
      />
    </div>
  );
}
