import { useState } from 'react';
import { Calendar, Typography } from 'neba';

export default function CalendarHero() {
  const [value, setValue] = useState<Date | null>(new Date());

  return (
    <div className="flex flex-wrap items-start gap-6">
      <Calendar value={value} onValueChange={setValue} />

      <Typography level="caption" className="text-(--neba-muted-fg)">
        {value ? value.toDateString() : 'Nothing chosen.'}
      </Typography>
    </div>
  );
}
