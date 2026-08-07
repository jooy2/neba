import { Card, TimelineChart } from 'neba';

const on = (iso: string) => new Date(`${iso}T00:00:00`);

const PLAN = [
  {
    name: 'Discovery',
    data: [
      { start: on('2026-01-06'), end: on('2026-01-27'), label: 'Interviews' },
      { start: on('2026-01-27'), end: on('2026-02-10'), label: 'Synthesis' }
    ]
  },
  {
    name: 'Design',
    data: [
      { start: on('2026-02-03'), end: on('2026-03-03'), label: 'Wireframes' },
      { start: on('2026-03-03'), end: on('2026-04-07'), label: 'Visual design' }
    ]
  },
  {
    name: 'Build',
    data: [
      { start: on('2026-03-17'), end: on('2026-05-19'), label: 'API' },
      { start: on('2026-04-14'), end: on('2026-06-16'), label: 'Client' }
    ]
  },
  {
    name: 'Launch',
    data: [{ start: on('2026-06-02'), end: on('2026-06-30'), label: 'Beta', color: 'success' }]
  }
];

export default function TimelineChartHero() {
  return (
    <Card title="Release plan" subtitle="First half of 2026" className="w-full">
      <TimelineChart label="Release plan by workstream" series={PLAN} />
    </Card>
  );
}
