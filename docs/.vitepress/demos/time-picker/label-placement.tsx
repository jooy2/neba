import { TimePicker } from 'neba';

export default function TimePickerLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <TimePicker labelPlacement="notch" label="Notch" placeholder="Pick a time" />
      <TimePicker
        labelPlacement="float"
        label="Float"
        placeholder="Pick a time"
        startIcon={false}
      />
    </div>
  );
}
