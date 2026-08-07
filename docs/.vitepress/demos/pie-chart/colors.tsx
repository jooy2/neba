import { Card, PieChart } from 'neba';

/**
 * A slice takes the palette slot its position gives it, and a point's own
 * `color` overrides that. Here the four states mean something — a colour that
 * says "failed" is doing a different job from one that says "series four" — so
 * every slice names its own.
 */
export default function PieChartColors() {
  return (
    <Card title="Pipeline runs" subtitle="Last 24 hours" className="w-full">
      <PieChart
        label="Pipeline runs by outcome"
        shape="donut"
        legend={{ side: 'right', align: 'center' }}
        data={[
          { x: 'Passed', y: 1284, color: 'success' },
          { x: 'Failed', y: 96, color: 'danger' },
          { x: 'Cancelled', y: 41, color: 'secondary' },
          { x: 'Flaky', y: 28, color: 'warning' }
        ]}
      />
    </Card>
  );
}
