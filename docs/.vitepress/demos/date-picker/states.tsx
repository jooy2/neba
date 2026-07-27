import { DatePicker } from 'neba';

const DAY = new Date(2026, 6, 27);

export default function DatePickerStates() {
  return (
    <div className="flex flex-wrap items-start gap-4">
      <DatePicker label="Read-only" readOnly defaultValue={DAY} />
      <DatePicker label="Disabled" disabled defaultValue={DAY} />
      <DatePicker label="Invalid" placeholder="Pick a day" error="A date is required." />
      <DatePicker label="With help" description="Local time." defaultValue={DAY} />
    </div>
  );
}
