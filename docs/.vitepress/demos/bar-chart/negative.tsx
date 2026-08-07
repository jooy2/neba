import { BarChart, Card } from 'neba';

/**
 * A bar that goes the other way grows down from the same zero the others grow
 * up from — the baseline is drawn where zero is, not at the bottom of the plot.
 *
 * A point may override its series' colour, which is what marks the two months
 * that lost ground without spending a second series on them.
 */
export default function BarChartNegative() {
  return (
    <Card title="Net seat change" subtitle="Added minus removed" className="w-full">
      <BarChart
        label="Net seat change by month"
        categories={['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']}
        valueLabels="all"
        series={[
          {
            name: 'Net seats',
            data: [124, 88, { y: -46, color: 'danger' }, 72, 140, { y: -18, color: 'danger' }, 206]
          }
        ]}
      />
    </Card>
  );
}
