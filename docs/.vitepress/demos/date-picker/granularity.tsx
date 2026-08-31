import { useState } from 'react';
import { DatePicker, Typography } from 'neba';

export default function DatePickerGranularity() {
  const [period, setPeriod] = useState<Date | null>(null);

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-end gap-4">
        <DatePicker label="Invoice date" placeholder="Pick a day" clearable />
        <DatePicker
          label="Billing period"
          placeholder="Pick a month"
          granularity="month"
          value={period}
          onValueChange={setPeriod}
          clearable
        />
        <DatePicker label="Tax year" placeholder="Pick a year" granularity="year" clearable />
      </div>

      <Typography level="caption" className="text-(--neba-muted-fg)">
        {period ? `Billing period starts ${period.toDateString()}` : 'No billing period yet.'}
      </Typography>
    </div>
  );
}
