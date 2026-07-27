import { DatePicker } from 'neba';

const today = new Date();
const inTwoWeeks = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 14);

/** Saturday and Sunday, as `Date.prototype.getDay` counts them. */
const isWeekend = (date: Date) => date.getDay() === 0 || date.getDay() === 6;

export default function DatePickerBounds() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <DatePicker
        label="Within a fortnight"
        placeholder="Pick a day"
        minDate={today}
        maxDate={inTwoWeeks}
      />
      <DatePicker
        label="Weekdays only"
        placeholder="Pick a day"
        shouldDisableDate={isWeekend}
        description="Weekends stay in the grid, greyed out."
      />
    </div>
  );
}
