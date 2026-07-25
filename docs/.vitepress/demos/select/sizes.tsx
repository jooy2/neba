import { Select } from 'neba';

const SIZES = ['xs', 'sm', 'md', 'lg', 'xl'] as const;

const ITEMS = [
  { value: 'day', label: 'Day' },
  { value: 'week', label: 'Week' },
  { value: 'month', label: 'Month' }
];

export default function SelectSizes() {
  return (
    <div className="flex flex-wrap items-end gap-3">
      {SIZES.map((size) => (
        <Select key={size} items={ITEMS} size={size} defaultValue="week" />
      ))}
    </div>
  );
}
