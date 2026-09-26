import { DatePicker } from 'neba';

export default function DatePickerLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <DatePicker labelPlacement="notch" label="Notch" placeholder="Pick a day" />
      <DatePicker labelPlacement="float" label="Float" placeholder="Pick a day" startIcon={false} />
    </div>
  );
}
