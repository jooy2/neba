import { Card, TimelineChart } from 'neba';

const at = (iso: string) => new Date(iso);

/**
 * A single day, so the axis steps in hours rather than in months. `min` and
 * `max` pin it to the working day; the run that started before nine is cut at
 * the edge rather than dragging the whole axis back to midnight.
 */
const SHIFTS = [
  {
    name: 'Build',
    data: [
      { start: at('2026-03-02T07:40:00'), end: at('2026-03-02T09:20:00'), label: 'Nightly' },
      { start: at('2026-03-02T11:10:00'), end: at('2026-03-02T12:05:00'), label: 'PR #4182' },
      { start: at('2026-03-02T15:30:00'), end: at('2026-03-02T16:40:00'), label: 'PR #4190' }
    ]
  },
  {
    name: 'Deploy',
    data: [
      { start: at('2026-03-02T12:20:00'), end: at('2026-03-02T12:50:00'), label: 'staging' },
      { start: at('2026-03-02T17:00:00'), end: at('2026-03-02T17:35:00'), label: 'production' }
    ]
  },
  {
    name: 'Incident',
    data: [
      {
        start: at('2026-03-02T13:05:00'),
        end: at('2026-03-02T14:10:00'),
        label: 'Elevated 5xx',
        color: 'danger'
      }
    ]
  }
];

export default function TimelineChartRange() {
  return (
    <Card title="Pipeline" subtitle="2 March, 09:00 – 18:00" className="w-full">
      <TimelineChart
        label="Pipeline activity on 2 March"
        min={at('2026-03-02T09:00:00')}
        max={at('2026-03-02T18:00:00')}
        series={SHIFTS}
      />
    </Card>
  );
}
