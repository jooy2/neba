import { NumberField } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function NumberFieldSizes() {
  return (
    <div className="flex flex-wrap items-end gap-3">
      {SIZES.map((size) => (
        <NumberField key={size} size={size} defaultValue={8} min={0} className="w-32" />
      ))}
    </div>
  );
}
