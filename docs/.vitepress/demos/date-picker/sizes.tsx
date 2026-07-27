import { DatePicker } from 'neba';

const DAY = new Date(2026, 6, 27);

export default function DatePickerSizes() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <DatePicker size="xs" label="xs" defaultValue={DAY} />
      <DatePicker size="sm" label="sm" defaultValue={DAY} />
      <DatePicker size="md" label="md" defaultValue={DAY} />
      <DatePicker size="lg" label="lg" defaultValue={DAY} />
      <DatePicker size="xl" label="xl" defaultValue={DAY} />
    </div>
  );
}
