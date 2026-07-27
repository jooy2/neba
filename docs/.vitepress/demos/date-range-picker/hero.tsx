import { useState } from 'react';
import { DateRangePicker, type DateRange } from 'neba';

export default function DateRangePickerHero() {
  const [value, setValue] = useState<DateRange>({ start: null, end: null });

  return (
    <div className="flex flex-wrap items-end gap-4">
      <DateRangePicker
        label="Stay"
        startPlaceholder="Check in"
        endPlaceholder="Check out"
        value={value}
        onValueChange={setValue}
        clearable
      />
    </div>
  );
}
