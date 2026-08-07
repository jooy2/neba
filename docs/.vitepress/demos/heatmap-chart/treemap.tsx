import { Card, HeatmapChart } from 'neba';

/** Storage by team, grouped by department. */
const STORAGE = [
  {
    name: 'Platform',
    data: [
      { x: 'Builds', y: 4200 },
      { x: 'Registry', y: 2600 },
      { x: 'Logs', y: 1900 }
    ]
  },
  {
    name: 'Product',
    data: [
      { x: 'Assets', y: 3100 },
      { x: 'Uploads', y: 1400 },
      { x: 'Exports', y: 720 }
    ]
  },
  {
    name: 'Data',
    data: [
      { x: 'Warehouse', y: 5400 },
      { x: 'Snapshots', y: 2200 }
    ]
  }
];

export default function HeatmapChartTreemap() {
  return (
    <Card title="Storage by team" subtitle="Gigabytes" className="w-full">
      <HeatmapChart
        label="Storage by team"
        shape="treemap"
        series={STORAGE}
        format={{ maximumFractionDigits: 0 }}
      />
    </Card>
  );
}
