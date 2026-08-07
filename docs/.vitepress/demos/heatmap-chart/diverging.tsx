import { Card, HeatmapChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

/** Percentage points against target — a value whose middle means something. */
const AGAINST_TARGET = [
  { name: 'EMEA', data: [-12, -6, -2, 3, 8, 11, 6, 14] },
  { name: 'APAC', data: [4, 9, 12, 7, -3, -8, -14, -5] },
  { name: 'Americas', data: [-2, 1, 0, 2, 5, 4, 9, 12] }
];

export default function HeatmapChartDiverging() {
  return (
    <Card title="Against target" subtitle="Percentage points" className="w-full">
      <HeatmapChart
        label="Revenue against target, by region and month"
        categories={MONTHS}
        series={AGAINST_TARGET}
        scale="diverging"
        valueLabels="all"
        format={{ signDisplay: 'exceptZero', maximumFractionDigits: 0 }}
      />
    </Card>
  );
}
