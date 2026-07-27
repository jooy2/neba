import { useState } from 'react';
import { DateTimePicker } from 'neba';

export default function DateTimePickerHero() {
  const [value, setValue] = useState<Date | null>(null);

  return (
    <div className="flex flex-wrap items-end gap-4">
      <DateTimePicker
        label="Publish at"
        placeholder="Pick a moment"
        value={value}
        onValueChange={setValue}
        minuteStep={15}
        clearable
      />
    </div>
  );
}
