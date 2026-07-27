import { DatePicker } from 'neba';

const DAY = new Date(2026, 6, 27);

export default function DatePickerVariants() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <DatePicker variant="solid" label="Solid" defaultValue={DAY} />
      <DatePicker variant="outline" label="Outline" defaultValue={DAY} />
      <DatePicker variant="text" label="Text" defaultValue={DAY} />
    </div>
  );
}
