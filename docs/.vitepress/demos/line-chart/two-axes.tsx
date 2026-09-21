import { Card, LineChart } from 'neba';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const REVENUE = [182_000, 196_000, 214_000, 208_000, 231_000, 246_000];
const CONVERSION = [2.4, 2.6, 2.5, 2.9, 3.1, 3.4];

export default function LineChartTwoAxes() {
  return (
    <Card title="Revenue and conversion" subtitle="Two units, one plot" className="w-full">
      <LineChart
        label="Revenue and conversion rate by month"
        categories={MONTHS}
        markers="all"
        yAxis={{ label: 'Revenue' }}
        format={{ style: 'currency', currency: 'USD', maximumFractionDigits: 0 }}
        secondaryAxis={{ label: 'Conversion', tickFormat: (value) => `${value}%` }}
        series={[
          { name: 'Revenue', data: REVENUE },
          { name: 'Conversion', data: CONVERSION, axis: 'secondary' }
        ]}
      />
    </Card>
  );
}
