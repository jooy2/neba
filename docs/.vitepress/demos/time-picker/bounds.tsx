import { TimePicker } from 'neba';

const day = new Date();
const at = (hours: number, minutes = 0) =>
  new Date(day.getFullYear(), day.getMonth(), day.getDate(), hours, minutes);

export default function TimePickerBounds() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <TimePicker
        label="Office hours"
        placeholder="Pick a time"
        minTime={at(9, 30)}
        maxTime={at(17, 30)}
        minuteStep={15}
        description="09:30 leaves the 9 available and greys out the minutes before it."
      />
      <TimePicker
        label="No lunch hour"
        placeholder="Pick a time"
        minuteStep={30}
        shouldDisableTime={(value, unit) => unit === 'hour' && value.getHours() === 12}
      />
    </div>
  );
}
