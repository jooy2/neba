import { NumberField } from 'neba';

export default function NumberFieldLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <NumberField label="Top" defaultValue={3} min={1} />
      <NumberField labelPlacement="notch" label="Notch" defaultValue={3} min={1} />
      <NumberField labelPlacement="float" label="Float" min={1} placeholder="How many?" />
    </div>
  );
}
