import { DateTimePicker } from 'neba';

export default function DateTimePickerLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <DateTimePicker labelPlacement="notch" label="Notch" placeholder="Pick a moment" />
      <DateTimePicker
        labelPlacement="float"
        label="Float"
        placeholder="Pick a moment"
        startIcon={false}
      />
    </div>
  );
}
