import { DateRangePicker } from 'neba';

export default function DateRangePickerLabelPlacement() {
  return (
    <div className="flex flex-wrap items-end gap-x-4 gap-y-6">
      <DateRangePicker
        labelPlacement="notch"
        label="Notch"
        startPlaceholder="Check in"
        endPlaceholder="Check out"
      />
      <DateRangePicker
        labelPlacement="float"
        label="Float"
        startPlaceholder="Check in"
        endPlaceholder="Check out"
        startIcon={false}
      />
    </div>
  );
}
