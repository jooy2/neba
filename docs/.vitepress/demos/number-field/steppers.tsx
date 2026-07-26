import { NumberField } from 'neba';

export default function NumberFieldSteppers() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <NumberField label="End" steppers="end" defaultValue={2} min={0} />
      <NumberField label="Split" steppers="split" defaultValue={2} min={0} />
      <NumberField label="None" steppers="none" defaultValue={2} min={0} />
    </div>
  );
}
