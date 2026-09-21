import { Card, LineChart } from 'neba';

const DAYS = 365;
const START = new Date(Date.UTC(2025, 0, 1));

// A year of daily readings — more points than a plot this wide has pixels.
const DATES = Array.from(
  { length: DAYS },
  (_, index) => new Date(START.getTime() + index * 86_400_000)
);
const READINGS = Array.from({ length: DAYS }, (_, index) =>
  Math.round(
    1200 +
      index * 1.8 +
      Math.sin(index / 9) * 140 +
      Math.sin(index / 2.3) * 60 +
      Math.cos(index / 31) * 220
  )
);

export default function LineChartBrush() {
  return (
    <Card title="Daily signups" subtitle="Drag the strip to choose a window" className="w-full">
      <LineChart
        label="Signups by day"
        height={280}
        categories={DATES}
        series={[{ name: 'Signups', data: READINGS }]}
        brush={{ defaultRange: [240, 320] }}
      />
    </Card>
  );
}
