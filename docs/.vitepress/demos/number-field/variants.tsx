import { NumberField } from 'neba';

export default function NumberFieldVariants() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <NumberField variant="solid" label="Solid" defaultValue={12} />
      <NumberField variant="outline" label="Outline" defaultValue={12} />
      <NumberField variant="text" label="Text" defaultValue={12} />
    </div>
  );
}
