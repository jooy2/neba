import { TimePicker } from 'neba';

const NINE_THIRTY = new Date(2026, 6, 27, 9, 30);

export default function TimePickerColumns() {
  return (
    <div className="flex flex-wrap items-end gap-4">
      <TimePicker label="Every five minutes" minuteStep={5} defaultValue={NINE_THIRTY} />
      <TimePicker label="With seconds" showSeconds defaultValue={NINE_THIRTY} />
      <TimePicker label="24-hour" hour12={false} defaultValue={NINE_THIRTY} />
    </div>
  );
}
