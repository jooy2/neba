import { Card, ScatterChart } from 'neba';

/** Session length against pages read, one point per visit. */
const ORGANIC = [
  { x: 22, y: 2 },
  { x: 41, y: 3 },
  { x: 55, y: 4 },
  { x: 68, y: 4 },
  { x: 74, y: 6 },
  { x: 90, y: 5 },
  { x: 112, y: 8 },
  { x: 128, y: 7 },
  { x: 141, y: 10 },
  { x: 166, y: 9 },
  { x: 184, y: 12 },
  { x: 203, y: 11 }
];

const PAID = [
  { x: 18, y: 1 },
  { x: 30, y: 2 },
  { x: 44, y: 2 },
  { x: 61, y: 3 },
  { x: 79, y: 2 },
  { x: 96, y: 4 },
  { x: 118, y: 3 },
  { x: 137, y: 5 },
  { x: 152, y: 4 },
  { x: 178, y: 6 }
];

export default function ScatterChartHero() {
  return (
    <Card
      title="Pages per visit"
      subtitle="Against session length, last 30 days"
      className="w-full"
    >
      <ScatterChart
        label="Pages read against session length, by channel"
        xAxis={{ label: 'Seconds on site' }}
        yAxis={{ label: 'Pages' }}
        series={[
          { name: 'Organic', data: ORGANIC },
          { name: 'Paid', data: PAID }
        ]}
      />
    </Card>
  );
}
