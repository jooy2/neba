import { useState } from 'react';
import { Calendar, Typography, type CalendarRange } from 'neba';

export default function CalendarModes() {
  const [days, setDays] = useState<Date[]>([]);
  const [span, setSpan] = useState<CalendarRange>({ start: null, end: null });

  return (
    <div className="flex flex-wrap items-start gap-6">
      <div className="flex flex-col gap-2">
        <Calendar mode="multiple" value={days} onValueChange={setDays} />
        <Typography level="caption" className="text-(--neba-muted-fg)">
          {days.length === 0 ? 'No days held.' : `${days.length} days held`}
        </Typography>
      </div>

      <div className="flex flex-col gap-2">
        <Calendar mode="range" value={span} onValueChange={setSpan} />
        <Typography level="caption" className="text-(--neba-muted-fg)">
          {span.start
            ? `${span.start.toDateString()} → ${span.end?.toDateString() ?? '…'}`
            : 'No span yet.'}
        </Typography>
      </div>
    </div>
  );
}
