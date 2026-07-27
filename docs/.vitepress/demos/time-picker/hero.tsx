import { useState } from 'react';
import { TimePicker } from 'neba';

export default function TimePickerHero() {
  const [value, setValue] = useState<Date | null>(null);

  return (
    <div className="flex flex-wrap items-end gap-4">
      <TimePicker
        label="Starts at"
        placeholder="Pick a time"
        value={value}
        onValueChange={setValue}
        minuteStep={15}
        clearable
      />
      <TimePicker label="Ends at" placeholder="Pick a time" minuteStep={15} />
    </div>
  );
}
