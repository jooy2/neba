import { NumberField } from 'neba';

export default function NumberFieldStates() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <NumberField label="Read-only" readOnly defaultValue={4} />
      <NumberField label="Disabled" disabled defaultValue={4} />
      <NumberField label="Seats" min={1} error="At least one seat." defaultValue={0} />
      <NumberField label="Clamped" min={0} max={5} defaultValue={5} description="0 to 5." />
    </div>
  );
}
