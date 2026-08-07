import { Card, ScatterChart } from 'neba';

/**
 * A third number per point turns a dot into a bubble. `z` is read as an
 * **area**, so the plan with four times the revenue draws a bubble twice as
 * wide rather than four times as wide.
 */
const PLANS = [
  { x: 12, y: 4.2, z: 180, label: 'Free' },
  { x: 29, y: 6.8, z: 620, label: 'Starter' },
  { x: 48, y: 8.1, z: 1450, label: 'Team' },
  { x: 71, y: 9.4, z: 2900, label: 'Business' },
  { x: 96, y: 11.2, z: 4100, label: 'Enterprise' }
];

export default function ScatterChartBubble() {
  return (
    <Card title="Revenue by plan" subtitle="Seats against weekly sessions" className="w-full">
      <ScatterChart
        label="Revenue by plan, against seats and weekly sessions"
        xAxis={{ label: 'Seats' }}
        yAxis={{ label: 'Sessions per week' }}
        maxRadius={26}
        // Each point's `label` names its plan, so the tooltip says which bubble
        // it is rather than repeating the y already on the axis.
        series={[{ name: 'Plan', data: PLANS }]}
      />
    </Card>
  );
}
