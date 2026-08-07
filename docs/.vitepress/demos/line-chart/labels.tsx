import { Card, LineChart } from 'neba';

const QUARTERS = ['Q1', 'Q2', 'Q3', 'Q4'];

/**
 * `valueLabels="last"` names where each series ended up and leaves the rest to
 * the axis. `gradient` fades each line from a paler step of its own hue, so the
 * recent end is the loud one.
 */
export default function LineChartLabels() {
  return (
    <Card title="Revenue by region" subtitle="Thousands, this year" className="w-full">
      <LineChart
        label="Revenue by region and quarter"
        categories={QUARTERS}
        valueLabels="last"
        gradient
        markers="all"
        format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
        series={[
          { name: 'Americas', data: [312, 344, 391, 428] },
          { name: 'EMEA', data: [208, 244, 231, 297] },
          { name: 'APAC', data: [141, 172, 209, 264] }
        ]}
      />
    </Card>
  );
}
