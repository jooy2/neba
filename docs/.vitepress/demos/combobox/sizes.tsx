import { Combobox } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

const ITEMS = [
  { value: 'day', label: 'Day' },
  { value: 'week', label: 'Week' },
  { value: 'month', label: 'Month' }
];

export default function ComboboxSizes() {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Combobox key={size} items={ITEMS} size={size} defaultValue="week" />
        ))}
      </div>
      <div className="flex flex-wrap items-end gap-3">
        {SIZES.map((size) => (
          <Combobox key={size} multiple items={ITEMS} size={size} defaultValue={['week']} />
        ))}
      </div>
    </div>
  );
}
