import { DateRangePicker } from 'neba';

const today = new Date();
const inThirtyDays = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);

export default function DateRangePickerOneMonth() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <DateRangePicker
        label="One panel"
        monthCount={1}
        startPlaceholder="From"
        endPlaceholder="To"
      />
      <DateRangePicker
        label="Next thirty days"
        minDate={today}
        maxDate={inThirtyDays}
        startPlaceholder="From"
        endPlaceholder="To"
      />
    </div>
  );
}
