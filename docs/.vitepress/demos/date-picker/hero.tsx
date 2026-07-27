import { useState } from 'react';
import { DatePicker } from 'neba';

export default function DatePickerHero() {
  const [value, setValue] = useState<Date | null>(new Date());

  return (
    <div className="flex flex-wrap items-end gap-4">
      <DatePicker
        label="Ships on"
        placeholder="Pick a day"
        value={value}
        onValueChange={setValue}
        clearable
      />
      <DatePicker label="Delivered" placeholder="Not yet" />
    </div>
  );
}
