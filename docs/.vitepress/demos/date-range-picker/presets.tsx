import { DateRangePicker, type DateRange } from 'neba';

/** Midnight today, so a range never carries the time the page happened to load. */
function today() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function daysBack(count: number): DateRange {
  const end = today();
  const start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - count + 1);
  return { start, end };
}

export default function DateRangePickerPresets() {
  return (
    <DateRangePicker
      label="Report period"
      startPlaceholder="From"
      endPlaceholder="To"
      presets={[
        // Functions, not values: a range computed at render time would be wrong
        // for anyone who left the tab open overnight.
        { label: 'Last 7 days', value: () => daysBack(7) },
        { label: 'Last 30 days', value: () => daysBack(30) },
        {
          label: 'This month',
          value: () => {
            const now = today();
            return {
              start: new Date(now.getFullYear(), now.getMonth(), 1),
              end: now
            };
          }
        }
      ]}
    />
  );
}
