import { DateTimePicker } from 'neba';

/** Now, to the minute — the ordinary "you cannot schedule into the past" rule. */
const now = new Date();

export default function DateTimePickerBounds() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <DateTimePicker
        label="Not before now"
        placeholder="Pick a moment"
        minDate={now}
        minuteStep={5}
        description="Today stays selectable; the hours already gone do not."
      />
      <DateTimePicker
        label="24-hour, with seconds"
        placeholder="Pick a moment"
        hour12={false}
        showSeconds
        secondStep={10}
      />
    </div>
  );
}
