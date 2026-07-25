import { Checkbox } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

export default function CheckboxSizes() {
  return (
    <div className="flex flex-col gap-3">
      {SIZES.map((size) => (
        <Checkbox key={size} size={size} label={size} defaultChecked />
      ))}
    </div>
  );
}
